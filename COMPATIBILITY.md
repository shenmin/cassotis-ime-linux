# Compatibility

## v2.1.0 Validation

The 2026-10-25 (UTC+8) validation uses the released Windows engine and
Cassotis Lexicon v2.4.0 inputs, including the revised benchmark readings and
Taiwan-form traditional dictionary. The model files are unchanged.

On both Ubuntu 26.04.1 x86_64 and aarch64, 916 core tests, 69 final-Tab projection checks,
SC/TC static and ready-neural candidate checks, isolated IBus/Fcitx 5 checks,
and native next-character query, cache and cancellation checks pass. The new
query interface is available to both foreground and background model views.
Nine GTK settings tests and control-client integration checks also pass. New
coverage includes corpus-prior ranking, short-phrase margin boundaries,
UTF-8/UTF-16/GBK frequency imports, SQLite rollback/persistence, cross-context
cache invalidation and retaining custom phrases when clearing learned data.

Fresh-process input checks passed on both architectures, each with 41 keys:

| Architecture | Process-cold first / maximum key (ms) | Blocked-model first / maximum key (ms) |
| --- | ---: | ---: |
| x86_64 | 3.992 / 30.558 | 3.994 / 28.223 |
| aarch64 | 3.986 / 27.729 | 4.277 / 27.844 |

These tests do not drop OS file caches. Blocked-model tests deliberately hold
model initialization and verify input again after releasing it. The text/next-character/query
ABI checks also verify independent 100 ms foreground, 120 ms background and
deadline-free test views, including supplementary-plane characters and the
traditional-to-simplified query mapping.

All four deadline-free corpus suites passed on both architectures. Long
Top1/Top2 are 13,435/14,314 on x86_64 and 13,435/14,313 on aarch64, out of
16,300. Context-enabled short Top1/Top2 are 63,455/64,423 and 63,454/64,423
out of 65,000. Short completion hits 10,512/12,831 and 10,513/12,831;
long continuation hits 3,876/16,300 and 3,883/16,300, saving 9,576 and 9,591
keys. Accuracy requirements were not relaxed.
Full measurements are in [BENCHMARK.md](BENCHMARK.md) /
[Chinese](BENCHMARK.CN.md).

Both architectures' Debian and portable validation packages contain the frozen SC/TC
databases and one verified model. Staged artifact checks, native inference,
settings and third-party notice checks pass. Installed-package validation passed:

| Platform | Verified checks |
| --- | --- |
| Ubuntu 26.04.1 x86_64 and aarch64, GNOME Wayland | Upgrade of the preceding 2.1.0 development installation, removal/reinstallation and unchanged personal dictionary/preferences; 31 input checks in each IBus/Fcitx 5, GTK 3/4, Wayland/XWayland combination (248 checks per architecture) |
| SteamOS 3.8.14 x86_64, KDE X11, IBus 1.5.32 | User-directory upgrade, uninstall/reinstall, discovery, settings launcher and 32 GTK input checks; personal dictionary/preferences and mount options unchanged, with no system installation |

The installed-input checks cover the effect of imported frequencies on actual
candidate selection, Taiwan-form candidates, traditional Tab completion and
switching back to simplified input, alongside punctuation, shuangpin, U/I/V
input, English recognition and custom phrases. Import tests use an isolated
synthetic dictionary, not personal exports. The SteamOS
check uses the existing desktop mount configuration; it is not a new read-only
mount test or a SteamOS Fcitx 5/game-mode claim.

A follow-up upgrade regression verifies the actual base database file descriptors
with stale user-directory copies still present. It covers system/relocated and
user installations, separate XDG data, symlinked homes/runtimes/launchers,
development fallback, environment and command-line overrides, and missing
explicit paths. Package validation also starts the staged executable without
dictionary overrides and checks both SC/TC paths. Personal data remains separate.
The corpus measurements above used explicit versioned databases; this path-only
fix does not change those dictionaries, models or ranking algorithms.

These results cover the v2.1.0 release inputs and the follow-up dictionary-path
fix described above. Earlier architecture or desktop results below retain their
historical scope; they are not substituted for the checks above. Upgrades refresh
the input framework; an application that was already open may need to be closed
normally and reopened to reconnect. Save any unsent text first.

## v2.0.0 Validation

