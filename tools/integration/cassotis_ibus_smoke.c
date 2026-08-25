#include <ibus.h>

#include <string.h>

#define CASSOTIS_ENGINE_NAME "cassotis"
#define CASSOTIS_INPUT_MODE_PROPERTY "InputMode"
#define CASSOTIS_WAIT_ATTEMPTS 150U
#define CASSOTIS_WAIT_US 20000U
#define CASSOTIS_TEXT_SHI "\xE6\x98\xAF"
#define CASSOTIS_TEXT_HAHA "\xE5\x93\x88\xE5\x93\x88"
#define CASSOTIS_TEXT_ELEME "\xE9\xA5\xBF\xE4\xBA\x86\xE4\xB9\x88"
#define CASSOTIS_TEXT_NI "\xE4\xBD\xA0"
#define CASSOTIS_TEXT_DE "\xE7\x9A\x84"
#define CASSOTIS_TEXT_WOMEN "\xE6\x88\x91\xE4\xBB\xAC"
#define CASSOTIS_TEXT_PERIOD "\xE3\x80\x82"
#define CASSOTIS_TEXT_FULL_SPACE "\xE3\x80\x80"
#define CASSOTIS_COMPLETION_ARROW "\xE2\x87\xA5"

typedef struct {
    gchar *preedit;
    gchar *first_candidate;
    gchar *selected_candidate;
    gchar *completion_row;
    gchar *auxiliary;
    gchar *commit;
    guint candidate_count;
    guint cursor_position;
    guint page_size;
    IBusOrientation orientation;
    gboolean preedit_visible;
    gboolean lookup_visible;
    gboolean auxiliary_visible;
} SmokeObservation;

static void drain_main_context(void)
{
    while (g_main_context_iteration(NULL, FALSE)) {
    }
}

static void wait_one_step(void)
{
    drain_main_context();
    g_usleep(CASSOTIS_WAIT_US);
    drain_main_context();
}

static void replace_text(gchar **destination, IBusText *text)
{
    g_free(*destination);
    *destination = g_strdup(text != NULL ? ibus_text_get_text(text) : "");
}

static void update_preedit(IBusInputContext *context,
                           IBusText *text,
                           guint cursor_position,
                           gboolean visible,
                           gpointer user_data)
{
    SmokeObservation *observation = user_data;
    (void)context;
    (void)cursor_position;
    observation->preedit_visible = visible;
    replace_text(&observation->preedit, text);
}

static void update_lookup_table(IBusInputContext *context,
                                IBusLookupTable *table,
                                gboolean visible,
                                gpointer user_data)
{
    SmokeObservation *observation = user_data;
    IBusText *candidate = NULL;
    guint index;
    (void)context;
    observation->lookup_visible = visible;
    observation->candidate_count =
        table != NULL ? ibus_lookup_table_get_number_of_candidates(table) : 0;
    observation->cursor_position =
        table != NULL ? ibus_lookup_table_get_cursor_pos(table) : 0;
    observation->page_size =
        table != NULL ? ibus_lookup_table_get_page_size(table) : 0;
    observation->orientation =
        table != NULL ? ibus_lookup_table_get_orientation(table)
                      : IBUS_ORIENTATION_SYSTEM;
    g_clear_pointer(&observation->completion_row, g_free);
    if (table != NULL) {
        for (index = 0; index < observation->candidate_count; ++index) {
            const gchar *candidate_text;
            candidate = ibus_lookup_table_get_candidate(table, index);
            candidate_text = candidate != NULL
                                 ? ibus_text_get_text(candidate)
                                 : NULL;
            if (candidate_text != NULL &&
                g_strstr_len(candidate_text, -1,
                             CASSOTIS_COMPLETION_ARROW) != NULL) {
                observation->completion_row = g_strdup(candidate_text);
                break;
            }
        }
    }
    candidate = NULL;
    if (table != NULL && observation->candidate_count > 0)
        candidate = ibus_lookup_table_get_candidate(table, 0);
    replace_text(&observation->first_candidate, candidate);
    candidate = NULL;
    if (table != NULL &&
        observation->cursor_position < observation->candidate_count)
        candidate = ibus_lookup_table_get_candidate(
            table, observation->cursor_position);
    replace_text(&observation->selected_candidate, candidate);
}

