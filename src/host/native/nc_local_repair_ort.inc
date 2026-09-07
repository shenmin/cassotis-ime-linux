namespace {
struct LocalRepairHandle {
    std::unique_ptr<Ort::Session> context_session;
    std::unique_ptr<Ort::Session> query_session;
    std::mutex lock;
    std::vector<int64_t> context_ids;
    std::vector<Ort::Value> memory;
    uint64_t document{};
    uint64_t encodings{};
};
}

extern "C" CASSOTIS_EXPORT void* cassotis_lr_create(
    const char* context_path, const char* query_path, int threads,
    char* error_text, int error_capacity) {
    SetError(error_text, error_capacity, "");
    if (!context_path || !query_path) return nullptr;
    try {
        FloatingPointMaskGuard floating_point_guard;
        const std::lock_guard<std::mutex> initialization_lock(InitializationMutex());
        Ort::InitApi();
        Ort::SessionOptions options;
        ConfigureSessionOptions(options, std::max(1, std::min(threads, 2)));
        auto handle = std::make_unique<LocalRepairHandle>();
        handle->context_session = std::make_unique<Ort::Session>(Environment(), context_path, options);
        handle->query_session = std::make_unique<Ort::Session>(Environment(), query_path, options);
        ReleaseUnusedHeapPages();
        return handle.release();
    } catch (const std::exception& error) {
        SetError(error_text, error_capacity, error.what());
    } catch (...) {
        SetError(error_text, error_capacity, "local repair initialization failed");
    }
    return nullptr;
}

extern "C" CASSOTIS_EXPORT int cassotis_lr_run(
    void* opaque, uint64_t document, const int64_t* context, int context_count,
    const int64_t* draft, const int64_t* pinyin, int length,
    int64_t* best, float* margins, float* edits,
    char* error_text, int error_capacity) {
    SetError(error_text, error_capacity, "");
    if (!opaque || !context || !draft || !pinyin || !best || !margins || !edits ||
        context_count < 2 || context_count > 258 || length < 1 || length > 40) return 0;
    try {
        FloatingPointMaskGuard floating_point_guard;
        auto& handle = *static_cast<LocalRepairHandle*>(opaque);
        const std::lock_guard<std::mutex> guard(handle.lock);
        const auto memory_info = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
        if (handle.memory.empty() || handle.document != document ||
            handle.context_ids.size() != static_cast<size_t>(context_count) ||
            !std::equal(handle.context_ids.begin(), handle.context_ids.end(), context)) {
            handle.memory.clear();
            handle.context_ids.assign(context, context + context_count);
            handle.document = document;
            const std::array<int64_t, 2> shape{1, context_count};
            auto input = Ort::Value::CreateTensor<int64_t>(memory_info,
                handle.context_ids.data(), context_count, shape.data(), shape.size());
            const char* names[] = {"context_ids"};
            const char* outputs[] = {"keys", "values", "context_mask"};
            handle.memory = handle.context_session->Run(Ort::RunOptions{nullptr}, names, &input, 1, outputs, 3);
            ++handle.encodings;
        }
        const std::array<int64_t, 2> shape{1, length};
        std::vector<Ort::Value> inputs;
        inputs.emplace_back(Ort::Value::CreateTensor<int64_t>(memory_info,
            const_cast<int64_t*>(draft), length, shape.data(), shape.size()));
        inputs.emplace_back(Ort::Value::CreateTensor<int64_t>(memory_info,
            const_cast<int64_t*>(pinyin), length, shape.data(), shape.size()));
        for (size_t index = 0; index < handle.memory.size(); ++index) {
            auto& tensor = handle.memory[index];
            auto info = tensor.GetTensorTypeAndShapeInfo();
            auto dimensions = info.GetShape();
            inputs.emplace_back(Ort::Value::CreateTensor(memory_info, tensor.GetTensorMutableRawData(),
                info.GetElementCount() * (index == 2 ? sizeof(bool) : sizeof(float)),
                dimensions.data(), dimensions.size(), info.GetElementType()));
        }
        const char* names[] = {"draft_ids", "pinyin_ids", "keys", "values", "context_mask"};
        const char* outputs[] = {"best_ids", "margins", "edit_probabilities"};
        auto results = handle.query_session->Run(Ort::RunOptions{nullptr}, names, inputs.data(), inputs.size(), outputs, 3);
        for (const auto& tensor : results) {
            if (tensor.GetTensorTypeAndShapeInfo().GetElementCount() != static_cast<size_t>(length)) {
                throw std::runtime_error("invalid local repair output shape");
            }
        }
        std::copy_n(results[0].GetTensorData<int64_t>(), length, best);
        std::copy_n(results[1].GetTensorData<float>(), length, margins);
        std::copy_n(results[2].GetTensorData<float>(), length, edits);
        return 1;
    } catch (const std::exception& error) {
        SetError(error_text, error_capacity, error.what());
    } catch (...) {
        SetError(error_text, error_capacity, "local repair query failed");
    }
    return 0;
}

extern "C" CASSOTIS_EXPORT int cassotis_lr_prepare_context(
    void* opaque, uint64_t document, const int64_t* context, int count,
    char* error_text, int error_capacity) {
    // A dummy query is sufficient to populate the same bounded KV cache. The
    // host calls this on its background worker, never on the input event thread.
    const int64_t draft = 4, pinyin = 4;
    int64_t best{};
    float margin{}, edit{};
    return cassotis_lr_run(opaque, document, context, count, &draft, &pinyin, 1,
        &best, &margin, &edit, error_text, error_capacity);
}

extern "C" CASSOTIS_EXPORT uint64_t cassotis_lr_encodings(void* opaque) {
    if (!opaque) return 0;
    auto& handle = *static_cast<LocalRepairHandle*>(opaque);
    const std::lock_guard<std::mutex> guard(handle.lock);
    return handle.encodings;
}

extern "C" CASSOTIS_EXPORT void cassotis_lr_clear(void* opaque) {
    if (!opaque) return;
    auto& handle = *static_cast<LocalRepairHandle*>(opaque);
    const std::lock_guard<std::mutex> guard(handle.lock);
    handle.memory.clear();
    std::fill(handle.context_ids.begin(), handle.context_ids.end(), 0);
    handle.context_ids.clear();
    handle.document = 0;
}

extern "C" CASSOTIS_EXPORT void cassotis_lr_destroy(void* opaque) {
    delete static_cast<LocalRepairHandle*>(opaque);
    ReleaseUnusedHeapPages();
}
