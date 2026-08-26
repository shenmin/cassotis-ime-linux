#ifndef CASSOTIS_PROTOCOL_H
#define CASSOTIS_PROTOCOL_H

#include <glib.h>

G_BEGIN_DECLS

#define CASSOTIS_IPC_HEADER_SIZE 44U
#define CASSOTIS_IPC_MAX_PAYLOAD (8U * 1024U * 1024U)
#define CASSOTIS_IPC_FLAG_RESPONSE 0x00000001U
#define CASSOTIS_IPC_FLAG_ERROR 0x00000002U

typedef enum {
    CASSOTIS_MESSAGE_INVALID = 0,
    CASSOTIS_MESSAGE_HELLO = 1,
    CASSOTIS_MESSAGE_HELLO_ACK = 2,
    CASSOTIS_MESSAGE_PING = 3,
    CASSOTIS_MESSAGE_PONG = 4,
    CASSOTIS_MESSAGE_CREATE_CONTEXT = 5,
    CASSOTIS_MESSAGE_DESTROY_CONTEXT = 6,
    CASSOTIS_MESSAGE_RESET_CONTEXT = 7,
    CASSOTIS_MESSAGE_SET_ACTIVE = 8,
    CASSOTIS_MESSAGE_SET_SURROUNDING = 9,
    CASSOTIS_MESSAGE_PROCESS_KEY = 10,
    CASSOTIS_MESSAGE_ENGINE_RESULT = 11,
    CASSOTIS_MESSAGE_GET_STATE = 12,
    CASSOTIS_MESSAGE_SET_STATE = 13,
    CASSOTIS_MESSAGE_SHUTDOWN = 14,
    CASSOTIS_MESSAGE_ERROR = 15,
    CASSOTIS_MESSAGE_CLEAR_USER_DICTIONARY = 16
} CassotisMessageType;

typedef enum {
    CASSOTIS_KEY_NONE = 0,
    CASSOTIS_KEY_BACKSPACE = 1,
    CASSOTIS_KEY_DELETE = 2,
    CASSOTIS_KEY_ENTER = 3,
    CASSOTIS_KEY_ESCAPE = 4,
    CASSOTIS_KEY_SPACE = 5,
    CASSOTIS_KEY_TAB = 6,
    CASSOTIS_KEY_LEFT = 7,
    CASSOTIS_KEY_RIGHT = 8,
    CASSOTIS_KEY_UP = 9,
    CASSOTIS_KEY_DOWN = 10,
    CASSOTIS_KEY_HOME = 11,
    CASSOTIS_KEY_END = 12,
    CASSOTIS_KEY_PAGE_UP = 13,
    CASSOTIS_KEY_PAGE_DOWN = 14,
    CASSOTIS_KEY_NUMPAD_MULTIPLY = 15,
    CASSOTIS_KEY_NUMPAD_ADD = 16,
    CASSOTIS_KEY_NUMPAD_SUBTRACT = 17,
    CASSOTIS_KEY_NUMPAD_DECIMAL = 18,
    CASSOTIS_KEY_NUMPAD_DIVIDE = 19,
    CASSOTIS_KEY_SHIFT = 20,
    CASSOTIS_KEY_CONTROL = 21,
    CASSOTIS_KEY_ALT = 22,
    CASSOTIS_KEY_SUPER = 23,
    CASSOTIS_KEY_F1 = 24,
    CASSOTIS_KEY_F2 = 25,
    CASSOTIS_KEY_F3 = 26,
    CASSOTIS_KEY_F4 = 27,
    CASSOTIS_KEY_F5 = 28,
    CASSOTIS_KEY_F6 = 29,
    CASSOTIS_KEY_F7 = 30,
    CASSOTIS_KEY_F8 = 31,
    CASSOTIS_KEY_F9 = 32,
    CASSOTIS_KEY_F10 = 33,
    CASSOTIS_KEY_F11 = 34,
    CASSOTIS_KEY_F12 = 35,
    CASSOTIS_KEY_F13 = 36,
    CASSOTIS_KEY_F14 = 37,
    CASSOTIS_KEY_F15 = 38,
    CASSOTIS_KEY_F16 = 39,
    CASSOTIS_KEY_F17 = 40,
    CASSOTIS_KEY_F18 = 41,
    CASSOTIS_KEY_F19 = 42,
    CASSOTIS_KEY_F20 = 43,
    CASSOTIS_KEY_F21 = 44,
    CASSOTIS_KEY_F22 = 45,
    CASSOTIS_KEY_F23 = 46,
    CASSOTIS_KEY_F24 = 47
} CassotisSpecialKey;

typedef enum {
    CASSOTIS_MODIFIER_SHIFT = 1U << 0,
    CASSOTIS_MODIFIER_CONTROL = 1U << 1,
    CASSOTIS_MODIFIER_ALT = 1U << 2,
    CASSOTIS_MODIFIER_SUPER = 1U << 3,
    CASSOTIS_MODIFIER_CAPS_LOCK = 1U << 4,
    CASSOTIS_MODIFIER_NUM_LOCK = 1U << 5
} CassotisModifier;

typedef enum {
    CASSOTIS_INPUT_CHINESE = 0,
    CASSOTIS_INPUT_ENGLISH = 1
} CassotisInputMode;

typedef enum {
    CASSOTIS_DICTIONARY_SIMPLIFIED = 0,
    CASSOTIS_DICTIONARY_TRADITIONAL = 1
} CassotisDictionaryVariant;