static void update_auxiliary(IBusInputContext *context,
                             IBusText *text,
                             gboolean visible,
                             gpointer user_data)
{
    SmokeObservation *observation = user_data;
    (void)context;
    observation->auxiliary_visible = visible;
    replace_text(&observation->auxiliary, text);
}

static void commit_text(IBusInputContext *context,
                        IBusText *text,
                        gpointer user_data)
{
    SmokeObservation *observation = user_data;
    (void)context;
    replace_text(&observation->commit, text);
}

static gboolean wait_for_engine(IBusInputContext *context)
{
    guint attempt;
    for (attempt = 0; attempt < CASSOTIS_WAIT_ATTEMPTS; ++attempt) {
        IBusEngineDesc *engine;
        const gchar *name;
        wait_one_step();
        engine = ibus_input_context_get_engine(context);
        name = engine != NULL ? ibus_engine_desc_get_name(engine) : NULL;
        if (g_strcmp0(name, CASSOTIS_ENGINE_NAME) == 0)
            return TRUE;
    }
    return FALSE;
}

static void clear_observation(SmokeObservation *observation)
{
    g_clear_pointer(&observation->preedit, g_free);
    g_clear_pointer(&observation->first_candidate, g_free);
    g_clear_pointer(&observation->selected_candidate, g_free);
    g_clear_pointer(&observation->completion_row, g_free);
    g_clear_pointer(&observation->auxiliary, g_free);
    g_clear_pointer(&observation->commit, g_free);
    observation->candidate_count = 0;
    observation->cursor_position = 0;
    observation->page_size = 0;
    observation->orientation = IBUS_ORIENTATION_SYSTEM;
    observation->preedit_visible = FALSE;
    observation->lookup_visible = FALSE;
    observation->auxiliary_visible = FALSE;
}

static gboolean verify_candidate_case(IBusInputContext *context,
                                      SmokeObservation *observation,
                                      const gchar *input,
                                      const gchar *expected_candidate)
{
    const guchar *cursor;

    ibus_input_context_reset(context);
    wait_one_step();
    clear_observation(observation);
    for (cursor = (const guchar *)input; *cursor != '\0'; ++cursor) {
        if (!ibus_input_context_process_key_event(
                context, (guint)*cursor, 0, 0)) {
            g_printerr("Cassotis did not handle candidate case '%s'.\n",
                       input);
            return FALSE;
        }
    }
    wait_one_step();
    if (!observation->preedit_visible ||
        !observation->lookup_visible ||
        observation->candidate_count == 0 ||
        g_strcmp0(observation->first_candidate, expected_candidate) != 0) {
        g_printerr(
            "Candidate case '%s' expected '%s' but received '%s'.\n",
            input, expected_candidate,
            observation->first_candidate != NULL
                ? observation->first_candidate
                : "");
        return FALSE;
    }
    return TRUE;
}

static gboolean type_ascii(IBusInputContext *context, const gchar *input)
{
    const guchar *cursor;
    for (cursor = (const guchar *)input; *cursor != '\0'; ++cursor) {
        if (!ibus_input_context_process_key_event(
                context, (guint)*cursor, 0, 0)) {
            g_printerr("Cassotis did not handle input '%s'.\n", input);
            return FALSE;
        }
    }
    return TRUE;
}

static gboolean verify_debug_weight(IBusInputContext *context,
                                    SmokeObservation *observation)
{
    const gchar *weight;

    ibus_input_context_reset(context);
    wait_one_step();
    clear_observation(observation);
    if (!type_ascii(context, "ni"))
        return FALSE;
    wait_one_step();
    weight = observation->first_candidate != NULL
                 ? strrchr(observation->first_candidate, '\n')
                 : NULL;
    if (!observation->lookup_visible || weight == NULL ||
        !g_str_has_prefix(observation->first_candidate, CASSOTIS_TEXT_NI) ||
        *(++weight) == '\0') {
        g_printerr("Debug candidate did not include a dictionary weight.\n");
        return FALSE;
    }
    while (*weight != '\0') {
        if (!g_ascii_isdigit(*weight)) {
            g_printerr("Debug candidate weight was not numeric.\n");
            return FALSE;
        }
        ++weight;
    }
    return TRUE;
}

