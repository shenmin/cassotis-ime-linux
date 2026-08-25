#include "cassotis_shortcut_match.h"

#include <stdio.h>

static int expect(gboolean condition, const char *message)
{
    if (condition)
        return 0;
    fprintf(stderr, "shortcut match test failed: %s\n", message);
    return 1;
}

int main(void)
{
    CassotisShortcut settings = {0x79U,
                                 CASSOTIS_MODIFIER_CONTROL |
                                     CASSOTIS_MODIFIER_SHIFT};
    CassotisShortcut punctuation = {0xbeU, CASSOTIS_MODIFIER_CONTROL};
    CassotisShortcut shift = {0x10U, 0};
    CassotisShortcut numpad_add = {0x6bU,
                                   CASSOTIS_MODIFIER_CONTROL |
                                       CASSOTIS_MODIFIER_SHIFT |
                                       CASSOTIS_MODIFIER_ALT};
    int failed = 0;

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
    if (failed == 0)
        puts("shortcut_match=ok");
    return failed != 0;
}
