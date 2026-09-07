#include "cassotis_client.h"

#include <stdio.h>
#include <string.h>

static CassotisClient client;
static CassotisEngineResult result;
static GError *error;
static guint64 generation = 1;
static gdouble maximum_key_ms;
static guint key_count;

static gboolean key(CassotisSpecialKey special, const gchar *text)
{
    cassotis_engine_result_clear(&result);
    const gint64 started = g_get_monotonic_time();
    if (!cassotis_client_process_key(&client, 1, ++generation, special,
                                    0, 0, FALSE, FALSE, 0, text,
                                    &result, &error))
        return FALSE;
    const gdouble elapsed = (g_get_monotonic_time() - started) / 1000.0;
    maximum_key_ms = MAX(maximum_key_ms, elapsed);
    ++key_count;
    if (key_count == 1)
        g_print("first_key_ms=%.3f\n", elapsed);
    if (!result.handled || result.error_code != 0 || elapsed > 1500.0) {
        g_printerr("key failed: text=%s error=%u elapsed_ms=%.3f\n",
                   text, result.error_code, elapsed);
        return FALSE;
    }
    return TRUE;
}

static gboolean type_query(const gchar *text)
{
    for (const gchar *cursor = text; *cursor != '\0'; ++cursor) {
        const gchar character[] = {*cursor, '\0'};
        if (!key(CASSOTIS_KEY_NONE, character))
            return FALSE;
        if (result.candidate_count == 0 ||
            result.candidates[0].text == NULL ||
            result.candidates[0].text[0] == '\0')
            return FALSE;
    }
    return TRUE;
}

#define CHECK(expression) do { \
    if (!(expression)) { \
        g_printerr("failed: %s%s%s\n", #expression, \
                   error != NULL ? ": " : "", \
                   error != NULL ? error->message : ""); \
        goto done; \
    } \
} while (0)

int main(int argc, char **argv)
{
    int exit_code = 1;
    gchar *completion = NULL;
    CassotisEngineState state;
    if (argc != 3)
        return 2;
    cassotis_client_init(&client, argv[1], argv[2]);
    cassotis_client_set_allow_spawn(&client, FALSE);
    CHECK(cassotis_client_ping(&client, &error));
    CHECK(cassotis_client_get_state(&client, &state, &error));
    CHECK(state.input_mode == CASSOTIS_INPUT_CHINESE);
    CHECK(state.pinyin_scheme == CASSOTIS_PINYIN_FULL);
    CHECK(cassotis_client_create_context(&client, 1, &error));
    CHECK(cassotis_client_set_active(&client, 1, generation, TRUE, &error));
    CHECK(type_query("nihao"));
    CHECK(g_strcmp0(result.candidates[0].text, "\u4f60\u597d") == 0);
    CHECK(key(CASSOTIS_KEY_SPACE, ""));
    CHECK(g_strcmp0(result.commit_text, "\u4f60\u597d") == 0);

    CHECK(type_query("pianruo"));
    CHECK(result.completion_text != NULL && result.completion_text[0] != '\0');
    completion = g_strdup(result.completion_text);
    CHECK(key(CASSOTIS_KEY_TAB, ""));
    CHECK(g_strcmp0(result.commit_text, completion) == 0);

    CHECK(type_query("jintiantianqihenhao"));
    cassotis_engine_result_clear(&result);
    CHECK(cassotis_client_poll_result(&client, 1, generation, &result, &error));
    CHECK(key(CASSOTIS_KEY_ENTER, ""));
    CHECK(g_strcmp0(result.commit_text, "jintiantianqihenhao") == 0);
    CHECK(cassotis_client_ping(&client, &error));
    g_print("key_count=%u\nmaximum_key_ms=%.3f\ncold_start_input=passed\n",
            key_count, maximum_key_ms);
    exit_code = 0;
done:
    g_free(completion);
    cassotis_engine_result_clear(&result);
    g_clear_error(&error);
    cassotis_client_clear(&client);
    return exit_code;
}
