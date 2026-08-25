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

Changing the input mode, pinyin scheme, or fuzzy-pinyin rules clears an active
composition so existing keystrokes are never reinterpreted under another
scheme.

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

Completion is offered only when the input contains at least two complete
syllables and a supported lexicon/user transition can continue the exact
prefix. It is displayed separately from ordinary candidates and cannot change
their order.

## Function Shortcuts

| Action | Default |
| --- | --- |
| Chinese/English mode | `Shift` |
| Chinese/English punctuation | `Ctrl+.` |
| Simplified/Traditional dictionary | `Ctrl+Shift+T` |
| Half/full width | `Shift+Space` |
| Open settings | `Ctrl+Shift+F10` |

Shortcuts must be unique. A shortcut without Ctrl or Alt is limited to Shift
or an F1-F24 key so ordinary text input cannot be captured accidentally.

## User Data And Diagnostics

The Advanced page can show engine scores in candidate annotations, open the
data directory, or clear the user dictionary after confirmation. Clearing the
user dictionary removes learned words and related preferences and cannot be
undone.

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
