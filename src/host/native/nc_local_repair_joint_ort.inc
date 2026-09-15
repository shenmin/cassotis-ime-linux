#include "nc_onnx_model_compat.inc"

// Optional final repair chooser. It shares the production encoder and context cache.
namespace {
struct LocalRepairJoint {
    Ort::Session& query;
    std::vector<Ort::Value>& memory;
    Ort::Session head;
    std::unique_ptr<Ort::Session> audit;
    Ort::MemoryInfo cpu{Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault)};
    std::array<float, 40 * 768> hidden{};
    std::array<int64_t, 40> draft{}, pinyin{};
    std::array<float, 40 * 99> logits{};
    std::array<int64_t, 40 * 99> readings{};
    std::array<LocalRepairEncoding, 2> cache;
    int next{}, count{};
    uint64_t audit_cache_hits{}, audit_query_runs{};
    bool ready = false;
    bool trimmed = true;
    LocalRepairJoint(LocalRepairHandle& owner, const char* head_path,
        const char* audit_path) : query(*owner.query_session), memory(owner.memory),
        head(make_session(head_path)) {
        audit = std::make_unique<Ort::Session>(make_session(audit_path));
        if (query.GetOutputCount() != 6 || head.GetInputCount() != 6 ||
            audit->GetInputCount() != 4) throw std::runtime_error("invalid joint repair graph ABI");
        warm_heads();
    }
    static Ort::SessionOptions make_options() {
        Ort::SessionOptions options;
        // Joint heads need the same non-VNNI precision and bounded allocation
        // policy as the shared encoder; default U8S8 kernels can saturate.
        ConfigureSessionOptions(options, 1);
        // ORT 1.20's signed-to-unsigned rewrite requires distinct constants.
        options.AddConfigEntry("optimization.disable_specified_optimizers", "ConstantSharing");
        options.AddConfigEntry("session.intra_op.allow_spinning", "0");
        options.AddConfigEntry("session.inter_op.allow_spinning", "0");
        return options;
    }
    static Ort::Session make_session(const char* path) {
        const auto model = OnnxHeadCompat::load(path);
        return Ort::Session(Environment(), model.data(), model.size(), make_options());
    }
    void warm_heads() {
        // Allocation/kernel warmup runs on the host loader, not the first key.
        // Synthetic tensors are discarded and never enter a candidate cache.
        std::vector<float> h(6 * 768), ends(2 * 6), features(2 * 16);
        std::vector<int64_t> d(6, 4), candidates(2 * 6, 4);
        std::array<bool, 2> valid{true, true};
        int64_t hs[]{1, 6, 768}, ds[]{1, 6}, cs[]{1, 2, 6}, fs[]{1, 2, 16}, vs[]{1, 2};
        std::vector<Ort::Value> inputs;
        inputs.emplace_back(Ort::Value::CreateTensor<float>(cpu, h.data(), h.size(), hs, 3));
        inputs.emplace_back(Ort::Value::CreateTensor<int64_t>(cpu, d.data(), d.size(), ds, 2));
        inputs.emplace_back(Ort::Value::CreateTensor<int64_t>(cpu, candidates.data(), candidates.size(), cs, 3));
        inputs.emplace_back(Ort::Value::CreateTensor<float>(cpu, ends.data(), ends.size(), cs, 3));
        inputs.emplace_back(Ort::Value::CreateTensor<float>(cpu, features.data(), features.size(), fs, 3));
        inputs.emplace_back(Ort::Value::CreateTensor<bool>(cpu, valid.data(), valid.size(), vs, 2));
        const char* names[]{"hidden", "draft", "candidate", "ends", "features", "valid"};
        const char* outputs[]{"scores"};
        head.Run(Ort::RunOptions{nullptr}, names, inputs.data(), inputs.size(), outputs, 1);
        inputs.clear();
        std::vector<float> states(2 * 40 * 768), evidence(2 * 40 * 8), numeric(2 * 8);
        std::array<bool, 40> present{};
        std::fill_n(present.begin(), 6, true);
        int64_t ss[]{1, 2, 40, 768}, es[]{1, 2, 40, 8}, ns[]{1, 2, 8}, ps[]{1, 40};
        inputs.emplace_back(Ort::Value::CreateTensor<float>(cpu, states.data(), states.size(), ss, 4));
        inputs.emplace_back(Ort::Value::CreateTensor<float>(cpu, evidence.data(), evidence.size(), es, 4));
        inputs.emplace_back(Ort::Value::CreateTensor<float>(cpu, numeric.data(), numeric.size(), ns, 3));
        inputs.emplace_back(Ort::Value::CreateTensor<bool>(cpu, present.data(), present.size(), ps, 2));
        const char* audit_names[]{"states", "evidence", "numeric", "present"};
        const char* audit_outputs[]{"decision"};
        audit->Run(Ort::RunOptions{nullptr}, audit_names, inputs.data(), inputs.size(), audit_outputs, 1);
    }
    void clear() {
        ready = false;
        next = 0;
        for (auto& item : cache) item = LocalRepairEncoding{};
        hidden.fill(0); draft.fill(0); pinyin.fill(0); logits.fill(0); readings.fill(0);
    }
    const LocalRepairEncoding* find(const int64_t* text, const int64_t* py, int n) const {
        for (const auto& item : cache) if (item.matches(text, py, n)) return &item;
        return nullptr;
    }
    void remember(const int64_t* text, const int64_t* py, int n,
        const std::vector<Ort::Value>& results) {
        if (n < 6 || n > 40 || results.size() != 6) return;
        if (results[3].GetTensorTypeAndShapeInfo().GetElementCount() != size_t(n * 768) ||
            results[4].GetTensorTypeAndShapeInfo().GetElementCount() != size_t(n * 99) ||
            results[5].GetTensorTypeAndShapeInfo().GetElementCount() != size_t(n * 99))
            throw std::runtime_error("invalid shared repair encoding");
        auto& item = cache[next];
        next = (next + 1) % 2;
        item = LocalRepairEncoding{};
        item.count = n;
        std::copy_n(text, n, item.draft.begin());
        std::copy_n(py, n, item.pinyin.begin());
        const auto* states = results[3].GetTensorData<float>();
        // The chooser uses FP16-rounded states; bilateral re-encoding used FP32.
        // Preserve both so a cache hit cannot change the audit's INT8 inputs.
        std::copy_n(states, n * 768, item.raw_hidden.begin());
        for (int i = 0; i < n * 768; ++i)
            item.hidden[i] = Ort::Float16_t(states[i]).ToFloat();
        std::copy_n(results[4].GetTensorData<float>(), n * 99, item.logits.begin());
        std::copy_n(results[5].GetTensorData<int64_t>(), n * 99, item.readings.begin());
    }
};
}

