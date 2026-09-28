// Host-only frozen contextual short-word inference. Included after ORT helpers.
namespace {
struct ShortContextHandle {
    std::array<std::unique_ptr<Ort::Session>, 4> sessions;
    std::unordered_map<std::u16string, int64_t> vocabulary;
    std::array<std::u16string, 65536> normal;
    std::array<uint8_t, 65536> flags{};
    std::array<double, 4> temperature{}, change{}, keep{};
    std::array<double, 34> mean{}, scale{}, coef{};
    double cutoff{}, intercept{};
    std::mutex mutex;
};

template<typename T> void ShortRead(std::ifstream& in, T& value) {
    if (!ReadBinary(in, value)) throw std::runtime_error("truncated short-context data");
}

void ShortLoadData(const std::u16string& directory, ShortContextHandle& h) {
    std::ifstream in(Utf16ToUtf8(directory) + "/policy.bin", std::ios::binary);
    char magic[8];
    if (!in.read(magic, 8) || std::memcmp(magic, "CASSCP01", 8))
        throw std::runtime_error("invalid short-context policy");
    for (auto* values : {&h.temperature, &h.change, &h.keep})
        for (auto& x : *values) ShortRead(in, x);
    ShortRead(in, h.cutoff);
    for (auto* values : {&h.mean, &h.scale, &h.coef})
        for (auto& x : *values) {
            ShortRead(in, x);
            if (!std::isfinite(x)) throw std::runtime_error("nonfinite short-context policy");
        }
    ShortRead(in, h.intercept);
    if (!std::isfinite(h.intercept) || !(h.cutoff >= 0 && h.cutoff <= 1))
        throw std::runtime_error("invalid short-context threshold");
    for (size_t i = 0; i < 4; ++i)
        if (!(h.temperature[i] > 0) || !std::isfinite(h.temperature[i]) ||
            !(h.change[i] >= 0 && h.change[i] <= 1.01) ||
            !(h.keep[i] >= 0 && h.keep[i] <= 1.01))
            throw std::runtime_error("invalid short-context exit policy");
    for (double x : h.scale) if (!(x > 0)) throw std::runtime_error("invalid veto scale");
    in.close();
    in.open(Utf16ToUtf8(directory) + "/tokenizer.bin", std::ios::binary);
    if (!in.read(magic, 8) || std::memcmp(magic, "CASSCT01", 8))
        throw std::runtime_error("invalid short-context tokenizer");
    uint32_t count;
    ShortRead(in, count);
    if (count != 21128) throw std::runtime_error("unexpected short-context vocabulary");
    for (uint32_t i = 0; i < count; ++i) {
        uint32_t length;
        ShortRead(in, length);
        if (length > 100) throw std::runtime_error("invalid WordPiece token");
        std::u16string word(length, 0);
        if (!in.read(reinterpret_cast<char*>(word.data()), length * sizeof(char16_t)))
            throw std::runtime_error("truncated vocabulary");
        h.vocabulary.emplace(std::move(word), i);
    }
    for (size_t i = 0; i < 65536; ++i) {
        uint8_t length;
        ShortRead(in, length);
        ShortRead(in, h.flags[i]);
        if (length > 16) throw std::runtime_error("invalid character normalization");
        h.normal[i].resize(length);
        if (!in.read(reinterpret_cast<char*>(h.normal[i].data()), length * sizeof(char16_t)))
            throw std::runtime_error("truncated normalization table");
    }
}

std::vector<int64_t> ShortTokenize(const ShortContextHandle& h, const std::u16string& text) {
    std::vector<int64_t> result;
    std::u16string word;
    auto flush = [&]() {
        if (word.empty()) return;
        std::vector<int64_t> parts;
        size_t start = 0;
        while (start < word.size() && word.size() <= 100) {
            size_t end = word.size();
            auto found = h.vocabulary.end();
            for (; end > start; --end) {
                auto part = (start ? u"##" : u"") + word.substr(start, end - start);
                found = h.vocabulary.find(part);
                if (found != h.vocabulary.end()) break;
            }
            if (end == start) break;
            parts.push_back(found->second);
            start = end;
        }
        if (start != word.size()) result.push_back(100);
        else result.insert(result.end(), parts.begin(), parts.end());
        word.clear();
    };
    for (size_t i = 0; i < text.size(); ++i) {
        const uint16_t cp = text[i];
        if (cp >= 0xd800 && cp <= 0xdfff)
            throw std::runtime_error("supplementary context uses baseline ranking");
        if (cp == u'[') {
            bool special = false;
            for (const char16_t* token : {u"[PAD]", u"[UNK]", u"[CLS]", u"[SEP]", u"[MASK]"}) {
                size_t length = std::char_traits<char16_t>::length(token);
                if (text.compare(i, length, token) == 0) {
                    flush(); result.push_back(h.vocabulary.at(token));
                    i += length - 1; special = true; break;
                }
            }
            if (special) continue;
        }
        for (char16_t normalized : h.normal[cp]) {
            if (normalized == u' ') { flush(); continue; }
            if (h.flags[static_cast<uint16_t>(normalized)] != 0) {
                flush(); word.push_back(normalized); flush();
            } else word.push_back(normalized);
        }
    }
    flush();
    return result;
}

struct ShortInputs {
    std::vector<int64_t> tokens, types;
    std::vector<float> masks;
    std::array<float, 9> features{};
    size_t context_tokens{};
};

ShortInputs ShortEncode(const ShortContextHandle& h, const std::u16string& context,
    const std::u16string& query, const std::u16string& a, const std::u16string& b,
    const int32_t* values) {
    ShortInputs out;
    auto append = [&](const std::u16string& text) {
        auto ids = ShortTokenize(h, text);
        out.tokens.insert(out.tokens.end(), ids.begin(), ids.end());
        out.tokens.push_back(102);
    };
    out.tokens.push_back(101);
    append(context);
    out.context_tokens = out.tokens.size() - 2;
    append(query);
    const size_t prefix = out.tokens.size();
    append(a);
    const size_t second = out.tokens.size();
    append(b);
    const size_t length = out.tokens.size();
    if (length > 128) throw std::runtime_error("short-context token budget exceeded");
    out.types.resize(length, 1);
    std::fill_n(out.types.begin(), prefix, 0);
    out.masks.resize(length * 2, 0);
    std::fill(out.masks.begin() + prefix, out.masks.begin() + second - 1, 1.0f);
    std::fill(out.masks.begin() + length + second, out.masks.end() - 1, 1.0f);
    for (size_t i = 0; i < 2; ++i) {
        out.features[i] = static_cast<float>(std::copysign(std::log1p(std::abs(double(values[i]))), double(values[i])) / 8);
        out.features[i + 2] = static_cast<float>(std::tanh(double(values[i + 2]) / 2000));
        out.features[i + 4] = static_cast<float>(std::tanh(double(values[i + 4]) / 12000));
    }
    out.features[6] = static_cast<float>(a.size() / 4.0);
    out.features[7] = static_cast<float>(b.size() / 4.0);
    out.features[8] = 1;
    return out;
}

std::array<double, 3> ShortProbability(const float* logits, double temperature) {
    std::array<double, 3> p;
    double maximum = std::max({double(logits[0]), double(logits[1]), double(logits[2])}) / temperature;
    double sum = 0;
    for (size_t i = 0; i < 3; ++i) sum += p[i] = std::exp(double(logits[i]) / temperature - maximum);
    if (!std::isfinite(sum) || !(sum > 0)) throw std::runtime_error("invalid classifier output");
    for (auto& value : p) value /= sum;
    return p;
}

// A real ORT cancellation deadline, not merely discarding an already-late result.
class ShortDeadline {
    std::mutex mutex_;
    std::condition_variable condition_;
    bool finished_ = false;
    std::thread worker_;
public:
    explicit ShortDeadline(Ort::RunOptions& options, int milliseconds) {
        if (milliseconds <= 0) return;
        worker_ = std::thread([this, &options, milliseconds]() {
            std::unique_lock<std::mutex> lock(mutex_);
            if (!condition_.wait_for(lock, std::chrono::milliseconds(milliseconds),
                    [this]() { return finished_; })) {
                try { options.SetTerminate(); } catch (...) {}
            }
        });
    }
    ~ShortDeadline() {
        { const std::lock_guard<std::mutex> lock(mutex_); finished_ = true; }
        condition_.notify_one();
        if (worker_.joinable()) worker_.join();
    }
};

std::vector<Ort::Value> ShortRun(Ort::Session& session, ShortInputs& input,
    Ort::Value* previous, Ort::RunOptions& options) {
    auto memory = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
    const std::array<int64_t, 2> tokens_shape{1, static_cast<int64_t>(input.tokens.size())};
    const std::array<int64_t, 3> masks_shape{1, 2, tokens_shape[1]};
    const std::array<int64_t, 2> features_shape{1, 9};
    const std::array<int64_t, 3> states_shape{1, tokens_shape[1], 768};
    std::vector<Ort::Value> tensors;
    tensors.push_back(Ort::Value::CreateTensor<int64_t>(memory, input.tokens.data(), input.tokens.size(), tokens_shape.data(), 2));
    tensors.push_back(Ort::Value::CreateTensor<int64_t>(memory, input.types.data(), input.types.size(), tokens_shape.data(), 2));
    tensors.push_back(Ort::Value::CreateTensor<float>(memory, input.masks.data(), input.masks.size(), masks_shape.data(), 3));
    tensors.push_back(Ort::Value::CreateTensor<float>(memory, input.features.data(), 9, features_shape.data(), 2));
    if (previous) tensors.push_back(Ort::Value::CreateTensor<float>(memory,
        previous->GetTensorMutableData<float>(), input.tokens.size()*768, states_shape.data(), 3));
    const char* names[] = {"tokens", "types", "masks", "features", "previous"};
    const char* outputs[] = {"states", "logits"};
    return session.Run(options, names, tensors.data(), tensors.size(), outputs, 2);
}

double ShortVeto(const ShortContextHandle& h, const std::u16string& context,
    const std::u16string& a, const std::u16string& b, const int32_t* values,
    const std::array<std::array<double, 3>, 4>& p, const std::array<double, 3>& empty,
    int depth, double* audit) {
    auto odds = [](const auto& x) { return std::log(std::max(x[1], 1e-8)/std::max(x[0], 1e-8)); };
    size_t prefix = 0, diffs = std::max(a.size(), b.size()) - std::min(a.size(), b.size());
    while (prefix < std::min(a.size(), b.size()) && a[prefix] == b[prefix]) ++prefix;
    for (size_t i = 0; i < std::min(a.size(), b.size()); ++i) diffs += a[i] != b[i];
    double wins = 0, avg = 0, variance = 0;
    for (auto& x : p) { wins += x[1] > x[0]; avg += x[1]/4; }
    for (auto& x : p) variance += (x[1]-avg)*(x[1]-avg)/4;
    std::vector<double> x;
    for (const auto* row : {&p[depth], &p[3], &empty}) x.insert(x.end(), row->begin(), row->end());
    x.insert(x.end(), {odds(p[3]), odds(empty), odds(p[3])-odds(empty),
        p[3][1]-empty[1], p[3][1]-std::max(p[3][0], p[3][2]), wins/4, std::sqrt(variance),
        p[2][1], double(depth), double(context.size()), double(a.size()), double(b.size()),
        double(prefix), double(diffs), double(context.find(a) != std::u16string::npos),
        double(context.find(b) != std::u16string::npos)});
    for (int group = 0; group < 3; ++group) {
        double u = values[group*2], v = values[group*2+1];
        if (!group) { u = std::log1p(std::max(0.0, u)); v = std::log1p(std::max(0.0, v)); }
        else { u = std::tanh(u/10000); v = std::tanh(v/10000); }
        x.insert(x.end(), {u, v, v-u});
    }
    if (x.size() != 34) throw std::runtime_error("veto feature size mismatch");
    double score = h.intercept;
    for (size_t i = 0; i < x.size(); ++i) {
        // Frozen Python first rounds features to Float32, then uses Float64 LR.
        x[i] = static_cast<float>(x[i]);
        if (audit) audit[19+i] = x[i];
        score += (x[i]-h.mean[i])/h.scale[i]*h.coef[i];
    }
    return 1/(1+std::exp(-std::clamp(score, -80.0, 80.0)));
}
} // namespace

