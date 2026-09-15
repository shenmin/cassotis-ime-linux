# Fcitx 5 Adapter

This directory contains the thin C++ `InputMethodEngineV2` adapter. It
translates Fcitx 5 context and key events to the shared Cassotis IPC protocol
and renders native preedit, candidates, completion, and status actions.

Dictionary access, pinyin decoding, candidate recall and ranking, and user
learning remain in the Free Pascal engine service. The adapter must not grow a
second implementation of those policies.

The adapter supports full pinyin and all six shuangpin schemes, paging and
cursor selection, mouse candidate activation, editing/cancel/raw commit,
one-key completion, Chinese/English input, punctuation and width shortcuts,
controlled fuzzy-pinyin actions, sensitive-field bypass, persistent user
learning, selected user-word deletion, context isolation, and transparent
engine reconnection. Surrounding text is synchronized with the shared engine
and participates in the same short-word and long-sentence context-ranking
stages used through IBus.

Build and install the user-local addon on Linux with:

```bash
./build_all.sh
./scripts/install_fcitx5.sh --dictionary /path/to/dict_sc.db
```

The installer stages and atomically installs
`libcassotis.so`, metadata, the shared engine/control/settings programs, and
the selected dictionary. By default it adds Cassotis to the current Fcitx
group. It does not change the desktop's selected input framework; after the
desktop is configured for Fcitx 5, choose `Cassotis 言泉拼音输入法`.

Cassotis exposes its existing GTK settings window through Fcitx's standard
input-method and addon configuration entries. Their configure actions in
`fcitx5-configtool` launch `cassotis-settings` directly;
`Ctrl+Shift+F10` remains available as the default in-input shortcut.

Remove the Fcitx integration with `./scripts/uninstall_fcitx5.sh`. The shared
runtime and data remain when IBus is installed, and learned user data is never
deleted by either framework uninstaller.
