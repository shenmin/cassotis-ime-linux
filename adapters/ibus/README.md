# IBus Adapter

This directory contains the thin C/GObject `IBusEngine` adapter. It translates
framework key events, exchanges versioned binary IPC frames with the Free
Pascal engine, and renders preedit and lookup-table results through native IBus
APIs. It does not contain dictionary, pinyin, learning, or ranking logic.

The adapter uses the shared production candidate pipeline, including the full
v1.20.0 exact, alias, prefix, jianpin, segmented-path, short-word, long-sentence,
context-ranking, completion, and user-signal stages. It supports selection by
space, number, mouse, and cursor movement; paging,
backspace, Escape, and raw-pinyin commit with Enter; persistent cross-context
user learning; full pinyin and six shuangpin schemes; Shift Chinese/English
switching; `Ctrl+.` punctuation switching; `Shift+Space` full-/half-width
switching; Chinese/English punctuation plus full-/half-width state; and
`Ctrl+Delete` removal of the currently selected deletable user word. Exact
one-key completion appears as a protected final lookup-table row after at
least two complete syllables and is accepted with its configured `Tab` or
backtick key; an unmatched completion key remains an application key. This
mapping keeps completion below ordinary candidates because GNOME Shell fixes
IBus auxiliary text above the lookup table.

Long-prefix static misses may enqueue the v1.20 constrained local-completion
worker, including its gated fallback generator. The adapter polls the
versioned engine result without blocking key
delivery, applies only the matching context generation, and stops polling on
focus loss, reset, disable, replacement by a newer request, or a bounded
timeout. Neural inference and all acceptance rules remain in the shared engine
process rather than the adapter.

IBus properties expose input mode, punctuation, character width, a pinyin
scheme submenu, and a controlled fuzzy-pinyin submenu. The fuzzy menu keeps a
separate master switch and eleven independently selectable rules; first-time
enablement selects a conservative default set. All state changes are sent to
the engine and persisted rather than being implemented as adapter-side
candidate logic.

The installed component exposes `cassotis-settings` through IBus's standard
setup entry and the `ibus-setup-cassotis.desktop` launcher required by GNOME's
input-source preferences action. The GTK 3 window invokes the small
`cassotis-control` protocol client, so settings, diagnostics, IBus, and the
native Fcitx 5 adapter all observe the same engine-owned state. While a Cassotis
context is focused, the adapter polls that shared state every 500 ms and updates
properties only when a value changes; polling stops on focus-out or disable and
does not rebuild candidates on unchanged ticks.

Password, PIN, and hidden-text content types are treated as sensitive. The
adapter deactivates their engine context, clears any visible composition, and
passes keys directly to the application; it does not send surrounding text or
candidate input to the engine in those fields.

Preedit and candidates are always rendered through IBus native APIs. Cassotis
does not create or position a separate candidate window, so cursor following,
Wayland placement, mixed-DPI behavior, and desktop theming remain the native
IBus panel's responsibility. Candidate behavior is supplied by the same
production Free Pascal engine used by the Fcitx 5 adapter and is covered by
the frozen Linux/Windows consistency gate.

Build on Linux with `./build_all.sh`, then install for the current user with:

```bash
./scripts/install_ibus.sh --dictionary /path/to/dict_sc.db
```

The rootless installer explicitly adds its private component directory to the
IBus daemon's static search path, while retaining the system component path,
and starts the GNOME user service with `--cache=refresh`. This is required
because IBus `cache=auto` can retain a registry that omits a newly installed
per-user component. GNOME can therefore enumerate Cassotis in its input-source
switcher immediately and after later daemon restarts. Do not layer the
rootless installation over a system-wide Cassotis Debian package: IBus gives
the system component with the same engine identifier precedence, so the
installer rejects that configuration instead of silently launching stale
binaries. IBus starts the adapter on demand; the adapter then starts the Pascal
engine through the versioned socket boundary. Use `Super+Space` to select
`Cassotis 言泉拼音输入法` after
installation.

The adapter-to-engine self-test uses a per-process private socket, verifies
incremental and exact candidates, shuangpin decoding, and a complete
`pianruo` one-key completion round trip, then cleans up the engine process it
starts. It can run while the desktop component is installed:

```bash
build/bin/ibus-engine-cassotis --self-test
```

The production socket also supports an acknowledged graceful shutdown used by
upgrade and uninstall scripts. `scripts/verify_ibus.sh` creates an isolated
input context through the active desktop IBus daemon and verifies that the
installed component handles fixed and mixed-jianpin candidates, one-key
completion, paging, editing, raw commit, mode shortcuts, sensitive fields, and
terminal- and Chromium-style capability profiles. This covers component
discovery and framework routing, not only the private adapter protocol.

`scripts/validate_desktop_apps.sh --interactive` adds real GTK 3/4 input-field
checks. It deliberately waits for explicit desktop focus because a process
launched over SSH must not circumvent GNOME Wayland focus security.

For bounded multi-context, multi-client, malformed-input, restart, latency,
and RSS testing, run `scripts/stress_ibus.sh`. It also uses a private socket and
temporary user database, so it does not interfere with the installed desktop
component. The multi-client check deliberately reuses the same wire context id
on two connections, disconnects one peer, and leaves a partial frame pending
on another peer to verify namespace and scheduling isolation.

The production socket accepts up to 16 simultaneous local clients. A
single-threaded event loop incrementally buffers their frames and serializes
engine access because the engine and its SQLite connection are not
thread-safe. Context ids are local to each connection and are translated to
unique engine ids; disconnecting an adapter destroys only the contexts owned
by that connection. This control plane allows IBus, settings tools, diagnostics,
and Fcitx 5 to coexist without duplicating engine state.

Each adapter client assigns a monotonically changing generation to successful
socket connections. Every IBus engine instance compares that generation before
context synchronization; after an engine restart it discards the stale remote
mapping, recreates the context, and reapplies active and surrounding-text
state before processing the next key. Sends remain bounded to 150 ms and
responses to 3.5 seconds. The latter exceeds the release gate's 3-second
worst-case query budget without permitting an unbounded UI wait. The
installed-daemon smoke test exercises this recovery with a live IBus input
context.
