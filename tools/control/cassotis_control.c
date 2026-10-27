#include "cassotis_client.h"

#include <glib.h>
#include <string.h>
#include <stdio.h>

static gchar *resolve_executable_path(const gchar *program_path)
{
    gchar *link_path = g_file_read_link("/proc/self/exe", NULL);
    gchar *absolute_path;

    if (link_path == NULL)
        link_path = g_canonicalize_filename(program_path, NULL);
    absolute_path = g_canonicalize_filename(link_path, NULL);
    g_free(link_path);
    return absolute_path;
}

static gchar *resolve_sibling(const gchar *executable_path,
                              const gchar *file_name)
{
    gchar *directory = g_path_get_dirname(executable_path);
    gchar *path = g_build_filename(directory, file_name, NULL);

    g_free(directory);
    return path;
}

static gchar *resolve_socket_path(void)
{
    const gchar *override = g_getenv("CASSOTIS_ENGINE_SOCKET");

    if (override != NULL && override[0] != '\0')
        return g_canonicalize_filename(override, NULL);
    return g_build_filename(g_get_user_runtime_dir(), "cassotis-ime",
                            "engine.sock", NULL);
}

static gboolean parse_uint(const gchar *text, guint32 maximum, guint32 *value)
{
    gchar *end = NULL;
    guint64 parsed;

    if (text == NULL || text[0] == '\0' || text[0] == '-')
        return FALSE;
    parsed = g_ascii_strtoull(text, &end, 10);
    if (end == text || end == NULL || *end != '\0' || parsed > maximum)
        return FALSE;
    *value = (guint32)parsed;
    return TRUE;
}

static void print_state(const CassotisEngineState *state)
{
    g_print("input_mode=%u\n", (guint)state->input_mode);
    g_print("dictionary_variant=%u\n", (guint)state->dictionary_variant);
    g_print("pinyin_scheme=%u\n", (guint)state->pinyin_scheme);
    g_print("fuzzy_pinyin_enabled=%u\n",
            state->fuzzy_pinyin_enabled ? 1U : 0U);
    g_print("fuzzy_pinyin_rules=%u\n", state->fuzzy_pinyin_rules);
    g_print("full_width_mode=%u\n", state->full_width_mode ? 1U : 0U);
    g_print("punctuation_full_width=%u\n",
            state->punctuation_full_width ? 1U : 0U);
    g_print("candidate_page_key_scheme=%u\n",
            (guint)state->candidate_page_key_scheme);
    g_print("one_key_completion_key=%u\n",
            (guint)state->one_key_completion_key);
    g_print("candidate_page_size=%u\n",
            (guint)state->candidate_page_size);
    g_print("debug_mode=%u\n", state->debug_mode ? 1U : 0U);
    g_print("shortcut_input_mode_key=%u\n",
            (guint)state->shortcuts.input_mode_toggle.key_code);
    g_print("shortcut_input_mode_modifiers=%u\n",
            (guint)state->shortcuts.input_mode_toggle.modifiers);
    g_print("shortcut_punctuation_key=%u\n",
            (guint)state->shortcuts.punctuation_toggle.key_code);
    g_print("shortcut_punctuation_modifiers=%u\n",
            (guint)state->shortcuts.punctuation_toggle.modifiers);
    g_print("shortcut_dictionary_key=%u\n",
            (guint)state->shortcuts.dictionary_variant_toggle.key_code);
    g_print("shortcut_dictionary_modifiers=%u\n",
            (guint)state->shortcuts.dictionary_variant_toggle.modifiers);
    g_print("shortcut_full_width_key=%u\n",
            (guint)state->shortcuts.full_width_toggle.key_code);
    g_print("shortcut_full_width_modifiers=%u\n",
            (guint)state->shortcuts.full_width_toggle.modifiers);
    g_print("shortcut_settings_key=%u\n",
            (guint)state->shortcuts.open_settings.key_code);
    g_print("shortcut_settings_modifiers=%u\n",
            (guint)state->shortcuts.open_settings.modifiers);
    g_print("shortcut_disabled_mask=%u\n",
            (state->shortcuts.input_mode_toggle.disabled ? 1U : 0U) |
            (state->shortcuts.punctuation_toggle.disabled ? 2U : 0U) |
            (state->shortcuts.dictionary_variant_toggle.disabled ? 4U : 0U) |
            (state->shortcuts.full_width_toggle.disabled ? 8U : 0U) |
            (state->shortcuts.open_settings.disabled ? 16U : 0U));
    g_print("decimal_period_after_digit=%u\n",
            state->decimal_period_after_digit ? 1U : 0U);
    g_print("auto_english=%u\n", state->auto_english ? 1U : 0U);
    g_print("punctuation_ascii_symbols=%s\n", state->punctuation_ascii_symbols);
    g_print("candidate_layout=%u\n", (guint)state->candidate_layout);
}

