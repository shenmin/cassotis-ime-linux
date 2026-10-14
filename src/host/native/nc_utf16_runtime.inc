// The model ABI uses UTF-16 explicitly, independent of platform wchar_t.
namespace {
static_assert(sizeof(char16_t) == 2);

std::u16string Utf8ToUtf16(const char* value) {
    std::u16string result;
    for (auto cp : Utf8Codepoints(value)) {
        if (cp <= 0xffff) result.push_back(static_cast<char16_t>(cp));
        else {
            cp -= 0x10000;
            result.push_back(static_cast<char16_t>(0xd800 + (cp >> 10)));
            result.push_back(static_cast<char16_t>(0xdc00 + (cp & 0x3ff)));
        }
    }
    return result;
}

std::string Utf16ToUtf8(std::u16string_view value) {
    std::string result;
    for (size_t i = 0; i < value.size(); ++i) {
        uint32_t cp = value[i];
        if (cp >= 0xd800 && cp <= 0xdbff) {
            if (++i == value.size() || value[i] < 0xdc00 || value[i] > 0xdfff)
                throw std::runtime_error("invalid UTF-16 surrogate pair");
            cp = 0x10000 + ((cp - 0xd800) << 10) + (value[i] - 0xdc00);
        } else if (cp >= 0xdc00 && cp <= 0xdfff) {
            throw std::runtime_error("unpaired UTF-16 low surrogate");
        }
        AppendUtf8Codepoint(result, cp);
    }
    return result;
}

void SetUtf16Error(char16_t* destination, int capacity, std::u16string_view text) {
    if (!destination || capacity <= 0) return;
    const size_t count = std::min(text.size(), static_cast<size_t>(capacity - 1));
    std::copy_n(text.data(), count, destination);
    destination[count] = 0;
}

}
