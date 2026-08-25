#include "cassotis_protocol.h"

#include <string.h>

#define CASSOTIS_PROTOCOL_MAJOR 1U
#define CASSOTIS_PROTOCOL_MINOR 0U
#define CASSOTIS_PAYLOAD_SCHEMA 1U
#define CASSOTIS_ENGINE_STATE_FUZZY_SCHEMA 2U
#define CASSOTIS_ENGINE_STATE_SHORTCUTS_SCHEMA 3U
#define CASSOTIS_ENGINE_STATE_SCHEMA 4U
#define CASSOTIS_MIN_PAGE_SIZE 3U
#define CASSOTIS_DEFAULT_PAGE_SIZE 9U
#define CASSOTIS_MAX_PAGE_SIZE 9U
#define CASSOTIS_MAX_CANDIDATES 256U
#define CASSOTIS_MAX_TEXT_BYTES (1024U * 1024U)
#define CASSOTIS_STATE_FLAG_FULL_WIDTH 0x01U
#define CASSOTIS_STATE_FLAG_PUNCTUATION_FULL_WIDTH 0x02U
#define CASSOTIS_STATE_FLAG_FUZZY_PINYIN_ENABLED 0x04U
#define CASSOTIS_STATE_FLAG_DEBUG_MODE 0x08U
#define CASSOTIS_STATE_KNOWN_FLAGS                                      \
    (CASSOTIS_STATE_FLAG_FULL_WIDTH |                                  \
     CASSOTIS_STATE_FLAG_PUNCTUATION_FULL_WIDTH |                      \
     CASSOTIS_STATE_FLAG_FUZZY_PINYIN_ENABLED |                        \
     CASSOTIS_STATE_FLAG_DEBUG_MODE)
#define CASSOTIS_SHORTCUT_KNOWN_MODIFIERS                               \
    (CASSOTIS_MODIFIER_SHIFT | CASSOTIS_MODIFIER_CONTROL |             \
     CASSOTIS_MODIFIER_ALT)

typedef struct {
    const guint8 *data;
    gsize length;
    gsize offset;
    GError **error;
} PayloadReader;

G_DEFINE_QUARK(cassotis-protocol-error-quark, cassotis_protocol_error)

void cassotis_engine_state_init_defaults(CassotisEngineState *state)
{
    g_return_if_fail(state != NULL);
    memset(state, 0, sizeof(*state));
    state->input_mode = CASSOTIS_INPUT_CHINESE;
    state->dictionary_variant = CASSOTIS_DICTIONARY_SIMPLIFIED;
    state->pinyin_scheme = CASSOTIS_PINYIN_FULL;
    state->punctuation_full_width = TRUE;
    state->candidate_page_size = CASSOTIS_DEFAULT_PAGE_SIZE;
    state->candidate_page_key_scheme = CASSOTIS_PAGE_KEYS_MINUS_PLUS;
    state->one_key_completion_key = CASSOTIS_COMPLETION_TAB;
    state->shortcuts.input_mode_toggle.key_code = 0x10U;
    state->shortcuts.punctuation_toggle.key_code = 0xbeU;
    state->shortcuts.punctuation_toggle.modifiers =
        CASSOTIS_MODIFIER_CONTROL;
    state->shortcuts.dictionary_variant_toggle.key_code = (guint16)'T';
    state->shortcuts.dictionary_variant_toggle.modifiers =
        CASSOTIS_MODIFIER_SHIFT | CASSOTIS_MODIFIER_CONTROL;
    state->shortcuts.full_width_toggle.key_code = 0x20U;
    state->shortcuts.full_width_toggle.modifiers =
        CASSOTIS_MODIFIER_SHIFT;
    state->shortcuts.open_settings.key_code = 0x79U;
    state->shortcuts.open_settings.modifiers =
        CASSOTIS_MODIFIER_SHIFT | CASSOTIS_MODIFIER_CONTROL;
}

static void append_u8(GByteArray *buffer, guint8 value)
{
    g_byte_array_append(buffer, &value, 1);
}