extern "C" CASSOTIS_EXPORT int nc_sc_runtime_format() {
    return 2;
}

extern "C" CASSOTIS_EXPORT void* nc_sc_create(
    const char16_t* directory, char16_t* error, int capacity) {
    SetUtf16Error(error, capacity, u"");
    try {
        if (!directory || !*directory) throw std::runtime_error("missing short-context directory");
        FloatingPointMaskGuard fp;
        const std::lock_guard<std::mutex> lock(InitializationMutex());
        Ort::InitApi();
        auto h = std::make_unique<ShortContextHandle>();
        ShortLoadData(directory, *h);
        Ort::SessionOptions options;
        ConfigureSessionOptions(options, 1);
        options.AddConfigEntry("session.intra_op.allow_spinning", "0");
        options.SetGraphOptimizationLevel(ORT_ENABLE_ALL);
        for (int i = 0; i < 4; ++i) {
            std::string path = Utf16ToUtf8(directory) + "/exit" + std::to_string(i) + ".int8.onnx";
            h->sessions[i] = std::make_unique<Ort::Session>(Environment(), path.c_str(), options);
        }
        // Match the other Linux model loaders: graph construction has finished.
        ReleaseUnusedHeapPages();
        return h.release();
    } catch (const std::exception& e) { SetUtf16Error(error, capacity, Utf8ToUtf16(e.what())); }
    catch (...) { SetUtf16Error(error, capacity, u"short-context initialization failed"); }
    return nullptr;
}

