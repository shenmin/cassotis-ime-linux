# Configuration

[简体中文](CONFIGURATION.CN.md) | English

Cassotis keeps input settings in the shared per-user engine. IBus and Fcitx 5
therefore observe the same state and user dictionary. Open **Cassotis IME
Settings** from the desktop application list or from the framework's Cassotis
property menu.

## General

| Option | Values | Default | Meaning |
| --- | --- | --- | --- |
| Input mode | Simplified Chinese, Traditional Chinese, English | Simplified Chinese | Selects Chinese/English input and the active base dictionary. |
| Pinyin scheme | Full Pinyin; Microsoft, Xiaohe, Ziranma, Sogou, Ziguang, or Pinyin Jiajia shuangpin | Full Pinyin | Changes only keyboard decoding; all schemes share recall, ranking, learning, and completion. |
| Punctuation | Chinese, English | Chinese | Chooses full-width Chinese punctuation mapping or literal English punctuation. |
| Character width | Half width, full width | Half width | Converts printable ASCII characters when full-width mode is enabled. |
| Decimal period after digits | On, off | On | In Chinese punctuation mode, a period immediately after directly typed digits produces `.` instead of `。`. |
| Recognize English words, commit with Space | On, off | On | In full pinyin, shows recognized English raw text as an unnumbered candidate. |
| Half-width punctuation exceptions | ASCII punctuation characters | Markdown preset | Keeps selected symbols half width in Chinese punctuation and half-width character mode. |

The **Markdown preset** contains `-`, `#`, `*`, `+`, `_`, `=`, the backtick,
`~`, `[`, `]`, `<`, `>`, `|` and `@`. Parentheses, quotation marks, commas,
periods and backslashes are not part of this preset. Use **Clear exceptions**
for ordinary Chinese punctuation or enter your own set. Duplicate symbols are
removed. Switching to English punctuation or full-width characters disables
exceptions without discarding the saved set.

English recognition preserves original case. Its unnumbered candidate appears
only on the first page; Space commits the highlighted candidate, while `1`-`9`
still select the corresponding Chinese candidates. Arrow keys or a mouse click
can select raw input explicitly. The engine remembers the latest raw/Chinese
choice for that query separately from learned Chinese words. This feature does
not reinterpret shuangpin codes or U/I/V quick-input commands. Disable it in
Settings to keep ordinary pinyin selection behavior.

Changing the input mode, pinyin scheme, or fuzzy-pinyin rules clears an active
composition so existing keystrokes are never reinterpreted under another
scheme.

Full pinyin accepts `lue`/`nue` as aliases of `lve`/`nve`, and complete
`jv`/`qv`/`xv`, `jve`/`qve`/`xve`, `jvan`/`qvan`/`xvan` and
`jvn`/`qvn`/`xvn` syllables as aliases of their canonical `u` spelling.
An explicit apostrophe keeps syllables separate (`lu'e` is not `lve`). Partial-prefix
candidates still refer to the original keystrokes, and Enter commits that
original spelling unchanged.

## Quick Input

In full pinyin, type a command directly. In any of the six shuangpin schemes,
start with `Shift+U`, `Shift+I` or `Shift+V` so normal double-pinyin codes
remain available.

| Command | Content |
| --- | --- |
| `ufh` | Common symbols |
| `uxh` | Numbered markers |
| `usx` | Mathematical symbols |
| `ujt` | Arrows |
| `udw` | Units |
| `ubd` | Chinese punctuation |
| `urq` / `usj` / `uxq` | Current date, time and weekday |
| `i123.45` / `v123.45` | Chinese numbers and uppercase currency amounts |

In numeric conversion mode, digit keys continue entering the number. Select
with the displayed letter labels (`a/b/c/d`), arrow keys and Space, or a
candidate click. These conversions need no language model and are not learned
as user words.

The default-on **Decimal period after digits** option makes the period key
produce `.` immediately after directly typed digits in Chinese punctuation
mode. It does not infer continuity from existing surrounding text. Navigation,
input-context changes and non-digit input restore ordinary Chinese periods;
candidate-selection digits do not count as directly typed numbers. English
punctuation mode is unchanged.

## Candidates

The candidate page size can be set from 3 through 9; the default is 9. The
candidate panel's font, colors, placement, scaling, and orientation are owned
by IBus/Fcitx and the desktop theme. Cassotis does not draw or position a
separate popup on Linux.

## Controlled Fuzzy Pinyin

Fuzzy pinyin is disabled by default. Individual initial/final pairs can be
enabled for `z/zh`, `c/ch`, `s/sh`, `l/n`, `f/h`, `r/l`, `an/ang`, `en/eng`,
`in/ing`, `ian/iang`, and `uan/uang`.