static void append_u16(GByteArray *buffer, guint16 value)
{
    guint16 encoded = GUINT16_TO_LE(value);
    g_byte_array_append(buffer, (const guint8 *)&encoded, sizeof(encoded));
}

static void append_u32(GByteArray *buffer, guint32 value)
{
    guint32 encoded = GUINT32_TO_LE(value);
    g_byte_array_append(buffer, (const guint8 *)&encoded, sizeof(encoded));
}

static void append_i32(GByteArray *buffer, gint32 value)
{
    append_u32(buffer, (guint32)value);
}

static void append_u64(GByteArray *buffer, guint64 value)
{
    guint64 encoded = GUINT64_TO_LE(value);
    g_byte_array_append(buffer, (const guint8 *)&encoded, sizeof(encoded));
}

static void append_string(GByteArray *buffer, const gchar *value)
{
    gsize length = value != NULL ? strlen(value) : 0;
    g_return_if_fail(length <= CASSOTIS_MAX_TEXT_BYTES);
    append_u32(buffer, (guint32)length);
    if (length > 0)
        g_byte_array_append(buffer, (const guint8 *)value, length);
}

static void append_shortcut(GByteArray *buffer,
                            const CassotisShortcut *shortcut)
{
    append_u16(buffer, shortcut->key_code);
    append_u8(buffer, shortcut->modifiers);
    append_u8(buffer, 0);
}

static void write_u16_at(GByteArray *buffer, gsize offset, guint16 value)
{
    guint16 encoded = GUINT16_TO_LE(value);
    memcpy(buffer->data + offset, &encoded, sizeof(encoded));
}

static void write_u32_at(GByteArray *buffer, gsize offset, guint32 value)
{
    guint32 encoded = GUINT32_TO_LE(value);
    memcpy(buffer->data + offset, &encoded, sizeof(encoded));
}

static void write_u64_at(GByteArray *buffer, gsize offset, guint64 value)
{
    guint64 encoded = GUINT64_TO_LE(value);
    memcpy(buffer->data + offset, &encoded, sizeof(encoded));
}

static guint16 read_u16_at(const guint8 *data, gsize offset)
{
    guint16 encoded;
    memcpy(&encoded, data + offset, sizeof(encoded));
    return GUINT16_FROM_LE(encoded);
}

static guint32 read_u32_at(const guint8 *data, gsize offset)
{
    guint32 encoded;
    memcpy(&encoded, data + offset, sizeof(encoded));
    return GUINT32_FROM_LE(encoded);
}

static guint64 read_u64_at(const guint8 *data, gsize offset)
{
    guint64 encoded;
    memcpy(&encoded, data + offset, sizeof(encoded));
    return GUINT64_FROM_LE(encoded);
}

static GByteArray *build_frame(CassotisMessageType message_type,
                               guint64 request_id,
                               guint64 context_id,
                               guint64 generation_id,
                               GByteArray *payload)
{
    gsize payload_length = payload != NULL ? payload->len : 0;
    GByteArray *frame = g_byte_array_sized_new(
        CASSOTIS_IPC_HEADER_SIZE + payload_length);
    g_byte_array_set_size(frame, CASSOTIS_IPC_HEADER_SIZE);
    memcpy(frame->data, "CSIM", 4);
    write_u16_at(frame, 4, CASSOTIS_PROTOCOL_MAJOR);
    write_u16_at(frame, 6, CASSOTIS_PROTOCOL_MINOR);
    write_u16_at(frame, 8, (guint16)message_type);
    write_u16_at(frame, 10, 0);
    write_u32_at(frame, 12, 0);
    write_u64_at(frame, 16, request_id);
    write_u64_at(frame, 24, context_id);
    write_u64_at(frame, 32, generation_id);
    write_u32_at(frame, 40, (guint32)payload_length);
    if (payload_length > 0)
        g_byte_array_append(frame, payload->data, payload_length);
    if (payload != NULL)
        g_byte_array_unref(payload);
    return frame;
}

static GByteArray *new_payload(void)
{
    GByteArray *payload = g_byte_array_new();
    append_u16(payload, CASSOTIS_PAYLOAD_SCHEMA);
    append_u16(payload, 0);
    return payload;
}