extern "C" CASSOTIS_EXPORT int cassotis_lr_joint_attach(
    void* opaque, const char* head, const char* audit,
    char* error_text, int error_capacity) {
    SetError(error_text, error_capacity, "");
    if (!opaque || !head || !audit) return 0;
    try {
        FloatingPointMaskGuard floating_point_guard;
        const std::lock_guard<std::mutex> init(InitializationMutex());
        auto& owner = *static_cast<LocalRepairHandle*>(opaque);
        const std::lock_guard<std::mutex> guard(owner.lock);
        owner.joint = std::make_unique<LocalRepairJoint>(owner, head, audit);
        return 1;
    } catch (const std::exception& error) {
        SetError(error_text, error_capacity, error.what());
    } catch (...) {
        SetError(error_text, error_capacity, "joint repair initialization failed");
    }
    return 0;
}

extern "C" CASSOTIS_EXPORT int cassotis_lr_joint_query(
    void* opaque, const int64_t* draft, const int64_t* pinyin, int count,
    float* logits, int64_t* readings) {
    if (!opaque || !draft || !pinyin || !logits || !readings || count < 6 || count > 40) return 0;
    try {
        auto& owner = *static_cast<LocalRepairHandle*>(opaque);
        const std::lock_guard<std::mutex> guard(owner.lock);
        if (!owner.joint || owner.context_ids != std::vector<int64_t>{3, 2}) return 0;
        auto& p = *owner.joint;
        p.ready = false;
        if (const auto* cached = p.find(draft, pinyin, count)) {
            const auto& item = *cached;
            p.hidden = item.hidden; p.draft = item.draft; p.pinyin = item.pinyin;
            p.logits = item.logits; p.readings = item.readings; p.count = count;
            std::copy_n(p.logits.data(), count * 99, logits);
            std::copy_n(p.readings.data(), count * 99, readings);
            p.ready = true;
            return 1;
        }
    } catch (...) {}
    return 0;
}