The 2026-10-17 (UTC+8) alignment uses the released Cassotis IME and Cassotis
Lexicon v2.2.0 tags, fresh schema-24 dictionaries and corrected case readings.
All four complete corpus suites pass the accuracy and memory requirements on
both architectures without search, model or completion wall-clock deadlines.
Accuracy and latency come from the same queries, using eight model threads.
Latency is reported rather than tested against the superseded timed-run ceilings.
Production foreground/background model budgets remain 100/120 ms. The earlier
timed x86_64 long-sentence run scored 37 fewer Top1 and 36 fewer Top2 than its
deadline-free run and missed the original production accuracy floors. Passing
the deadline-free corpus suite does not remove that production limitation.
These budgets are not ceilings on whole-query or end-to-end key latency.
Measurements are in [BENCHMARK.md](BENCHMARK.md) /
[Chinese](BENCHMARK.CN.md).

| Platform | Current checks |
| --- | --- |
| Ubuntu 26.04.1 x86_64 and aarch64, GNOME Wayland hosts | 887 core tests and 69 final-Tab projection checks per architecture; six settings tests, candidate-layout and shortcut regressions |
| Both architectures | SC/TC incremental and whole-input candidate checks in static and ready-neural modes; ambiguous nasal boundaries, explicit apostrophes, double Pinyin, partial selection and undo |
| Both architectures | Isolated IBus normal/debug/disabled-shortcut checks and Fcitx 5 adapter checks, including Shift punctuation, U/I/V quick input, decimal periods and English/raw selection |
| Both architectures | Full deadline-free long/short candidate and completion suites, with the earlier x86_64 production limitation noted above; blocked model initialization, independent process-cold input, idle-memory reclamation and native math ABI checks |
| Both architectures | Three fresh-process replays of 500 cases with different argument/environment layouts; all candidate/completion traces identical within each architecture |

The packaging pipeline strips staging copies only, preserves the tested build
output, and uses XZ for Debian payloads. It checks dictionary and model hashes,
retired-model absence, both framework adapters, and portable install/uninstall
in a staging root. These checks do not replace installed-desktop testing.

The installed-package desktop matrix and SteamOS tests below were performed
before this final engine/dictionary alignment. They are retained with their
original scope, not claimed as new tests of these final packages. The current
isolated checks do not restart the user's active desktop input method.

### Earlier v2.1.0 Alignment

The 2026-10-14 alignment against v2.1.0 passed all four complete benchmark
groups, 869 core tests, 69 final-Tab checks, isolated framework checks and
cold-start/idle-memory tests on both architectures. Its dictionaries and case
readings predate the final v2.2.0 updates, so those results do not replace the
current gate. The earlier measurements remain in the benchmark documents.

### Earlier v2.0.0 Desktop And Pre-Alignment Validation

Native follow-up testing on 2026-10-13/14 (UTC+8) uses the Cassotis IME and Cassotis Lexicon
v2.0.0 baseline, one shared character language model and schema-24 dictionaries.
All four complete benchmark groups passed on aarch64. The x86_64 production
long-sentence accuracy gate had not passed at that point; short-word and completion gates
passed. Foreground/background model budgets remain 100/120 ms. These budgets are not
ceilings on whole-query or end-to-end key latency. Accuracy, latency and memory
measurements are in [BENCHMARK.md](BENCHMARK.md) / [Chinese](BENCHMARK.CN.md).

| Platform | Verified checks |
| --- | --- |
| Ubuntu 26.04.1 x86_64 and aarch64, GNOME Wayland | 863 core tests and 69 final-Tab projection checks per architecture; full long/short candidate and completion suites with the x86_64 quality failure noted above; model score/cache/cancellation checks |
| Ubuntu x86_64 and aarch64 | Initial Debian v1.0.1-to-v2.0.0 upgrade and follow-up v2.0.0 reinstall, removal/reinstallation, discovery and unchanged personal-dictionary hashes; only the shared model remains installed |
| Ubuntu x86_64 and aarch64 | 24 input checks in each of eight installed-package IBus/Fcitx 5, GTK 3/4 and Wayland/XWayland combinations (192 checks per architecture), including ASCII punctuation exceptions and English/raw selection |
| Ubuntu x86_64 and aarch64 | Relocated user installation with a read-only system tree; both framework adapters, upgrade/removal and retained user data |
| SteamOS 3.8.14 x86_64, KDE X11, IBus 1.5.32 | Follow-up user-directory upgrade, uninstall/reinstall, discovery, settings launcher and 25 real GTK input checks, including ASCII punctuation and English/raw selection; user data and mount options unchanged |

The follow-up passed both architectures' SC/TC candidate checks in incremental
and whole-input, static and ready-neural modes, actual-dictionary prefix/undo
checks, 25-field settings round trips, blocked-model initialization, independent
process-cold trials and idle-memory checks. Standalone source builds passed on
both architectures. Cold-start checks do not flush OS file caches.