static GByteArray *new_payload_with_schema(guint16 schema)
{
    GByteArray *payload = g_byte_array_new();
    append_u16(payload, schema);
    append_u16(payload, 0);
    return payload;
}

GByteArray *cassotis_protocol_build_empty_request(
    CassotisMessageType message_type,
    guint64 request_id,
    guint64 context_id,
    guint64 generation_id)
{
    return build_frame(message_type, request_id, context_id, generation_id,
                       NULL);
}

GByteArray *cassotis_protocol_build_set_active_request(
    guint64 request_id,
    guint64 context_id,
    guint64 generation_id,
    gboolean active)
{
    GByteArray *payload = new_payload();
    append_u8(payload, active ? 1 : 0);
    return build_frame(CASSOTIS_MESSAGE_SET_ACTIVE, request_id, context_id,
                       generation_id, payload);
}

GByteArray *cassotis_protocol_build_set_surrounding_request(
    guint64 request_id,
    guint64 context_id,
    guint64 generation_id,
    gint32 cursor_offset,
    const gchar *text)
{
    g_return_val_if_fail(cursor_offset >= 0, NULL);
    GByteArray *payload = new_payload();
    append_i32(payload, cursor_offset);
    append_string(payload, text != NULL ? text : "");
    return build_frame(CASSOTIS_MESSAGE_SET_SURROUNDING, request_id,
                       context_id, generation_id, payload);
}

GByteArray *cassotis_protocol_build_process_key_request(
    guint64 request_id,
    guint64 context_id,
    guint64 generation_id,
    CassotisSpecialKey special_key,
    guint32 modifiers,
    guint32 scan_code,
    gboolean is_release,
    gboolean is_repeat,
    guint64 timestamp_ms,
    const gchar *text)
{
    guint32 flags = (is_release ? 1U : 0U) | (is_repeat ? 2U : 0U);
    GByteArray *payload = new_payload();
    append_u16(payload, (guint16)special_key);
    append_u16(payload, 0);
    append_u32(payload, modifiers);
    append_u32(payload, scan_code);
    append_u32(payload, flags);
    append_u64(payload, timestamp_ms);
    append_string(payload, text != NULL ? text : "");
    return build_frame(CASSOTIS_MESSAGE_PROCESS_KEY, request_id, context_id,
                       generation_id, payload);
}

GByteArray *cassotis_protocol_build_set_state_request(
    guint64 request_id,
    const CassotisEngineState *state)
{
    guint8 flags = 0;
    GByteArray *payload;
    g_return_val_if_fail(state != NULL, NULL);
    payload = new_payload_with_schema(CASSOTIS_ENGINE_STATE_SCHEMA);
    append_u8(payload, (guint8)state->input_mode);
    append_u8(payload, (guint8)state->dictionary_variant);
    append_u8(payload, (guint8)state->pinyin_scheme);
    if (state->full_width_mode)
        flags |= CASSOTIS_STATE_FLAG_FULL_WIDTH;
    if (state->punctuation_full_width)
        flags |= CASSOTIS_STATE_FLAG_PUNCTUATION_FULL_WIDTH;
    if (state->fuzzy_pinyin_enabled)
        flags |= CASSOTIS_STATE_FLAG_FUZZY_PINYIN_ENABLED;
    if (state->debug_mode)
        flags |= CASSOTIS_STATE_FLAG_DEBUG_MODE;
    append_u8(payload, flags);
    append_u32(payload, state->fuzzy_pinyin_rules);
    append_u8(payload, (guint8)state->candidate_page_key_scheme);
    append_u8(payload, (guint8)state->one_key_completion_key);
    append_u8(payload, state->candidate_page_size);
    append_u8(payload, 0);
    append_shortcut(payload, &state->shortcuts.input_mode_toggle);
    append_shortcut(payload, &state->shortcuts.punctuation_toggle);
    append_shortcut(payload, &state->shortcuts.dictionary_variant_toggle);
    append_shortcut(payload, &state->shortcuts.full_width_toggle);
    append_shortcut(payload, &state->shortcuts.open_settings);
    return build_frame(CASSOTIS_MESSAGE_SET_STATE, request_id, 0, 0,
                       payload);
}

