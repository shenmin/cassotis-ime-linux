#include "cassotis_client.h"
#include "cassotis_candidate_layout.h"
#include "cassotis_shortcut_match.h"

#include <errno.h>
#include <glib/gstdio.h>
#include <ibus.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#define CASSOTIS_ENGINE_NAME "cassotis"
#define CASSOTIS_BUS_NAME "org.freedesktop.IBus.Cassotis"
#define CASSOTIS_DEFAULT_PAGE_SIZE 9U
#define CASSOTIS_SURROUNDING_RADIUS 2048U
#define CASSOTIS_STATE_POLL_INTERVAL_MS 500U
#define CASSOTIS_PROP_INPUT_MODE "InputMode"
#define CASSOTIS_PROP_PUNCTUATION "Punctuation"
#define CASSOTIS_PROP_WIDTH "CharacterWidth"
#define CASSOTIS_PROP_PINYIN_SCHEME "PinyinScheme"
#define CASSOTIS_PROP_SCHEME_PREFIX "PinyinScheme."
#define CASSOTIS_PROP_FUZZY_PINYIN "FuzzyPinyin"
#define CASSOTIS_PROP_FUZZY_ENABLED "FuzzyPinyin.Enabled"
#define CASSOTIS_PROP_FUZZY_RULE_PREFIX "FuzzyPinyin.Rule."
#define CASSOTIS_PROP_SETTINGS "Settings"
#define CASSOTIS_DEFAULT_FUZZY_RULES                                  \
    (CASSOTIS_FUZZY_Z_ZH | CASSOTIS_FUZZY_C_CH |                    \
     CASSOTIS_FUZZY_S_SH | CASSOTIS_FUZZY_L_N |                     \
     CASSOTIS_FUZZY_AN_ANG | CASSOTIS_FUZZY_EN_ENG |                \
     CASSOTIS_FUZZY_IN_ING)
#define CASSOTIS_INPUT_HINT_HIDDEN_TEXT (1U << 12)

typedef struct {
    IBusEngine parent;
    guint64 context_id;
    guint64 generation_id;
    guint64 client_generation;
    gboolean context_created;
    gboolean context_active;
    gboolean desired_active;
    gboolean enabled;
    gboolean focused;
    gboolean has_surrounding;
    gboolean surrounding_dirty;
    gchar *surrounding_text;
    gint32 surrounding_cursor;
    gint32 page_index;
    guint input_purpose;
    guint input_hints;
    guint state_poll_id;
    guint32 rendered_page_candidate_count;
    gboolean rendered_completion_row;
    CassotisEngineState state;
    gboolean state_valid;
} CassotisIbusEngine;

typedef struct {
    IBusEngineClass parent;
} CassotisIbusEngineClass;

static CassotisClient global_client;
static gchar *global_settings_path;
static guint64 next_context_id = 1;

G_DEFINE_TYPE(CassotisIbusEngine, cassotis_ibus_engine, IBUS_TYPE_ENGINE)

static void log_client_error(const gchar *operation, GError *error)
{
    g_warning("Cassotis %s: %s", operation,
              error != NULL ? error->message : "unknown error");
    g_clear_error(&error);
}

static void clear_ui(IBusEngine *engine)
{
    ibus_engine_hide_preedit_text(engine);
    ibus_engine_hide_lookup_table(engine);
    ibus_engine_hide_auxiliary_text(engine);
}

static guint effective_page_size(const CassotisEngineState *state)
{
    if (state != NULL && state->candidate_page_size >= 3U &&
        state->candidate_page_size <= 9U)
        return state->candidate_page_size;
    return CASSOTIS_DEFAULT_PAGE_SIZE;
}

static gboolean is_sensitive_context(const CassotisIbusEngine *self)
{
    return self->input_purpose == IBUS_INPUT_PURPOSE_PASSWORD ||
           self->input_purpose == IBUS_INPUT_PURPOSE_PIN ||
           (self->input_hints & CASSOTIS_INPUT_HINT_HIDDEN_TEXT) != 0;
}

static IBusProperty *new_property(const gchar *key,
                                  IBusPropType type,
                                  const gchar *label,
                                  const gchar *tooltip,
                                  IBusPropState state,
                                  IBusPropList *sub_properties)
{
    return ibus_property_new(key, type, ibus_text_new_from_string(label), "",
                             ibus_text_new_from_string(tooltip), TRUE, TRUE,
                             state, sub_properties);
}

static void register_properties(CassotisIbusEngine *self)
{
    IBusPropList *properties;
    IBusProperty *property;

    if (!self->enabled || !self->focused)
        return;
    properties = ibus_prop_list_new();
    property = new_property(
        CASSOTIS_PROP_SETTINGS, PROP_TYPE_NORMAL,
        "\xE8\xAE\xBE\xE7\xBD\xAE",
        "Cassotis IME settings", PROP_STATE_UNCHECKED, NULL);
    ibus_prop_list_append(properties, property);
    ibus_engine_register_properties(IBUS_ENGINE(self), properties);
}

