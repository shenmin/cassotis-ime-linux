#define NOMINMAX
#define ORT_API_MANUAL_INIT
#include <onnxruntime_cxx_api.h>

#include <algorithm>
#include <array>
#include <cstdint>
#include <cstring>
#include <cerrno>
#include <cstdio>
#include <limits>
#include <memory>
#include <mutex>
#include <string>
#include <string_view>
#include <tuple>
#include <thread>
#include <utility>
#include <vector>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

#if defined(__x86_64__) || defined(__i386__)
#include <xmmintrin.h>
#endif

#define CASSOTIS_EXPORT __attribute__((visibility("default")))

namespace {

constexpr int64_t kCandidateCount = 12;
constexpr int64_t kSequenceLength = 41;
constexpr int64_t kNumericFeatureCount = 88;

std::mutex& InitializationMutex() {
    static std::mutex value;
    return value;
}

int EffectiveThreadCount(int requested_threads) {
    const int requested = std::max(1, requested_threads);
    const unsigned int available = std::thread::hardware_concurrency();
    if (available == 0) {
        return requested;
    }
    return std::min(requested, static_cast<int>(available));
}

struct SessionHandle {
    std::unique_ptr<Ort::Session> session;
};

class FloatingPointMaskGuard {
public:
    FloatingPointMaskGuard() {
#if defined(__x86_64__) || defined(__i386__)
        old_mxcsr_ = _mm_getcsr();
        _mm_setcsr(old_mxcsr_ | _MM_MASK_MASK);
#elif defined(__aarch64__)
        asm volatile("mrs %0, fpcr" : "=r"(old_fpcr_));
        asm volatile("mrs %0, fpsr" : "=r"(old_fpsr_));
        constexpr std::uint64_t kExceptionEnableMask =
            (UINT64_C(0x1f) << 8) | (UINT64_C(1) << 15);
        const std::uint64_t masked_fpcr = old_fpcr_ & ~kExceptionEnableMask;
        asm volatile("msr fpcr, %0\n\tisb" : : "r"(masked_fpcr) : "memory");
        asm volatile("msr fpsr, xzr" : : : "memory");
#endif
    }

    ~FloatingPointMaskGuard() {
#if defined(__x86_64__) || defined(__i386__)
        _mm_setcsr(old_mxcsr_);
#elif defined(__aarch64__)
        asm volatile("msr fpsr, %0" : : "r"(old_fpsr_) : "memory");
        asm volatile("msr fpcr, %0\n\tisb" : : "r"(old_fpcr_) : "memory");
#endif
    }

private:
#if defined(__x86_64__) || defined(__i386__)
    unsigned int old_mxcsr_{};
#elif defined(__aarch64__)
    std::uint64_t old_fpcr_{};
    std::uint64_t old_fpsr_{};
#endif
};

Ort::Env& Environment() {
    static Ort::Env env(ORT_LOGGING_LEVEL_WARNING, "cassotis_pinyin_transformer");
    return env;
}

void SetError(char* destination, int capacity, std::string_view message) {
    if (destination == nullptr || capacity <= 0) {
        return;
    }
    const size_t copy_length = std::min(message.size(), static_cast<size_t>(capacity - 1));
    if (copy_length > 0) {
        std::memcpy(destination, message.data(), copy_length);
    }
    destination[copy_length] = '\0';
}

std::string ErrorText(const char* message) {
    if (message == nullptr || *message == '\0') {
        return "unknown ONNX Runtime error";
    }
    return message;
}

}  // namespace

extern "C" CASSOTIS_EXPORT void* nc_pt_create(
    const char* model_path,
    int intra_threads,
    char* error_text,
    int error_capacity) {
    SetError(error_text, error_capacity, "");
    if (model_path == nullptr || *model_path == '\0') {
        SetError(error_text, error_capacity, "model path is empty");
        return nullptr;
    }
    try {
        FloatingPointMaskGuard floating_point_guard;
        const std::lock_guard<std::mutex> initialization_lock(
            InitializationMutex());
        Ort::InitApi();
        Ort::SessionOptions options;
        options.SetExecutionMode(ExecutionMode::ORT_SEQUENTIAL);
        options.SetIntraOpNumThreads(EffectiveThreadCount(intra_threads));
        options.SetInterOpNumThreads(1);
        options.SetGraphOptimizationLevel(GraphOptimizationLevel::ORT_ENABLE_ALL);
        auto handle = std::make_unique<SessionHandle>();
        handle->session = std::make_unique<Ort::Session>(Environment(), model_path, options);
        return handle.release();
    } catch (const Ort::Exception& error) {
        SetError(error_text, error_capacity, ErrorText(error.what()));
    } catch (const std::exception& error) {
        SetError(error_text, error_capacity, ErrorText(error.what()));
    } catch (...) {
        SetError(error_text, error_capacity, "unknown model initialization failure");
    }
    return nullptr;
}