static gboolean set_reader_error(PayloadReader *reader, const gchar *message)
{
    g_set_error_literal(reader->error, cassotis_protocol_error_quark(), 1,
                        message);
    return FALSE;
}

static gboolean reader_require(PayloadReader *reader, gsize count)
{
    if (count > reader->length - reader->offset)
        return set_reader_error(reader, "truncated IPC payload");
    return TRUE;
}

static gboolean reader_u8(PayloadReader *reader, guint8 *value)
{
    if (!reader_require(reader, 1))
        return FALSE;
    *value = reader->data[reader->offset++];
    return TRUE;
}

static gboolean reader_u16(PayloadReader *reader, guint16 *value)
{
    if (!reader_require(reader, 2))
        return FALSE;
    *value = read_u16_at(reader->data, reader->offset);
    reader->offset += 2;
    return TRUE;
}

static gboolean reader_u32(PayloadReader *reader, guint32 *value)
{
    if (!reader_require(reader, 4))
        return FALSE;
    *value = read_u32_at(reader->data, reader->offset);
    reader->offset += 4;
    return TRUE;
}

static gboolean reader_i32(PayloadReader *reader, gint32 *value)
{
    guint32 encoded;
    if (!reader_u32(reader, &encoded))
        return FALSE;
    *value = (gint32)encoded;
    return TRUE;
}

static gboolean reader_string(PayloadReader *reader, gchar **value)
{
    guint32 length;
    if (!reader_u32(reader, &length))
        return FALSE;
    if (length > CASSOTIS_MAX_TEXT_BYTES)
        return set_reader_error(reader, "IPC string exceeds configured limit");
    if (!reader_require(reader, length))
        return FALSE;
    if (!g_utf8_validate((const gchar *)reader->data + reader->offset,
                         length, NULL))
        return set_reader_error(reader, "IPC string is not valid UTF-8");
    *value = g_strndup((const gchar *)reader->data + reader->offset, length);
    reader->offset += length;
    return TRUE;
}

static gboolean reader_header(PayloadReader *reader)
{
    guint16 schema;
    guint16 reserved;
    if (!reader_u16(reader, &schema) || !reader_u16(reader, &reserved))
        return FALSE;
    if (schema != CASSOTIS_PAYLOAD_SCHEMA || reserved != 0)
        return set_reader_error(reader, "unsupported IPC payload schema");
    return TRUE;
}

static gboolean reader_state_header(PayloadReader *reader, guint16 *schema)
{
    guint16 reserved;
    if (!reader_u16(reader, schema) || !reader_u16(reader, &reserved))
        return FALSE;
    if ((*schema < CASSOTIS_PAYLOAD_SCHEMA ||
         *schema > CASSOTIS_ENGINE_STATE_SCHEMA) ||
        reserved != 0)
        return set_reader_error(reader,
                                "unsupported engine state payload schema");
    return TRUE;
}

static gboolean reader_shortcut(PayloadReader *reader,
                                CassotisShortcut *shortcut)
{
    guint8 reserved;
    if (!reader_u16(reader, &shortcut->key_code) ||
        !reader_u8(reader, &shortcut->modifiers) ||
        !reader_u8(reader, &reserved))
        return FALSE;
    if (reserved != 0 ||
        (shortcut->modifiers & ~CASSOTIS_SHORTCUT_KNOWN_MODIFIERS) != 0)
        return set_reader_error(reader, "invalid shortcut payload");
    return TRUE;
}

static gboolean shortcut_is_valid(const CassotisShortcut *shortcut)
{
    if (shortcut->key_code == 0)
        return FALSE;
    if (shortcut->key_code == 0x10U)
        return shortcut->modifiers == 0;
    if (shortcut->key_code == 0x11U || shortcut->key_code == 0x12U)
        return FALSE;
    return shortcut->modifiers != 0 ||
           (shortcut->key_code >= 0x70U && shortcut->key_code <= 0x87U);
}