static gboolean refresh_engine_state(CassotisIbusEngine *self)
{
    CassotisEngineState observed_state;
    GError *error = NULL;
    gboolean changed;

    if (!cassotis_client_get_state(&global_client, &observed_state, &error)) {
        self->state_valid = FALSE;
        log_client_error("get engine state failed", error);
        return FALSE;
    }
    changed = !self->state_valid ||
              self->state.input_mode != observed_state.input_mode ||
              self->state.dictionary_variant !=
                  observed_state.dictionary_variant ||
              self->state.pinyin_scheme != observed_state.pinyin_scheme ||
              self->state.fuzzy_pinyin_enabled !=
                  observed_state.fuzzy_pinyin_enabled ||
              self->state.fuzzy_pinyin_rules !=
                  observed_state.fuzzy_pinyin_rules ||
              self->state.full_width_mode != observed_state.full_width_mode ||
              self->state.punctuation_full_width !=
                  observed_state.punctuation_full_width ||
              self->state.candidate_page_size !=
                  observed_state.candidate_page_size ||
              self->state.candidate_page_key_scheme !=
                  observed_state.candidate_page_key_scheme ||
              self->state.one_key_completion_key !=
                  observed_state.one_key_completion_key ||
              self->state.debug_mode != observed_state.debug_mode ||
              memcmp(&self->state.shortcuts, &observed_state.shortcuts,
                     sizeof(self->state.shortcuts)) != 0;
    self->state = observed_state;
    self->state_valid = TRUE;
    if (changed)
        clear_ui(IBUS_ENGINE(self));
    return TRUE;
}

static gboolean poll_engine_state(gpointer user_data)
{
    CassotisIbusEngine *self = user_data;

    if (!self->focused || !self->enabled) {
        self->state_poll_id = 0;
        return G_SOURCE_REMOVE;
    }
    refresh_engine_state(self);
    return G_SOURCE_CONTINUE;
}

static void stop_state_polling(CassotisIbusEngine *self)
{
    guint source_id = self->state_poll_id;

    self->state_poll_id = 0;
    if (source_id != 0)
        g_source_remove(source_id);
}

static void start_state_polling(CassotisIbusEngine *self)
{
    if (self->state_poll_id != 0 || !self->focused || !self->enabled)
        return;
    self->state_poll_id = g_timeout_add(
        CASSOTIS_STATE_POLL_INTERVAL_MS, poll_engine_state, self);
}

static gboolean update_engine_state(CassotisIbusEngine *self,
                                    const CassotisEngineState *state)
{
    GError *error = NULL;
    if (!cassotis_client_set_state(&global_client, state, &error)) {
        self->state_valid = FALSE;
        log_client_error("set engine state failed", error);
        return FALSE;
    }
    self->state = *state;
    self->state_valid = TRUE;
    clear_ui(IBUS_ENGINE(self));
    return TRUE;
}

static void mark_context_lost(CassotisIbusEngine *self)
{
    self->context_created = FALSE;
    self->context_active = FALSE;
    self->surrounding_dirty = self->has_surrounding;
    self->state_valid = FALSE;
}

static gboolean ensure_context(CassotisIbusEngine *self)
{
    GError *error = NULL;
    guint64 client_generation;

    if (!cassotis_client_prepare(&global_client, &error)) {
        mark_context_lost(self);
        log_client_error("connect to engine failed", error);
        return FALSE;
    }
    client_generation =
        cassotis_client_connection_generation(&global_client);
    if (self->client_generation != client_generation) {
        mark_context_lost(self);
        self->client_generation = client_generation;
    }
    if (self->context_created)
        return TRUE;
    if (!cassotis_client_create_context(&global_client, self->context_id,
                                        &error)) {
        log_client_error("create context failed", error);
        return FALSE;
    }
    self->client_generation =
        cassotis_client_connection_generation(&global_client);
    self->context_created = TRUE;
    self->context_active = FALSE;
    self->surrounding_dirty = self->has_surrounding;
    return TRUE;
}

static gboolean synchronize_context(CassotisIbusEngine *self)
{
    GError *error = NULL;
    if (!ensure_context(self))
        return FALSE;
    if (self->surrounding_dirty) {
        ++self->generation_id;
        if (!cassotis_client_set_surrounding(
                &global_client, self->context_id, self->generation_id,
                self->surrounding_text, self->surrounding_cursor, &error)) {
            mark_context_lost(self);
            log_client_error("set surrounding text failed", error);
            return FALSE;
        }
        self->surrounding_dirty = FALSE;
    }
    if (self->context_active != self->desired_active) {
        ++self->generation_id;
        if (!cassotis_client_set_active(
                &global_client, self->context_id, self->generation_id,
                self->desired_active, &error)) {
            mark_context_lost(self);
            log_client_error("set active state failed", error);
            return FALSE;
        }
        self->context_active = self->desired_active;
    }
    return TRUE;
}