extern "C" CASSOTIS_EXPORT int nc_pt_run(
    void* opaque_handle,
    const int64_t* char_ids,
    const int64_t* pinyin_ids,
    const int64_t* boundary_ids,
    const float* numeric_features,
    const uint8_t* candidate_mask,
    float* output_scores,
    int output_score_count,
    char* error_text,
    int error_capacity) {
    SetError(error_text, error_capacity, "");
    if (opaque_handle == nullptr || char_ids == nullptr || pinyin_ids == nullptr ||
        boundary_ids == nullptr || numeric_features == nullptr || candidate_mask == nullptr ||
        output_scores == nullptr || output_score_count < kCandidateCount) {
        SetError(error_text, error_capacity, "invalid inference arguments");
        return 0;
    }
    try {
        FloatingPointMaskGuard floating_point_guard;
        auto* handle = static_cast<SessionHandle*>(opaque_handle);
        if (!handle->session) {
            SetError(error_text, error_capacity, "model session is unavailable");
            return 0;
        }

        static_assert(sizeof(bool) == sizeof(uint8_t), "ONNX bool tensor requires one-byte bool");
        std::array<uint8_t, kCandidateCount> mask_storage{};
        std::copy_n(candidate_mask, kCandidateCount, mask_storage.begin());

        const std::array<int64_t, 3> candidate_shape{1, kCandidateCount, kSequenceLength};
        const std::array<int64_t, 2> pinyin_shape{1, kSequenceLength};
        const std::array<int64_t, 3> numeric_shape{1, kCandidateCount, kNumericFeatureCount};
        const std::array<int64_t, 2> mask_shape{1, kCandidateCount};
        auto memory = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);

        std::array<Ort::Value, 5> inputs{
            Ort::Value::CreateTensor<int64_t>(memory, const_cast<int64_t*>(char_ids),
                kCandidateCount * kSequenceLength, candidate_shape.data(), candidate_shape.size()),
            Ort::Value::CreateTensor<int64_t>(memory, const_cast<int64_t*>(pinyin_ids),
                kSequenceLength, pinyin_shape.data(), pinyin_shape.size()),
            Ort::Value::CreateTensor<int64_t>(memory, const_cast<int64_t*>(boundary_ids),
                kCandidateCount * kSequenceLength, candidate_shape.data(), candidate_shape.size()),
            Ort::Value::CreateTensor<float>(memory, const_cast<float*>(numeric_features),
                kCandidateCount * kNumericFeatureCount, numeric_shape.data(), numeric_shape.size()),
            Ort::Value::CreateTensor<bool>(memory, reinterpret_cast<bool*>(mask_storage.data()),
                kCandidateCount, mask_shape.data(), mask_shape.size())};

        constexpr std::array<const char*, 5> input_names{
            "char_ids", "pinyin_ids", "boundary_ids", "numeric_features", "candidate_mask"};
        constexpr std::array<const char*, 1> output_names{"scores"};
        auto outputs = handle->session->Run(Ort::RunOptions{nullptr}, input_names.data(),
            inputs.data(), inputs.size(), output_names.data(), output_names.size());
        if (outputs.size() != 1 || !outputs[0].IsTensor()) {
            SetError(error_text, error_capacity, "model returned an invalid output tensor");
            return 0;
        }
        const auto info = outputs[0].GetTensorTypeAndShapeInfo();
        if (info.GetElementCount() < kCandidateCount) {
            SetError(error_text, error_capacity, "model output tensor is too small");
            return 0;
        }
        const float* scores = outputs[0].GetTensorData<float>();
        std::copy_n(scores, kCandidateCount, output_scores);
        return 1;
    } catch (const Ort::Exception& error) {
        SetError(error_text, error_capacity, ErrorText(error.what()));
    } catch (const std::exception& error) {
        SetError(error_text, error_capacity, ErrorText(error.what()));
    } catch (...) {
        SetError(error_text, error_capacity, "unknown inference failure");
    }
    return 0;
}

extern "C" CASSOTIS_EXPORT void nc_pt_destroy(void* opaque_handle) {
    delete static_cast<SessionHandle*>(opaque_handle);
}

namespace {

constexpr std::array<char, 8> kLocalCompletionMagic{
    'C', 'A', 'S', 'L', 'C', 'I', '0', '1'};
constexpr uint32_t kLocalCompletionIndexVersion = 1;
constexpr size_t kLocalCompletionInputLength = 105;
constexpr size_t kLocalCompletionCandidateCount = 32;
constexpr size_t kLocalCompletionPathWords = 3;
constexpr size_t kLocalCompletionFeatureCount = 8;
constexpr size_t kLocalCompletionOutputCount = kLocalCompletionCandidateCount + 1;

#pragma pack(push, 1)
struct LocalCompletionIndexHeader {
    char magic[8];
    uint32_t version;
    uint32_t max_input_length;
    uint32_t candidate_limit;
    uint32_t path_words;
    uint32_t feature_count;
    uint32_t input_vocab_size;
    uint32_t word_vocab_size;
    uint32_t pinyin_offset;
    uint32_t separator_id;
    uint32_t cls_id;
    uint32_t unknown_char_id;
    uint32_t unknown_pinyin_id;
    uint32_t char_count;
    uint32_t pinyin_count;
    uint32_t word_count;
    uint32_t anchor_count;
    uint32_t candidate_count;
    uint32_t reserved;
    uint64_t char_offset;
    uint64_t pinyin_offset_bytes;
    uint64_t word_offset;
    uint64_t anchor_offset;
    uint64_t candidate_offset;
    uint64_t string_offset;
    uint64_t file_size;
};

struct LocalCompletionCharRecord {
    uint32_t codepoint;
    uint16_t token_id;
    uint16_t reserved;
};

struct LocalCompletionTextIdRecord {
    uint32_t text_offset;
    uint16_t text_length;
    uint16_t token_id;
};

struct LocalCompletionWordRecord {
    uint32_t text_offset;
    uint16_t text_length;
    uint32_t pinyin_offset;
    uint16_t pinyin_length;
    uint8_t text_units;
    uint8_t syllable_count;
    uint16_t reserved;
};

struct LocalCompletionAnchorRecord {
    uint32_t text_offset;
    uint16_t text_length;
    uint16_t candidate_count;
    uint32_t candidate_start;
};

struct LocalCompletionCandidateRecord {
    uint16_t word_ids[kLocalCompletionPathWords];
    uint16_t reserved;
    int32_t score;
    int32_t count;
    int32_t source_count;
    int32_t domain_count;
};
#pragma pack(pop)

static_assert(sizeof(LocalCompletionIndexHeader) == 136,
    "local-completion header layout changed");
static_assert(sizeof(LocalCompletionCandidateRecord) == 24,
    "local-completion candidate layout changed");

class ReadOnlyMappedFile {
public:
    ~ReadOnlyMappedFile() { Close(); }