static gboolean verify_completion_case(IBusInputContext *context,
                                       SmokeObservation *observation)
{
    const gchar *completion;
    gchar *expected;

    ibus_input_context_reset(context);
    wait_one_step();
    clear_observation(observation);
    if (!type_ascii(context, "pianruo"))
        return FALSE;
    wait_one_step();
    if (!observation->lookup_visible ||
        observation->completion_row == NULL) {
        g_printerr("One-key completion did not publish a lookup row.\n");
        return FALSE;
    }
    if (observation->orientation != IBUS_ORIENTATION_VERTICAL) {
        g_printerr("One-key completion lookup table is not vertical.\n");
        return FALSE;
    }
    completion = g_strstr_len(observation->completion_row, -1,
                              CASSOTIS_COMPLETION_ARROW);
    if (completion == NULL || completion[strlen(CASSOTIS_COMPLETION_ARROW)] == '\0') {
        g_printerr("One-key completion lookup row is malformed.\n");
        return FALSE;
    }
    expected = g_strdup(completion + strlen(CASSOTIS_COMPLETION_ARROW));
    clear_observation(observation);
    if (!ibus_input_context_process_key_event(context, IBUS_KEY_Tab, 0, 0)) {
        g_printerr("Tab did not accept one-key completion.\n");
        g_free(expected);
        return FALSE;
    }
    wait_one_step();
    if (g_strcmp0(observation->commit, expected) != 0) {
        g_printerr("One-key completion committed '%s' instead of '%s'.\n",
                   observation->commit != NULL ? observation->commit : "",
                   expected);
        g_free(expected);
        return FALSE;
    }
    g_free(expected);
    return TRUE;
}

static gboolean verify_navigation_and_editing(IBusInputContext *context,
                                              SmokeObservation *observation)
{
    gchar *first_page_candidate;

    ibus_input_context_reset(context);
    wait_one_step();
    clear_observation(observation);
    if (!type_ascii(context, "shi"))
        return FALSE;
    wait_one_step();
    if (observation->page_size == 0 || observation->candidate_count == 0 ||
        observation->first_candidate == NULL ||
        observation->first_candidate[0] == '\0') {
        g_printerr("Paging case did not expose a populated first page.\n");
        return FALSE;
    }
    first_page_candidate = g_strdup(observation->first_candidate);
    if (!ibus_input_context_process_key_event(
            context, IBUS_KEY_Page_Down, 0, 0)) {
        g_printerr("PageDown was not handled.\n");
        g_free(first_page_candidate);
        return FALSE;
    }
    wait_one_step();
    if (observation->cursor_position >= observation->candidate_count ||
        observation->selected_candidate == NULL ||
        observation->selected_candidate[0] == '\0' ||
        g_strcmp0(observation->first_candidate, first_page_candidate) == 0) {
        g_printerr("PageDown did not move to a populated second page.\n");
        g_free(first_page_candidate);
        return FALSE;
    }
    if (!ibus_input_context_process_key_event(
            context, IBUS_KEY_Page_Up, 0, 0)) {
        g_printerr("PageUp was not handled.\n");
        g_free(first_page_candidate);
        return FALSE;
    }
    wait_one_step();
    if (observation->cursor_position >= observation->candidate_count ||
        g_strcmp0(observation->first_candidate, first_page_candidate) != 0) {
        g_printerr("PageUp did not return to the first page.\n");
        g_free(first_page_candidate);
        return FALSE;
    }
    g_free(first_page_candidate);

    ibus_input_context_reset(context);
    wait_one_step();
    clear_observation(observation);
    if (!type_ascii(context, "nih") ||
        !ibus_input_context_process_key_event(
            context, IBUS_KEY_BackSpace, 0, 0))
        return FALSE;
    wait_one_step();
    if (g_strcmp0(observation->preedit, "ni") != 0) {
        g_printerr("Backspace did not restore the expected preedit.\n");
        return FALSE;
    }
    clear_observation(observation);
    if (!ibus_input_context_process_key_event(
            context, IBUS_KEY_Escape, 0, 0)) {
        g_printerr("Escape did not clear composition.\n");
        return FALSE;
    }
    wait_one_step();
    if (observation->preedit_visible || observation->lookup_visible) {
        g_printerr("Escape left composition UI visible.\n");
        return FALSE;
    }

    clear_observation(observation);
    if (!type_ascii(context, "ni") ||
        !ibus_input_context_process_key_event(
            context, IBUS_KEY_Return, 0, 0))
        return FALSE;
    wait_one_step();
    if (g_strcmp0(observation->commit, "ni") != 0) {
        g_printerr("Enter did not commit raw pinyin.\n");
        return FALSE;
    }
    return TRUE;
}