static gchar *candidate_display_text(const CassotisEngineState *state,
                                     const CassotisCandidate *candidate)
{
    const gchar *candidate_text =
        candidate->text != NULL ? candidate->text : "";

    if (state->debug_mode && candidate->has_dictionary_weight) {
        return g_strdup_printf("%s\n%d", candidate_text,
                               candidate->dictionary_weight);
    }
    return g_strdup(candidate_text);
}

static void render_result(CassotisIbusEngine *self,
                          CassotisEngineResult *result)
{
    IBusEngine *engine = IBUS_ENGINE(self);
    IBusText *text;
    IBusLookupTable *table;
    guint32 index;
    gchar *display_text;
    gboolean has_completion;
    gboolean vertical;
    guint page_size;

    if (result->commit_text != NULL && result->commit_text[0] != '\0') {
        text = ibus_text_new_from_string(result->commit_text);
        ibus_engine_commit_text(engine, text);
    }

    if (result->preedit_text != NULL && result->preedit_text[0] != '\0') {
        text = ibus_text_new_from_string(result->preedit_text);
        ibus_engine_update_preedit_text(
            engine, text, (guint)g_utf8_strlen(result->preedit_text, -1), TRUE);
    } else {
        ibus_engine_hide_preedit_text(engine);
    }

    has_completion = result->completion_text != NULL &&
                     result->completion_text[0] != '\0';
    /* GNOME Shell fixes auxiliary text above the lookup table.  Completion
       is represented as a dedicated lookup row so it is actually below the
       candidates and remains clickable without changing engine candidates. */
    ibus_engine_hide_auxiliary_text(engine);

    if (result->candidate_count == 0 && !has_completion) {
        ibus_engine_hide_lookup_table(engine);
        self->page_index = 0;
        self->rendered_page_candidate_count = 0;
        self->rendered_completion_row = FALSE;
        return;
    }

    vertical = cassotis_candidate_panel_requires_vertical(result);
    page_size = effective_page_size(&self->state);
    table = ibus_lookup_table_new(
        has_completion ? page_size + 1U : page_size,
        0, TRUE, TRUE);
    ibus_lookup_table_set_orientation(
        table, vertical ? IBUS_ORIENTATION_VERTICAL
                        : IBUS_ORIENTATION_HORIZONTAL);

    if (has_completion) {
        for (index = 0; index < result->candidate_count; ++index) {
            gchar label_text[2] = {(gchar)('1' + index), '\0'};
            IBusText *label = ibus_text_new_from_string(label_text);
            ibus_lookup_table_append_label(table, label);
        }
        ibus_lookup_table_append_label(
            table, ibus_text_new_from_string("Tab"));
        for (index = 0; index < result->candidate_count; ++index) {
            display_text = candidate_display_text(
                &self->state, &result->candidates[index]);
            text = ibus_text_new_from_string(display_text);
            ibus_lookup_table_append_candidate(table, text);
            g_free(display_text);
        }
        display_text = g_strdup_printf(
            result->candidate_count == page_size
                ? "\xE2\x87\xA5%s"
                : "Tab  \xE2\x87\xA5%s",
            result->completion_text);
        text = ibus_text_new_from_string(display_text);
        ibus_lookup_table_append_candidate(table, text);
        g_free(display_text);
        self->rendered_page_candidate_count = result->candidate_count;
        self->rendered_completion_row = TRUE;
    } else {
        for (index = 0; index < result->candidate_count; ++index) {
            display_text = candidate_display_text(
                &self->state, &result->candidates[index]);
            text = ibus_text_new_from_string(display_text);
            ibus_lookup_table_append_candidate(table, text);
            g_free(display_text);
        }
        self->rendered_page_candidate_count = result->candidate_count;
        self->rendered_completion_row = FALSE;
    }
    if (result->selected_index >= 0 &&
        (guint32)result->selected_index < result->candidate_count) {
        ibus_lookup_table_set_cursor_pos(
            table, (guint32)result->selected_index);
    }
    self->page_index = result->page_index;
    ibus_engine_update_lookup_table(engine, table, TRUE);
}