    bool Open(const char* path, std::string& error) {
        Close();
        file_ = open(path, O_RDONLY | O_CLOEXEC);
        if (file_ < 0) {
            error = "cannot open local-completion index: " +
                std::string(std::strerror(errno));
            return false;
        }
        struct stat metadata {};
        if (fstat(file_, &metadata) != 0 || metadata.st_size <= 0) {
            error = "cannot read local-completion index size";
            Close();
            return false;
        }
        size_ = static_cast<size_t>(metadata.st_size);
        data_ = static_cast<const uint8_t*>(
            mmap(nullptr, size_, PROT_READ, MAP_PRIVATE, file_, 0));
        if (data_ == MAP_FAILED) {
            data_ = nullptr;
            error = "cannot map local-completion index: " +
                std::string(std::strerror(errno));
            Close();
            return false;
        }
        return true;
    }

    void Close() {
        if (data_ != nullptr) {
            munmap(const_cast<uint8_t*>(data_), size_);
            data_ = nullptr;
        }
        if (file_ >= 0) {
            close(file_);
            file_ = -1;
        }
        size_ = 0;
    }

    const uint8_t* data() const { return data_; }
    size_t size() const { return size_; }

private:
    int file_{-1};
    const uint8_t* data_{};
    size_t size_{};
};

bool CheckedSection(uint64_t offset, uint64_t count, uint64_t item_size,
    uint64_t file_size) {
    return offset <= file_size && count <= file_size && item_size <= file_size &&
        count <= (file_size - offset) / item_size;
}

std::vector<uint32_t> Utf8Codepoints(const char* value) {
    std::vector<uint32_t> result;
    if (value == nullptr) {
        return result;
    }
    const auto* cursor = reinterpret_cast<const unsigned char*>(value);
    while (*cursor != 0) {
        uint32_t codepoint = 0;
        size_t length = 0;
        if (*cursor < 0x80) {
            codepoint = *cursor;
            length = 1;
        } else if ((*cursor & 0xE0) == 0xC0) {
            codepoint = *cursor & 0x1F;
            length = 2;
        } else if ((*cursor & 0xF0) == 0xE0) {
            codepoint = *cursor & 0x0F;
            length = 3;
        } else if ((*cursor & 0xF8) == 0xF0) {
            codepoint = *cursor & 0x07;
            length = 4;
        } else {
            ++cursor;
            continue;
        }
        bool valid = true;
        for (size_t index = 1; index < length; ++index) {
            if ((cursor[index] & 0xC0) != 0x80) {
                valid = false;
                break;
            }
            codepoint = (codepoint << 6) | (cursor[index] & 0x3F);
        }
        if (!valid || codepoint > 0x10FFFF ||
            (codepoint >= 0xD800 && codepoint <= 0xDFFF)) {
            ++cursor;
            continue;
        }
        result.push_back(codepoint);
        cursor += length;
    }
    return result;
}

std::vector<std::string> SplitPath(const char* value) {
    std::vector<std::string> result;
    if (value == nullptr) {
        return result;
    }
    std::string current;
    for (const char* cursor = value;; ++cursor) {
        if (*cursor == '\3' || *cursor == '\0') {
            if (!current.empty()) {
                result.push_back(current);
                current.clear();
            }
            if (*cursor == '\0') {
                break;
            }
        } else {
            current.push_back(*cursor);
        }
    }
    return result;
}

std::vector<std::string> SplitPinyin(const char* value) {
    std::vector<std::string> result;
    if (value == nullptr) {
        return result;
    }
    std::string current;
    for (const char* cursor = value;; ++cursor) {
        if (*cursor == '\'' || *cursor == ' ' || *cursor == '\3' ||
            *cursor == '\0') {
            if (!current.empty()) {
                result.push_back(current);
                current.clear();
            }
            if (*cursor == '\0') {
                break;
            }
        } else {
            char character = *cursor;
            if (character >= 'A' && character <= 'Z') {
                character = static_cast<char>(character - 'A' + 'a');
            }
            current.push_back(character);
        }
    }
    return result;
}

class LocalCompletionIndex {
public:
    bool Load(const char* path, std::string& error) {
        if (path == nullptr || *path == '\0') {
            error = "local-completion index path is empty";
            return false;
        }
        if (!file_.Open(path, error)) {
            return false;
        }
        if (file_.size() < sizeof(LocalCompletionIndexHeader)) {
            error = "local-completion index is truncated";
            return false;
        }
        header_ = reinterpret_cast<const LocalCompletionIndexHeader*>(file_.data());
        if (!std::equal(kLocalCompletionMagic.begin(), kLocalCompletionMagic.end(),
                header_->magic) || header_->version != kLocalCompletionIndexVersion) {
            error = "local-completion index format is unsupported";
            return false;
        }
        if (header_->max_input_length != kLocalCompletionInputLength ||
            header_->candidate_limit != kLocalCompletionCandidateCount ||
            header_->path_words != kLocalCompletionPathWords ||
            header_->feature_count != kLocalCompletionFeatureCount ||
            header_->word_count != header_->word_vocab_size ||
            header_->file_size != file_.size() ||
            header_->string_offset > header_->file_size ||
            !CheckedSection(header_->char_offset, header_->char_count,
                sizeof(LocalCompletionCharRecord), header_->file_size) ||
            !CheckedSection(header_->pinyin_offset_bytes, header_->pinyin_count,
                sizeof(LocalCompletionTextIdRecord), header_->file_size) ||
            !CheckedSection(header_->word_offset, header_->word_count,
                sizeof(LocalCompletionWordRecord), header_->file_size) ||
            !CheckedSection(header_->anchor_offset, header_->anchor_count,
                sizeof(LocalCompletionAnchorRecord), header_->file_size) ||
            !CheckedSection(header_->candidate_offset, header_->candidate_count,
                sizeof(LocalCompletionCandidateRecord), header_->file_size)) {
            error = "local-completion index metadata is invalid";
            return false;
        }
        chars_ = reinterpret_cast<const LocalCompletionCharRecord*>(
            file_.data() + header_->char_offset);
        pinyins_ = reinterpret_cast<const LocalCompletionTextIdRecord*>(
            file_.data() + header_->pinyin_offset_bytes);
        words_ = reinterpret_cast<const LocalCompletionWordRecord*>(
            file_.data() + header_->word_offset);
        anchors_ = reinterpret_cast<const LocalCompletionAnchorRecord*>(
            file_.data() + header_->anchor_offset);
        candidates_ = reinterpret_cast<const LocalCompletionCandidateRecord*>(
            file_.data() + header_->candidate_offset);
        strings_ = reinterpret_cast<const char*>(file_.data() + header_->string_offset);
        strings_size_ = header_->file_size - header_->string_offset;
        return ValidateSorted(error);
    }

