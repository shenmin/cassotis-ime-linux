// Optional bounded literary recovery, after the ordinary long-sentence pipeline.
// Dictionary callbacks are read-only and run on the host's engine thread.
namespace {
using StyleEntry = int (*)(void*, const char16_t*, const char16_t*, int*, int*);
using StyleLm = int (*)(void*, const char16_t*, int, int*, int*);
using StylePath = std::vector<std::u16string>;

std::u16string StyleJoin(const StylePath& values, const char16_t separator = 0) {
    std::u16string result;
    for (const auto& value : values) {
        if (!result.empty() && separator) result += separator;
        result += value;
    }
    return result;
}
StylePath StyleSplit(const std::u16string& text, char16_t separator) {
    StylePath result;
    size_t start = 0;
    for (size_t i = 0; i <= text.size(); ++i) if (i == text.size() || text[i] == separator) {
        if (i > start) result.push_back(text.substr(start, i-start));
        start = i+1;
    }
    return result;
}
StylePath StyleSlice(const StylePath& a, int start, int end) { return {a.begin()+start, a.begin()+end}; }
std::set<int> StyleBoundaries(const StylePath& path) {
    std::set<int> result{0};
    int position = 0;
    for (const auto& word : path) { position += int(word.size()); result.insert(position); }
    return result;
}
// About 100k phrases stay resident; interned readings and a shared source pool
// avoid per-phrase heap nodes without changing lookup or ranking semantics.
struct StylePhrase {
    std::u16string text;
    std::array<uint16_t,5> py{};
    uint32_t source_offset{};
    uint16_t source_count{};
};
struct StyleRows {
    const uint32_t* first{};
    const uint32_t* last{};
    const uint32_t* begin() const { return first; }
    const uint32_t* end() const { return last; }
    bool empty() const { return first==last; }
};
struct StyleSupport {
    double score{};
    std::vector<std::tuple<int,int,size_t>> matches;
};
struct StylePatch {
    int start{}, end{}, witness_start{}, witness_end{};
    std::u16string text, witness;
    size_t sources{};
};
struct StyleProposal {
    std::u16string text;
    StylePath py, path;
    double gain{};
    int seed{}, changed{}, patches{};
};
struct StylePhraseRuntime {
    Ort::Session head;
    std::vector<StylePhrase> phrases;
    std::vector<int> sources;
    std::vector<std::u16string> syllables;
    std::unordered_map<std::u16string,uint16_t> syllable_ids;
    std::vector<uint32_t> by_text, by_py;
    std::vector<std::pair<uint32_t,uint32_t>> py_groups;
    std::unordered_map<std::u16string,int64_t> vocab, py_vocab;
    std::map<char16_t,StylePath> readings;
    float threshold{}, margin{};
    StylePhraseRuntime(const char16_t* graph, const char16_t* index)
        : head(LocalRepairJoint::make_session(Utf16ToUtf8(graph).c_str())) {
        std::ifstream stream(Utf16ToUtf8(index), std::ios::binary);
        char magic[8]{};
        if (!stream.read(magic, 8) || std::memcmp(magic,"CASSTY01",8))
            throw std::runtime_error("invalid style phrase index");
        auto number = [&]() { uint32_t n{}; if (!ReadBinary(stream,n)) throw std::runtime_error("truncated style index"); return n; };
        auto text = [&]() {
            const auto n = number();
            if (!n || n > 1024) throw std::runtime_error("invalid style string");
            std::u16string value(n,0);
            if (!stream.read(reinterpret_cast<char*>(value.data()),n*2)) throw std::runtime_error("truncated style text");
            return value;
        };
        if (!ReadBinary(stream,threshold) || !ReadBinary(stream,margin) ||
            !std::isfinite(threshold) || threshold < .9f || threshold > 1 ||
            !std::isfinite(margin) || margin < 0) throw std::runtime_error("invalid style policy");
        for (auto* table : {&vocab,&py_vocab}) {
            auto count = number();
            if (count < 5 || count > 16384) throw std::runtime_error("invalid style vocabulary");
            for (uint32_t i=0;i<count;++i) {
                auto value=text(); auto id=number();
                if (id>=count || !table->emplace(value,id).second) throw std::runtime_error("invalid style ID");
            }
        }
        auto count=number();
        if (count>65536) throw std::runtime_error("oversized style readings");
        for (uint32_t i=0;i<count;++i) {
            auto value=text(); auto n=number();
            if (value.size()!=1 || n>64) throw std::runtime_error("invalid character reading");
            auto& target=readings[value[0]];
            for (uint32_t j=0;j<n;++j) {
                target.push_back(text());
                if (target.back().find(u' ')!=std::u16string::npos) throw std::runtime_error("invalid character reading");
            }
            std::sort(target.begin(),target.end());
        }
        count=number();
        if (count>200000) throw std::runtime_error("oversized style evidence");
        phrases.reserve(count);
        std::vector<int> row;
        for (uint32_t i=0;i<count;++i) {
            StylePhrase p; p.text=text(); auto py=StyleSplit(text(),u' ');
            auto n=number();
            if (p.text.size()<3 || p.text.size()>5 || py.size()!=p.text.size() || n<1 || n>4096)
                throw std::runtime_error("invalid local phrase evidence");
            row.clear();
            for (uint32_t j=0;j<n;++j) row.push_back(int(number()));
            std::sort(row.begin(),row.end()); row.erase(std::unique(row.begin(),row.end()),row.end());
            p.source_offset=uint32_t(sources.size()); p.source_count=uint16_t(row.size());
            sources.insert(sources.end(),row.begin(),row.end());
            for (size_t j=0;j<py.size();++j) p.py[j]=intern(py[j]);
            phrases.push_back(std::move(p));
        }
        if (stream.peek()!=std::char_traits<char>::eof() || head.GetInputCount()!=5 || head.GetOutputCount()!=3)
            throw std::runtime_error("invalid style graph/index ABI");
        by_text.resize(phrases.size());
        for (uint32_t i=0;i<by_text.size();++i) by_text[i]=i;
        std::stable_sort(by_text.begin(),by_text.end(),[&](uint32_t a,uint32_t b) { return phrases[a].text<phrases[b].text; });
        // Reading groups keep the former per-key rank order and eight-row limit.
        std::vector<uint32_t> ranked(by_text);
        std::stable_sort(ranked.begin(),ranked.end(),[&](uint32_t a,uint32_t b) {
            const auto& x=phrases[a]; const auto& y=phrases[b];
            if(int order=compare_py(x,y)) return order<0;
            if(x.source_count!=y.source_count) return x.source_count>y.source_count;
            return x.text<y.text;
        });
        for (size_t i=0;i<ranked.size();) {
            size_t j=i+1;
            while (j<ranked.size() && !compare_py(phrases[ranked[i]],phrases[ranked[j]])) ++j;
            const auto first=uint32_t(by_py.size());
            by_py.insert(by_py.end(),ranked.begin()+i,ranked.begin()+std::min(j,i+8));
            py_groups.emplace_back(first,uint32_t(by_py.size()));
            i=j;
        }
        by_py.shrink_to_fit(); sources.shrink_to_fit();
    }
    uint16_t intern(const std::u16string& value) {
        auto found=syllable_ids.find(value); if(found!=syllable_ids.end()) return found->second;
        if(syllables.size()>=65535) throw std::runtime_error("oversized style readings");
        syllable_ids.emplace(value,uint16_t(syllables.size())); syllables.push_back(value);
        return uint16_t(syllables.size()-1);
    }
    static int compare_py(const StylePhrase& a,const StylePhrase& b) {
        if(a.text.size()!=b.text.size()) return a.text.size()<b.text.size()?-1:1;
        for(size_t i=0;i<a.text.size();++i) if(a.py[i]!=b.py[i]) return a.py[i]<b.py[i]?-1:1;
        return 0;
    }
    bool same_py(const StylePhrase& p,const StylePath& py,int start,int end) const {
        if(int(p.text.size())!=end-start) return false;
        for(int i=start;i<end;++i) if(syllables[p.py[i-start]]!=py[i]) return false;
        return true;
    }
    StyleRows find_text(const std::u16string& text) const {
        auto lo=std::lower_bound(by_text.begin(),by_text.end(),text,[&](uint32_t id,const std::u16string& t) { return phrases[id].text<t; });
        auto hi=std::upper_bound(lo,by_text.end(),text,[&](const std::u16string& t,uint32_t id) { return t<phrases[id].text; });
        return {by_text.data()+(lo-by_text.begin()),by_text.data()+(hi-by_text.begin())};
    }
    StyleRows find_py(const StylePath& py,int start,int end) const {
        StylePhrase key; if(end-start<1 || end-start>5) return {};
        key.text.assign(size_t(end-start),u' ');
        for(int i=start;i<end;++i) {
            auto found=syllable_ids.find(py[i]); if(found==syllable_ids.end()) return {};
            key.py[i-start]=found->second;
        }
        auto group=std::lower_bound(py_groups.begin(),py_groups.end(),key,[&](const std::pair<uint32_t,uint32_t>& g,const StylePhrase& k) {
            return compare_py(phrases[by_py[g.first]],k)<0;
        });
        if(group==py_groups.end() || compare_py(phrases[by_py[group->first]],key)) return {};
        return {by_py.data()+group->first,by_py.data()+group->second};
    }
    StylePath align(const std::u16string& text,const std::u16string& query) const {
        std::u16string raw; std::set<int> boundaries;
        for(char16_t c:query) {
            if(c==u'\'') boundaries.insert(int(raw.size()));
            else if(c>=u'a' && c<=u'z') raw+=c;
            else return {};
        }
        if(raw.size()<12 || raw.size()>160 || text.size()<6 || text.size()>32) return {};
        std::map<int,StylePath> states{{0,{}}};
        for(char16_t c:text) {
            auto r=readings.find(c); if(r==readings.end()) return {};
            std::map<int,StylePath> next;
            for(const auto& state:states) for(const auto& py:r->second) {
                int end=state.first+int(py.size());
                auto boundary=boundaries.upper_bound(state.first);
                if(raw.substr(state.first,py.size())!=py || (boundary!=boundaries.end() && *boundary<end)) continue;
                auto value=state.second; value.push_back(py); next.emplace(end,std::move(value));
            }
            states=std::move(next);
        }
        auto found=states.find(int(raw.size())); return found==states.end()?StylePath{}:found->second;
    }
    StyleSupport support(const std::u16string& text,const StylePath& py,const StylePath& path) const {
        StyleSupport result; auto bounds=StyleBoundaries(path);
        std::vector<double> weights(text.size());
        for(int start:bounds) for(int width=3;width<=5;++width) {
            int end=start+width; if(!bounds.count(end)) continue;
            for(auto idx:find_text(text.substr(start,width))) {
                const auto& p=phrases[idx]; if(!same_py(p,py,start,end)) continue;
                const double strength=1+std::min(2.,std::log2(double(p.source_count)));
                for(int i=start;i<end;++i) weights[i]=std::max(weights[i],strength);
                result.matches.emplace_back(start,end,idx);
            }
        }
        for(double w:weights) result.score+=w;
        return result;
    }
};

struct StyleRequest {
    StylePhraseRuntime& model;
    LocalRepairHandle& owner;
    void* user;
    StyleEntry lookup;
    StyleLm lm_lookup;
    uint64_t started=MonotonicMilliseconds();
    uint32_t timeout;
    struct Entry { bool found{}; int weight{},rank{}; };
    std::map<std::u16string,Entry> entries;
    std::map<std::u16string,std::pair<int,int>> grams;
    std::map<std::vector<int64_t>,LocalRepairEncoding> encoded;
    int encodings{};
    void check_time() const { if(timeout && MonotonicMilliseconds()-started>timeout) throw std::runtime_error("style emergency timeout"); }
    Entry entry(const std::u16string& text,const StylePath& py) {
        auto pinyin=StyleJoin(py); auto key=pinyin+u'\3'+text;
        auto cached=entries.find(key); if(cached!=entries.end()) return cached->second;
        if(entries.size()>=4096) throw std::runtime_error("style exact work budget exceeded");
        Entry result;
        int status=lookup(user,pinyin.c_str(),text.c_str(),&result.weight,&result.rank);
        if(status<0) throw std::runtime_error("style preserves user words or unavailable dictionary");
        result.found=status==1; entries.emplace(key,result); return result;
    }
    bool exact(const std::u16string& text,const StylePath& py) {
        if(text.size()!=py.size() || text.empty()) return false;
        for(size_t i=0;i<text.size();++i) {
            auto r=model.readings.find(text[i]);
            if(r==model.readings.end() || !std::binary_search(r->second.begin(),r->second.end(),py[i])) return false;
        }
        auto found=entry(text,py);
        return found.found && (text.size()>1 || (found.rank>=0 && found.rank<32));
    }
    bool valid(const std::u16string& text,const StylePath& py,const StylePath& path) {
        if(path.empty() || StyleJoin(path)!=text) return false;
        int pos=0;
        for(const auto& w:path) { if(!exact(w,StyleSlice(py,pos,pos+int(w.size())))) return false; pos+=int(w.size()); }
        return true;
    }
    StylePath path(const std::u16string& text,const StylePath& py) {
        int n=int(text.size()); if(py.size()!=text.size()) return {};
        std::map<int,StylePath> paths{{n,{}}};
        for(int i=n-1;i>=0;--i) for(int width=std::min(6,n-i);width>0;--width) {
            auto following=paths.find(i+width); if(following==paths.end()) continue;
            auto word=text.substr(i,width); if(!exact(word,StyleSlice(py,i,i+width))) continue;
            StylePath p{word}; p.insert(p.end(),following->second.begin(),following->second.end()); paths.emplace(i,std::move(p)); break;
        }
        auto found=paths.find(0); return found==paths.end()?StylePath{}:found->second;
    }
    std::vector<StylePatch> patches(const std::u16string& text,const StylePath& py,const StylePath& words) {
        auto bounds=StyleBoundaries(words); std::vector<StylePatch> out;
        for(int start=0;start<int(text.size());++start) for(int width=3;width<=5;++width) {
            int end=start+width; if(end>int(text.size())) continue;
            for(auto idx:model.find_py(py,start,end)) {
                const auto& row=model.phrases[idx];
                int lo=end,hi=start;
                for(int i=0;i<width;++i) if(text[start+i]!=row.text[i]) {lo=std::min(lo,start+i);hi=start+i+1;}
                if(lo>=hi || (width<4 && row.source_count<2)) continue;
                int left=*std::prev(bounds.upper_bound(lo)),right=*bounds.lower_bound(hi);
                if(left<start || right>end) continue;
                auto replacement=row.text.substr(left-start,right-left);
                if(path(replacement,StyleSlice(py,left,right)).empty()) continue;
                StylePatch patch{left,right,start,end,replacement,row.text,row.source_count};
                auto old=std::find_if(out.begin(),out.end(),[&](const StylePatch& p){return p.start==left && p.end==right && p.text==replacement;});
                if(old==out.end()) out.push_back(std::move(patch));
                else if(std::make_pair(width,patch.sources)>std::make_pair(old->witness_end-old->witness_start,old->sources)) *old=std::move(patch);
            }
        }
        std::stable_sort(out.begin(),out.end(),[](const StylePatch& a,const StylePatch& b) {
            return std::make_tuple(-int(a.sources),a.witness_start-a.witness_end,a.start,a.text)<
                   std::make_tuple(-int(b.sources),b.witness_start-b.witness_end,b.start,b.text);
        });
        if(out.size()>24) out.resize(24);
        return out;
    }
    bool apply(const std::u16string& seed,const StylePath& py,const StylePath& original,
        const std::vector<StylePatch>& patches,StyleProposal& result) {
        std::u16string text=seed; std::map<int,char16_t> changed;
        std::vector<std::pair<int,int>> ranges;
        for(const auto& p:patches) {
            for(int i=p.start;i<p.end;++i) {
                auto old=changed.find(i); char16_t c=p.text[i-p.start];
                if(old!=changed.end() && old->second!=c) return false;
                changed[i]=c; text[i]=c;
            }
            ranges.emplace_back(p.start,p.end);
        }
        int edits=0; for(size_t i=0;i<text.size();++i) edits+=text[i]!=seed[i];
        if(edits>6) return false;
        for(const auto& p:patches) if(text.substr(p.witness_start,p.witness_end-p.witness_start)!=p.witness) return false;
        std::sort(ranges.begin(),ranges.end()); std::vector<std::pair<int,int>> intervals;
        for(auto r:ranges) {
            if(!intervals.empty() && r.first<=intervals.back().second) intervals.back().second=std::max(r.second,intervals.back().second);
            else intervals.push_back(r);
        }
        std::map<int,std::u16string> old; int pos=0;
        for(const auto& word:original) {old[pos]=word;pos+=int(word.size());}
        StylePath words; pos=0;
        auto copy_word=[&](){auto found=old.find(pos);if(found==old.end()) throw std::runtime_error("invalid patch boundary");words.push_back(found->second);pos+=int(found->second.size());};
        for(auto r:intervals) {
            while(pos<r.first) copy_word();
            auto local=path(text.substr(r.first,r.second-r.first),StyleSlice(py,r.first,r.second));
            if(local.empty()) return false;
            words.insert(words.end(),local.begin(),local.end()); pos=r.second;
        }
        while(pos<int(text.size())) copy_word();
        if(!valid(text,py,words)) return false;
        auto support=model.support(text,py,words);
        for(size_t i=0;i<text.size();++i) if(text[i]!=seed[i]) {
            bool found=false;
            for(auto m:support.matches) if(std::get<0>(m)<=int(i) && int(i)<std::get<1>(m)) {found=true;break;}
            if(!found) return false;
        }
        result.text=text;result.py=py;result.path=words;result.gain=support.score;
        result.changed=edits;result.patches=int(patches.size());return true;
    }
    std::vector<StyleProposal> recover(const std::u16string& query,const StylePath& seeds,const StylePath& paths) {
        std::map<std::u16string,StyleProposal> out;
        for(int rank=0;rank<int(seeds.size());++rank) {
            check_time(); const auto& seed=seeds[rank]; auto py=model.align(seed,query); if(py.empty()) continue;
            // Cheap index preflight: do not touch SQLite when no local evidence exists.
            bool trigger=false;
            for(int start=0;start<int(py.size()) && !trigger;++start) for(int width=3;width<=5 && start+width<=int(py.size());++width)
                if(!model.find_py(py,start,start+width).empty()) {trigger=true;break;}
            if(!trigger) continue;
            auto words=StyleSplit(paths[rank],u'\3'); if(words.empty()) words=path(seed,py);
            if(!valid(seed,py,words)) continue;
            auto base=model.support(seed,py,words); auto edits=patches(seed,py,words);
            auto propose=[&](const std::vector<StylePatch>& plan) {
                StyleProposal p;if(!apply(seed,py,words,plan,p)) return;
                p.gain-=base.score;p.seed=rank;if(p.gain<=0) return;
                auto old=out.find(p.text);
                if(old==out.end() || std::make_tuple(p.gain,-p.seed,-p.patches)>
                    std::make_tuple(old->second.gain,-old->second.seed,-old->second.patches)) out[p.text]=std::move(p);
            };
            for(const auto& p:edits) propose({p});
            for(size_t a=0;a<edits.size();++a) for(size_t b=a+1;b<edits.size();++b) propose({edits[a],edits[b]});
        }
        std::vector<StyleProposal> result;for(auto& item:out) result.push_back(std::move(item.second));
        std::sort(result.begin(),result.end(),[](const StyleProposal& a,const StyleProposal& b) {
            return std::make_tuple(-a.gain,a.seed,a.changed,a.text)<std::make_tuple(-b.gain,b.seed,b.changed,b.text);
        });
        if(result.size()>8) result.resize(8);
        return result;
    }
    void load_lm(const StylePath& texts) {
        std::set<std::u16string> wanted;
        for(const auto& text:texts) for(int end=1;end<=int(text.size());++end) for(int start=std::max(0,end-4);start<end;++start) wanted.insert(text.substr(start,end-start));
        StylePath values(wanted.begin(),wanted.end());
        std::vector<int> scores(values.size()),backoffs(values.size()); auto packed=StyleJoin(values,u'\3');
        if(values.size()>4096 || lm_lookup(user,packed.c_str(),int(values.size()),scores.data(),backoffs.data())!=1)
            throw std::runtime_error("style LM unavailable");
        for(size_t i=0;i<values.size();++i) if(scores[i]!=INT_MIN) grams[values[i]]={scores[i],backoffs[i]};
    }
    double lm_score(const std::u16string& text) const {
        double total=0;
        for(int end=1;end<=int(text.size());++end) for(int width=std::min(4,end);width>=1;--width) {
            auto gram=grams.find(text.substr(end-width,width));
            if(gram!=grams.end()) {total+=gram->second.first;break;}
            if(width==1) total-=30000;
            else {auto prefix=grams.find(text.substr(end-width,width-1));if(prefix!=grams.end()) total+=prefix->second.second;}
        }
        return total/std::max(size_t(1),text.size());
    }
    std::array<float,8> numeric(const std::u16string& text,const StylePath& py,const StylePath& words,
        const std::vector<int>& changed) {
        int lo=std::max(0,changed.front()-3),hi=std::min(int(text.size()),changed.back()+4),pos=0,multi=0;
        std::vector<double> weights;
        for(const auto& word:words) {
            int end=pos+int(word.size());
            if(end>lo && pos<hi) {
                weights.push_back(std::log1p(std::max(0,entry(word,StyleSlice(py,pos,end)).weight)));
                if(word.size()>1) multi+=int(word.size());
            }
            pos=end;
        }
        auto support=model.support(text,py,words);std::set<int> sources,covered;
        for(auto m:support.matches) if(std::get<1>(m)>lo && std::get<0>(m)<hi) {
            const auto& p=model.phrases[std::get<2>(m)];
            sources.insert(model.sources.begin()+p.source_offset,model.sources.begin()+p.source_offset+p.source_count);
            for(int i=std::max(lo,std::get<0>(m));i<std::min(hi,std::get<1>(m));++i) covered.insert(i);
        }
        double sum=0;for(auto w:weights) sum+=w;
        return {float(std::log1p(sources.size())),float(covered.size())/std::max(1,hi-lo),
            float(weights.empty()?0:*std::min_element(weights.begin(),weights.end())),float(sum/std::max(size_t(1),weights.size())),
            float(lm_score(text.substr(lo,hi-lo))/1000),float(multi)/text.size(),float(weights.size())/text.size(),float(changed.size())/text.size()};
    }
    bool ids(const std::u16string& text,const StylePath& py,std::vector<int64_t>& chars,std::vector<int64_t>& pinyin) {
        for(size_t i=0;i<text.size();++i) {
            auto a=model.vocab.find(text.substr(i,1)),b=model.py_vocab.find(py[i]);
            if(a==model.vocab.end() || b==model.py_vocab.end() || a->second<4 || b->second<4) return false;
            chars.push_back(a->second);pinyin.push_back(b->second);
        }
        return true;
    }
    const LocalRepairEncoding& encode(const std::vector<int64_t>& text,const std::vector<int64_t>& py) {
        check_time();auto cached=encoded.find(text);if(cached!=encoded.end()) return cached->second;
        auto [where,inserted]=encoded.emplace(text,LocalRepairEncoding{});auto& item=where->second;
        const int n=int(text.size());
        if(owner.joint) if(const auto* value=owner.joint->find(text.data(),py.data(),n)) {item=*value;return item;}
        if(++encodings>17) throw std::runtime_error("style encoding budget exceeded");
        auto cpu=Ort::MemoryInfo::CreateCpu(OrtArenaAllocator,OrtMemTypeDefault);int64_t shape[]{1,n};
        std::vector<Ort::Value> inputs;
        inputs.emplace_back(Ort::Value::CreateTensor<int64_t>(cpu,const_cast<int64_t*>(text.data()),n,shape,2));
        inputs.emplace_back(Ort::Value::CreateTensor<int64_t>(cpu,const_cast<int64_t*>(py.data()),n,shape,2));
        for(auto& memory:owner.memory) {
            auto info=memory.GetTensorTypeAndShapeInfo();auto dimensions=info.GetShape();
            inputs.emplace_back(Ort::Value::CreateTensor(cpu,memory.GetTensorMutableRawData(),
                info.GetElementCount()*(info.GetElementType()==ONNX_TENSOR_ELEMENT_DATA_TYPE_BOOL?1:4),dimensions.data(),dimensions.size(),info.GetElementType()));
        }
        const char* names[]{"draft_ids","pinyin_ids","keys","values","context_mask"};
        const char* outputs[]{"joint_hidden","joint_scores","joint_reading_ids"};
        auto result=owner.query_session->Run(Ort::RunOptions{nullptr},names,inputs.data(),inputs.size(),outputs,3);
        const size_t sizes[]{size_t(n*768),size_t(n*99),size_t(n*99)};
        for(int i=0;i<3;++i) if(result[i].GetTensorTypeAndShapeInfo().GetElementCount()!=sizes[i]) throw std::runtime_error("style encoder shape mismatch");
        const auto* hidden=result[0].GetTensorData<float>();
        for(int i=0;i<n*768;++i) item.hidden[i]=Ort::Float16_t(hidden[i]).ToFloat();
        std::copy_n(result[1].GetTensorData<float>(),n*99,item.logits.begin());
        std::copy_n(result[2].GetTensorData<int64_t>(),n*99,item.readings.begin());
        item.count=n;return item;
    }
    std::vector<float> probabilities(const LocalRepairEncoding& encoded,const std::vector<int64_t>& target) const {
        std::vector<float> out(target.size());
        for(int i=0;i<int(target.size());++i) {
            const auto* logits=encoded.logits.data()+i*99;const auto* ids=encoded.readings.data()+i*99;
            float peak=*std::max_element(logits,logits+99),sum=0;int index=-1;
            for(int j=0;j<99;++j) {
                sum+=std::exp(logits[j]-peak);
                if(ids[j]==target[i]) {if(index!=-1) throw std::runtime_error("nonunique style reading"); index=j;}
            }
            if(index<0) throw std::runtime_error("unavailable style reading");
            out[i]=logits[index]-peak-std::log(sum);
        }
        return out;
    }
    int choose(const std::u16string& baseline,const StylePath& py,const StylePath& baseline_path,
        const std::vector<StyleProposal>& proposals,float* scores,float* confidence) {
        std::vector<int64_t> a,pinyin;if(!ids(baseline,py,a,pinyin)) return -1;
        std::vector<float> states(8*2*32*768),evidence(8*2*32*10),numbers(8*2*8);
        std::array<bool,8*32> present{};std::array<bool,8> valid{};
        for(int i=0;i<8;++i) present[i*32]=true;
        StylePath texts{baseline};for(const auto& p:proposals) texts.push_back(p.text);load_lm(texts);
        int compatible=0;
        for(int slot=0;slot<int(proposals.size());++slot) {
            const auto& p=proposals[slot];if(p.text==baseline || p.py!=py || p.text.size()!=baseline.size()) continue;
            std::vector<int> changed;for(int i=0;i<int(a.size());++i) if(baseline[i]!=p.text[i]) changed.push_back(i);
            if(changed.empty() || changed.size()>6) continue;
            std::vector<int64_t> b,other_py;if(!ids(p.text,py,b,other_py)) continue;
            auto masked=a;for(int i:changed) masked[i]=1;
            const auto& ea=encode(a,pinyin);const auto& eb=encode(b,pinyin);const auto& em=encode(masked,pinyin);
            std::vector<float> aa,ab,ba,bb,ma,mb;
            try {aa=probabilities(ea,a);ab=probabilities(ea,b);ba=probabilities(eb,a);bb=probabilities(eb,b);ma=probabilities(em,a);mb=probabilities(em,b);}
            catch(const std::runtime_error&) {continue;}
            auto aends=StyleBoundaries(baseline_path),bends=StyleBoundaries(p.path);
            auto an=numeric(baseline,py,baseline_path,changed),bn=numeric(p.text,py,p.path,changed);
            std::copy(an.begin(),an.end(),numbers.begin()+slot*16);std::copy(bn.begin(),bn.end(),numbers.begin()+slot*16+8);
            std::copy_n(ea.hidden.begin(),a.size()*768,states.begin()+slot*2*32*768);
            std::copy_n(eb.hidden.begin(),a.size()*768,states.begin()+(slot*2+1)*32*768);
            for(int i=0;i<int(a.size());++i) {
                bool diff=a[i]!=b[i],window=false;
                for(int position:changed) if(std::abs(position-i)<=3) {window=true;break;}
                present[slot*32+i]=window;
                const float av[]{aa[i],ab[i],ba[i],bb[i],ma[i],mb[i],float(aends.count(i+1)),float(bends.count(i+1)),float(diff),float(window)};
                const float bv[]{bb[i],ba[i],ab[i],aa[i],mb[i],ma[i],float(bends.count(i+1)),float(aends.count(i+1)),float(diff),float(window)};
                std::copy_n(av,10,evidence.begin()+(slot*2*32+i)*10);
                std::copy_n(bv,10,evidence.begin()+((slot*2+1)*32+i)*10);
            }
            valid[slot]=true;++compatible;
        }
        if(!compatible) return -1;
        check_time();
        auto cpu=Ort::MemoryInfo::CreateCpu(OrtArenaAllocator,OrtMemTypeDefault);
        int64_t ss[]{1,8,2,32,768},es[]{1,8,2,32,10},ns[]{1,8,2,8},ps[]{1,8,32},vs[]{1,8};
        std::vector<Ort::Value> inputs;
        inputs.emplace_back(Ort::Value::CreateTensor<float>(cpu,states.data(),states.size(),ss,5));
        inputs.emplace_back(Ort::Value::CreateTensor<float>(cpu,evidence.data(),evidence.size(),es,5));
        inputs.emplace_back(Ort::Value::CreateTensor<float>(cpu,numbers.data(),numbers.size(),ns,4));
        inputs.emplace_back(Ort::Value::CreateTensor<bool>(cpu,present.data(),present.size(),ps,3));
        inputs.emplace_back(Ort::Value::CreateTensor<bool>(cpu,valid.data(),valid.size(),vs,2));
        const char* names[]{"states","evidence","numeric","present","valid"};const char* outputs[]{"scores","grades","accept"};
        auto results=model.head.Run(Ort::RunOptions{nullptr},names,inputs.data(),inputs.size(),outputs,3);
        if(results[0].GetTensorTypeAndShapeInfo().GetElementCount()!=9 || results[1].GetTensorTypeAndShapeInfo().GetElementCount()!=36 || results[2].GetTensorTypeAndShapeInfo().GetElementCount()!=1) return -1;
        const auto* raw=results[0].GetTensorData<float>();int best=0;
        for(int i=0;i<9;++i) {if(!std::isfinite(raw[i])) return -1;scores[i]=raw[i];if(raw[i]>raw[best]) best=i;}
        if(!best || !valid[best-1]) return -1;
        float alternative=-10000;for(int i=0;i<9;++i) if(i!=best) alternative=std::max(alternative,raw[i]);
        const auto* grades=results[1].GetTensorData<float>()+best*4;
        float peak=*std::max_element(grades,grades+4),sum=0,good=0;
        for(int i=0;i<4;++i) {float p=std::exp(grades[i]-peak);sum+=p;if(i<2) good+=p;}
        *confidence=std::min(good/sum,1.f/(1.f+std::exp(-results[2].GetTensorData<float>()[0])));
        if(!std::isfinite(*confidence) || *confidence<model.threshold || raw[best]-alternative<model.margin) return -1;
        check_time();return best-1;
    }
};
}