static gboolean send_key_event(CassotisIbusEngine *self,
                               CassotisSpecialKey special_key,
                               guint32 modifiers,
                               guint32 scan_code,
                               gboolean is_release,
                               gboolean is_repeat,
                               const gchar *text_value)
{
    CassotisEngineResult result;
    GError *error = NULL;
    gboolean success;
    gint attempt;

    memset(&result, 0, sizeof(result));
    result.selected_index = -1;
    for (attempt = 0; attempt < 2; ++attempt) {
        if (!synchronize_context(self))
            return FALSE;
        ++self->generation_id;
        success = cassotis_client_process_key(
            &global_client, self->context_id, self->generation_id,
            special_key, modifiers, scan_code, is_release, is_repeat,
            (guint64)(g_get_monotonic_time() / 1000), text_value, &result,
            &error);
        if (!success) {
            mark_context_lost(self);
            clear_ui(IBUS_ENGINE(self));
            log_client_error("process key failed", error);
            return FALSE;
        }
        if (result.error_code == 1 && attempt == 0) {
            cassotis_engine_result_clear(&result);
            mark_context_lost(self);
            continue;
        }
        break;
    }
    if (result.error_code != 0)
        g_warning("Cassotis engine result error %u: %s", result.error_code,
                  result.error_text != NULL ? result.error_text : "");
    success = result.handled;
    if (success)
        render_result(self, &result);
    cassotis_engine_result_clear(&result);
    return success;
}

static gboolean send_key(CassotisIbusEngine *self,
                         CassotisSpecialKey special_key,
                         guint32 modifiers,
                         guint32 scan_code,
                         const gchar *text_value)
{
    return send_key_event(self, special_key, modifiers, scan_code, FALSE,
                          FALSE, text_value);
}

static CassotisSpecialKey translate_special_key(guint keyval)
{
    if (keyval >= IBUS_KEY_F1 && keyval <= IBUS_KEY_F24)
        return (CassotisSpecialKey)(CASSOTIS_KEY_F1 + keyval - IBUS_KEY_F1);

    switch (keyval) {
    case IBUS_KEY_BackSpace:
        return CASSOTIS_KEY_BACKSPACE;
    case IBUS_KEY_Delete:
    case IBUS_KEY_KP_Delete:
        return CASSOTIS_KEY_DELETE;
    case IBUS_KEY_Return:
    case IBUS_KEY_KP_Enter:
        return CASSOTIS_KEY_ENTER;
    case IBUS_KEY_Escape:
        return CASSOTIS_KEY_ESCAPE;
    case IBUS_KEY_space:
    case IBUS_KEY_KP_Space:
        return CASSOTIS_KEY_SPACE;
    case IBUS_KEY_Tab:
    case IBUS_KEY_ISO_Left_Tab:
        return CASSOTIS_KEY_TAB;
    case IBUS_KEY_Left:
    case IBUS_KEY_KP_Left:
        return CASSOTIS_KEY_LEFT;
    case IBUS_KEY_Right:
    case IBUS_KEY_KP_Right:
        return CASSOTIS_KEY_RIGHT;
    case IBUS_KEY_Up:
    case IBUS_KEY_KP_Up:
        return CASSOTIS_KEY_UP;
    case IBUS_KEY_Down:
    case IBUS_KEY_KP_Down:
        return CASSOTIS_KEY_DOWN;
    case IBUS_KEY_Home:
    case IBUS_KEY_KP_Home:
        return CASSOTIS_KEY_HOME;
    case IBUS_KEY_End:
    case IBUS_KEY_KP_End:
        return CASSOTIS_KEY_END;
    case IBUS_KEY_Page_Up:
    case IBUS_KEY_KP_Page_Up:
        return CASSOTIS_KEY_PAGE_UP;
    case IBUS_KEY_Page_Down:
    case IBUS_KEY_KP_Page_Down:
        return CASSOTIS_KEY_PAGE_DOWN;
    case IBUS_KEY_KP_Multiply:
        return CASSOTIS_KEY_NUMPAD_MULTIPLY;
    case IBUS_KEY_KP_Add:
        return CASSOTIS_KEY_NUMPAD_ADD;
    case IBUS_KEY_KP_Subtract:
        return CASSOTIS_KEY_NUMPAD_SUBTRACT;
    case IBUS_KEY_KP_Decimal:
        return CASSOTIS_KEY_NUMPAD_DECIMAL;
    case IBUS_KEY_KP_Divide:
        return CASSOTIS_KEY_NUMPAD_DIVIDE;
    case IBUS_KEY_Shift_L:
    case IBUS_KEY_Shift_R:
        return CASSOTIS_KEY_SHIFT;
    case IBUS_KEY_Control_L:
    case IBUS_KEY_Control_R:
        return CASSOTIS_KEY_CONTROL;
    case IBUS_KEY_Alt_L:
    case IBUS_KEY_Alt_R:
        return CASSOTIS_KEY_ALT;
    case IBUS_KEY_Super_L:
    case IBUS_KEY_Super_R:
        return CASSOTIS_KEY_SUPER;
    default:
        return CASSOTIS_KEY_NONE;
    }
}

static guint32 translate_modifiers(guint state)
{
    guint32 result = 0;
    if ((state & IBUS_SHIFT_MASK) != 0)
        result |= CASSOTIS_MODIFIER_SHIFT;
    if ((state & IBUS_CONTROL_MASK) != 0)
        result |= CASSOTIS_MODIFIER_CONTROL;
    if ((state & IBUS_MOD1_MASK) != 0)
        result |= CASSOTIS_MODIFIER_ALT;
    if ((state & IBUS_SUPER_MASK) != 0)
        result |= CASSOTIS_MODIFIER_SUPER;
    if ((state & IBUS_LOCK_MASK) != 0)
        result |= CASSOTIS_MODIFIER_CAPS_LOCK;
    if ((state & IBUS_MOD2_MASK) != 0)
        result |= CASSOTIS_MODIFIER_NUM_LOCK;
    return result;
}