    const LocalCompletionIndexHeader& header() const { return *header_; }

    uint16_t CharId(uint32_t codepoint) const {
        const auto* first = chars_;
        const auto* last = chars_ + header_->char_count;
        const auto* found = std::lower_bound(first, last, codepoint,
            [](const LocalCompletionCharRecord& row, uint32_t target) {
                return row.codepoint < target;
            });
        return found != last && found->codepoint == codepoint
            ? found->token_id
            : static_cast<uint16_t>(header_->unknown_char_id);
    }

    uint16_t PinyinId(std::string_view pinyin) const {
        size_t low = 0;
        size_t high = header_->pinyin_count;
        while (low < high) {
            const size_t middle = low + (high - low) / 2;
            const auto& row = pinyins_[middle];
            const int comparison = Text(row.text_offset, row.text_length).compare(pinyin);
            if (comparison < 0) {
                low = middle + 1;
            } else {
                high = middle;
            }
        }
        if (low < header_->pinyin_count) {
            const auto& row = pinyins_[low];
            if (Text(row.text_offset, row.text_length) == pinyin) {
                return row.token_id;
            }
        }
        return static_cast<uint16_t>(header_->unknown_pinyin_id);
    }

    const LocalCompletionAnchorRecord* FindAnchor(std::string_view anchor) const {
        size_t low = 0;
        size_t high = header_->anchor_count;
        while (low < high) {
            const size_t middle = low + (high - low) / 2;
            const auto& row = anchors_[middle];
            const int comparison = Text(row.text_offset, row.text_length).compare(anchor);
            if (comparison < 0) {
                low = middle + 1;
            } else {
                high = middle;
            }
        }
        if (low >= header_->anchor_count) {
            return nullptr;
        }
        const auto& row = anchors_[low];
        return Text(row.text_offset, row.text_length) == anchor ? &row : nullptr;
    }

    const LocalCompletionCandidateRecord& Candidate(uint32_t index) const {
        return candidates_[index];
    }

    const LocalCompletionWordRecord& Word(uint16_t id) const {
        return words_[id];
    }

    std::string_view WordText(uint16_t id) const {
        const auto& word = Word(id);
        return Text(word.text_offset, word.text_length);
    }

    std::string_view WordPinyin(uint16_t id) const {
        const auto& word = Word(id);
        return Text(word.pinyin_offset, word.pinyin_length);
    }

private:
    std::string_view Text(uint32_t offset, uint16_t length) const {
        if (offset > strings_size_ || length > strings_size_ - offset) {
            return {};
        }
        return std::string_view(strings_ + offset, length);
    }

