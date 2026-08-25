#ifndef CASSOTIS_SHORTCUT_MATCH_H
#define CASSOTIS_SHORTCUT_MATCH_H

#include <glib.h>

#include "cassotis_protocol.h"

/* XKB, IBus, and Fcitx use the same keysym values for these keys. */
#define CASSOTIS_KEYSYM_BACKSPACE 0xff08U
#define CASSOTIS_KEYSYM_TAB 0xff09U
#define CASSOTIS_KEYSYM_RETURN 0xff0dU
#define CASSOTIS_KEYSYM_ESCAPE 0xff1bU
#define CASSOTIS_KEYSYM_HOME 0xff50U
#define CASSOTIS_KEYSYM_LEFT 0xff51U
#define CASSOTIS_KEYSYM_UP 0xff52U
#define CASSOTIS_KEYSYM_RIGHT 0xff53U
#define CASSOTIS_KEYSYM_DOWN 0xff54U
#define CASSOTIS_KEYSYM_PAGE_UP 0xff55U
#define CASSOTIS_KEYSYM_PAGE_DOWN 0xff56U
#define CASSOTIS_KEYSYM_END 0xff57U
#define CASSOTIS_KEYSYM_INSERT 0xff63U
#define CASSOTIS_KEYSYM_DELETE 0xffffU
#define CASSOTIS_KEYSYM_KP_MULTIPLY 0xffaaU
#define CASSOTIS_KEYSYM_KP_ADD 0xffabU
#define CASSOTIS_KEYSYM_KP_SUBTRACT 0xffadU
#define CASSOTIS_KEYSYM_KP_DECIMAL 0xffaeU
#define CASSOTIS_KEYSYM_KP_DIVIDE 0xffafU
#define CASSOTIS_KEYSYM_F1 0xffbeU
#define CASSOTIS_KEYSYM_F24 0xffd5U
#define CASSOTIS_KEYSYM_SHIFT_L 0xffe1U
#define CASSOTIS_KEYSYM_SHIFT_R 0xffe2U
#define CASSOTIS_KEYSYM_CONTROL_L 0xffe3U
#define CASSOTIS_KEYSYM_CONTROL_R 0xffe4U
#define CASSOTIS_KEYSYM_ALT_L 0xffe9U
#define CASSOTIS_KEYSYM_ALT_R 0xffeaU

static inline guint16 cassotis_shortcut_virtual_key(guint32 key_sym)
{
    if (key_sym >= (guint32)'a' && key_sym <= (guint32)'z')
        return (guint16)(key_sym - (guint32)'a' + (guint32)'A');
    if ((key_sym >= (guint32)'A' && key_sym <= (guint32)'Z') ||
        (key_sym >= (guint32)'0' && key_sym <= (guint32)'9'))
        return (guint16)key_sym;
    if (key_sym >= CASSOTIS_KEYSYM_F1 && key_sym <= CASSOTIS_KEYSYM_F24)
        return (guint16)(0x70U + key_sym - CASSOTIS_KEYSYM_F1);

    switch (key_sym) {
    case CASSOTIS_KEYSYM_BACKSPACE:
        return 0x08U;
    case CASSOTIS_KEYSYM_TAB:
        return 0x09U;
    case CASSOTIS_KEYSYM_RETURN:
        return 0x0dU;
    case CASSOTIS_KEYSYM_SHIFT_L:
    case CASSOTIS_KEYSYM_SHIFT_R:
        return 0x10U;
    case CASSOTIS_KEYSYM_CONTROL_L:
    case CASSOTIS_KEYSYM_CONTROL_R:
        return 0x11U;
    case CASSOTIS_KEYSYM_ALT_L:
    case CASSOTIS_KEYSYM_ALT_R:
        return 0x12U;
    case CASSOTIS_KEYSYM_ESCAPE:
        return 0x1bU;
    case (guint32)' ':
        return 0x20U;
    case CASSOTIS_KEYSYM_PAGE_UP:
        return 0x21U;
    case CASSOTIS_KEYSYM_PAGE_DOWN:
        return 0x22U;
    case CASSOTIS_KEYSYM_END:
        return 0x23U;
    case CASSOTIS_KEYSYM_HOME:
        return 0x24U;
    case CASSOTIS_KEYSYM_LEFT:
        return 0x25U;
    case CASSOTIS_KEYSYM_UP:
        return 0x26U;
    case CASSOTIS_KEYSYM_RIGHT:
        return 0x27U;
    case CASSOTIS_KEYSYM_DOWN:
        return 0x28U;
    case CASSOTIS_KEYSYM_INSERT:
        return 0x2dU;
    case CASSOTIS_KEYSYM_DELETE:
        return 0x2eU;
    case CASSOTIS_KEYSYM_KP_MULTIPLY:
        return 0x6aU;
    case CASSOTIS_KEYSYM_KP_ADD:
        return 0x6bU;
    case CASSOTIS_KEYSYM_KP_SUBTRACT:
        return 0x6dU;
    case CASSOTIS_KEYSYM_KP_DECIMAL:
        return 0x6eU;
    case CASSOTIS_KEYSYM_KP_DIVIDE:
        return 0x6fU;
    case (guint32)';':
    case (guint32)':':
        return 0xbaU;
    case (guint32)'=':
    case (guint32)'+':
        return 0xbbU;
    case (guint32)',':
    case (guint32)'<':
        return 0xbcU;
    case (guint32)'-':
    case (guint32)'_':
        return 0xbdU;
    case (guint32)'.':
    case (guint32)'>':
        return 0xbeU;
    case (guint32)'/':
    case (guint32)'?':
        return 0xbfU;
    case (guint32)'`':
    case (guint32)'~':
        return 0xc0U;
    case (guint32)'[':
    case (guint32)'{':
        return 0xdbU;
    case (guint32)'\\':
    case (guint32)'|':
        return 0xdcU;
    case (guint32)']':
    case (guint32)'}':
        return 0xddU;
    case (guint32)'\'':
    case (guint32)'"':
        return 0xdeU;
    default:
        return 0;
    }
}

static inline gboolean cassotis_shortcut_matches_keysym(
    const CassotisShortcut *shortcut, guint32 key_sym, guint32 modifiers)
{
    guint16 key_code;
    guint32 actual_modifiers;

    if (shortcut == NULL || shortcut->key_code == 0 ||
        (modifiers & CASSOTIS_MODIFIER_SUPER) != 0)
        return FALSE;
    key_code = cassotis_shortcut_virtual_key(key_sym);
    if (key_code == 0 || key_code != shortcut->key_code)
        return FALSE;

    actual_modifiers = modifiers &
                       (CASSOTIS_MODIFIER_SHIFT |
                        CASSOTIS_MODIFIER_CONTROL |
                        CASSOTIS_MODIFIER_ALT);
    if (key_code == 0x10U)
        actual_modifiers &= ~CASSOTIS_MODIFIER_SHIFT;
    else if (key_code == 0x11U)
        actual_modifiers &= ~CASSOTIS_MODIFIER_CONTROL;
    else if (key_code == 0x12U)
        actual_modifiers &= ~CASSOTIS_MODIFIER_ALT;
    return actual_modifiers == shortcut->modifiers;
}

#endif