extern "C" CASSOTIS_EXPORT int cassotis_lr_joint_score(void* handle, const int64_t* candidate, const float* ends,
    const float* features, const uint8_t* valid, float* scores) {
    try {
        if (!handle) return 0;
        FloatingPointMaskGuard floating_point_guard;
        auto& owner = *static_cast<LocalRepairHandle*>(handle);
        const std::lock_guard<std::mutex> guard(owner.lock);
        if (!owner.joint) return 0;
        auto& p = *owner.joint;
        if (!p.ready || !candidate || !ends || !features || !valid || !scores) return 0;
        const int n = p.trimmed ? p.count : 40;
        int k = 9;
        if (p.trimmed) { k = 0; while (k < 9 && valid[k]) ++k; }
        if (!k) return 0;
        std::vector<int64_t> packed_candidates(k * n);
        std::vector<float> packed_ends(k * n);
        for (int i = 0; i < k; ++i) {
            std::copy_n(candidate + i * 40, n, packed_candidates.data() + i * n);
            std::copy_n(ends + i * 40, n, packed_ends.data() + i * n);
        }
        int64_t hidden_shape[] = {1, n, 768}, draft_shape[] = {1, n};
        int64_t candidate_shape[] = {1, k, n}, feature_shape[] = {1, k, 16}, valid_shape[] = {1, k};
        std::vector<Ort::Value> input;
        input.emplace_back(Ort::Value::CreateTensor<float>(p.cpu, p.hidden.data(), n * 768, hidden_shape, 3));
        input.emplace_back(Ort::Value::CreateTensor<int64_t>(p.cpu, p.draft.data(), n, draft_shape, 2));
        input.emplace_back(Ort::Value::CreateTensor<int64_t>(p.cpu, packed_candidates.data(), k * n, candidate_shape, 3));
        input.emplace_back(Ort::Value::CreateTensor<float>(p.cpu, packed_ends.data(), k * n, candidate_shape, 3));
        input.emplace_back(Ort::Value::CreateTensor<float>(p.cpu, const_cast<float*>(features), k * 16, feature_shape, 3));
        input.emplace_back(Ort::Value::CreateTensor<bool>(p.cpu, reinterpret_cast<bool*>(const_cast<uint8_t*>(valid)), k, valid_shape, 2));
        const char* in[] = {"hidden", "draft", "candidate", "ends", "features", "valid"};
        const char* out[] = {"scores"};
        auto result = p.head.Run(Ort::RunOptions{nullptr}, in, input.data(), input.size(), out, 1);
        if (result[0].GetTensorTypeAndShapeInfo().GetElementCount() != size_t(k)) return 0;
        const auto* values = result[0].GetTensorData<float>();
        std::fill(scores, scores + 9, -10000.0f);
        for (int i = 0; i < k; ++i) {
            if (!std::isfinite(values[i])) return 0;
            scores[i] = values[i];
        }
        return 1;
    } catch (...) { return 0; }
}

