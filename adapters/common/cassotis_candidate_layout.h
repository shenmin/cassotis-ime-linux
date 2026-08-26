#ifndef CASSOTIS_CANDIDATE_LAYOUT_H
#define CASSOTIS_CANDIDATE_LAYOUT_H

#include <glib.h>

#include "cassotis_protocol.h"

/*
 * Native panels do not consistently constrain a horizontal lookup table.
 * Keep ordinary short lists horizontal, but use a conservative cell budget
 * before asking the desktop framework to render the row vertically.
 */
#define CASSOTIS_HORIZONTAL_CANDIDATE_CELL_BUDGET 72U
#define CASSOTIS_CANDIDATE_LABEL_CELL_OVERHEAD 3U

static inline guint32 cassotis_candidate_display_cells(const gchar *text)
{
    const gchar *cursor = text != NULL ? text : "";
    guint32 cells = 0;

    while (*cursor != '\0') {
        gunichar value = g_utf8_get_char_validated(cursor, -1);
        if (value == (gunichar)-1 || value == (gunichar)-2)
            return CASSOTIS_HORIZONTAL_CANDIDATE_CELL_BUDGET + 1U;
        cells += g_unichar_iswide(value) ? 2U : 1U;
        if (cells > CASSOTIS_HORIZONTAL_CANDIDATE_CELL_BUDGET)
            return cells;
        cursor = g_utf8_next_char(cursor);
    }
    return cells;
}

static inline gboolean cassotis_candidate_row_requires_vertical(
    const CassotisEngineResult *result)
{
    guint32 index;
    guint32 cells = 0;

    if (result == NULL)
        return FALSE;
    for (index = 0; index < result->candidate_count; ++index) {
        guint32 item_cells = cassotis_candidate_display_cells(
            result->candidates[index].text);
        if (item_cells > CASSOTIS_HORIZONTAL_CANDIDATE_CELL_BUDGET)
            return TRUE;
        if (cells > CASSOTIS_HORIZONTAL_CANDIDATE_CELL_BUDGET -
                        CASSOTIS_CANDIDATE_LABEL_CELL_OVERHEAD)
            return TRUE;
        cells += CASSOTIS_CANDIDATE_LABEL_CELL_OVERHEAD;
        if (cells > CASSOTIS_HORIZONTAL_CANDIDATE_CELL_BUDGET - item_cells)
            return TRUE;
        cells += item_cells;
    }
    return FALSE;
}

static inline gboolean cassotis_candidate_panel_requires_vertical(
    const CassotisEngineResult *result)
{
    if (result == NULL)
        return FALSE;
    if (result->completion_text != NULL && result->completion_text[0] != '\0')
        return TRUE;
    return cassotis_candidate_row_requires_vertical(result);
}

#endif