typedef enum {
    CASSOTIS_PINYIN_FULL = 0,
    CASSOTIS_PINYIN_MICROSOFT = 1,
    CASSOTIS_PINYIN_XIAOHE = 2,
    CASSOTIS_PINYIN_ZIRANMA = 3,
    CASSOTIS_PINYIN_SOGOU = 4,
    CASSOTIS_PINYIN_ZIGUANG = 5,
    CASSOTIS_PINYIN_PINYINJIAJIA = 6
} CassotisPinyinScheme;

typedef enum {
    CASSOTIS_PAGE_KEYS_MINUS_PLUS = 0,
    CASSOTIS_PAGE_KEYS_BRACKETS = 1,
    CASSOTIS_PAGE_KEYS_COMMA_PERIOD = 2,
    CASSOTIS_PAGE_KEYS_SHIFT_TAB = 3
} CassotisCandidatePageKeyScheme;

typedef enum {
    CASSOTIS_COMPLETION_TAB = 0,
    CASSOTIS_COMPLETION_BACKTICK = 1
} CassotisOneKeyCompletionKey;

typedef enum {
    CASSOTIS_FUZZY_Z_ZH = 1U << 0,
    CASSOTIS_FUZZY_C_CH = 1U << 1,
    CASSOTIS_FUZZY_S_SH = 1U << 2,
    CASSOTIS_FUZZY_L_N = 1U << 3,
    CASSOTIS_FUZZY_F_H = 1U << 4,
    CASSOTIS_FUZZY_R_L = 1U << 5,
    CASSOTIS_FUZZY_AN_ANG = 1U << 6,
    CASSOTIS_FUZZY_EN_ENG = 1U << 7,
    CASSOTIS_FUZZY_IN_ING = 1U << 8,
    CASSOTIS_FUZZY_IAN_IANG = 1U << 9,
    CASSOTIS_FUZZY_UAN_UANG = 1U << 10
} CassotisFuzzyRule;

#define CASSOTIS_FUZZY_RULE_COUNT 11U
#define CASSOTIS_FUZZY_RULE_MASK ((1U << CASSOTIS_FUZZY_RULE_COUNT) - 1U)

typedef struct {
    guint16 key_code;
    guint8 modifiers;
} CassotisShortcut;

typedef struct {
    CassotisShortcut input_mode_toggle;
    CassotisShortcut punctuation_toggle;
    CassotisShortcut dictionary_variant_toggle;
    CassotisShortcut full_width_toggle;
    CassotisShortcut open_settings;
} CassotisShortcutConfig;

typedef struct {
    CassotisInputMode input_mode;
    CassotisDictionaryVariant dictionary_variant;
    CassotisPinyinScheme pinyin_scheme;
    gboolean fuzzy_pinyin_enabled;
    guint32 fuzzy_pinyin_rules;
    gboolean full_width_mode;
    gboolean punctuation_full_width;
    guint8 candidate_page_size;
    CassotisCandidatePageKeyScheme candidate_page_key_scheme;
    CassotisOneKeyCompletionKey one_key_completion_key;
    gboolean debug_mode;
    CassotisShortcutConfig shortcuts;
} CassotisEngineState;

typedef struct {
    gchar *text;
    gchar *comment;
    gint32 score;
    gint32 dictionary_weight;
    gboolean has_dictionary_weight;
    gboolean deletable;
} CassotisCandidate;

typedef struct {
    gboolean handled;
    gchar *commit_text;
    gchar *preedit_text;
    gchar *query_text;
    gchar *completion_text;
    gchar *error_text;
    guint32 error_code;
    gint32 selected_index;
    gint32 page_index;
    gint32 page_count;
    CassotisCandidate *candidates;
    guint32 candidate_count;
} CassotisEngineResult;

typedef struct {
    guint16 message_type;
    guint32 flags;
    guint64 request_id;
    guint64 context_id;
    guint64 generation_id;
    guint32 payload_length;
} CassotisFrameHeader;

GByteArray *cassotis_protocol_build_empty_request(
    CassotisMessageType message_type,
    guint64 request_id,
    guint64 context_id,
    guint64 generation_id);

GByteArray *cassotis_protocol_build_set_active_request(
    guint64 request_id,
    guint64 context_id,
    guint64 generation_id,
    gboolean active);

GByteArray *cassotis_protocol_build_set_surrounding_request(
    guint64 request_id,
    guint64 context_id,
    guint64 generation_id,
    gint32 cursor_offset,
    const gchar *text);

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
    const gchar *text);

GByteArray *cassotis_protocol_build_set_state_request(
    guint64 request_id,
    const CassotisEngineState *state);

void cassotis_engine_state_init_defaults(CassotisEngineState *state);

gboolean cassotis_protocol_parse_header(
    const guint8 *data,
    gsize length,
    CassotisFrameHeader *header,
    GError **error);

gboolean cassotis_protocol_decode_engine_result(
    const guint8 *payload,
    gsize payload_length,
    CassotisEngineResult *result,
    GError **error);

gboolean cassotis_protocol_decode_engine_state(
    const guint8 *payload,
    gsize payload_length,
    CassotisEngineState *state,
    GError **error);

gboolean cassotis_protocol_decode_error(
    const guint8 *payload,
    gsize payload_length,
    guint32 *error_code,
    gchar **error_text,
    GError **error);

void cassotis_engine_result_clear(CassotisEngineResult *result);
GQuark cassotis_protocol_error_quark(void);

G_END_DECLS

#endif