The initial port also passed SC/TC fuzzy-input checks across contexts/restarts
and three identical 500-case candidate replays. A separate 1,000-case long-input
sample on aarch64 found no per-key/whole-input candidate-list differences in
static or ready-neural mode. Those initial-port checks do not replace the
follow-up's complete-corpus quality gate or its recorded x86_64 failure.

The portable native library retains the established glibc math ABI rather than
requiring glibc 2.43 solely because of the build host. Its inference instructions
and constants are unchanged; native model tests and 500-case replays passed
after the compatibility rebuild. SteamOS installation required no `sudo`,
system-directory writes or filesystem-protection changes. Personal dictionary
hashes and mount options were unchanged. Read-only `/usr` enforcement was also
tested in Ubuntu namespaces. No SteamOS corpus-performance result is claimed.

SteamOS Fcitx 5 and Gaming Mode, Chromium/Electron, standalone GNOME X11
sessions and mixed-DPI candidate placement are not newly qualified by these
checks. Text-commit assertions do not replace visual placement tests. The
coverage below remains historical.

## v1.0.1 Punctuation Fix

The shared IBus/Fcitx 5 key mapping now converts resolved Shift+number-row
symbols before applying the selected punctuation mode. Chinese punctuation
with half-width characters produces `（` and `）` from Shift+9 and Shift+0.
English punctuation, ordinary digits and modified application shortcuts retain
their existing behavior.

Regression coverage includes both native adapters, all ten shifted number-row
symbols, half/full-width modes and Shift release after a composition commit.
Package qualification covers Ubuntu x86_64 and aarch64, both frameworks and
GTK 3/4 Wayland/XWayland clients, alongside upgrade and user-install checks.
The reported Arch Linux Obsidian/VS Code environment and SteamOS are not
newly qualified for this patch. Text assertions do not establish visual
candidate-placement correctness.

Models, dictionaries and ranking are unchanged from v1.0.0. The benchmark
tables and historical measurements below retain their original version and
date; no new corpus benchmark result is claimed for this punctuation patch.

## v1.0.0 Validation

The shared character-language-model update uses the v1.31.0 engine and
dictionary baseline. Native qualification and installed-package checks were
completed on 2026-10-04.

| Platform | Verified checks |
| --- | --- |
| Ubuntu 26.04.1 x86_64 and aarch64, GNOME Wayland | 543 core tests per architecture; complete long-sentence and short-word candidate suites; production and deadline-free long completion; short completion; cold-start, inference cancellation, repeatability and IPC recovery |
| Ubuntu x86_64 and aarch64 | Debian v0.9.1-to-v1.0.0 upgrade, removal/reinstallation, immediate GNOME discovery and unchanged personal-dictionary hashes |
| Ubuntu x86_64 and aarch64 | Installed-package GTK 3/4 input through IBus and Fcitx 5, with Wayland and XWayland clients: eight combinations per architecture |
| Ubuntu x86_64 and aarch64 | Relocated portable user installation with a read-only `/usr`, both native frameworks, upgrade/removal and retained user data |
| SteamOS 3.8.14 x86_64, KDE X11, IBus 1.5.32 | User installation/upgrade, uninstall/reinstall, source discovery, settings launcher, Chinese/traditional/Ziguang input, bare Shift and Shift-letter handling, English punctuation and Tab completion |

All four complete quality suites passed on both architectures. Production uses
a 100 ms foreground character-model budget and a separate 120 ms background
completion budget; neither is a ceiling on the whole query. Models load
asynchronously, and dictionary candidates remain available during initialization.
Accuracy, latency, cold-start and memory measurements are published in
[BENCHMARK.md](BENCHMARK.md) / [Chinese](BENCHMARK.CN.md).

SteamOS installation did not require `sudo`, system-directory writes or changes
to filesystem protection. Enforcement of a read-only `/usr` was also exercised
in Ubuntu namespaces. No SteamOS corpus-performance result is claimed.
SteamOS Fcitx 5 and Gaming Mode, Chromium/Electron, standalone GNOME X11
sessions and mixed-DPI candidate placement are not newly qualified by these
checks. Text-commit assertions do not replace visual candidate-placement checks.
Previous version coverage below remains historical.

## v0.9.1 Validation

The memory-maintenance update retains the v1.29.0 engine/data baseline and both
framework adapters. The following checks were completed on 2026-09-29.

