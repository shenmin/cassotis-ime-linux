# Compatibility

## Binary Release Matrix

| Platform | IBus | Fcitx 5 | Status |
| --- | --- | --- | --- |
| Ubuntu 26.04.1 x86_64, GNOME, Wayland | Native adapter, real daemon input-context smoke | Native addon, official testfrontend plus desktop discovery/reload | Automated framework matrix passed |
| Ubuntu 26.04.1 x86_64, GNOME, X11 | Expected from the same framework APIs | Expected from the same framework APIs | Not yet release-gated |
| Ubuntu 26.04.1 aarch64, GNOME, Wayland | Native adapter, real daemon input-context smoke | Native addon, official testfrontend plus desktop discovery/reload | Automated framework matrix passed |
| Other distributions | Source build | Source build | Community-tested; no repackaged Debian binaries |

The x86_64 release-gated host uses Ubuntu 26.04.1, Linux 7.0.0-30,
Free Pascal 3.2.2, IBus
1.5.34-rc2, and Fcitx 5.1.19. Its automated desktop matrix was last completed
on 2026-09-16. Native ARM64 framework validation was completed on 2026-09-16
using Ubuntu 26.04.1, Linux 7.0.0-30, Free Pascal 3.2.2, IBus 1.5.34-rc2, and
Fcitx 5.1.19. These v1.26.1 port qualification runs use the frozen schema-24
simplified/traditional dictionaries; they do not replace final package acceptance.

Both architecture qualification runs covered the core test suite, simplified/traditional
dictionary regressions, frozen corpus quality and memory measurements, neural-runtime
smokes, blocked-model cold start, IPC stress/restart recovery, and all five
automated IBus/Fcitx desktop matrix stages. Completion qualification exceptions
are recorded in [BENCHMARK.md](BENCHMARK.md) and
[BENCHMARK.CN.md](BENCHMARK.CN.md), not treated as passed gates.
Each binary release must separately pass the full gate from its exact source
revision. Installing the final Debian package, application focus,
rendering, and desktop appearance remain manual checklist items on both
architectures.

Real GTK 3 and GTK 4 entry fields were also exercised through IBus on both
GNOME Wayland hosts on 2026-09-16. Native keyboard events verified Chinese
commit, raw Enter commit, bare Shift followed by an English period, and a
Shift-letter chord that must preserve Chinese mode. These input assertions
do not establish candidate placement or mixed-DPI rendering correctness.

Both framework adapters are deliberately thin. Parsing, dictionaries,
ranking, completion, settings state, and user learning live in the same local
engine, so framework choice must not change candidate quality.

## Automated Framework Matrix

Coverage includes:

| Framework | Automated assertion |
| --- | --- |
| IBus | Per-user installation, settings state round-trip, real desktop-daemon input context, preedit, candidates, raw commit, debug-weight mode, engine restart recovery |
| Fcitx 5 | Per-user installation, official isolated native testfrontend key path, candidate and completion behavior, settings state, addon discovery and reload in the real desktop daemon |
| Shared engine | One socket service, shared simplified/traditional dictionaries, shared user learning, all seven pinyin modes |

## Manual Release Checks

Wayland prevents an SSH-launched process from reliably stealing focus. The
following remain explicit manual checks before publishing a release:

- Enable Cassotis from GNOME Settings and type in one GTK 3 and one GTK 4 app.
- Switch between IBus and Fcitx 5 and confirm the same candidate order.
- Exercise simplified/traditional, full pinyin, one shuangpin scheme, user
  learning/deletion, completion, and the settings launcher.
- Confirm candidate placement and scaling on the release desktop.

Floating status-window styling, a tray application, and product logging remain
outside the current Linux product scope.

Windows-style red pinyin warnings are not part of this release. Windows renders
them in its own candidate window. IBus supports text-color attributes, whereas
the native Fcitx 5 text-format API offers theme-defined highlighting rather than
an explicit warning color. Linux retains the framework's normal rendering and
does not promise consistent red warnings across desktops or client applications.

## Read-Only Systems And User Installation

The portable `--user` installer was exercised on Ubuntu x86_64 and aarch64 on
2026-09-17 with a read-only `/usr`, a separate writable HOME and an isolated
D-Bus/PID namespace. Both native frameworks passed input, completion and
shortcut tests using relocated runtime files and registration metadata.
Upgrade and removal retained the learned-word database. These checks do not
modify the user's active desktop session.

This validates the user-directory installation mechanism, not SteamOS itself.
SteamOS Desktop Mode has not been tested on hardware; Gaming Mode is outside
this validation. A compatible IBus or Fcitx 5 and the required runtime libraries
must already be available. The installer refuses unsupported architectures,
missing/ABI-incompatible dependencies, non-writable or noexec runtime paths,
and conflicting installations before copying files. It never turns off OS
filesystem protection or lowers compiled framework version requirements.
See [portable user installation](BUILD.md#portable-user-installation).