static gboolean verify_mode_shortcuts(IBusInputContext *context,
                                      SmokeObservation *observation)
{
    gboolean handled;

    ibus_input_context_reset(context);
    wait_one_step();
    clear_observation(observation);
    handled = ibus_input_context_process_key_event(
        context, IBUS_KEY_space, 0, 0);
    wait_one_step();
    if (handled) {
        if (g_strcmp0(observation->commit, CASSOTIS_TEXT_FULL_SPACE) != 0) {
            g_printerr("Unexpected plain-space handling before width test.\n");
            return FALSE;
        }
        if (!ibus_input_context_process_key_event(
                context, IBUS_KEY_space, 0, IBUS_SHIFT_MASK)) {
            g_printerr("Shift+Space did not disable pre-existing full-width mode.\n");
            return FALSE;
        }
        wait_one_step();
    }

    clear_observation(observation);
    handled = ibus_input_context_process_key_event(
        context, IBUS_KEY_period, 0, 0);
    wait_one_step();
    if (!handled) {
        if (!ibus_input_context_process_key_event(
                context, IBUS_KEY_period, 0, IBUS_CONTROL_MASK)) {
            g_printerr("Ctrl+period could not normalize punctuation mode.\n");
            return FALSE;
        }
        wait_one_step();
        clear_observation(observation);
        handled = ibus_input_context_process_key_event(
            context, IBUS_KEY_period, 0, 0);
        wait_one_step();
    }
    if (!handled || g_strcmp0(observation->commit, CASSOTIS_TEXT_PERIOD) != 0) {
        g_printerr("Unable to normalize Chinese punctuation mode.\n");
        return FALSE;
    }

    if (!ibus_input_context_process_key_event(
            context, IBUS_KEY_period, 0, IBUS_CONTROL_MASK)) {
        g_printerr("Ctrl+period did not toggle punctuation mode.\n");
        return FALSE;
    }
    wait_one_step();
    clear_observation(observation);
    if (ibus_input_context_process_key_event(
            context, IBUS_KEY_period, 0, 0)) {
        g_printerr("English punctuation mode consumed a plain period.\n");
        return FALSE;
    }
    if (!ibus_input_context_process_key_event(
            context, IBUS_KEY_period, 0, IBUS_CONTROL_MASK)) {
        g_printerr("Ctrl+period did not restore Chinese punctuation mode.\n");
        return FALSE;
    }
    wait_one_step();

    if (!ibus_input_context_process_key_event(
            context, IBUS_KEY_space, 0, IBUS_SHIFT_MASK)) {
        g_printerr("Shift+Space did not enable full-width mode.\n");
        return FALSE;
    }
    wait_one_step();
    if (!ibus_input_context_process_key_event(
            context, IBUS_KEY_Shift_L, 0, IBUS_SHIFT_MASK)) {
        g_printerr("Shift did not enter English mode for the width test.\n");
        return FALSE;
    }
    wait_one_step();
    clear_observation(observation);
    handled = ibus_input_context_process_key_event(
        context, IBUS_KEY_space, 0, 0);
    wait_one_step();
    if (!handled) {
        g_printerr("Full-width mode did not consume a plain space "
                   "(commit='%s').\n",
                   observation->commit != NULL ? observation->commit : "");
        return FALSE;
    }
    if (g_strcmp0(observation->commit, CASSOTIS_TEXT_FULL_SPACE) != 0) {
        g_printerr("Full-width mode did not commit an ideographic space.\n");
        return FALSE;
    }
    if (!ibus_input_context_process_key_event(
            context, IBUS_KEY_Shift_L, 0, IBUS_SHIFT_MASK)) {
        g_printerr("Shift did not leave English mode after the width test.\n");
        return FALSE;
    }
    wait_one_step();
    if (!ibus_input_context_process_key_event(
            context, IBUS_KEY_space, 0, IBUS_SHIFT_MASK)) {
        g_printerr("Shift+Space did not restore half-width mode.\n");
        return FALSE;
    }
    wait_one_step();

    if (!ibus_input_context_process_key_event(
            context, IBUS_KEY_Shift_L, 0, IBUS_SHIFT_MASK)) {
        g_printerr("Shift did not enter English mode.\n");
        return FALSE;
    }
    wait_one_step();
    if (ibus_input_context_process_key_event(context, IBUS_KEY_n, 0, 0)) {
        g_printerr("English mode consumed a Latin letter.\n");
        return FALSE;
    }
    if (!ibus_input_context_process_key_event(
            context, IBUS_KEY_Shift_L, 0, IBUS_SHIFT_MASK)) {
        g_printerr("Shift did not return to Chinese mode.\n");
        return FALSE;
    }
    wait_one_step();
    return TRUE;
}