extern "C" CASSOTIS_EXPORT int cassotis_lr_joint_audit(void* handle, const int64_t* a, const int64_t* b,
    const int64_t* pinyin, int count, const float* a_ends, const float* b_ends,
    const float* a_features, const float* b_features, float a_score, float b_score,
    float* decision) {
    try {
        if (!handle) return 0;
        FloatingPointMaskGuard floating_point_guard;
        auto& owner = *static_cast<LocalRepairHandle*>(handle);
        const std::lock_guard<std::mutex> guard(owner.lock);
        if (!owner.joint) return 0;
        auto& p = *owner.joint;
        if (!a || !b || !pinyin || !a_ends || !b_ends || !a_features || !b_features || !decision) return 0;
        if (!p.audit || !p.ready || count != p.count || count < 6 || count > 40 ||
            !std::equal(pinyin, pinyin + count, p.pinyin.begin()) ||
            std::equal(a, a + count, b)) return 0;
        std::vector<float> states(2 * 40 * 768);
        std::array<float, 2 * 40 * 8> evidence{};
        std::array<float, 2 * 8> numeric{};
        std::array<bool, 40> present{};
        float logprob[2][2][40]{};
        const int64_t* texts[] = {a, b};
        const float* ends[] = {a_ends, b_ends};
        const float* features[] = {a_features, b_features};
        const float scores[] = {a_score, b_score};
        for (int side = 0; side < 2; ++side) {
            std::vector<Ort::Value> result;
            const float* logits = p.logits.data();
            const int64_t* readings = p.readings.data();
            const float* hidden = p.hidden.data();
            const bool original = std::equal(texts[side], texts[side] + count, p.draft.begin());
            const auto* cached = original ? nullptr : p.find(texts[side], pinyin, count);
            if (cached) {
                hidden = cached->raw_hidden.data();
                logits = cached->logits.data();
                readings = cached->readings.data();
                ++p.audit_cache_hits;
            } else if (!original) {
                int64_t shape[] = {1, count};
                std::vector<Ort::Value> inputs;
                inputs.emplace_back(Ort::Value::CreateTensor<int64_t>(p.cpu, const_cast<int64_t*>(texts[side]), count, shape, 2));
                inputs.emplace_back(Ort::Value::CreateTensor<int64_t>(p.cpu, const_cast<int64_t*>(pinyin), count, shape, 2));
                for (auto& value : p.memory) {
                    const auto info = value.GetTensorTypeAndShapeInfo();
                    const auto dims = info.GetShape();
                    inputs.emplace_back(Ort::Value::CreateTensor(p.cpu, value.GetTensorMutableRawData(),
                        info.GetElementCount() * (info.GetElementType() == ONNX_TENSOR_ELEMENT_DATA_TYPE_BOOL ? 1 : 4),
                        dims.data(), dims.size(), info.GetElementType()));
                }
                const char* in[] = {"draft_ids", "pinyin_ids", "keys", "values", "context_mask"};
                const char* out[] = {"joint_hidden", "joint_scores", "joint_reading_ids"};
                result = p.query.Run(Ort::RunOptions{nullptr}, in, inputs.data(), inputs.size(), out, 3);
                ++p.audit_query_runs;
                if (result[0].GetTensorTypeAndShapeInfo().GetElementCount() != size_t(count * 768) ||
                    result[1].GetTensorTypeAndShapeInfo().GetElementCount() != size_t(count * 99) ||
                    result[2].GetTensorTypeAndShapeInfo().GetElementCount() != size_t(count * 99)) return 0;
                hidden = result[0].GetTensorData<float>();
                logits = result[1].GetTensorData<float>();
                readings = result[2].GetTensorData<int64_t>();
            }
            std::copy_n(hidden, count * 768, states.data() + side * 40 * 768);
            for (int i = 0; i < count; ++i) {
                const auto* values = logits + i * 99;
                // FP64 intermediates avoid library-specific FP32 reduction jitter
                // crossing an INT8 activation boundary. The model still gets FP32.
                const double peak = *std::max_element(values, values + 99);
                double sum = 0;
                int columns[] = {-1, -1};
                for (int k = 0; k < 99; ++k) {
                    if (!std::isfinite(values[k])) return 0;
                    sum += std::exp(double(values[k]) - peak);
                    for (int other = 0; other < 2; ++other) {
                        if (readings[i * 99 + k] == texts[other][i]) {
                            if (columns[other] != -1) return 0;
                            columns[other] = k;
                        }
                    }
                }
                if (!(sum > 0) || columns[0] < 0 || columns[1] < 0) return 0;
                for (int other = 0; other < 2; ++other)
                    logprob[side][other][i] = float(double(values[columns[other]]) - peak - std::log(sum));
            }
            const int selected_features[] = {7, 8, 9, 10, 11, 2};
            for (int k = 0; k < 6; ++k) numeric[side * 8 + k] = features[side][selected_features[k]];
            numeric[side * 8 + 6] = scores[side];
            numeric[side * 8 + 7] = original ? 1.0f : 0.0f;
        }
        for (int side = 0; side < 2; ++side) {
            const int other = 1 - side;
            for (int i = 0; i < count; ++i) {
                present[i] = true;
                float* values = evidence.data() + (side * 40 + i) * 8;
                values[0] = logprob[side][side][i];
                values[1] = logprob[side][other][i];
                values[2] = logprob[other][side][i];
                values[3] = logprob[other][other][i];
                values[4] = ends[side][i];
                values[5] = ends[other][i];
                values[6] = a[i] != b[i] ? 1.0f : 0.0f;
                for (int k = std::max(0, i - 3); k < std::min(count, i + 4); ++k)
                    if (a[k] != b[k]) values[7] = 1.0f;
            }
        }
        int64_t state_shape[] = {1, 2, 40, 768}, evidence_shape[] = {1, 2, 40, 8};
        int64_t numeric_shape[] = {1, 2, 8}, present_shape[] = {1, 40};
        std::vector<Ort::Value> inputs;
        inputs.emplace_back(Ort::Value::CreateTensor<float>(p.cpu, states.data(), states.size(), state_shape, 4));
        inputs.emplace_back(Ort::Value::CreateTensor<float>(p.cpu, evidence.data(), evidence.size(), evidence_shape, 4));
        inputs.emplace_back(Ort::Value::CreateTensor<float>(p.cpu, numeric.data(), numeric.size(), numeric_shape, 3));
        inputs.emplace_back(Ort::Value::CreateTensor<bool>(p.cpu, present.data(), present.size(), present_shape, 2));
        const char* in[] = {"states", "evidence", "numeric", "present"};
        const char* out[] = {"decision"};
        auto result = p.audit->Run(Ort::RunOptions{nullptr}, in, inputs.data(), inputs.size(), out, 1);
        if (result[0].GetTensorTypeAndShapeInfo().GetElementCount() != 2) return 0;
        const auto* values = result[0].GetTensorData<float>();
        if (!std::isfinite(values[0]) || !std::isfinite(values[1])) return 0;
        std::copy_n(values, 2, decision);
        return 1;
    } catch (...) { return 0; }
}

extern "C" CASSOTIS_EXPORT int cassotis_lr_joint_profile(
    void* opaque, uint64_t* cache_hits, uint64_t* query_runs) {
    if (!opaque || !cache_hits || !query_runs) return 0;
    try {
        auto& owner = *static_cast<LocalRepairHandle*>(opaque);
        const std::lock_guard<std::mutex> guard(owner.lock);
        if (!owner.joint) return 0;
        *cache_hits = owner.joint->audit_cache_hits;
        *query_runs = owner.joint->audit_query_runs;
        return 1;
    } catch (...) { return 0; }
}