    bool ValidateSorted(std::string& error) const {
        for (uint32_t index = 1; index < header_->char_count; ++index) {
            if (chars_[index - 1].codepoint >= chars_[index].codepoint) {
                error = "local-completion character index is not sorted";
                return false;
            }
        }
        for (uint32_t index = 1; index < header_->pinyin_count; ++index) {
            const auto& previous = pinyins_[index - 1];
            const auto& current = pinyins_[index];
            if (Text(previous.text_offset, previous.text_length) >=
                Text(current.text_offset, current.text_length)) {
                error = "local-completion pinyin index is not sorted";
                return false;
            }
        }
        for (uint32_t index = 0; index < header_->anchor_count; ++index) {
            const auto& row = anchors_[index];
            if (row.candidate_start > header_->candidate_count ||
                row.candidate_count > header_->candidate_count - row.candidate_start) {
                error = "local-completion anchor candidate range is invalid";
                return false;
            }
            if (index > 0) {
                const auto& previous = anchors_[index - 1];
                if (Text(previous.text_offset, previous.text_length) >=
                    Text(row.text_offset, row.text_length)) {
                    error = "local-completion anchor index is not sorted";
                    return false;
                }
            }
        }
        for (uint32_t index = 0; index < header_->candidate_count; ++index) {
            for (uint16_t word_id : candidates_[index].word_ids) {
                if (word_id >= header_->word_count) {
                    error = "local-completion candidate word ID is invalid";
                    return false;
                }
            }
        }
        return true;
    }

