// A 64-wide attention head with the same floating-point evaluation order as
// Scores64/Normalize/Combine in nc_trie_attention_avx2.cpp. Small differences
// here can cross the next layer's fixed INT8 rounding boundary.
#pragma once
#include <algorithm>
#include <arm_neon.h>
#include <cstddef>
#include <cstdint>
#include <limits>

namespace nc_trie_attention::arm64 {

inline float Sum8(float32x4_t lo, float32x4_t hi) {
    const auto four = vaddq_f32(lo, hi);
    const auto two = vadd_f32(vget_low_f32(four), vget_high_f32(four));
    return vget_lane_f32(vpadd_f32(two, two), 0);
}

inline float32x4_t ExpNonPositive(float32x4_t x) {
    x = vmaxq_f32(x, vdupq_n_f32(-87.33654f));
    const auto n = vrndnq_f32(vmulq_n_f32(x, 1.44269504088896341f));
    auto r = vfmsq_n_f32(x, n, 0.693359375f);
    r = vfmsq_n_f32(r, n, -2.12194440e-4f);
    auto p = vdupq_n_f32(1.9875691500e-4f);
    p = vfmaq_f32(vdupq_n_f32(1.3981999507e-3f), p, r);
    p = vfmaq_f32(vdupq_n_f32(8.3334519073e-3f), p, r);
    p = vfmaq_f32(vdupq_n_f32(4.1665795894e-2f), p, r);
    p = vfmaq_f32(vdupq_n_f32(1.6666665459e-1f), p, r);
    p = vfmaq_f32(vdupq_n_f32(5.0000001201e-1f), p, r);
    const auto y = vaddq_f32(vfmaq_f32(r, p, vmulq_f32(r, r)), vdupq_n_f32(1.0f));
    const auto power = vshlq_n_s32(vaddq_s32(vcvtq_s32_f32(n), vdupq_n_s32(127)), 23);
    return vmulq_f32(y, vreinterpretq_f32_s32(power));
}

inline float32x4_t Dot64Half(const float* q, const float* k) {
    const auto pair = [&](unsigned d) {
        return vfmaq_f32(vmulq_f32(vld1q_f32(q + d), vld1q_f32(k + d)),
                         vld1q_f32(q + d + 32), vld1q_f32(k + d + 32));
    };
    return vaddq_f32(vaddq_f32(pair(0), pair(8)), vaddq_f32(pair(16), pair(24)));
}

// As in the AVX2 path, weights has space for the longest list rounded up to eight.
inline void Attend64(const float* query, size_t query_stride, const float* past_keys,
    const float* past_values, size_t past_count, const float* new_keys, const float* new_values,
    const uint32_t* seen, const size_t* starts, size_t first, size_t last,
    float scale, float* weights, float* out, size_t out_stride) {
    constexpr size_t dim = 64;
    const auto at = [past_count](const float* past, const float* fresh, size_t index) {
        return index < past_count ? past + index * dim : fresh + (index - past_count) * dim;
    };
    for (size_t row = first; row < last; ++row) {
        const auto count = starts[row + 1] - starts[row];
        const auto list = seen + starts[row];
        const auto q = query + row * query_stride;
        auto result = out + row * out_stride;
        if (!count) {
            std::fill_n(result, dim, 0.0f);
            continue;
        }
        float best = -std::numeric_limits<float>::max();
        for (size_t i = 0; i < count; ++i) {
            const auto key = at(past_keys, new_keys, list[i]);
            const float score = Sum8(Dot64Half(q, key), Dot64Half(q + 4, key + 4)) * scale;
            weights[i] = score;
            best = std::max(best, score);
        }
        const size_t padded = (count + 7) & ~size_t(7);
        std::fill(weights + count, weights + padded, best);
        const auto shift = vdupq_n_f32(best);
        for (size_t i = 0; i < padded; i += 4)
            vst1q_f32(weights + i, ExpNonPositive(vsubq_f32(vld1q_f32(weights + i), shift)));
        std::fill(weights + count, weights + padded, 0.0f);
        auto lo = vdupq_n_f32(0.0f), hi = lo;
        for (size_t i = 0; i < padded; i += 8) {
            lo = vaddq_f32(lo, vld1q_f32(weights + i));
            hi = vaddq_f32(hi, vld1q_f32(weights + i + 4));
        }
        const float inverse = 1.0f / Sum8(lo, hi);
        float32x4_t accum[dim / 4] = {};
        for (size_t i = 0; i < count; ++i) {
            const float w = weights[i] * inverse;
            const float* v = at(past_values, new_values, list[i]);
            for (size_t block = 0; block < dim / 4; ++block)
                accum[block] = vfmaq_n_f32(accum[block], vld1q_f32(v + 4 * block), w);
        }
        for (size_t block = 0; block < dim / 4; ++block)
            vst1q_f32(result + 4 * block, accum[block]);
    }
}

}  // namespace nc_trie_attention::arm64