extern "C" CASSOTIS_EXPORT int cassotis_lr_style_attach(void* opaque,
    const char16_t* graph,const char16_t* index,char16_t* error,int capacity) {
    SetUtf16Error(error,capacity,u"");if(!opaque || !graph || !index) return 0;
    try {
        FloatingPointMaskGuard f;const std::lock_guard<std::mutex> init(InitializationMutex());
        auto& owner=*static_cast<LocalRepairHandle*>(opaque);const std::lock_guard<std::mutex> lock(owner.lock);
        if(owner.query_session->GetOutputCount()!=6) return 0;
        owner.style=std::make_unique<StylePhraseRuntime>(graph,index);
        ReleaseUnusedHeapPages();
        return 1;
    } catch(const std::exception& e) {SetUtf16Error(error,capacity,Utf8ToUtf16(e.what()));} catch(...) {SetUtf16Error(error,capacity,u"style initialization failed");}
    return 0;
}

extern "C" CASSOTIS_EXPORT int cassotis_lr_style_run(void* opaque,
    const char16_t* query,const char16_t* first,const char16_t* second,const char16_t* first_path,const char16_t* second_path,
    void* user,StyleEntry entry,StyleLm lm,uint32_t timeout,char16_t* text,int text_capacity,
    char16_t* path,int path_capacity,char16_t* pinyin,int py_capacity,float* scores,float* confidence,
    int* proposals,int* encodings,char16_t* error,int error_capacity) {
    SetUtf16Error(error,error_capacity,u"");
    if(!opaque || !query || !first || !second || !first_path || !second_path || !entry || !lm ||
       !text || text_capacity<33 || !path || path_capacity<65 || !pinyin || py_capacity<193 ||
       !scores || !confidence || !proposals || !encodings) return 0;
    text[0]=path[0]=pinyin[0]=0;*proposals=*encodings=0;*confidence=0;
    std::fill_n(scores,9,-10000.f);
    try {
        FloatingPointMaskGuard f;auto& owner=*static_cast<LocalRepairHandle*>(opaque);
        const std::lock_guard<std::mutex> lock(owner.lock);
        if(!owner.style || owner.memory.empty() || owner.context_ids!=std::vector<int64_t>{3,2} ||
           std::char_traits<char16_t>::length(query)>200 || std::char_traits<char16_t>::length(first)>32 || std::char_traits<char16_t>::length(second)>40) return 0;
        StyleRequest request{*owner.style,owner,user,entry,lm,
            MonotonicMilliseconds(),timeout,{},{},{},0};
        auto pool=request.recover(query,{first,second},{first_path,second_path});*proposals=int(pool.size());
        if(pool.empty()) return 0;
        auto py=owner.style->align(first,query);if(py.empty()) return 0;
        auto words=StyleSplit(first_path,u'\3');if(words.empty()) words=request.path(first,py);
        if(!request.valid(first,py,words)) return 0;
        int selected=request.choose(first,py,words,pool,scores,confidence);*encodings=request.encodings;
        if(selected<0) return 0;
        const auto& winner=pool[selected];
        auto encoded_path=StyleJoin(winner.path,u'\3'),encoded_py=StyleJoin(winner.py,u'\3');
        if(winner.text.size()>=size_t(text_capacity) || encoded_path.size()>=size_t(path_capacity) || encoded_py.size()>=size_t(py_capacity)) return 0;
        std::copy(winner.text.begin(),winner.text.end(),text);text[winner.text.size()]=0;
        std::copy(encoded_path.begin(),encoded_path.end(),path);path[encoded_path.size()]=0;
        std::copy(encoded_py.begin(),encoded_py.end(),pinyin);pinyin[encoded_py.size()]=0;
        return 1;
    } catch(const std::exception& e) {SetUtf16Error(error,error_capacity,Utf8ToUtf16(e.what()));} catch(...) {SetUtf16Error(error,error_capacity,u"style recovery failed");}
    return 0;
}
