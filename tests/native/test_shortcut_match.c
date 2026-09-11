#include "cassotis_shortcut_match.h"

#include <stdio.h>
#include <string.h>

static int expect(gboolean condition, const char *message)
{
    if (condition)
        return 0;
    fprintf(stderr, "shortcut match test failed: %s\n", message);
    return 1;
}

static int verify_state_protocol(void)
{
    CassotisEngineState source, decoded;
    GByteArray *frame;
    GError *error = NULL;
    guint8 *payload;
    gsize payload_length;
    int failed = 0;

    memset(&source, 0xff, sizeof(source));
    cassotis_engine_state_init_defaults(&source);
    source.debug_mode = TRUE;
    source.candidate_page_size = 3;
    source.shortcuts.input_mode_toggle.disabled = TRUE;
    source.shortcuts.punctuation_toggle = source.shortcuts.input_mode_toggle;
    frame = cassotis_protocol_build_set_state_request(1, &source);
    payload = frame->data + CASSOTIS_IPC_HEADER_SIZE;
    payload_length = frame->len - CASSOTIS_IPC_HEADER_SIZE;
    failed |= expect(cassotis_protocol_decode_engine_state(
                         payload, payload_length, &decoded, &error),
                     "schema 5 must accept disabled duplicate bindings");
    failed |= expect(decoded.shortcuts.input_mode_toggle.disabled &&
                         decoded.shortcuts.punctuation_toggle.disabled &&
                         !decoded.shortcuts.open_settings.disabled &&
                         decoded.debug_mode && decoded.candidate_page_size == 3,
                     "schema 5 must preserve disabled and schema-4 fields");
    g_clear_error(&error);
    payload[0] = 4;
    failed |= expect(!cassotis_protocol_decode_engine_state(
                         payload, payload_length, &decoded, &error),
                     "legacy schemas must reject the new reserved flags");
    g_clear_error(&error);
    g_byte_array_unref(frame);

    cassotis_engine_state_init_defaults(&source);
    source.debug_mode = TRUE;
    source.candidate_page_size = 3;
    frame = cassotis_protocol_build_set_state_request(2, &source);
    payload = frame->data + CASSOTIS_IPC_HEADER_SIZE;
    payload_length = frame->len - CASSOTIS_IPC_HEADER_SIZE;
    payload[0] = 4;
    failed |= expect(cassotis_protocol_decode_engine_state(
                         payload, payload_length, &decoded, &error),
                     "schema 4 must remain readable");
    failed |= expect(!decoded.shortcuts.input_mode_toggle.disabled &&
                         decoded.debug_mode && decoded.candidate_page_size == 3,
                     "legacy shortcuts must default to enabled");
    g_clear_error(&error);
    g_byte_array_unref(frame);
    return failed;
}

int main(void)
{
    CassotisShortcut settings = {0x79U,
                                 CASSOTIS_MODIFIER_CONTROL |
                                     CASSOTIS_MODIFIER_SHIFT, FALSE};
    CassotisShortcut punctuation = {0xbeU, CASSOTIS_MODIFIER_CONTROL, FALSE};
    CassotisShortcut shift = {0x10U, 0, FALSE};
    CassotisShortcut numpad_add = {0x6bU,
                                   CASSOTIS_MODIFIER_CONTROL |
                                       CASSOTIS_MODIFIER_SHIFT |
                                       CASSOTIS_MODIFIER_ALT, FALSE};
    int failed = verify_state_protocol();

    failed |= expect(cassotis_shortcut_virtual_key('a') == 'A',
                     "letters must normalize to uppercase virtual keys");
    failed |= expect(cassotis_shortcut_virtual_key(
                         CASSOTIS_KEYSYM_F1 + 9U) == 0x79U,
                     "F10 must map to VK_F10");
    failed |= expect(cassotis_shortcut_matches_keysym(
                         &settings, CASSOTIS_KEYSYM_F1 + 9U,
                         CASSOTIS_MODIFIER_CONTROL |
                             CASSOTIS_MODIFIER_SHIFT),
                     "Ctrl+Shift+F10 must open settings");
    failed |= expect(!cassotis_shortcut_matches_keysym(
                         &settings, CASSOTIS_KEYSYM_F1 + 9U,
                         CASSOTIS_MODIFIER_CONTROL |
                             CASSOTIS_MODIFIER_SHIFT |
                             CASSOTIS_MODIFIER_ALT),
                     "extra shortcut modifiers must not match");
    failed |= expect(cassotis_shortcut_matches_keysym(
                         &punctuation, '.', CASSOTIS_MODIFIER_CONTROL),
                     "Ctrl+period must map to VK_OEM_PERIOD");
    failed |= expect(cassotis_shortcut_matches_keysym(
                         &shift, CASSOTIS_KEYSYM_SHIFT_L,
                         CASSOTIS_MODIFIER_SHIFT),
                     "modifier-only Shift must ignore its own state bit");
    failed |= expect(cassotis_shortcut_matches_keysym(
                         &numpad_add, CASSOTIS_KEYSYM_KP_ADD,
                         CASSOTIS_MODIFIER_CONTROL |
                             CASSOTIS_MODIFIER_SHIFT |
                             CASSOTIS_MODIFIER_ALT),
                     "numpad shortcuts and all three modifiers must match");
    failed |= expect(!cassotis_shortcut_matches_keysym(
                         &settings, CASSOTIS_KEYSYM_F1 + 9U,
                         CASSOTIS_MODIFIER_CONTROL |
                             CASSOTIS_MODIFIER_SHIFT |
                             CASSOTIS_MODIFIER_SUPER),
                     "Super-modified desktop shortcuts must not match");
    settings.disabled = TRUE;
    failed |= expect(!cassotis_shortcut_matches_keysym(
                         &settings, CASSOTIS_KEYSYM_F1 + 9U,
                         CASSOTIS_MODIFIER_CONTROL | CASSOTIS_MODIFIER_SHIFT),
                     "a disabled settings shortcut must pass through");
    if (failed == 0)
        puts("shortcut_match=ok");
    return failed != 0;
}