static gboolean verify_sensitive_context(IBusInputContext *context,
                                         SmokeObservation *observation)
{
    ibus_input_context_reset(context);
    ibus_input_context_set_content_type(
        context, IBUS_INPUT_PURPOSE_PASSWORD, IBUS_INPUT_HINT_NONE);
    wait_one_step();
    clear_observation(observation);
    if (ibus_input_context_process_key_event(context, IBUS_KEY_n, 0, 0)) {
        g_printerr("Password input was unexpectedly consumed.\n");
        return FALSE;
    }
    wait_one_step();
    if (observation->preedit_visible || observation->lookup_visible) {
        g_printerr("Password input exposed composition UI.\n");
        return FALSE;
    }
    ibus_input_context_set_content_type(
        context, IBUS_INPUT_PURPOSE_FREE_FORM, IBUS_INPUT_HINT_NONE);
    wait_one_step();
    return TRUE;
}

static gboolean stop_installed_engine(void)
{
    gchar *smoke_path = NULL;
    gchar *install_dir = NULL;
    gchar *adapter_path = NULL;
    gchar *arguments[3] = {NULL, (gchar *)"--shutdown-engine", NULL};
    GError *error = NULL;
    gint wait_status = 0;
    gboolean success = FALSE;

    smoke_path = g_file_read_link("/proc/self/exe", &error);
    if (smoke_path == NULL)
        goto done;
    install_dir = g_path_get_dirname(smoke_path);
    adapter_path = g_build_filename(install_dir, "ibus-engine-cassotis", NULL);
    arguments[0] = adapter_path;
    if (!g_spawn_sync(NULL, arguments, NULL,
                      G_SPAWN_STDOUT_TO_DEV_NULL |
                          G_SPAWN_STDERR_TO_DEV_NULL,
                      NULL, NULL, NULL, NULL, &wait_status, &error) ||
        !g_spawn_check_wait_status(wait_status, &error))
        goto done;
    success = TRUE;

done:
    if (!success)
        g_printerr("Unable to restart the engine during validation: %s\n",
                   error != NULL ? error->message : "unknown error");
    g_clear_error(&error);
    g_free(adapter_path);
    g_free(install_dir);
    g_free(smoke_path);
    return success;
}

static gboolean verify_engine_restart_recovery(
    IBusInputContext *context, SmokeObservation *observation)
{
    gboolean success = FALSE;

    ibus_input_context_reset(context);
    wait_one_step();
    clear_observation(observation);
    if (!stop_installed_engine())
        return FALSE;
    g_usleep(50000);
    if (!ibus_input_context_process_key_event(context, IBUS_KEY_n, 0, 0) ||
        !ibus_input_context_process_key_event(context, IBUS_KEY_i, 0, 0)) {
        g_printerr("Cassotis did not handle input after engine restart.\n");
        goto done;
    }
    wait_one_step();
    if (!observation->preedit_visible ||
        !observation->lookup_visible || observation->candidate_count == 0 ||
        observation->first_candidate == NULL ||
        observation->first_candidate[0] == '\0') {
        g_printerr("Cassotis did not restore candidates after engine restart.\n");
        goto done;
    }
    success = TRUE;

done:
    ibus_input_context_reset(context);
    wait_one_step();
    clear_observation(observation);
    return success;
}

