#define NOMINMAX
#define ORT_API_MANUAL_INIT
#include <onnxruntime_cxx_api.h>

#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <cerrno>
#include <cstdio>
#include <fstream>
#include <limits>
#include <memory>
#include <mutex>
#include <map>
#include <set>
#include <chrono>
#include <condition_variable>
#include <string>
#include <string_view>
#include <tuple>
#include <thread>
#include <unordered_map>
#include <utility>
#include <vector>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include <filesystem>
#include <cstdlib>
#include <cfloat>

#if defined(__GLIBC__)
#include <malloc.h>
#endif

#if defined(__x86_64__) || defined(__i386__)
#include <xmmintrin.h>
#endif

#define CASSOTIS_EXPORT __attribute__((visibility("default")))


namespace {
std::mutex& InitializationMutex() {
    static std::mutex value;
    return value;
}

int BoundThreadCount(int requested_threads, unsigned int available) {
    const int requested = std::clamp(requested_threads, 1, 8);
    if (available == 0) {
        return requested;
    }
    return static_cast<int>(std::min(static_cast<unsigned int>(requested), available));
}

int EffectiveThreadCount(int requested_threads) {
    return BoundThreadCount(requested_threads, std::thread::hardware_concurrency());
}

void ConfigureSessionOptions(Ort::SessionOptions& options, int intra_threads) {
    options.SetExecutionMode(ExecutionMode::ORT_SEQUENTIAL);
    options.SetIntraOpNumThreads(EffectiveThreadCount(intra_threads));
    options.SetInterOpNumThreads(1);
    options.SetGraphOptimizationLevel(GraphOptimizationLevel::ORT_ENABLE_ALL);
    // All consumers now share one model/session. Reuse transient tensors rather
    // than allocating every layer again for each packed candidate batch.
    // Keep shape-pattern caching off: trie sizes change on every keystroke.
    options.DisableMemPattern();
    options.EnableCpuMemArena();
    options.AddConfigEntry("session.use_device_allocator_for_initializers", "1");
    // Avoid saturating U8S8 intermediates on x86 CPUs without VNNI. ORT
    // applies the exact U8U8 conversion only on affected CPUs; model files
    // and their quantization scales remain unchanged.
    options.AddConfigEntry("session.x64quantprecision", "1");
    // Return idle worker capacity to decoding after each infrequent inference.
    options.AddConfigEntry("session.force_spinning_stop", "1");
}

void ReleaseUnusedHeapPages() {
#if defined(__GLIBC__)
    // Model construction also releases large temporary graph buffers. Return
    // their unused pages after loading and destruction, never on each key.
    malloc_trim(0);
#endif
}

template <typename T>
bool ReadBinary(std::ifstream& stream, T& value) {
    return static_cast<bool>(stream.read(
        reinterpret_cast<char*>(&value), static_cast<std::streamsize>(sizeof(value))));
}

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
void AppendUtf8Codepoint(std::string& output, uint32_t codepoint) {
    if (codepoint <= 0x7f) {
        output.push_back(static_cast<char>(codepoint));
    } else if (codepoint <= 0x7ff) {
        output.push_back(static_cast<char>(0xc0 | (codepoint >> 6)));
        output.push_back(static_cast<char>(0x80 | (codepoint & 0x3f)));
    } else if (codepoint <= 0xffff) {
        output.push_back(static_cast<char>(0xe0 | (codepoint >> 12)));
        output.push_back(static_cast<char>(0x80 | ((codepoint >> 6) & 0x3f)));
        output.push_back(static_cast<char>(0x80 | (codepoint & 0x3f)));
    } else {
        output.push_back(static_cast<char>(0xf0 | (codepoint >> 18)));
        output.push_back(static_cast<char>(0x80 | ((codepoint >> 12) & 0x3f)));
        output.push_back(static_cast<char>(0x80 | ((codepoint >> 6) & 0x3f)));
        output.push_back(static_cast<char>(0x80 | (codepoint & 0x3f)));
    }
}


}  // namespace

#include "nc_utf16_runtime.inc"
#include "nc_trie_attention.inc"
#include "nc_char_lm_ort.inc"

// glibc 2.43 changed sqrtf's default symbol for legacy error handling.
// Keep the established ABI without changing arithmetic or enabling fast-math.
#if defined(__GLIBC__) && defined(__x86_64__)
__asm__(".symver sqrtf,sqrtf@GLIBC_2.2.5");
#elif defined(__GLIBC__) && defined(__aarch64__)
__asm__(".symver sqrtf,sqrtf@GLIBC_2.17");
#endif