extern "C" CASSOTIS_EXPORT void nc_sc_destroy(void* handle) {
    FloatingPointMaskGuard fp;
    delete static_cast<ShortContextHandle*>(handle);
    ReleaseUnusedHeapPages();
}

extern "C" CASSOTIS_EXPORT int nc_sc_run(void* handle,
    const char16_t* context, const char16_t* query, const char16_t* first, const char16_t* second,
    const int32_t* values, int timeout_ms, double* audit, int audit_count,
    char16_t* error, int capacity) {
    SetUtf16Error(error, capacity, u"");
    if (audit && audit_count >= 54) std::fill_n(audit, 54, 0);
    else audit = nullptr;
    try {
        if (!handle || !context || !query || !first || !second || !values)
            throw std::runtime_error("invalid short-context input");
        auto& h = *static_cast<ShortContextHandle*>(handle);
        std::unique_lock<std::mutex> lock(h.mutex, std::try_to_lock);
        if (!lock.owns_lock()) return -1;
        FloatingPointMaskGuard fp;
        std::u16string c(context), q(query), a(first), b(second);
        if (c.empty() || c.size() > 256 || q.size() > 32 || q.empty() || a == b ||
            a.size() < 2 || a.size() > 4 || b.size() < 2 || b.size() > 4)
            return -1;
        if (c.size() > 48) c = c.substr(c.size()-48);
        const auto started = std::chrono::steady_clock::now();
        Ort::RunOptions options;
        ShortDeadline deadline(options, timeout_ms);
        auto input = ShortEncode(h, c, q, a, b, values);
        if (!input.context_tokens) return -1;
        std::array<std::array<double, 3>, 4> probabilities{};
        std::vector<Ort::Value> output;
        int chosen = -1;
        for (int depth = 0; depth < 4; ++depth) {
            auto next = ShortRun(*h.sessions[depth], input, depth ? &output[0] : nullptr, options);
            output = std::move(next);
            auto p = probabilities[depth] = ShortProbability(output[1].GetTensorData<float>(), h.temperature[depth]);
            if (audit) std::copy(p.begin(), p.end(), audit+4+3*depth);
            if (chosen < 0) {
                if (audit) audit[0] = depth;
                if (p[1] >= h.change[depth] && p[1] > std::max(p[0], p[2])) chosen = depth;
                else if (depth == 3 || std::max(p[0], p[2]) >= h.keep[depth]) return 0;
            }
        }
        if (audit) { audit[0] = chosen; audit[1] = 1; }
        auto empty_input = ShortEncode(h, u"", q, a, b, values);
        // The counterfactual uses the same encoder and final head. Reuse the
        // segments instead of retaining a second complete copy of the network.
        output.clear();
        for (int depth = 0; depth < 4; ++depth) {
            auto next = ShortRun(*h.sessions[depth], empty_input,
                depth ? &output[0] : nullptr, options);
            output = std::move(next);
        }
        auto empty = ShortProbability(output[1].GetTensorData<float>(), h.temperature[3]);
        if (audit) std::copy(empty.begin(), empty.end(), audit+16);
        double confidence = ShortVeto(h, c, a, b, values, probabilities, empty, chosen, audit);
        const double elapsed = std::chrono::duration<double, std::milli>(
            std::chrono::steady_clock::now()-started).count();
        if (audit) { audit[2] = confidence; audit[3] = elapsed; }
        if (timeout_ms > 0 && elapsed > timeout_ms) return -1;
        return confidence >= h.cutoff ? 1 : 0;
    } catch (const std::exception& e) { SetUtf16Error(error, capacity, Utf8ToUtf16(e.what())); }
    catch (...) { SetUtf16Error(error, capacity, u"short-context inference failed"); }
    return -1;
}

// Input parity probe; does not expose labels or any benchmark-specific logic.
extern "C" CASSOTIS_EXPORT int nc_sc_encode(void* handle,
    const char16_t* context, const char16_t* query, const char16_t* first, const char16_t* second,
    int64_t* tokens, int64_t* types, float* masks, int capacity) {
    try {
        if (!handle || !context || !query || !first || !second || !tokens || !types || !masks) return -1;
        std::u16string tail(context);
        if (tail.size() > 48) tail = tail.substr(tail.size()-48);
        int32_t values[6]{};
        auto input = ShortEncode(*static_cast<ShortContextHandle*>(handle), tail, query, first, second, values);
        if (static_cast<int>(input.tokens.size()) > capacity) return -1;
        std::copy(input.tokens.begin(), input.tokens.end(), tokens);
        std::copy(input.types.begin(), input.types.end(), types);
        std::copy(input.masks.begin(), input.masks.end(), masks);
        return static_cast<int>(input.tokens.size());
    } catch (...) { return -1; }
}
