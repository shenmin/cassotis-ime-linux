// FastGelu rounding compatibility for the shared character model.
// The polynomial/constants are derived from ONNX Runtime v1.20.1:
// Copyright (c) Microsoft Corporation. Licensed under the MIT License.
// See third_party/onnxruntime/LICENSE.
#pragma once

#include <onnxruntime_cxx_api.h>
#include <algorithm>
#include <cmath>
#include <cstddef>
#include <exception>

#if defined(__aarch64__)
#include <arm_neon.h>
#endif

namespace cassotis {

// Keep the input polynomial unfused, but fuse the tanh polynomial as in the
// x86 FMA3 kernel. Tiny changes here can cross later INT8 rounding boundaries.
#if defined(__GNUC__) && !defined(__clang__)
__attribute__((optimize("fp-contract=off")))
#endif
inline void FastGeluCompatible(const float* input, float* output, size_t size) {
#if defined(__clang__)
#pragma clang fp contract(off)
#endif
    size_t i = 0;
#if defined(__aarch64__)
    for (; i + 4 <= size; i += 4) {
        const auto x = vld1q_f32(input + i);
        auto t = vmulq_n_f32(x, 0.035677408136300125f);
        t = vmulq_f32(t, x);
        t = vaddq_f32(t, vdupq_n_f32(0.7978845608028654f));
        t = vmulq_f32(t, x);
        t = vmaxq_f32(vdupq_n_f32(-9.f), t);
        t = vminq_f32(vdupq_n_f32(9.f), t);
        const auto s = vmulq_f32(t, t);
        auto p = vfmaq_n_f32(vdupq_n_f32(2.00018790482477e-13f), s, -2.76076847742355e-16f);
        p = vfmaq_f32(vdupq_n_f32(-8.60467152213735e-11f), p, s);
        p = vfmaq_f32(vdupq_n_f32(5.12229709037114e-08f), p, s);
        p = vfmaq_f32(vdupq_n_f32(1.48572235717979e-05f), p, s);
        p = vfmaq_f32(vdupq_n_f32(6.37261928875436e-04f), p, s);
        p = vfmaq_f32(vdupq_n_f32(4.89352455891786e-03f), p, s);
        p = vmulq_f32(p, t);
        auto q = vfmaq_n_f32(vdupq_n_f32(1.18534705686654e-04f), s, 1.19825839466702e-06f);
        q = vfmaq_f32(vdupq_n_f32(2.26843463243900e-03f), q, s);
        q = vfmaq_f32(vdupq_n_f32(4.89352518554385e-03f), q, s);
        const auto result = vmulq_f32(vmulq_n_f32(x, .5f),
            vaddq_f32(vdivq_f32(p, q), vdupq_n_f32(1.f)));
        vst1q_f32(output + i, result);
    }
#endif
    for (; i < size; ++i) {
        const float x = input[i];
        float t = x * ((0.035677408136300125f * x) * x + 0.7978845608028654f);
        t = std::min(std::max(t, -9.f), 9.f);
        const float s = t * t;
        float p = std::fma(s, -2.76076847742355e-16f, 2.00018790482477e-13f);
        p = std::fma(p, s, -8.60467152213735e-11f);
        p = std::fma(p, s, 5.12229709037114e-08f);
        p = std::fma(p, s, 1.48572235717979e-05f);
        p = std::fma(p, s, 6.37261928875436e-04f);
        p = std::fma(p, s, 4.89352455891786e-03f);
        p *= t;
        float q = std::fma(s, 1.19825839466702e-06f, 1.18534705686654e-04f);
        q = std::fma(q, s, 2.26843463243900e-03f);
        q = std::fma(q, s, 4.89352518554385e-03f);
        output[i] = (.5f * x) * (p / q + 1.f);
    }
}

struct FastGeluCompatibleKernel {
    OrtStatusPtr ComputeV2(OrtKernelContext* raw) noexcept {
        try {
            Ort::KernelContext context(raw);
            const auto input = context.GetInput(0);
            const auto info = input.GetTensorTypeAndShapeInfo();
            const auto shape = info.GetShape();
            auto output = context.GetOutput(0, shape);
            FastGeluCompatible(input.GetTensorData<float>(), output.GetTensorMutableData<float>(),
                info.GetElementCount());
            return nullptr;
        } catch (const Ort::Exception& error) {
            return Ort::GetApi().CreateStatus(error.GetOrtErrorCode(), error.what());
        } catch (const std::exception& error) {
            return Ort::GetApi().CreateStatus(ORT_FAIL, error.what());
        } catch (...) {
            return Ort::GetApi().CreateStatus(ORT_FAIL, "FastGelu compatibility kernel failed");
        }
    }
};

struct FastGeluCompatibleOp : Ort::CustomOpBase<FastGeluCompatibleOp, FastGeluCompatibleKernel, true> {
    OrtStatusPtr CreateKernelV2(const OrtApi& api, const OrtKernelInfo*, void** kernel) const noexcept {
        *kernel = nullptr;
        try {
            *kernel = new FastGeluCompatibleKernel;
            return nullptr;
        } catch (const std::exception& error) {
            return api.CreateStatus(ORT_FAIL, error.what());
        } catch (...) {
            return api.CreateStatus(ORT_FAIL, "FastGelu compatibility kernel allocation failed");
        }
    }
    const char* GetName() const { return "FastGelu"; }
    size_t GetInputTypeCount() const { return 1; }
    size_t GetOutputTypeCount() const { return 1; }
    ONNXTensorElementDataType GetInputType(size_t) const { return ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT; }
    ONNXTensorElementDataType GetOutputType(size_t) const { return ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT; }
};

inline Ort::CustomOpDomain& CharacterMathDomain() {
    static FastGeluCompatibleOp operation;
    static Ort::CustomOpDomain domain = [] {
        Ort::CustomOpDomain result("com.microsoft");
        result.Add(&operation);
        return result;
    }();
    return domain;
}

} // namespace cassotis
