// The character model normalizes the last dimension with one scale per channel.
// Keep the x86 runtime's two roundings: a fused square-and-sum can move a
// normalized activation across the following INT8 quantization boundary.
#pragma once
#include <onnxruntime_cxx_api.h>
#include <cmath>
#include <cstddef>
#include <stdexcept>

namespace cassotis {

#if defined(__GNUC__) && !defined(__clang__)
__attribute__((optimize("fp-contract=off")))
#endif
inline void NormalizeCharacterRow(const float* x, const float* scale, const float* bias,
    size_t width, float epsilon, float* output, float* mean_output, float* inverse_output) {
#if defined(__clang__)
#pragma clang fp contract(off)
#endif
    float sum = 0.0f, squares = 0.0f;
    for (size_t i = 0; i < width; ++i) {
        sum += x[i];
        squares += x[i] * x[i];
    }
    const auto n = static_cast<float>(width);
    const float mean = sum / n;
    const float deviation = std::sqrt(squares / n - mean * mean + epsilon);
    if (mean_output) *mean_output = mean;
    if (inverse_output) *inverse_output = 1.0f / deviation;
    for (size_t i = 0; i < width; ++i) {
        const float scaled = ((x[i] - mean) / deviation) * scale[i];
        output[i] = bias ? scaled + bias[i] : scaled;
    }
}

class CharacterLayerNormKernel {
    float epsilon = 1.0e-5f;
    int64_t axis = -1;
    struct Rows {
        const float *x, *scale, *bias;
        float *output, *means, *inverses;
        size_t width;
        float epsilon;
    };
    static void Normalize(void* raw, size_t row) {
        const auto& r = *static_cast<const Rows*>(raw);
        const size_t offset = row * r.width;
        NormalizeCharacterRow(r.x + offset, r.scale, r.bias, r.width, r.epsilon, r.output + offset,
            r.means ? r.means + row : nullptr, r.inverses ? r.inverses + row : nullptr);
    }

public:
    explicit CharacterLayerNormKernel(const OrtKernelInfo* info) {
        // The attributes are optional in ONNX. Keep their defaults when omitted.
        float e; int64_t a;
        Ort::Status epsilon_status(Ort::GetApi().KernelInfoGetAttribute_float(info, "epsilon", &e));
        Ort::Status axis_status(Ort::GetApi().KernelInfoGetAttribute_int64(info, "axis", &a));
        if (epsilon_status.IsOK()) epsilon = e;
        if (axis_status.IsOK()) axis = a;
        if (!(epsilon >= 0.0f)) throw std::invalid_argument("Invalid character layer normalization epsilon");
    }

    OrtStatusPtr ComputeV2(OrtKernelContext* raw) noexcept {
        try {
            Ort::KernelContext ctx(raw);
            const auto x = ctx.GetInput(0), scale = ctx.GetInput(1);
            const auto info = x.GetTensorTypeAndShapeInfo();
            const auto shape = info.GetShape();
            if (shape.empty() || shape.back() <= 0 ||
                (axis != -1 && axis != static_cast<int64_t>(shape.size() - 1)))
                throw std::invalid_argument("Character layer normalization requires a nonempty last axis");
            const size_t width = static_cast<size_t>(shape.back());
            const auto check_channels = [width](const Ort::ConstValue& v) {
                const auto dims = v.GetTensorTypeAndShapeInfo().GetShape();
                if (dims.size() != 1 || dims.front() != static_cast<int64_t>(width))
                    throw std::invalid_argument("Character layer normalization requires one value per channel");
            };
            check_channels(scale);
            const float* bias = nullptr;
            if (ctx.GetInputCount() > 2) {
                const auto b = ctx.GetInput(2);
                if (b) { check_channels(b); bias = b.GetTensorData<float>(); }
            }
            auto stat_shape = shape;
            stat_shape.back() = 1;
            const auto stat_output = [&](size_t i) -> float* {
                if (i >= ctx.GetOutputCount()) return nullptr;
                auto v = ctx.GetOutput(i, stat_shape);
                return v ? v.GetTensorMutableData<float>() : nullptr;
            };
            auto y = ctx.GetOutput(0, shape);
            Rows rows{x.GetTensorData<float>(), scale.GetTensorData<float>(), bias,
                y.GetTensorMutableData<float>(), stat_output(1), stat_output(2), width, epsilon};
            const size_t count = info.GetElementCount() / width;
            if (info.GetElementCount() < 16384) {
                for (size_t i = 0; i < count; ++i) Normalize(&rows, i);
            } else {
                ctx.ParallelFor(Normalize, count, 0, &rows);
            }
            return nullptr;
        } catch (const Ort::Exception& e) {
            return Ort::Status(e).release();
        } catch (const std::exception& e) {
            return Ort::Status(e.what(), ORT_FAIL).release();
        }
    }
};

struct CharacterLayerNormOp : Ort::CustomOpBase<CharacterLayerNormOp, CharacterLayerNormKernel, true> {
    CharacterLayerNormOp() { start_ver_ = 17; }
    const char* GetName() const { return "LayerNormalization"; }
    size_t GetInputTypeCount() const { return 3; }
    size_t GetOutputTypeCount() const { return 3; }
    ONNXTensorElementDataType GetInputType(size_t) const { return ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT; }
    ONNXTensorElementDataType GetOutputType(size_t) const { return ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT; }
    OrtCustomOpInputOutputCharacteristic GetInputCharacteristic(size_t i) const {
        return i == 2 ? INPUT_OUTPUT_OPTIONAL : INPUT_OUTPUT_REQUIRED;
    }
    OrtCustomOpInputOutputCharacteristic GetOutputCharacteristic(size_t i) const {
        return i ? INPUT_OUTPUT_OPTIONAL : INPUT_OUTPUT_REQUIRED;
    }
    OrtStatusPtr CreateKernelV2(const OrtApi&, const OrtKernelInfo* info, void** kernel) const noexcept {
        try {
            *kernel = new CharacterLayerNormKernel(info);
            return nullptr;
        } catch (const Ort::Exception& e) {
            return Ort::Status(e).release();
        } catch (const std::exception& e) {
            return Ort::Status(e.what(), ORT_FAIL).release();
        }
    }
};

// Register only on the ARM character-model session, never process-wide.
inline Ort::CustomOpDomain& CharacterNormDomain() {
    static const CharacterLayerNormOp op;
    static Ort::CustomOpDomain domain = [] {
        Ort::CustomOpDomain d("");
        d.Add(&op);
        return d;
    }();
    return domain;
}

}  // namespace cassotis
