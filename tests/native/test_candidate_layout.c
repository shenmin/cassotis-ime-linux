#include "cassotis_candidate_layout.h"

#include <stdio.h>
#include <string.h>

static int expect(gboolean condition, const char *message)
{
    if (condition)
        return 0;
    fprintf(stderr, "candidate layout test failed: %s\n", message);
    return 1;
}

static void initialize_result(CassotisEngineResult *result,
                              CassotisCandidate *candidates,
                              guint32 count)
{
    memset(result, 0, sizeof(*result));
    result->candidates = candidates;
    result->candidate_count = count;
}

int main(void)
{
    CassotisEngineResult result;
    CassotisCandidate short_candidates[9] = {0};
    CassotisCandidate long_candidates[9] = {0};
    guint32 index;
    int failed = 0;

    for (index = 0; index < 9; ++index) {
        short_candidates[index].text = (gchar *)"\xE4\xBD\xA0\xE5\xA5\xBD";
        long_candidates[index].text =
            (gchar *)"\xE4\xBB\x8A\xE5\xA4\xA9\xE5\x92\x8C\xE8\x80\x81\xE5\xA9\x86"
                     "\xE4\xB8\x80\xE8\xB5\xB7\xE5\x8E\xBB\xE4\xBB\x96\xE4\xBB\xAC"
                     "\xE8\xAF\xB7\xE6\x89\xAB\xE5\xA2\x93";
    }

    initialize_result(&result, short_candidates, 9);
    failed |= expect(!cassotis_candidate_row_requires_vertical(&result),
                     "nine short candidates should remain horizontal");
    initialize_result(&result, long_candidates, 9);
    failed |= expect(cassotis_candidate_row_requires_vertical(&result),
                     "the screenshot-sized row must become vertical");
    failed |= expect(cassotis_candidate_display_cells("abc") == 3,
                     "ASCII display width");
    failed |= expect(cassotis_candidate_display_cells(
                         "\xE8\xA8\x80\xE6\xB3\x89") == 4,
                     "CJK display width");
    failed |= expect(cassotis_candidate_display_cells("\xff") >
                         CASSOTIS_HORIZONTAL_CANDIDATE_CELL_BUDGET,
                     "invalid UTF-8 must use the safe layout");
    if (failed == 0)
        puts("candidate_layout=ok");
    return failed != 0;
}