    ReadOnlyMappedFile file_;
    const LocalCompletionIndexHeader* header_{};
    const LocalCompletionCharRecord* chars_{};
    const LocalCompletionTextIdRecord* pinyins_{};
    const LocalCompletionWordRecord* words_{};
    const LocalCompletionAnchorRecord* anchors_{};
    const LocalCompletionCandidateRecord* candidates_{};
    const char* strings_{};
    size_t strings_size_{};
};

struct LocalRuntimeCandidate {
    const LocalCompletionCandidateRecord* source{};
    std::array<uint16_t, kLocalCompletionPathWords> word_ids{};
    int base_rank{};
    int anchor_width{};
    int rank_score{};
    int text_units{};
};

struct LocalCompletionHandle {
    std::unique_ptr<Ort::Session> session;
    LocalCompletionIndex index;
};

bool SameRuntimeCandidate(const LocalRuntimeCandidate& left,
    const LocalRuntimeCandidate& right) {
    return left.base_rank == right.base_rank && left.word_ids == right.word_ids;
}

void AppendBaseCandidates(const LocalCompletionIndex& index, int base_rank,
    const char* encoded_path, std::vector<LocalRuntimeCandidate>& output) {
    const auto words = SplitPath(encoded_path);
    for (int width = std::min<int>(3, static_cast<int>(words.size()));
         width >= 1; --width) {
        std::string anchor;
        for (size_t position = words.size() - width; position < words.size(); ++position) {
            if (!anchor.empty()) {
                anchor.push_back('\3');
            }
            anchor.append(words[position]);
        }
        const auto* row = index.FindAnchor(anchor);
        if (row == nullptr) {
            continue;
        }
        for (uint32_t item = 0; item < row->candidate_count; ++item) {
            const auto& candidate = index.Candidate(row->candidate_start + item);
            LocalRuntimeCandidate value{};
            value.source = &candidate;
            std::copy(std::begin(candidate.word_ids), std::end(candidate.word_ids),
                value.word_ids.begin());
            value.base_rank = base_rank;
            value.anchor_width = width;
            value.rank_score = candidate.score + (width - 1) * 32 -
                (base_rank - 1) * 12;
            for (uint16_t word_id : value.word_ids) {
                if (word_id != 0) {
                    value.text_units += index.Word(word_id).text_units;
                }
            }
            auto previous = std::find_if(output.begin(), output.end(),
                [&value](const LocalRuntimeCandidate& item_value) {
                    return SameRuntimeCandidate(item_value, value);
                });
            if (previous == output.end()) {
                output.push_back(value);
            } else if (value.rank_score > previous->rank_score) {
                *previous = value;
            }
        }
    }
}

void AppendTextInput(const LocalCompletionIndex& index,
    const std::vector<uint32_t>& codepoints, size_t limit, int64_t type_id,
    std::vector<int64_t>& ids, std::vector<int64_t>& types) {
    const size_t start = codepoints.size() > limit ? codepoints.size() - limit : 0;
    for (size_t position = start; position < codepoints.size(); ++position) {
        ids.push_back(index.CharId(codepoints[position]));
        types.push_back(type_id);
    }
    ids.push_back(index.header().separator_id);
    types.push_back(0);
}

bool BuildLocalInputs(const LocalCompletionIndex& index, const char* context,
    const char* query_syllables, const char* top1_text,
    const char* top1_path, const char* top2_text, const char* top2_path,
    std::array<int64_t, kLocalCompletionInputLength>& input_ids,
    std::array<int64_t, kLocalCompletionInputLength>& type_ids,
    std::array<int64_t, kLocalCompletionCandidateCount * kLocalCompletionPathWords>& candidate_ids,
    std::array<float, kLocalCompletionCandidateCount * kLocalCompletionFeatureCount>& candidate_features,
    std::vector<LocalRuntimeCandidate>& candidates) {
    candidates.clear();
    if (top1_text == nullptr || *top1_text == '\0' ||
        top1_path == nullptr || *top1_path == '\0') {
        return false;
    }
    AppendBaseCandidates(index, 1, top1_path, candidates);
    if (top2_text != nullptr && *top2_text != '\0' &&
        top2_path != nullptr && *top2_path != '\0') {
        AppendBaseCandidates(index, 2, top2_path, candidates);
    }
    std::sort(candidates.begin(), candidates.end(),
        [](const LocalRuntimeCandidate& left, const LocalRuntimeCandidate& right) {
            if (left.rank_score != right.rank_score) {
                return left.rank_score > right.rank_score;
            }
            if (left.base_rank != right.base_rank) {
                return left.base_rank < right.base_rank;
            }
            return left.word_ids < right.word_ids;
        });
    if (candidates.size() > kLocalCompletionCandidateCount) {
        candidates.resize(kLocalCompletionCandidateCount);
    }
    if (candidates.empty()) {
        return false;
    }

    std::vector<int64_t> ids{static_cast<int64_t>(index.header().cls_id)};
    std::vector<int64_t> types{0};
    AppendTextInput(index, Utf8Codepoints(context), 12, 1, ids, types);
    const auto pinyins = SplitPinyin(query_syllables);
    const size_t pinyin_start = pinyins.size() > 24 ? pinyins.size() - 24 : 0;
    for (size_t position = pinyin_start; position < pinyins.size(); ++position) {
        ids.push_back(index.header().pinyin_offset + index.PinyinId(pinyins[position]));
        types.push_back(2);
    }
    ids.push_back(index.header().separator_id);
    types.push_back(0);
    AppendTextInput(index, Utf8Codepoints(top1_text), 32, 3, ids, types);
    AppendTextInput(index, Utf8Codepoints(top2_text), 32, 4, ids, types);
    if (ids.size() > kLocalCompletionInputLength) {
        return false;
    }
    input_ids.fill(0);
    type_ids.fill(0);
    std::copy(ids.begin(), ids.end(), input_ids.begin());
    std::copy(types.begin(), types.end(), type_ids.begin());
    candidate_ids.fill(0);
    candidate_features.fill(0.0f);
    for (size_t index_value = 0; index_value < candidates.size(); ++index_value) {
        const auto& item = candidates[index_value];
        const size_t id_offset = index_value * kLocalCompletionPathWords;
        const size_t feature_offset = index_value * kLocalCompletionFeatureCount;
        int path_words = 0;
        for (size_t word = 0; word < kLocalCompletionPathWords; ++word) {
            candidate_ids[id_offset + word] = item.word_ids[word];
            path_words += item.word_ids[word] != 0 ? 1 : 0;
        }
        candidate_features[feature_offset + 0] = static_cast<float>(item.source->score);
        candidate_features[feature_offset + 1] = static_cast<float>(item.source->count);
        candidate_features[feature_offset + 2] = static_cast<float>(item.source->source_count);
        candidate_features[feature_offset + 3] = static_cast<float>(item.source->domain_count);
        candidate_features[feature_offset + 4] = static_cast<float>(item.anchor_width);
        candidate_features[feature_offset + 5] = static_cast<float>(item.base_rank);
        candidate_features[feature_offset + 6] = static_cast<float>(path_words);
        candidate_features[feature_offset + 7] = static_cast<float>(item.text_units);
    }
    return true;
}

void WarmLocalCompletionSession(Ort::Session& session,
    const LocalCompletionIndex& index) {
    std::array<int64_t, kLocalCompletionInputLength> input_ids{};
    std::array<int64_t, kLocalCompletionInputLength> type_ids{};
    std::array<int64_t,
        kLocalCompletionCandidateCount * kLocalCompletionPathWords> candidate_ids{};
    std::array<float,
        kLocalCompletionCandidateCount * kLocalCompletionFeatureCount> candidate_features{};
    input_ids[0] = index.header().cls_id;
    if (index.header().word_count > 4) {
        candidate_ids[0] = 4;
    }
    const std::array<int64_t, 2> input_shape{
        1, static_cast<int64_t>(kLocalCompletionInputLength)};
    const std::array<int64_t, 3> candidate_shape{
        1, static_cast<int64_t>(kLocalCompletionCandidateCount),
        static_cast<int64_t>(kLocalCompletionPathWords)};
    const std::array<int64_t, 3> feature_shape{
        1, static_cast<int64_t>(kLocalCompletionCandidateCount),
        static_cast<int64_t>(kLocalCompletionFeatureCount)};
    auto memory = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
    std::array<Ort::Value, 4> inputs{
        Ort::Value::CreateTensor<int64_t>(memory, input_ids.data(), input_ids.size(),
            input_shape.data(), input_shape.size()),
        Ort::Value::CreateTensor<int64_t>(memory, type_ids.data(), type_ids.size(),
            input_shape.data(), input_shape.size()),
        Ort::Value::CreateTensor<int64_t>(memory, candidate_ids.data(),
            candidate_ids.size(), candidate_shape.data(), candidate_shape.size()),
        Ort::Value::CreateTensor<float>(memory, candidate_features.data(),
            candidate_features.size(), feature_shape.data(), feature_shape.size())};
    constexpr std::array<const char*, 4> input_names{
        "input_ids", "type_ids", "candidate_ids", "candidate_features"};
    constexpr std::array<const char*, 1> output_names{"scores"};
    const auto outputs = session.Run(Ort::RunOptions{nullptr}, input_names.data(),
        inputs.data(), inputs.size(), output_names.data(), output_names.size());
    if (outputs.size() != 1 || !outputs[0].IsTensor() ||
        outputs[0].GetTensorTypeAndShapeInfo().GetElementCount() <
            kLocalCompletionOutputCount) {
        throw std::runtime_error(
            "local-completion model warmup returned an invalid output tensor");
    }
}

void SetOutput(char* destination, int capacity, std::string_view value) {
    if (destination == nullptr || capacity <= 0) {
        return;
    }
    const size_t length = std::min(value.size(), static_cast<size_t>(capacity - 1));
    if (length > 0) {
        std::memcpy(destination, value.data(), length);
    }
    destination[length] = '\0';
}

}  // namespace