static void launch_settings(void)
{
    gchar *arguments[] = {global_settings_path, NULL};
    GError *error = NULL;
    GSpawnFlags flags = G_SPAWN_STDOUT_TO_DEV_NULL |
                        G_SPAWN_STDERR_TO_DEV_NULL;

    if (global_settings_path == NULL ||
        !g_spawn_async(NULL, arguments, NULL, flags, NULL, NULL, NULL,
                       &error))
        log_client_error("launch settings failed", error);
}

static gboolean cassotis_process_key_event(IBusEngine *engine,
                                           guint keyval,
                                           guint keycode,
                                           guint state)
{
    CassotisIbusEngine *self = (CassotisIbusEngine *)engine;
    CassotisSpecialKey special_key;
    gunichar unicode_value;
    gchar text_value[8] = {0};
    guint32 modifiers;
    gboolean is_release;

    if (is_sensitive_context(self))
        return FALSE;
    is_release = (state & IBUS_RELEASE_MASK) != 0;
    modifiers = translate_modifiers(state);
    if (keyval == IBUS_KEY_Shift_L || keyval == IBUS_KEY_Shift_R)
        modifiers |= CASSOTIS_MODIFIER_SHIFT;
    else if (keyval == IBUS_KEY_Control_L || keyval == IBUS_KEY_Control_R)
        modifiers |= CASSOTIS_MODIFIER_CONTROL;
    else if (keyval == IBUS_KEY_Alt_L || keyval == IBUS_KEY_Alt_R)
        modifiers |= CASSOTIS_MODIFIER_ALT;
    else if (keyval == IBUS_KEY_Super_L || keyval == IBUS_KEY_Super_R)
        modifiers |= CASSOTIS_MODIFIER_SUPER;
    special_key = translate_special_key(keyval);
    if (is_release) {
        gboolean handled;
        if (special_key != CASSOTIS_KEY_SHIFT)
            return FALSE;
        handled = send_key_event(self, special_key, modifiers, keycode, TRUE,
                                 FALSE, "");
        if (handled)
            refresh_engine_state(self);
        /* The matching Shift press is passed through to the application.
           Passing the release through as well prevents a latched Shift state
           after Cassotis handles the bare-Shift mode toggle internally. */
        return FALSE;
    }
    if ((!self->state_valid && !refresh_engine_state(self)))
        return FALSE;
    if (cassotis_shortcut_matches_keysym(
            &self->state.shortcuts.open_settings, keyval, modifiers)) {
        launch_settings();
        return TRUE;
    }
    if (special_key != CASSOTIS_KEY_NONE)
        return send_key(self, special_key, modifiers, keycode, "");

    unicode_value = ibus_keyval_to_unicode(keyval);
    if (unicode_value >= 0x21U && unicode_value <= 0x7eU) {
        text_value[0] = (gchar)unicode_value;
        return send_key(self, CASSOTIS_KEY_NONE, modifiers, keycode,
                        text_value);
    }
    return FALSE;
}

static gint32 utf16_length_between(const gchar *start, const gchar *end)
{
    const gchar *cursor = start;
    gint32 length = 0;
    while (cursor < end && *cursor != '\0') {
        gunichar value = g_utf8_get_char(cursor);
        length += value > 0xffffU ? 2 : 1;
        cursor = g_utf8_next_char(cursor);
    }
    return length;
}

static void cache_surrounding_text(CassotisIbusEngine *self,
                                   const gchar *source,
                                   guint cursor_pos)
{
    glong character_count;
    glong start_index;
    glong end_index;
    const gchar *start;
    const gchar *cursor;
    const gchar *end;
    gchar *text;
    gint32 utf16_cursor;

    if (source == NULL || !g_utf8_validate(source, -1, NULL))
        source = "";
    character_count = g_utf8_strlen(source, -1);
    if ((glong)cursor_pos > character_count)
        cursor_pos = (guint)character_count;
    start_index = cursor_pos > CASSOTIS_SURROUNDING_RADIUS
                      ? (glong)cursor_pos - CASSOTIS_SURROUNDING_RADIUS
                      : 0;
    end_index = MIN(character_count,
                    (glong)cursor_pos + CASSOTIS_SURROUNDING_RADIUS);
    start = g_utf8_offset_to_pointer(source, start_index);
    cursor = g_utf8_offset_to_pointer(source, cursor_pos);
    end = g_utf8_offset_to_pointer(source, end_index);
    text = g_strndup(start, (gsize)(end - start));
    utf16_cursor = utf16_length_between(start, cursor);

    if (!self->has_surrounding || self->surrounding_cursor != utf16_cursor ||
        g_strcmp0(self->surrounding_text, text) != 0) {
        g_free(self->surrounding_text);
        self->surrounding_text = text;
        self->surrounding_cursor = utf16_cursor;
        self->has_surrounding = TRUE;
        self->surrounding_dirty = TRUE;
    } else {
        g_free(text);
    }
}