static gboolean verify_client_profile(IBusBus *bus,
                                      const gchar *client_name,
                                      guint capabilities,
                                      guint purpose,
                                      const gchar *surrounding_text,
                                      const gchar *input,
                                      const gchar *expected_candidate)
{
    IBusInputContext *context;
    IBusText *surrounding;
    SmokeObservation observation = {0};
    gboolean success = FALSE;

    if (!ibus_bus_set_global_engine(bus, CASSOTIS_ENGINE_NAME)) {
        g_printerr("Profile '%s' could not select Cassotis globally.\n",
                   client_name);
        return FALSE;
    }
    wait_one_step();
    context = ibus_bus_create_input_context(bus, client_name);
    if (context == NULL)
        return FALSE;
    g_signal_connect(context, "update-preedit-text",
                     G_CALLBACK(update_preedit), &observation);
    g_signal_connect(context, "update-lookup-table",
                     G_CALLBACK(update_lookup_table), &observation);
    g_signal_connect(context, "update-auxiliary-text",
                     G_CALLBACK(update_auxiliary), &observation);
    g_signal_connect(context, "commit-text",
                     G_CALLBACK(commit_text), &observation);
    ibus_input_context_set_capabilities(context, capabilities);
    ibus_input_context_set_cursor_location(context, 220, 180, 2, 26);
    ibus_input_context_set_content_type(context, purpose,
                                        IBUS_INPUT_HINT_NONE);
    if (surrounding_text != NULL) {
        surrounding = ibus_text_new_from_string(surrounding_text);
        ibus_input_context_set_surrounding_text(
            context, surrounding,
            (guint)g_utf8_strlen(surrounding_text, -1),
            (guint)g_utf8_strlen(surrounding_text, -1));
    }
    ibus_input_context_focus_in(context);
    ibus_input_context_set_engine(context, CASSOTIS_ENGINE_NAME);
    if (!wait_for_engine(context)) {
        IBusEngineDesc *engine = ibus_input_context_get_engine(context);
        const gchar *engine_name =
            engine != NULL ? ibus_engine_desc_get_name(engine) : NULL;
        g_printerr("Profile '%s' did not activate Cassotis "
                   "(current engine: %s).\n",
                   client_name, engine_name != NULL ? engine_name : "none");
        goto done;
    }
    success = verify_candidate_case(context, &observation, input,
                                    expected_candidate);

done:
    ibus_input_context_reset(context);
    ibus_input_context_focus_out(context);
    g_object_unref(context);
    clear_observation(&observation);
    return success;
}