static gboolean shortcuts_are_valid(const CassotisShortcutConfig *config)
{
    const CassotisShortcut *items[] = {
        &config->input_mode_toggle,
        &config->punctuation_toggle,
        &config->dictionary_variant_toggle,
        &config->full_width_toggle,
        &config->open_settings,
    };
    guint first;
    guint second;

    for (first = 0; first < G_N_ELEMENTS(items); ++first) {
        if (!shortcut_is_valid(items[first]))
            return FALSE;
        for (second = first + 1; second < G_N_ELEMENTS(items); ++second) {
            if (items[first]->key_code == items[second]->key_code &&
                items[first]->modifiers == items[second]->modifiers)
                return FALSE;
        }
    }
    return TRUE;
}

gboolean cassotis_protocol_parse_header(const guint8 *data,
                                        gsize length,
                                        CassotisFrameHeader *header,
                                        GError **error)
{
    guint16 major;
    guint16 minor;
    guint16 reserved;
    if (data == NULL || header == NULL || length < CASSOTIS_IPC_HEADER_SIZE) {
        g_set_error_literal(error, cassotis_protocol_error_quark(), 1,
                            "truncated IPC frame header");
        return FALSE;
    }
    if (memcmp(data, "CSIM", 4) != 0) {
        g_set_error_literal(error, cassotis_protocol_error_quark(), 1,
                            "invalid IPC frame magic");
        return FALSE;
    }
    major = read_u16_at(data, 4);
    minor = read_u16_at(data, 6);
    reserved = read_u16_at(data, 10);
    if (major != CASSOTIS_PROTOCOL_MAJOR ||
        minor > CASSOTIS_PROTOCOL_MINOR || reserved != 0) {
        g_set_error_literal(error, cassotis_protocol_error_quark(), 1,
                            "unsupported IPC frame version");
        return FALSE;
    }
    header->message_type = read_u16_at(data, 8);
    header->flags = read_u32_at(data, 12);
    header->request_id = read_u64_at(data, 16);
    header->context_id = read_u64_at(data, 24);
    header->generation_id = read_u64_at(data, 32);
    header->payload_length = read_u32_at(data, 40);
    if (header->message_type == CASSOTIS_MESSAGE_INVALID ||
        header->message_type > CASSOTIS_MESSAGE_CLEAR_USER_DICTIONARY ||
        (header->flags & ~(CASSOTIS_IPC_FLAG_RESPONSE |
                           CASSOTIS_IPC_FLAG_ERROR)) != 0 ||
        header->payload_length > CASSOTIS_IPC_MAX_PAYLOAD) {
        g_set_error_literal(error, cassotis_protocol_error_quark(), 1,
                            "invalid IPC frame header fields");
        return FALSE;
    }
    return TRUE;
}

void cassotis_engine_result_clear(CassotisEngineResult *result)
{
    guint32 index;
    if (result == NULL)
        return;
    g_free(result->commit_text);
    g_free(result->preedit_text);
    g_free(result->query_text);
    g_free(result->completion_text);
    g_free(result->error_text);
    for (index = 0; index < result->candidate_count; ++index) {
        g_free(result->candidates[index].text);
        g_free(result->candidates[index].comment);
    }
    g_free(result->candidates);
    memset(result, 0, sizeof(*result));
    result->selected_index = -1;
}