static void cassotis_set_surrounding_text(IBusEngine *engine,
                                          IBusText *text,
                                          guint cursor_pos,
                                          guint anchor_pos)
{
    CassotisIbusEngine *self = (CassotisIbusEngine *)engine;
    const gchar *value = text != NULL ? ibus_text_get_text(text) : "";
    (void)anchor_pos;
    cache_surrounding_text(self, value, cursor_pos);
    synchronize_context(self);
}

static void cassotis_enable(IBusEngine *engine)
{
    CassotisIbusEngine *self = (CassotisIbusEngine *)engine;
    if (IBUS_ENGINE_CLASS(cassotis_ibus_engine_parent_class)->enable != NULL)
        IBUS_ENGINE_CLASS(cassotis_ibus_engine_parent_class)->enable(engine);
    self->enabled = TRUE;
    self->desired_active = self->focused && !is_sensitive_context(self);
    ibus_engine_get_surrounding_text(engine, NULL, NULL, NULL);
    synchronize_context(self);
    refresh_engine_state(self);
    register_properties(self);
    start_state_polling(self);
}

static void cassotis_disable(IBusEngine *engine)
{
    CassotisIbusEngine *self = (CassotisIbusEngine *)engine;
    stop_state_polling(self);
    self->enabled = FALSE;
    self->desired_active = FALSE;
    synchronize_context(self);
    clear_ui(engine);
    if (IBUS_ENGINE_CLASS(cassotis_ibus_engine_parent_class)->disable != NULL)
        IBUS_ENGINE_CLASS(cassotis_ibus_engine_parent_class)->disable(engine);
}

static void cassotis_focus_in(IBusEngine *engine)
{
    CassotisIbusEngine *self = (CassotisIbusEngine *)engine;
    if (IBUS_ENGINE_CLASS(cassotis_ibus_engine_parent_class)->focus_in != NULL)
        IBUS_ENGINE_CLASS(cassotis_ibus_engine_parent_class)->focus_in(engine);
    self->focused = TRUE;
    self->desired_active = self->enabled && !is_sensitive_context(self);
    synchronize_context(self);
    refresh_engine_state(self);
    register_properties(self);
    start_state_polling(self);
}

static void cassotis_focus_out(IBusEngine *engine)
{
    CassotisIbusEngine *self = (CassotisIbusEngine *)engine;
    stop_state_polling(self);
    self->focused = FALSE;
    self->desired_active = FALSE;
    synchronize_context(self);
    clear_ui(engine);
    if (IBUS_ENGINE_CLASS(cassotis_ibus_engine_parent_class)->focus_out != NULL)
        IBUS_ENGINE_CLASS(cassotis_ibus_engine_parent_class)->focus_out(engine);
}

static void cassotis_reset(IBusEngine *engine)
{
    CassotisIbusEngine *self = (CassotisIbusEngine *)engine;
    GError *error = NULL;
    if (ensure_context(self)) {
        ++self->generation_id;
        if (!cassotis_client_reset_context(&global_client, self->context_id,
                                           self->generation_id, &error)) {
            mark_context_lost(self);
            log_client_error("reset context failed", error);
        }
    }
    clear_ui(engine);
}

static void cassotis_set_content_type(IBusEngine *engine,
                                      guint purpose,
                                      guint hints)
{
    CassotisIbusEngine *self = (CassotisIbusEngine *)engine;
    gboolean was_sensitive = is_sensitive_context(self);

    self->input_purpose = purpose;
    self->input_hints = hints;
    self->desired_active =
        self->enabled && self->focused && !is_sensitive_context(self);
    if (!was_sensitive && is_sensitive_context(self))
        cassotis_reset(engine);
    synchronize_context(self);
    if (is_sensitive_context(self))
        clear_ui(engine);
}

static void cassotis_page_up(IBusEngine *engine)
{
    send_key((CassotisIbusEngine *)engine, CASSOTIS_KEY_PAGE_UP, 0, 0, "");
}

static void cassotis_page_down(IBusEngine *engine)
{
    send_key((CassotisIbusEngine *)engine, CASSOTIS_KEY_PAGE_DOWN, 0, 0, "");
}

static void cassotis_cursor_up(IBusEngine *engine)
{
    send_key((CassotisIbusEngine *)engine, CASSOTIS_KEY_UP, 0, 0, "");
}

static void cassotis_cursor_down(IBusEngine *engine)
{
    send_key((CassotisIbusEngine *)engine, CASSOTIS_KEY_DOWN, 0, 0, "");
}