extern "C" CASSOTIS_EXPORT void* nc_lc_create(
    const char* model_path,
    const char* index_path,
    int intra_threads,
    char* error_text,
    int error_capacity) {
    SetError(error_text, error_capacity, "");
    if (model_path == nullptr || *model_path == '\0') {
        SetError(error_text, error_capacity, "local-completion model path is empty");
        return nullptr;
    }
    try {
        FloatingPointMaskGuard floating_point_guard;
        const std::lock_guard<std::mutex> initialization_lock(
            InitializationMutex());
        Ort::InitApi();
        auto handle = std::make_unique<LocalCompletionHandle>();
        std::string index_error;
        if (!handle->index.Load(index_path, index_error)) {
            SetError(error_text, error_capacity, index_error);
            return nullptr;
        }
        Ort::SessionOptions options;
        options.SetExecutionMode(ExecutionMode::ORT_SEQUENTIAL);
        options.SetIntraOpNumThreads(EffectiveThreadCount(intra_threads));
        options.SetInterOpNumThreads(1);
        options.SetGraphOptimizationLevel(GraphOptimizationLevel::ORT_ENABLE_ALL);
        handle->session = std::make_unique<Ort::Session>(
            Environment(), model_path, options);
        WarmLocalCompletionSession(*handle->session, handle->index);
        return handle.release();
    } catch (const Ort::Exception& error) {
        SetError(error_text, error_capacity, ErrorText(error.what()));
    } catch (const std::exception& error) {
        SetError(error_text, error_capacity, ErrorText(error.what()));
    } catch (...) {
        SetError(error_text, error_capacity,
            "unknown local-completion initialization failure");
    }
    return nullptr;
}

extern "C" CASSOTIS_EXPORT int nc_lc_build_inputs_for_test(
    void* opaque_handle,
    const char* context,
    const char* query_syllables,
    const char* top1_text,
    const char* top1_path,
    const char* top2_text,
    const char* top2_path,
    int64_t* output_input_ids,
    int64_t* output_type_ids,
    int64_t* output_candidate_ids,
    float* output_candidate_features,
    int* output_candidate_count) {
    if (opaque_handle == nullptr || output_input_ids == nullptr ||
        output_type_ids == nullptr || output_candidate_ids == nullptr ||
        output_candidate_features == nullptr || output_candidate_count == nullptr) {
        return 0;
    }
    try {
        auto* handle = static_cast<LocalCompletionHandle*>(opaque_handle);
        std::array<int64_t, kLocalCompletionInputLength> input_ids{};
        std::array<int64_t, kLocalCompletionInputLength> type_ids{};
        std::array<int64_t,
            kLocalCompletionCandidateCount * kLocalCompletionPathWords> candidate_ids{};
        std::array<float,
            kLocalCompletionCandidateCount * kLocalCompletionFeatureCount> candidate_features{};
        std::vector<LocalRuntimeCandidate> candidates;
        if (!BuildLocalInputs(handle->index, context, query_syllables,
                top1_text, top1_path, top2_text, top2_path, input_ids, type_ids,
                candidate_ids, candidate_features, candidates)) {
            return 0;
        }
        std::copy(input_ids.begin(), input_ids.end(), output_input_ids);
        std::copy(type_ids.begin(), type_ids.end(), output_type_ids);
        std::copy(candidate_ids.begin(), candidate_ids.end(), output_candidate_ids);
        std::copy(candidate_features.begin(), candidate_features.end(),
            output_candidate_features);
        *output_candidate_count = static_cast<int>(candidates.size());
        return 1;
    } catch (...) {
        return 0;
    }
}