gboolean cassotis_protocol_decode_engine_result(
    const guint8 *payload,
    gsize payload_length,
    CassotisEngineResult *result,
    GError **error)
{
    PayloadReader reader = {payload, payload_length, 0, error};
    guint8 handled;
    guint8 reserved8;
    guint16 reserved16;
    guint32 candidate_count;
    guint32 index;
    guint8 source;
    guint8 display_kind;
    guint8 has_weight;
    guint8 deletable;
    guint32 ignored_u32;
    gint32 ignored_i32;

    memset(result, 0, sizeof(*result));
    result->selected_index = -1;
    if (!reader_header(&reader) || !reader_u8(&reader, &handled) ||
        !reader_u16(&reader, &reserved16) ||
        !reader_u8(&reader, &reserved8) ||
        !reader_i32(&reader, &result->selected_index) ||
        !reader_i32(&reader, &result->page_index) ||
        !reader_i32(&reader, &result->page_count) ||
        !reader_u32(&reader, &result->error_code) ||
        !reader_string(&reader, &result->commit_text) ||
        !reader_string(&reader, &result->preedit_text) ||
        !reader_string(&reader, &result->query_text) ||
        !reader_string(&reader, &result->completion_text) ||
        !reader_string(&reader, &result->error_text) ||
        !reader_u32(&reader, &candidate_count))
        goto fail;
    if (handled > 1 || reserved16 != 0 || reserved8 != 0 ||
        candidate_count > CASSOTIS_MAX_CANDIDATES) {
        set_reader_error(&reader, "invalid engine result fields");
        goto fail;
    }
    result->handled = handled != 0;
    result->candidate_count = candidate_count;
    result->candidates = g_new0(CassotisCandidate, candidate_count);
    for (index = 0; index < candidate_count; ++index) {
        CassotisCandidate *candidate = &result->candidates[index];
        if (!reader_u8(&reader, &source) ||
            !reader_u8(&reader, &display_kind) ||
            !reader_u8(&reader, &has_weight) ||
            !reader_u8(&reader, &deletable) ||
            !reader_i32(&reader, &candidate->score) ||
            !reader_i32(&reader, &candidate->dictionary_weight) ||
            !reader_i32(&reader, &ignored_i32) ||
            !reader_u32(&reader, &ignored_u32) ||
            !reader_string(&reader, &candidate->text) ||
            !reader_string(&reader, &candidate->comment))
            goto fail;
        if (source > 1 || display_kind > 1 || has_weight > 1 || deletable > 1) {
            g_set_error(reader.error, cassotis_protocol_error_quark(), 1,
                        "invalid candidate fields at index %u "
                        "(source=%u display_kind=%u has_weight=%u "
                        "deletable=%u)",
                        index, source, display_kind, has_weight, deletable);
            goto fail;
        }
        candidate->has_dictionary_weight = has_weight != 0;
        candidate->deletable = deletable != 0;
    }
    if (reader.offset != reader.length) {
        set_reader_error(&reader, "trailing bytes in engine result");
        goto fail;
    }
    return TRUE;

fail:
    cassotis_engine_result_clear(result);
    return FALSE;
}