static void cassotis_candidate_clicked(IBusEngine *engine,
                                       guint index,
                                       guint button,
                                       guint state)
{
    CassotisIbusEngine *self = (CassotisIbusEngine *)engine;
    gchar selection[2] = {0};
    guint local_index;
    guint page_size;
    (void)state;
    if (button != 1)
        return;
    page_size = effective_page_size(&self->state);
    local_index = index % (self->rendered_completion_row
                               ? page_size + 1U
                               : page_size);
    if (self->rendered_completion_row &&
        local_index == self->rendered_page_candidate_count) {
        send_key(self, CASSOTIS_KEY_TAB, 0, 0, "");
        return;
    }
    if (local_index >= self->rendered_page_candidate_count)
        return;
    selection[0] = (gchar)('1' + local_index);
    send_key(self, CASSOTIS_KEY_NONE, 0, 0, selection);
}

static void cassotis_property_activate(IBusEngine *engine,
                                       const gchar *property_name,
                                       guint property_state)
{
    CassotisIbusEngine *self = (CassotisIbusEngine *)engine;
    CassotisEngineState state;
    gchar *end = NULL;
    guint64 scheme;
    guint64 fuzzy_rule;
    (void)property_state;

    if (g_strcmp0(property_name, CASSOTIS_PROP_SETTINGS) == 0) {
        launch_settings();
        return;
    }
    if (!self->state_valid && !refresh_engine_state(self))
        return;
    state = self->state;
    if (g_strcmp0(property_name, CASSOTIS_PROP_INPUT_MODE) == 0) {
        state.input_mode = state.input_mode == CASSOTIS_INPUT_CHINESE
                               ? CASSOTIS_INPUT_ENGLISH
                               : CASSOTIS_INPUT_CHINESE;
    } else if (g_strcmp0(property_name, CASSOTIS_PROP_PUNCTUATION) == 0) {
        state.punctuation_full_width = !state.punctuation_full_width;
    } else if (g_strcmp0(property_name, CASSOTIS_PROP_WIDTH) == 0) {
        state.full_width_mode = !state.full_width_mode;
    } else if (g_strcmp0(property_name,
                         CASSOTIS_PROP_FUZZY_ENABLED) == 0) {
        state.fuzzy_pinyin_enabled = !state.fuzzy_pinyin_enabled;
        if (state.fuzzy_pinyin_enabled && state.fuzzy_pinyin_rules == 0)
            state.fuzzy_pinyin_rules = CASSOTIS_DEFAULT_FUZZY_RULES;
    } else if (g_str_has_prefix(property_name,
                                CASSOTIS_PROP_FUZZY_RULE_PREFIX)) {
        fuzzy_rule = g_ascii_strtoull(
            property_name + strlen(CASSOTIS_PROP_FUZZY_RULE_PREFIX),
            &end, 10);
        if (end == NULL || *end != '\0' ||
            fuzzy_rule >= CASSOTIS_FUZZY_RULE_COUNT)
            return;
        state.fuzzy_pinyin_rules ^= 1U << fuzzy_rule;
    } else if (g_str_has_prefix(property_name,
                                CASSOTIS_PROP_SCHEME_PREFIX)) {
        scheme = g_ascii_strtoull(
            property_name + strlen(CASSOTIS_PROP_SCHEME_PREFIX), &end, 10);
        if (end == NULL || *end != '\0' ||
            scheme > CASSOTIS_PINYIN_PINYINJIAJIA)
            return;
        state.pinyin_scheme = (CassotisPinyinScheme)scheme;
    } else {
        return;
    }
    update_engine_state(self, &state);
}

static void cassotis_ibus_engine_finalize(GObject *object)
{
    CassotisIbusEngine *self = (CassotisIbusEngine *)object;
    GError *error = NULL;
    stop_state_polling(self);
    if (self->context_created) {
        ++self->generation_id;
        if (!cassotis_client_destroy_context(&global_client, self->context_id,
                                             self->generation_id, &error))
            g_clear_error(&error);
    }
    g_clear_pointer(&self->surrounding_text, g_free);
    G_OBJECT_CLASS(cassotis_ibus_engine_parent_class)->finalize(object);
}

static void cassotis_ibus_engine_init(CassotisIbusEngine *self)
{
    self->context_id = next_context_id++;
    self->generation_id = 0;
    self->client_generation = 0;
    self->context_created = FALSE;
    self->context_active = FALSE;
    self->desired_active = FALSE;
    self->enabled = TRUE;
    self->focused = FALSE;
    self->has_surrounding = FALSE;
    self->surrounding_dirty = FALSE;
    self->surrounding_text = NULL;
    self->surrounding_cursor = 0;
    self->page_index = 0;
    self->input_purpose = IBUS_INPUT_PURPOSE_FREE_FORM;
    self->input_hints = IBUS_INPUT_HINT_NONE;
    self->state_poll_id = 0;
    memset(&self->state, 0, sizeof(self->state));
    self->state_valid = FALSE;
    ensure_context(self);
}