| Platform | Verified checks |
| --- | --- |
| Ubuntu x86_64 and aarch64 | 507 core tests per architecture; complete long-sentence, short-word and completion suites; cold-start, IPC recovery and sustained resident-memory checks |
| Ubuntu x86_64 and aarch64 | Debian v0.9.0-to-v0.9.1 upgrade, removal/reinstallation, immediate GNOME discovery and unchanged personal-dictionary hashes |
| Ubuntu x86_64 and aarch64 | Installed-package GTK 3/4 input through IBus and Fcitx 5, using Wayland and XWayland clients: eight combinations per architecture |
| Ubuntu x86_64 and aarch64 | Relocated portable user installation with a read-only `/usr`, both native frameworks, upgrade/removal and retained user data |
| SteamOS 3.8.14 x86_64, KDE X11, IBus 1.5.32 | User installation/upgrade, uninstall/reinstall, source discovery, settings launcher, Chinese/traditional/Ziguang input, Shift shortcuts and Tab completion |

After 11,000 queries and six seconds of inactivity, engine RSS measured
495.8 MiB on x86_64 and 494.6 MiB on aarch64, without swap. Complete long/short
candidate accuracy did not decline relative to v0.9.0. The x86_64 production
completion run saved 977 keys versus 979 previously; this two-key difference is
an explicitly accepted v0.9.1 exception, not a change to the 50 ms runtime budget
or other quality gates. Measurements and scope are recorded in
[BENCHMARK.md](BENCHMARK.md) / [Chinese](BENCHMARK.CN.md).

SteamOS checks did not change filesystem protection; read-only `/usr` enforcement
was exercised separately in Ubuntu namespaces. SteamOS Fcitx 5 and Gaming Mode,
Chromium/Electron, standalone GNOME X11 sessions and mixed-DPI candidate placement
are not newly qualified by these checks. Text-commit assertions do not replace
visual candidate-placement checks. The v0.9.0 coverage below remains historical.

## v0.9.0 Validation

The v1.29.0 engine/dictionary port and Linux 60 ms short-context inference budget
use the following native and installed-package coverage. Full corpus measurements
were completed on 2026-09-28; each final package must also pass payload, lifecycle
and desktop checks from its recorded source revision before publication.

| Platform | Verified checks |
| --- | --- |
| Ubuntu x86_64 and aarch64 | 491 core tests per architecture; complete long-sentence, short-word and completion suites; blocked-model and process-cold input; IPC stress and restart recovery |
| Ubuntu x86_64 and aarch64 | Debian v0.8.0-to-v0.9.0 upgrade, removal/reinstallation, immediate GNOME discovery and unchanged personal-dictionary hashes |
| Ubuntu x86_64 and aarch64 | Installed-package GTK 3/4 input under IBus/Fcitx 5, each with Wayland and XWayland clients: eight combinations per architecture |
| Ubuntu x86_64 and aarch64 | Relocated portable user installation with a read-only `/usr`, native tests for both frameworks, upgrade/removal and retained user data |
| SteamOS 3.8.14 x86_64, KDE X11, IBus 1.5.32 | User installation/upgrade, uninstall/reinstall, source discovery, preferences launcher, ordinary/traditional/Ziguang input and Tab completion |