The engine applies at most one configured change to a complete input of at
most four syllables. Exact original spelling remains preferred over a fuzzy
match. Prefix, jianpin, and arbitrary sentence-path recall are not expanded.

## Paging And Completion

Candidate paging supports `-/+`, `[/]`, `,/.`, or `Shift+Tab/Tab`. One-key
completion supports either `Tab` or the backtick key. `Tab` cannot be assigned
to both paging and completion; the settings application resolves that conflict
before applying the state.

After at least two complete syllables, dictionary and reliable transition
evidence can offer an immediate completion. The local language model may rerank
or extend it in the background; insufficient-confidence predictions stay hidden.
Completion is displayed separately from ordinary candidates and does not change
their order. Ordinary candidate selection remains available while the model works.

## Custom Phrases

Add shortcuts and literal text on the **Custom Phrases** page, then click
**Apply**. Shortcuts contain 1–32 ASCII letters and are case-insensitive.
The list supports 1,024 entries with up to 4,096 UTF-16 code units per phrase.
In Chinese mode, an exact shortcut takes priority in the completion row;
press the configured `Tab` or backtick key to commit it. Full pinyin and all
six shuangpin schemes match the keys actually typed, not decoded pinyin.

Numbered candidates and Space selection are unchanged. Whitespace, newlines
and tabs are preserved; phrases are not converted between scripts or widths
and are not learned as ordinary user words. The panel shows only a bounded
single-line preview. Expansion is disabled in English mode and after choosing
a prefix word within the current composition.

Edit, delete or reorder entries; the first entry wins for duplicate shortcuts.
Import/export uses the same UTF-8 JSON format as the Windows version:

```json
[["addr", "My usual address"], ["sig", "First line\nSecond line"]]
```

Import validates the entire file before asking to replace the editor list;
click **Apply** to persist it. Restoring defaults and clearing learned words
do not delete custom phrases. Use the page's Delete button instead. Phrases
are stored as settings in the user database, shared by both frameworks and
preserved across restarts.

## Function Shortcuts

| Action | Default |
| --- | --- |
| Chinese/English mode | `Shift` |
| Chinese/English punctuation | `Ctrl+.` |
| Simplified/Traditional dictionary | `Ctrl+Shift+T` |
| Half/full width | `Shift+Space` |
| Open settings | `Ctrl+Shift+F10` |

Each function shortcut can be enabled or disabled independently. Disabling
one preserves its configured key combination without consuming those keys;
the setting is shared by both frameworks and survives restart. Only enabled
shortcuts must be unique. An unmodified key is limited to Shift or F1-F24 so
ordinary text input cannot be captured accidentally.

## User Data And Diagnostics

The Advanced page can show engine scores in candidate annotations, open the
data directory, or clear the user dictionary after confirmation. Clearing the
user dictionary removes learned words and related preferences, including Tab
continuation feedback and imported frequencies, and cannot be undone. Custom
phrases are kept.

### Importing Word Frequencies

In Advanced, choose **Import word frequencies** (导入输入频次), read the warning,
then select a file containing your own typing statistics. This changes candidate
ranking immediately; it is not a replacement base dictionary and does not need
Apply. Use only statistics you trust. Reimporting the same file adds its counts
again; an import cannot be undone separately. Back up your user data with the
engine stopped if you need to restore it later.

Accepted formats include CSV, tab-separated text, and numbered text exports:

```text
实现,shixian,30
shiyan,实验,12
"测试","ceshi","5"
1. 输入法 — 20 次 — shurufa
```

For CSV/TSV, fields may be in any order; the count is optional and defaults to
one. ASCII/full-width commas and optionally quoted fields are accepted. Use
full pinyin, not abbreviations or Double Pinyin codes. Blank lines, `#` comments
and invalid rows are skipped. UTF-8, BOM-marked UTF-16 and GBK files up to 16 MiB
are supported.

Entries pass normal user-learning validation; a parsed row may still be rejected
if its text and reading do not match. Each row contributes at most 400 selections,
and the most frequent row for an input becomes its latest choice. The entire
import is one transaction; database errors roll it back. The result reports both
parsed and imported rows. It takes effect in IBus and Fcitx 5 and survives an
engine restart. Complete any pending composition before importing.

Default paths follow the XDG base-directory specification:

```text
~/.local/share/cassotis-ime/user_dict.db
~/.local/share/cassotis-ime/dict_sc.db
~/.local/share/cassotis-ime/dict_tc.db
$XDG_RUNTIME_DIR/cassotis-ime/engine.sock
```

System packages place read-only base dictionaries under
`/usr/share/cassotis-ime/`; a per-user dictionary at the path above takes
precedence. Learned data is never removed by package or portable uninstall.