static void cassotis_ibus_engine_class_init(CassotisIbusEngineClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS(klass);
    IBusEngineClass *engine_class = IBUS_ENGINE_CLASS(klass);
    object_class->finalize = cassotis_ibus_engine_finalize;
    engine_class->process_key_event = cassotis_process_key_event;
    engine_class->focus_in = cassotis_focus_in;
    engine_class->focus_out = cassotis_focus_out;
    engine_class->reset = cassotis_reset;
    engine_class->enable = cassotis_enable;
    engine_class->disable = cassotis_disable;
    engine_class->set_surrounding_text = cassotis_set_surrounding_text;
    engine_class->set_content_type = cassotis_set_content_type;
    engine_class->page_up = cassotis_page_up;
    engine_class->page_down = cassotis_page_down;
    engine_class->cursor_up = cassotis_cursor_up;
    engine_class->cursor_down = cassotis_cursor_down;
    engine_class->candidate_clicked = cassotis_candidate_clicked;
    engine_class->property_activate = cassotis_property_activate;
}

static gchar *resolve_executable_path(const gchar *program_path)
{
    gchar *executable_path = g_file_read_link("/proc/self/exe", NULL);
    gchar *absolute_path;
    if (executable_path == NULL)
        executable_path = g_canonicalize_filename(program_path, NULL);
    absolute_path = g_canonicalize_filename(executable_path, NULL);
    g_free(executable_path);
    return absolute_path;
}

static gchar *resolve_engine_path(const gchar *executable_path)
{
    gchar *directory = g_path_get_dirname(executable_path);
    gchar *engine_path = g_build_filename(directory, "cassotis-engine", NULL);
    g_free(directory);
    return engine_path;
}

static gchar *resolve_settings_path(const gchar *executable_path)
{
    gchar *directory = g_path_get_dirname(executable_path);
    gchar *settings_path = g_build_filename(directory, "cassotis-settings",
                                            NULL);
    g_free(directory);
    return settings_path;
}

static gchar *resolve_socket_path(void)
{
    const gchar *runtime_directory = g_get_user_runtime_dir();
    return g_build_filename(runtime_directory, "cassotis-ime", "engine.sock",
                            NULL);
}

static void bus_disconnected(IBusBus *bus, gpointer user_data)
{
    (void)bus;
    (void)user_data;
    ibus_quit();
}

int main(int argc, char **argv)
{
    IBusBus *bus;
    IBusFactory *factory;
    gchar *socket_path;
    gchar *adapter_path;
    gchar *engine_path;
    GError *error = NULL;
    gboolean shutdown_engine =
        argc == 2 && strcmp(argv[1], "--shutdown-engine") == 0;

    ibus_init();
    socket_path = resolve_socket_path();
    adapter_path = resolve_executable_path(argv[0]);
    engine_path = resolve_engine_path(adapter_path);
    global_settings_path = resolve_settings_path(adapter_path);
    cassotis_client_init(&global_client, socket_path, engine_path);
    g_free(engine_path);

    if (shutdown_engine) {
        gboolean success;
        cassotis_client_set_allow_spawn(&global_client, FALSE);
        success = cassotis_client_shutdown(&global_client, &error);
        if (!success)
            log_client_error("engine shutdown failed", error);
        cassotis_client_clear(&global_client);
        g_free(socket_path);
        g_free(adapter_path);
        g_clear_pointer(&global_settings_path, g_free);
        return success ? 0 : 1;
    }

    g_free(socket_path);

    bus = ibus_bus_new();
    if (!ibus_bus_is_connected(bus)) {
        g_printerr("Unable to connect to the IBus daemon.\n");
        g_object_unref(bus);
        cassotis_client_clear(&global_client);
        g_free(adapter_path);
        g_clear_pointer(&global_settings_path, g_free);
        return 1;
    }
    g_signal_connect(bus, "disconnected", G_CALLBACK(bus_disconnected), NULL);
    factory = ibus_factory_new(ibus_bus_get_connection(bus));
    ibus_factory_add_engine(factory, CASSOTIS_ENGINE_NAME,
                            cassotis_ibus_engine_get_type());
    if (ibus_bus_request_name(bus, CASSOTIS_BUS_NAME, 0) == 0) {
        g_printerr("Unable to acquire the Cassotis IBus service name.\n");
        g_object_unref(factory);
        g_object_unref(bus);
        cassotis_client_clear(&global_client);
        g_free(adapter_path);
        g_clear_pointer(&global_settings_path, g_free);
        return 1;
    }
    g_free(adapter_path);
    ibus_main();
    g_object_unref(factory);
    g_object_unref(bus);
    cassotis_client_clear(&global_client);
    g_clear_pointer(&global_settings_path, g_free);
    return 0;
}