int main(int argc, char **argv)
{
    IBusBus *bus = NULL;
    IBusInputContext *context = NULL;
    IBusEngineDesc *global_engine = NULL;
    IBusText *surrounding;
    SmokeObservation observation = {0};
    gchar *original_engine_name = NULL;
    gboolean global_engine_changed = FALSE;
    gboolean toggled_input_mode = FALSE;
    gboolean main_focused = FALSE;
    gboolean handled;
    gboolean settings_shortcut_test =
        argc == 2 && g_strcmp0(argv[1], "--settings-shortcut") == 0;
    gboolean debug_weight_test =
        argc == 2 && g_strcmp0(argv[1], "--debug-weight") == 0;
    int result = 1;

    if (argc > 2 ||
        (argc == 2 && !settings_shortcut_test && !debug_weight_test)) {
        g_printerr("Usage: %s [--settings-shortcut|--debug-weight]\n",
                   argv[0]);
        return 2;
    }

    ibus_init();
    bus = ibus_bus_new();
    if (!ibus_bus_is_connected(bus)) {
        g_printerr("Unable to connect to the active IBus daemon.\n");
        goto done;
    }
    global_engine = ibus_bus_get_global_engine(bus);
    if (global_engine != NULL) {
        original_engine_name = g_strdup(
            ibus_engine_desc_get_name(global_engine));
        g_object_unref(global_engine);
        global_engine = NULL;
    }
    if (original_engine_name != NULL &&
        g_strcmp0(original_engine_name, CASSOTIS_ENGINE_NAME) != 0) {
        if (!ibus_bus_set_global_engine(bus, CASSOTIS_ENGINE_NAME)) {
            g_printerr("Unable to select Cassotis for desktop validation.\n");
            goto done;
        }
        global_engine_changed = TRUE;
        wait_one_step();
    }
    context = ibus_bus_create_input_context(bus, "cassotis-ibus-smoke");
    if (context == NULL) {
        g_printerr("Unable to create an IBus input context.\n");
        goto done;
    }

    g_signal_connect(context, "update-preedit-text",
                     G_CALLBACK(update_preedit), &observation);
    g_signal_connect(context, "update-lookup-table",
                     G_CALLBACK(update_lookup_table), &observation);
    g_signal_connect(context, "update-auxiliary-text",
                     G_CALLBACK(update_auxiliary), &observation);
    g_signal_connect(context, "commit-text",
                     G_CALLBACK(commit_text), &observation);
    ibus_input_context_set_capabilities(
        context, IBUS_CAP_FOCUS | IBUS_CAP_PREEDIT_TEXT |
                     IBUS_CAP_AUXILIARY_TEXT | IBUS_CAP_LOOKUP_TABLE |
                     IBUS_CAP_PROPERTY | IBUS_CAP_SURROUNDING_TEXT);
    ibus_input_context_set_cursor_location(context, 100, 100, 2, 24);
    surrounding = ibus_text_new_from_static_string("");
    ibus_input_context_set_surrounding_text(context, surrounding, 0, 0);
    ibus_input_context_focus_in(context);
    main_focused = TRUE;
    ibus_input_context_set_engine(context, CASSOTIS_ENGINE_NAME);
    if (!wait_for_engine(context)) {
        g_printerr("Cassotis did not become active for the test context.\n");
        goto done;
    }
    ibus_input_context_reset(context);
    wait_one_step();

    if (settings_shortcut_test) {
        handled = ibus_input_context_process_key_event(
            context, IBUS_KEY_F10, 0,
            IBUS_CONTROL_MASK | IBUS_SHIFT_MASK);
        if (!handled) {
            g_printerr("The default settings shortcut was not handled.\n");
            goto done;
        }
        wait_one_step();
        g_print("settings_shortcut=ok\n");
        result = 0;
        goto done;
    }

    if (debug_weight_test) {
        if (!verify_debug_weight(context, &observation))
            goto done;
        g_print("debug_candidate_weight=ok\n");
        result = 0;
        goto done;
    }

    handled = ibus_input_context_process_key_event(
        context, IBUS_KEY_n, 0, 0);
    if (!handled) {
        ibus_input_context_property_activate(
            context, CASSOTIS_INPUT_MODE_PROPERTY, PROP_STATE_UNCHECKED);
        toggled_input_mode = TRUE;
        wait_one_step();
        handled = ibus_input_context_process_key_event(
            context, IBUS_KEY_n, 0, 0);
    }
    if (!handled ||
        !ibus_input_context_process_key_event(context, IBUS_KEY_i, 0, 0)) {
        g_printerr("Cassotis did not handle the smoke-test pinyin.\n");
        goto done;
    }
    wait_one_step();
    if (!observation.preedit_visible || observation.preedit == NULL ||
        observation.preedit[0] == '\0') {
        g_printerr("Cassotis did not publish visible preedit text.\n");
        goto done;
    }
    if (!observation.lookup_visible || observation.candidate_count == 0 ||
        observation.first_candidate == NULL ||
        observation.first_candidate[0] == '\0') {
        g_printerr("Cassotis did not publish a populated lookup table.\n");
        goto done;
    }
    if (!ibus_input_context_process_key_event(
            context, IBUS_KEY_Return, 0, 0)) {
        g_printerr("Cassotis did not handle raw composition commit.\n");
        goto done;
    }
    wait_one_step();
    if (observation.commit == NULL || observation.commit[0] == '\0') {
        g_printerr("Cassotis did not emit committed text.\n");
        goto done;
    }

    g_print("ibus_connection=ok\n");
    g_print("engine=%s\n", CASSOTIS_ENGINE_NAME);
    g_print("preedit=%s\n", observation.preedit);
    g_print("candidate_count=%u\n", observation.candidate_count);
    g_print("first_candidate=%s\n", observation.first_candidate);
    g_print("raw_commit=%s\n", observation.commit);

    if (!verify_candidate_case(context, &observation, "shi",
                               CASSOTIS_TEXT_SHI)) {
        g_printerr("Fixed-single candidate validation failed.\n");
        goto done;
    }
    if (!verify_candidate_case(context, &observation, "hha",
                               CASSOTIS_TEXT_HAHA) ||
        !verify_candidate_case(context, &observation, "elm",
                               CASSOTIS_TEXT_ELEME)) {
        g_printerr("Mixed-jianpin candidate validation failed.\n");
        goto done;
    }
    if (!verify_completion_case(context, &observation)) {
        g_printerr("One-key completion validation failed.\n");
        goto done;
    }
    if (!verify_navigation_and_editing(context, &observation)) {
        g_printerr("Navigation and editing validation failed.\n");
        goto done;
    }
    if (!verify_engine_restart_recovery(context, &observation)) {
        g_printerr("Engine restart recovery validation failed.\n");
        goto done;
    }
    if (!verify_mode_shortcuts(context, &observation)) {
        g_printerr("Mode shortcut validation failed.\n");
        goto done;
    }
    if (!verify_sensitive_context(context, &observation)) {
        g_printerr("Sensitive-context validation failed.\n");
        goto done;
    }
    g_print("fixed_single=ok\n");
    g_print("mixed_jianpin=ok\n");
    g_print("completion=ok\n");
    g_print("navigation_editing=ok\n");
    g_print("engine_restart_recovery=ok\n");
    g_print("mode_shortcuts=ok\n");
    g_print("sensitive_context=ok\n");

    ibus_input_context_reset(context);
    ibus_input_context_focus_out(context);
    main_focused = FALSE;
    if (!verify_client_profile(
            bus, "cassotis-terminal-profile",
            IBUS_CAP_FOCUS | IBUS_CAP_PREEDIT_TEXT |
                IBUS_CAP_AUXILIARY_TEXT | IBUS_CAP_LOOKUP_TABLE |
                IBUS_CAP_PROPERTY,
            IBUS_INPUT_PURPOSE_TERMINAL, NULL, "ni", CASSOTIS_TEXT_NI) ||
        !verify_client_profile(
            bus, "cassotis-chromium-profile",
            IBUS_CAP_FOCUS | IBUS_CAP_PREEDIT_TEXT |
                IBUS_CAP_AUXILIARY_TEXT | IBUS_CAP_LOOKUP_TABLE |
                IBUS_CAP_PROPERTY | IBUS_CAP_SURROUNDING_TEXT,
            IBUS_INPUT_PURPOSE_FREE_FORM, CASSOTIS_TEXT_WOMEN, "de",
            CASSOTIS_TEXT_DE))
        goto done;
    g_print("terminal_profile=ok\n");
    g_print("chromium_profile=ok\n");
    result = 0;

done:
    if (context != NULL) {
        ibus_input_context_reset(context);
        if (toggled_input_mode) {
            ibus_input_context_property_activate(
                context, CASSOTIS_INPUT_MODE_PROPERTY, PROP_STATE_UNCHECKED);
            wait_one_step();
        }
        if (main_focused)
            ibus_input_context_focus_out(context);
        g_object_unref(context);
    }
    if (bus != NULL && global_engine_changed &&
        original_engine_name != NULL) {
        if (!ibus_bus_set_global_engine(bus, original_engine_name)) {
            g_printerr("Unable to restore the previous IBus engine '%s'.\n",
                       original_engine_name);
            result = 1;
        }
        wait_one_step();
    }
    if (bus != NULL)
        g_object_unref(bus);
    g_free(original_engine_name);
    clear_observation(&observation);
    return result;
}