gboolean cassotis_protocol_decode_engine_state(
    const guint8 *payload,
    gsize payload_length,
    CassotisEngineState *state,
    GError **error)
{
    PayloadReader reader = {payload, payload_length, 0, error};
    guint8 input_mode;
    guint8 dictionary_variant;
    guint8 pinyin_scheme;
    guint8 flags;
    guint16 schema;
    guint32 fuzzy_rules = 0;
    guint8 candidate_page_key_scheme;
    guint8 one_key_completion_key;
    guint8 candidate_page_size;
    guint8 reserved_byte;
    guint16 reserved;

    g_return_val_if_fail(state != NULL, FALSE);
    cassotis_engine_state_init_defaults(state);
    candidate_page_key_scheme = (guint8)state->candidate_page_key_scheme;
    one_key_completion_key = (guint8)state->one_key_completion_key;
    candidate_page_size = state->candidate_page_size;
    reserved_byte = 0;
    reserved = 0;
    if (!reader_state_header(&reader, &schema) ||
        !reader_u8(&reader, &input_mode) ||
        !reader_u8(&reader, &dictionary_variant) ||
        !reader_u8(&reader, &pinyin_scheme) || !reader_u8(&reader, &flags))
        return FALSE;
    if (schema >= CASSOTIS_ENGINE_STATE_FUZZY_SCHEMA &&
        !reader_u32(&reader, &fuzzy_rules))
        return FALSE;
    if (schema >= CASSOTIS_ENGINE_STATE_SHORTCUTS_SCHEMA) {
        if (!reader_u8(&reader, &candidate_page_key_scheme) ||
            !reader_u8(&reader, &one_key_completion_key))
            return FALSE;
        if (schema >= CASSOTIS_ENGINE_STATE_SCHEMA) {
            if (!reader_u8(&reader, &candidate_page_size) ||
                !reader_u8(&reader, &reserved_byte) || reserved_byte != 0)
                return FALSE;
        } else if (!reader_u16(&reader, &reserved) || reserved != 0) {
            return FALSE;
        }
        if (!reader_shortcut(&reader, &state->shortcuts.input_mode_toggle) ||
            !reader_shortcut(&reader, &state->shortcuts.punctuation_toggle) ||
            !reader_shortcut(
                &reader, &state->shortcuts.dictionary_variant_toggle) ||
            !reader_shortcut(&reader, &state->shortcuts.full_width_toggle) ||
            !reader_shortcut(&reader, &state->shortcuts.open_settings))
            return FALSE;
    }
    if (input_mode > CASSOTIS_INPUT_ENGLISH ||
        dictionary_variant > CASSOTIS_DICTIONARY_TRADITIONAL ||
        pinyin_scheme > CASSOTIS_PINYIN_PINYINJIAJIA ||
        (flags & ~CASSOTIS_STATE_KNOWN_FLAGS) != 0 ||
        (schema == CASSOTIS_PAYLOAD_SCHEMA &&
         (flags & CASSOTIS_STATE_FLAG_FUZZY_PINYIN_ENABLED) != 0) ||
        (schema < CASSOTIS_ENGINE_STATE_SCHEMA &&
         (flags & CASSOTIS_STATE_FLAG_DEBUG_MODE) != 0) ||
        (fuzzy_rules & ~CASSOTIS_FUZZY_RULE_MASK) != 0 ||
        candidate_page_size < CASSOTIS_MIN_PAGE_SIZE ||
        candidate_page_size > CASSOTIS_MAX_PAGE_SIZE ||
        candidate_page_key_scheme > CASSOTIS_PAGE_KEYS_SHIFT_TAB ||
        one_key_completion_key > CASSOTIS_COMPLETION_BACKTICK ||
        (candidate_page_key_scheme == CASSOTIS_PAGE_KEYS_SHIFT_TAB &&
         one_key_completion_key == CASSOTIS_COMPLETION_TAB) ||
        !shortcuts_are_valid(&state->shortcuts) ||
        reader.offset != reader.length)
        return set_reader_error(&reader, "invalid engine state payload");
    state->input_mode = (CassotisInputMode)input_mode;
    state->dictionary_variant =
        (CassotisDictionaryVariant)dictionary_variant;
    state->pinyin_scheme = (CassotisPinyinScheme)pinyin_scheme;
    state->fuzzy_pinyin_enabled =
        (flags & CASSOTIS_STATE_FLAG_FUZZY_PINYIN_ENABLED) != 0;
    state->fuzzy_pinyin_rules = fuzzy_rules;
    state->full_width_mode =
        (flags & CASSOTIS_STATE_FLAG_FULL_WIDTH) != 0;
    state->punctuation_full_width =
        (flags & CASSOTIS_STATE_FLAG_PUNCTUATION_FULL_WIDTH) != 0;
    state->candidate_page_size = candidate_page_size;
    state->candidate_page_key_scheme =
        (CassotisCandidatePageKeyScheme)candidate_page_key_scheme;
    state->one_key_completion_key =
        (CassotisOneKeyCompletionKey)one_key_completion_key;
    state->debug_mode =
        (flags & CASSOTIS_STATE_FLAG_DEBUG_MODE) != 0;
    return TRUE;
}

gboolean cassotis_protocol_decode_error(const guint8 *payload,
                                        gsize payload_length,
                                        guint32 *error_code,
                                        gchar **error_text,
                                        GError **error)
{
    PayloadReader reader = {payload, payload_length, 0, error};
    *error_code = 0;
    *error_text = NULL;
    if (!reader_header(&reader) || !reader_u32(&reader, error_code) ||
        !reader_string(&reader, error_text))
        return FALSE;
    if (reader.offset != reader.length) {
        g_free(*error_text);
        *error_text = NULL;
        return set_reader_error(&reader, "trailing bytes in error payload");
    }
    return TRUE;
}