SteamOS testing did not change filesystem protection. This host currently has
a writable `/usr`; enforcement of a read-only `/usr` was tested separately in
the isolated Ubuntu namespaces. No SteamOS corpus benchmark was required.
The SteamOS Fcitx 5 and Gaming Mode combinations remain untested. The input
assertions do not establish candidate placement or mixed-DPI rendering correctness.
Aggregate quality results and timing scope are recorded in
[BENCHMARK.md](BENCHMARK.md#v090-native-measurements) and
[BENCHMARK.CN.md](BENCHMARK.CN.md#v090-原生实测).

Both Ubuntu hosts run GNOME Wayland with IBus 1.5.34-rc2 and Fcitx 5.1.19.
The final package checks include both frameworks and all eight GTK/backend
combinations per architecture. SteamOS acceptance uses the final x86_64 portable
bundle; it is not an additional corpus-performance qualification.

Chromium/Electron, standalone GNOME X11 sessions, Gaming Mode and mixed-DPI
candidate placement are not claimed as newly verified by these automated runs.
Framework-managed candidate rendering still needs application-specific manual
observation; a successful text-commit assertion is not a visual-placement test.

## Historical v0.8.0 Release Matrix

| Platform | IBus | Fcitx 5 | Status |
| --- | --- | --- | --- |
| Ubuntu 26.04.1 x86_64, GNOME, Wayland | Native adapter, real daemon and GTK 3/4 input | Native addon, official testfrontend and GTK 3/4 input | Framework matrix and package acceptance passed |
| Ubuntu 26.04.1 x86_64, GNOME, X11 | Expected from the same framework APIs | Expected from the same framework APIs | Not yet release-gated |
| Ubuntu 26.04.1 aarch64, GNOME, Wayland | Native adapter, real daemon and GTK 3/4 input | Native addon, official testfrontend and GTK 3/4 input | Framework matrix and package acceptance passed |
| SteamOS 3.8.14 x86_64, KDE, X11 | IBus 1.5.32, user-directory installation and real GTK input | Not installed on the test host | User install/upgrade/removal, settings and desktop input passed |
| Other distributions | Source build | Source build | Community-tested; no repackaged Debian binaries |

The x86_64 release-gated host uses Ubuntu 26.04.1, Linux 7.0.0-31,
Free Pascal 3.2.2, IBus
1.5.34-rc2, and Fcitx 5.1.19. Its automated desktop matrix was last completed
on 2026-09-18. Native ARM64 framework validation was completed on 2026-09-18
using Ubuntu 26.04.1, Linux 7.0.0-30, Free Pascal 3.2.2, IBus 1.5.34-rc2, and
Fcitx 5.1.19. These v1.27.0 qualification runs use the frozen schema-24
simplified/traditional dictionaries. Debian acceptance separately covers a
v0.7.0 upgrade, removal and fresh v0.8.0 installation, with byte-identical
user data and immediate GNOME input-source discovery. Installed base
dictionaries match the v1.27.0 hashes.

Both architecture qualification runs covered the core test suite, simplified/traditional
dictionary regressions, frozen corpus quality and memory measurements, neural-runtime
smokes, blocked-model cold start, IPC stress/restart recovery, and all five
automated IBus/Fcitx desktop matrix stages. Completion results and the remaining
small cross-architecture differences are recorded in [BENCHMARK.md](BENCHMARK.md)
and [BENCHMARK.CN.md](BENCHMARK.CN.md). Both complete completion tracks pass
their unchanged quality and latency gates.
Each binary release must separately pass the full gate from its exact source
revision. Application focus behavior outside the tested clients, candidate
placement, rendering and desktop appearance remain manual checklist items.

Real GTK 3 and GTK 4 entry fields were exercised through both IBus and Fcitx 5
on the GNOME Wayland hosts on 2026-09-18, using native Wayland and XWayland
clients. Native keyboard events verified Chinese
commit, raw Enter commit, bare Shift followed by an English period, and a
Shift-letter chord that must preserve Chinese mode. These input assertions
do not establish candidate placement or mixed-DPI rendering correctness.
XWayland client tests do not imply that a standalone GNOME X11 session was tested.

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
2026-09-17/18 with a read-only `/usr`, a separate writable HOME and an isolated
D-Bus/PID namespace. Both native frameworks passed input, completion and
shortcut tests using relocated runtime files and registration metadata.
Upgrade and removal retained the learned-word database. These checks do not
modify the user's active desktop session.

The portable bundle was also tested on a SteamOS 3.8.14 x86_64 host
(build 20260707.10, glibc 2.41), KDE X11, IBus 1.5.32 on 2026-09-17.
Install, upgrade, uninstall and reinstall wrote only to the desktop user's
writable directories and preserved the user database byte-for-byte. A real
GTK entry field verified Chinese commit, raw Enter commit, bare Shift followed
by an English period, a Shift-letter chord, traditional conversion and Tab
completion. Ziguang shuangpin additionally passed ordinary input and an `ong`
boundary case. The actual IBus preferences entry opened the settings window,
and the installer preserved the
selected English keyboard and other IBus input sources during refresh.
No system OpenCC was installed: this test exercised the bundle's private
OpenCC/MARISA libraries and conversion data, including their attribution files.
No filesystem protection was changed. Gaming Mode and Fcitx 5 on SteamOS remain
untested; the separate Ubuntu read-only namespace tests cover write protection.
SteamOS acceptance is limited to installation and actual usability. Corpus
quality and performance benchmarks run on the two Ubuntu hosts, not SteamOS.

A compatible IBus or Fcitx 5 and the remaining runtime libraries must already
be available. The installer refuses unsupported architectures,
missing/ABI-incompatible dependencies, non-writable or noexec runtime paths,
and conflicting installations before copying files. It never turns off OS
filesystem protection or lowers compiled framework version requirements.
See [portable user installation](BUILD.md#portable-user-installation).
