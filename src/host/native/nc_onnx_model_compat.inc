// ORT 1.20's AVX2 precision rewrite cannot reuse an INT8 initializer twice.
// Unshare only MatMulInteger weights/zero points in the small, flat head graphs.
// Preserve every other protobuf field and every tensor byte, including unknown
// fields; no weights, scales, operators or deployed files are changed.
namespace {
namespace OnnxHeadCompat {
struct Field {
    uint32_t number;
    unsigned wire;
    std::string_view value, encoded;
};

uint64_t read_varint(std::string_view message, size_t& offset) {
    uint64_t result = 0;
    for (unsigned shift = 0; shift < 64; shift += 7) {
        if (offset >= message.size()) throw std::runtime_error("truncated ONNX varint");
        const auto byte = static_cast<uint8_t>(message[offset++]);
        if (shift == 63 && byte > 1) throw std::runtime_error("ONNX varint overflow");
        result |= uint64_t(byte & 127) << shift;
        if (!(byte & 128)) return result;
    }
    throw std::runtime_error("invalid ONNX varint");
}

std::vector<Field> fields(std::string_view message) {
    std::vector<Field> result;
    size_t offset = 0;
    while (offset < message.size()) {
        const size_t start = offset;
        const auto tag = read_varint(message, offset);
        if (tag < 8 || tag > 0xFFFFFFFFULL) throw std::runtime_error("invalid ONNX field tag");
        const unsigned wire = tag & 7;
        size_t value_start = offset, length = 0;
        switch (wire) {
            case 0: read_varint(message, offset); length = offset - value_start; break;
            case 1: length = 8; break;
            case 2: {
                const auto size = read_varint(message, offset);
                if (size > message.size() - offset) throw std::runtime_error("truncated ONNX field");
                value_start = offset;
                length = static_cast<size_t>(size);
                break;
            }
            case 5: length = 4; break;
            default: throw std::runtime_error("unsupported ONNX wire type");
        }
        if (length > message.size() - value_start) throw std::runtime_error("truncated ONNX payload");
        offset = value_start + length;
        result.push_back({static_cast<uint32_t>(tag >> 3), wire,
            message.substr(value_start, length), message.substr(start, offset - start)});
    }
    return result;
}

void varint(std::string& output, uint64_t value) {
    while (value >= 128) {
        output.push_back(static_cast<char>((value & 127) | 128));
        value >>= 7;
    }
    output.push_back(static_cast<char>(value));
}

void append(std::string& output, uint32_t number, std::string_view value) {
    varint(output, (uint64_t(number) << 3) | 2);
    varint(output, value.size());
    output.append(value);
}

std::string_view text(const std::vector<Field>& values, uint32_t number) {
    for (const auto& value : values)
        if (value.number == number && value.wire == 2) return value.value;
    return {};
}

std::string unshare(std::string_view graph) {
    const auto graph_fields = fields(graph);
    std::unordered_map<std::string, std::string_view> tensors;
    std::unordered_map<std::string, unsigned> uses;
    std::unordered_map<std::string, bool> names;
    for (const auto& field : graph_fields) {
        if (field.wire != 2) continue;
        if (field.number == 5) {
            const auto tensor = fields(field.value);
            const std::string name(text(tensor, 8));
            if (name.empty() || names.contains(name))
                throw std::runtime_error("invalid ONNX initializer name");
            names[name] = true;
            for (const auto& item : tensor) {
                if (item.number == 2 && item.wire == 0) {
                    size_t offset = 0;
                    if (read_varint(item.value, offset) == 3) tensors[name] = field.value;
                }
            }
        }
    }
    for (const auto& field : graph_fields) {
        if (field.number != 1 || field.wire != 2) continue;
        for (const auto& item : fields(field.value))
            if ((item.number == 1 || item.number == 2) && item.wire == 2)
                names[std::string(item.value)] = true;
    }
    std::string result, copies;
    unsigned serial = 0;
    for (const auto& field : graph_fields) {
        if (field.number != 1 || field.wire != 2) { result.append(field.encoded); continue; }
        const auto node = fields(field.value);
        const auto domain = text(node, 7);
        if (text(node, 4) != "MatMulInteger" || (!domain.empty() && domain != "ai.onnx")) {
            result.append(field.encoded);
            continue;
        }
        std::string rewritten;
        unsigned input = 0;
        for (const auto& item : node) {
            if (item.number == 1 && item.wire == 2) {
                const unsigned slot = input++;
                const std::string original(item.value);
                const auto tensor = tensors.find(original);
                if ((slot == 1 || slot == 3) && tensor != tensors.end() && uses[original]++ > 0) {
                    std::string alias;
                    do { alias = original + "_cassotis_use_" + std::to_string(++serial); }
                    while (names.contains(alias));
                    names[alias] = true;
                    std::string copy;
                    for (const auto& part : fields(tensor->second)) {
                        if (part.number == 8 && part.wire == 2) append(copy, 8, alias);
                        else copy.append(part.encoded);
                    }
                    if (copies.size() + copy.size() > 32 * 1024 * 1024)
                        throw std::runtime_error("joint head initializer budget exceeded");
                    append(copies, 5, copy);
                    append(rewritten, 1, alias);
                    continue;
                }
            }
            rewritten.append(item.encoded);
        }
        append(result, 1, rewritten);
    }
    result += copies;
    return result;
}

std::string prepare(std::string_view model) {
    std::string result;
    unsigned graphs = 0;
    for (const auto& field : fields(model)) {
        if (field.number == 7 && field.wire == 2) {
            append(result, 7, unshare(field.value));
            ++graphs;
        } else result.append(field.encoded);
    }
    if (graphs != 1) throw std::runtime_error("invalid ONNX model graph");
    return result;
}

std::string load(const char* path) {
    std::ifstream stream(path, std::ios::binary | std::ios::ate);
    if (!stream) throw std::runtime_error("cannot open joint repair head");
    const auto size = stream.tellg();
    if (size <= 0 || size > 16 * 1024 * 1024)
        throw std::runtime_error("invalid joint repair head size");
    std::string model(static_cast<size_t>(size), '\0');
    stream.seekg(0);
    if (!stream.read(model.data(), size)) throw std::runtime_error("cannot read joint repair head");
    return prepare(model);
}
}  // namespace OnnxHeadCompat
}  // namespace