static void print_usage(const gchar *program_name)
{
    g_printerr(
        "Usage:\n"
        "  %s get-state\n"
        "  %s set-state INPUT DICTIONARY SCHEME FUZZY RULES WIDTH PUNCT\n"
        "       [PAGE_KEYS COMPLETION_KEY [PAGE_SIZE DEBUG] "
        "INPUT_KEY INPUT_MOD PUNCT_KEY PUNCT_MOD "
        "DICT_KEY DICT_MOD WIDTH_KEY WIDTH_MOD SETTINGS_KEY SETTINGS_MOD "
        "[DISABLED_MASK [DECIMAL_PERIOD [AUTO_ENGLISH ASCII_SYMBOLS [LAYOUT]]]]]\n"
        "  %s ping\n"
        "  %s clear-user-dictionary\n"
        "  %s shutdown\n",
        program_name, program_name, program_name, program_name,
        program_name);
    g_printerr("  %s get-preferences\n"
               "  %s import-user-words FILE\n"
               "  %s set-preferences (same arguments as set-state; phrase JSON on stdin)\n",
               program_name, program_name, program_name);
}

static gchar *read_phrases(GError **error)
{
    GString *text = g_string_new(NULL);
    gchar buffer[8192];
    gsize count;
    while ((count = fread(buffer, 1, sizeof(buffer), stdin)) != 0) {
        if (text->len + count > CASSOTIS_CUSTOM_PHRASES_MAX_JSON)
            goto invalid;
        g_string_append_len(text, buffer, count);
    }
    if (ferror(stdin) || text->len == 0 ||
        !g_utf8_validate(text->str, text->len, NULL))
        goto invalid;
    return g_string_free(text, FALSE);
invalid:
    g_string_free(text, TRUE);
    g_set_error_literal(error, cassotis_client_error_quark(), 1,
                        "expected bounded UTF-8 phrase JSON on stdin");
    return NULL;
}