extern "C" CASSOTIS_EXPORT int nc_lc_run(
    void* opaque_handle,
    const char* context,
    const char* query_syllables,
    const char* top1_text,
    const char* top1_path,
    const char* top2_text,
    const char* top2_path,
    float minimum_confidence,
    char* output_suffix_text,
    int output_suffix_text_capacity,
    char* output_suffix_pinyin,
    int output_suffix_pinyin_capacity,
    char* output_suffix_path,
    int output_suffix_path_capacity,
    int* output_base_rank,
    float* output_confidence,
    char* error_text,
    int error_capacity) {
    SetError(error_text, error_capacity, "");
    SetOutput(output_suffix_text, output_suffix_text_capacity, "");
    SetOutput(output_suffix_pinyin, output_suffix_pinyin_capacity, "");
    SetOutput(output_suffix_path, output_suffix_path_capacity, "");
    if (output_base_rank != nullptr) {
        *output_base_rank = 0;
    }
    if (output_confidence != nullptr) {
        *output_confidence = 0.0f;
    }
    if (opaque_handle == nullptr || output_suffix_text == nullptr ||
        output_suffix_pinyin == nullptr || output_suffix_path == nullptr ||
        output_base_rank == nullptr || output_confidence == nullptr) {
        SetError(error_text, error_capacity,
            "invalid local-completion inference arguments");
        return 0;
    }
    try {
        FloatingPointMaskGuard floating_point_guard;
        auto* handle = static_cast<LocalCompletionHandle*>(opaque_handle);
        if (!handle->session) {
            SetError(error_text, error_capacity,
                "local-completion model session is unavailable");
            return 0;
        }
        std::array<int64_t, kLocalCompletionInputLength> input_ids{};
        std::array<int64_t, kLocalCompletionInputLength> type_ids{};
        std::array<int64_t,
            kLocalCompletionCandidateCount * kLocalCompletionPathWords> candidate_ids{};
        std::array<float,
            kLocalCompletionCandidateCount * kLocalCompletionFeatureCount> candidate_features{};
        std::vector<LocalRuntimeCandidate> candidates;
        if (!BuildLocalInputs(handle->index, context, query_syllables,
                top1_text, top1_path, top2_text, top2_path, input_ids, type_ids,
                candidate_ids, candidate_features, candidates)) {
            return 0;
        }

        const std::array<int64_t, 2> input_shape{
            1, static_cast<int64_t>(kLocalCompletionInputLength)};
        const std::array<int64_t, 3> candidate_shape{
            1, static_cast<int64_t>(kLocalCompletionCandidateCount),
            static_cast<int64_t>(kLocalCompletionPathWords)};
        const std::array<int64_t, 3> feature_shape{
            1, static_cast<int64_t>(kLocalCompletionCandidateCount),
            static_cast<int64_t>(kLocalCompletionFeatureCount)};
        auto memory = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
        std::array<Ort::Value, 4> inputs{
            Ort::Value::CreateTensor<int64_t>(memory, input_ids.data(), input_ids.size(),
                input_shape.data(), input_shape.size()),
            Ort::Value::CreateTensor<int64_t>(memory, type_ids.data(), type_ids.size(),
                input_shape.data(), input_shape.size()),
            Ort::Value::CreateTensor<int64_t>(memory, candidate_ids.data(),
                candidate_ids.size(), candidate_shape.data(), candidate_shape.size()),
            Ort::Value::CreateTensor<float>(memory, candidate_features.data(),
                candidate_features.size(), feature_shape.data(), feature_shape.size())};
        constexpr std::array<const char*, 4> input_names{
            "input_ids", "type_ids", "candidate_ids", "candidate_features"};
        constexpr std::array<const char*, 1> output_names{"scores"};
        auto outputs = handle->session->Run(Ort::RunOptions{nullptr},
            input_names.data(), inputs.data(), inputs.size(), output_names.data(),
            output_names.size());
        if (outputs.size() != 1 || !outputs[0].IsTensor() ||
            outputs[0].GetTensorTypeAndShapeInfo().GetElementCount() <
                kLocalCompletionOutputCount) {
            SetError(error_text, error_capacity,
                "local-completion model returned an invalid output tensor");
            return 0;
        }
        const float* scores = outputs[0].GetTensorData<float>();
        size_t best_index = 0;
        float best_score = -std::numeric_limits<float>::infinity();
        float second_score = scores[kLocalCompletionCandidateCount];
        for (size_t index_value = 0; index_value < candidates.size(); ++index_value) {
            const float score = scores[index_value];
            if (score > best_score) {
                second_score = std::max(second_score, best_score);
                best_score = score;
                best_index = index_value;
            } else {
                second_score = std::max(second_score, score);
            }
        }
        const float confidence = best_score - second_score;
        if (best_score <= scores[kLocalCompletionCandidateCount] ||
            confidence < minimum_confidence) {
            return 0;
        }
        const auto& selected = candidates[best_index];
        std::string suffix_text;
        std::string suffix_pinyin;
        std::string suffix_path;
        for (uint16_t word_id : selected.word_ids) {
            if (word_id == 0) {
                continue;
            }
            const std::string_view word_text = handle->index.WordText(word_id);
            const std::string_view word_pinyin = handle->index.WordPinyin(word_id);
            suffix_text.append(word_text);
            if (!suffix_pinyin.empty()) {
                suffix_pinyin.push_back('\3');
            }
            suffix_pinyin.append(word_pinyin);
            if (!suffix_path.empty()) {
                suffix_path.push_back('\3');
            }
            suffix_path.append(word_text);
        }
        if (suffix_text.empty() || suffix_pinyin.empty()) {
            return 0;
        }
        SetOutput(output_suffix_text, output_suffix_text_capacity, suffix_text);
        SetOutput(output_suffix_pinyin, output_suffix_pinyin_capacity,
            suffix_pinyin);
        SetOutput(output_suffix_path, output_suffix_path_capacity, suffix_path);
        *output_base_rank = selected.base_rank;
        *output_confidence = confidence;
        return 1;
    } catch (const Ort::Exception& error) {
        SetError(error_text, error_capacity, ErrorText(error.what()));
    } catch (const std::exception& error) {
        SetError(error_text, error_capacity, ErrorText(error.what()));
    } catch (...) {
        SetError(error_text, error_capacity,
            "unknown local-completion inference failure");
    }
    return 0;
}

extern "C" CASSOTIS_EXPORT void nc_lc_destroy(void* opaque_handle) {
    delete static_cast<LocalCompletionHandle*>(opaque_handle);
}