int main(int argc, char **argv)
{
    CassotisClient client;
    CassotisEngineState state;
    gchar *executable_path;
    gchar *socket_path;
    gchar *engine_path;
    const gchar *engine_override;
    GError *error = NULL;
    guint32 values[24];
    guint index;
    guint shortcut_offset;
    gboolean extended_state;
    gboolean success = FALSE;
    gboolean preferences;
    gchar *phrases = NULL;

    if (argc < 2) {
        print_usage(argv[0]);
        return 2;
    }
    executable_path = resolve_executable_path(argv[0]);
    socket_path = resolve_socket_path();
    engine_override = g_getenv("CASSOTIS_ENGINE_PATH");
    engine_path = engine_override != NULL && engine_override[0] != '\0'
                      ? g_canonicalize_filename(engine_override, NULL)
                      : resolve_sibling(executable_path, "cassotis-engine");
    cassotis_client_init(&client, socket_path, engine_path);
    preferences = g_strcmp0(argv[1], "set-preferences") == 0;

    if (g_strcmp0(argv[1], "get-preferences") == 0 && argc == 2) {
        success = cassotis_client_get_preferences(&client, &state, &phrases, &error);
        if (success) {
            print_state(&state);
            g_print("custom_phrases=%s\n", phrases);
        }
    } else if (g_strcmp0(argv[1], "get-state") == 0 && argc == 2) {
        success = cassotis_client_get_state(&client, &state, &error);
        if (success)
            print_state(&state);
    } else if ((g_strcmp0(argv[1], "set-state") == 0 || preferences) &&
               (argc == 9 || argc == 21 || argc == 23 || argc == 24 ||
                argc == 25 || argc == 27 || argc == 28)) {
        cassotis_engine_state_init_defaults(&state);
        if (!cassotis_client_get_state(&client, &state, &error))
            goto done;
        extended_state = argc >= 23;
        for (index = 0; index < (guint)(argc >= 27 ? 24 : argc - 2); ++index) {
            guint32 maximum = 1U;
            if (index == 4)
                maximum = CASSOTIS_FUZZY_RULE_MASK;
            if (index == 2)
                maximum = CASSOTIS_PINYIN_PINYINJIAJIA;
            else if (index == 7)
                maximum = CASSOTIS_PAGE_KEYS_SHIFT_TAB;
            else if (extended_state && index == 9)
                maximum = 9U;
            else if (extended_state && index >= 11 &&
                     ((index - 11) % 2) == 0)
                maximum = G_MAXUINT16;
            else if (extended_state && index >= 12)
                maximum = CASSOTIS_MODIFIER_SHIFT |
                          CASSOTIS_MODIFIER_CONTROL |
                          CASSOTIS_MODIFIER_ALT;
            else if (!extended_state && index >= 9 &&
                     ((index - 9) % 2) == 0)
                maximum = G_MAXUINT16;
            else if (!extended_state && index >= 10)
                maximum = CASSOTIS_MODIFIER_SHIFT |
                          CASSOTIS_MODIFIER_CONTROL |
                          CASSOTIS_MODIFIER_ALT;
            if (index == 21)
                maximum = 31U;
            if (index == 22 || index == 23)
                maximum = 1U;
            if (!parse_uint(argv[index + 2], maximum, &values[index])) {
                g_set_error(&error, cassotis_client_error_quark(), 1,
                            "invalid set-state value '%s'", argv[index + 2]);
                goto done;
            }
        }
        state.input_mode = (CassotisInputMode)values[0];
        state.dictionary_variant = (CassotisDictionaryVariant)values[1];
        state.pinyin_scheme = (CassotisPinyinScheme)values[2];
        state.fuzzy_pinyin_enabled = values[3] != 0;
        state.fuzzy_pinyin_rules = values[4];
        state.full_width_mode = values[5] != 0;
        state.punctuation_full_width = values[6] != 0;
        if (extended_state) {
            if (values[9] < 3U) {
                g_set_error_literal(&error, cassotis_client_error_quark(), 1,
                                    "candidate page size must be 3..9");
                goto done;
            }
            state.candidate_page_size = (guint8)values[9];
            state.debug_mode = values[10] != 0;
        }
        if (argc >= 21) {
            state.candidate_page_key_scheme =
                (CassotisCandidatePageKeyScheme)values[7];
            state.one_key_completion_key =
                (CassotisOneKeyCompletionKey)values[8];
            shortcut_offset = extended_state ? 11U : 9U;
            state.shortcuts.input_mode_toggle.key_code =
                values[shortcut_offset];
            state.shortcuts.input_mode_toggle.modifiers =
                values[shortcut_offset + 1U];
            state.shortcuts.punctuation_toggle.key_code =
                values[shortcut_offset + 2U];
            state.shortcuts.punctuation_toggle.modifiers =
                values[shortcut_offset + 3U];
            state.shortcuts.dictionary_variant_toggle.key_code =
                values[shortcut_offset + 4U];
            state.shortcuts.dictionary_variant_toggle.modifiers =
                values[shortcut_offset + 5U];
            state.shortcuts.full_width_toggle.key_code =
                values[shortcut_offset + 6U];
            state.shortcuts.full_width_toggle.modifiers =
                values[shortcut_offset + 7U];
            state.shortcuts.open_settings.key_code =
                values[shortcut_offset + 8U];
            state.shortcuts.open_settings.modifiers =
                values[shortcut_offset + 9U];
        }
        if (argc >= 24) {
            state.shortcuts.input_mode_toggle.disabled = (values[21] & 1U) != 0;
            state.shortcuts.punctuation_toggle.disabled = (values[21] & 2U) != 0;
            state.shortcuts.dictionary_variant_toggle.disabled = (values[21] & 4U) != 0;
            state.shortcuts.full_width_toggle.disabled = (values[21] & 8U) != 0;
            state.shortcuts.open_settings.disabled = (values[21] & 16U) != 0;
        }
        if (argc >= 25)
            state.decimal_period_after_digit = values[22] != 0;
        if (argc >= 27) {
            const gchar *symbols = argv[26];
            gsize length = strlen(symbols);
            if (length >= sizeof(state.punctuation_ascii_symbols)) {
                g_set_error_literal(&error, cassotis_client_error_quark(), 1,
                                    "ASCII punctuation list is too long");
                goto done;
            }
            for (gsize i = 0; i < length; ++i) {
                if (!g_ascii_ispunct(symbols[i]) || strchr(symbols + i + 1, symbols[i])) {
                    g_set_error_literal(&error, cassotis_client_error_quark(), 1,
                                        "expected unique ASCII punctuation symbols");
                    goto done;
                }
            }
            state.auto_english = values[23] != 0;
            g_strlcpy(state.punctuation_ascii_symbols, symbols,
                      sizeof(state.punctuation_ascii_symbols));
        }
        if (argc == 28) {
            guint32 layout;
            if (!parse_uint(argv[27], CASSOTIS_LAYOUT_HORIZONTAL, &layout)) {
                g_set_error_literal(&error, cassotis_client_error_quark(), 1,
                                    "candidate layout must be 0..2");
                goto done;
            }
            state.candidate_layout = (CassotisCandidateLayout)layout;
        }
        if (preferences) {
            phrases = read_phrases(&error);
            if (phrases == NULL)
                goto done;
            success = cassotis_client_set_preferences(&client, &state, phrases, &error);
            g_clear_pointer(&phrases, g_free);
            if (success)
                success = cassotis_client_get_preferences(&client, &state, &phrases, &error);
        } else {
            success = cassotis_client_set_state(&client, &state, &error);
            if (success)
                success = cassotis_client_get_state(&client, &state, &error);
        }
        if (success) {
            print_state(&state);
            if (preferences)
                g_print("custom_phrases=%s\n", phrases);
        }
    } else if (g_strcmp0(argv[1], "ping") == 0 && argc == 2) {
        success = cassotis_client_ping(&client, &error);
        if (success)
            g_print("ping=ok\n");
    } else if (g_strcmp0(argv[1], "import-user-words") == 0 && argc == 3) {
        guint entries = 0, imported = 0;
        gchar *path = g_canonicalize_filename(argv[2], NULL);
        success = cassotis_client_import_user_words(&client, path, &entries, &imported, &error);
        g_free(path);
        if (success)
            g_print("entries=%u\nimported=%u\n", entries, imported);
    } else if (g_strcmp0(argv[1], "clear-user-dictionary") == 0 &&
               argc == 2) {
        success = cassotis_client_clear_user_dictionary(&client, &error);
        if (success)
            g_print("clear_user_dictionary=ok\n");
    } else if (g_strcmp0(argv[1], "shutdown") == 0 && argc == 2) {
        cassotis_client_set_allow_spawn(&client, FALSE);
        success = cassotis_client_shutdown(&client, &error);
        if (success)
            g_print("shutdown=ok\n");
    } else {
        print_usage(argv[0]);
        goto done;
    }

done:
    g_free(phrases);
    if (!success && error != NULL)
        g_printerr("cassotis-control: %s\n", error->message);
    g_clear_error(&error);
    cassotis_client_clear(&client);
    g_free(engine_path);
    g_free(socket_path);
    g_free(executable_path);
    return success ? 0 : 1;
}
