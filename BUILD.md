# Native Linux Build

The supported build entry points in this document run inside a native Linux
environment.

## Core Requirements

- Linux x86_64 or aarch64
- Bash
- Free Pascal 3.2.2 (the validated baseline)
- SQLite 3 runtime library (`libsqlite3.so.0`)
- GNU `realpath`
- C and C++20 compilers plus `pkg-config`
- IBus development package (`ibus-1.0`)
- Fcitx 5 development package (`Fcitx5Core`)
- Python 3 and PyGObject with GTK 3 introspection data
- `desktop-file-validate` from `desktop-file-utils` for release validation

CMake is not required by the current shell/FPC build. Both framework adapters
are part of a full build, so their development headers are required even when
only one adapter will be installed.

The repository carries the reviewed ONNX Runtime 1.20.1 headers and native
runtime libraries for x86_64 and aarch64, together with the deployed v1.19
models. No system ONNX Runtime package, network download, CUDA toolkit, or GPU
is required. `scripts/validate_runtime_assets.sh` selects the current native
architecture and verifies every bundled model and runtime artifact by SHA-256
before compilation.

The settings interface requires Python 3 and GTK 3 introspection at build and
runtime. Optional real-application validation additionally requires GTK 4 and
AT-SPI introspection data plus an active graphical desktop session; those
extra packages are not required for ordinary builds or the fully automated
IBus-daemon matrix.

## Environment Check

```bash
./scripts/check_environment.sh
```

Set `FPC` when the compiler is not available as `fpc`:

```bash
FPC=/opt/fpc/bin/fpc ./scripts/check_environment.sh
```

Set `CASSOTIS_SQLITE_LIBRARY` only when SQLite is installed under a nonstandard
name or location.

## Full Rebuild

```bash
./rebuild_all.sh
```

This performs the following deterministic sequence:

1. Validate that the host and FPC target are Linux.
2. Safely remove only the repository's `build/` directory.
3. Build the C++20 ONNX Runtime bridge and stage the architecture-matched
   runtime and model assets.
4. Force-rebuild the engine CLI, tests, benchmarks, neural runtime smokes,
   IBus adapter, and native Fcitx 5 addon.
5. Run CLI and neural-runtime smoke tests, including all six shuangpin schemes.
6. Run the complete FPCUnit suite.

Options:

```bash
./rebuild_all.sh --skip-tests
./rebuild_all.sh --benchmarks
./rebuild_all.sh --dictionary /path/to/dict_sc.db
```

The last command benchmarks both raw exact queries and the complete candidate
pipeline against a generated Cassotis Lexicon database.

Validate the frozen candidate-quality set against a final dictionary without
loading any user data:

```bash
./scripts/validate_candidates.sh --dictionary /path/to/dict_sc.db
```

The runner reports the observed rank for every expected phrase, grouped by
case category, plus mean, P50, P95, and maximum query latency. It exits with a
nonzero status when a phrase is missing or falls below its frozen rank bound.
Use `--cases FILE` to evaluate a separate UTF-8 TSV set with the same
`query`, `expected_text`, `maximum_rank`, and `category` columns.

For ranking diagnostics, invoke the runner directly with `--candidates`:

```bash
./build/bin/cassotis-candidate-regression /path/to/dict_sc.db \
    /path/to/cases.tsv --candidates
```

This optional mode prints the final score, original dictionary/path weight,
candidate source, display kind, and raw character-language-model score. Normal
regression runs do not open the additional diagnostic reader and retain their
ordinary latency measurement path.

## Incremental Commands

```bash
./build_all.sh
./test_all.sh
./clean_all.sh
./benchmark_all.sh --iterations 1000 --candidate-iterations 100
```

`build_all.sh --force` rebuilds all referenced Pascal units without first
removing `build/`. `build_all.sh --clean` performs a safe clean before that
forced build.

`--iterations` controls the parser, six-scheme shuangpin, and raw exact-query
loops. `--candidate-iterations` independently controls the more expensive
complete candidate pipeline, whose default is 100 iterations over 12 queries.

## Outputs

Current binaries are written to `build/bin/`:

- `cassotis-engine`
- `cassotis-core-tests`
- `cassotis-parser-benchmark`
- `cassotis-shuangpin-benchmark`
- `cassotis-dictionary-benchmark`
- `cassotis-candidate-benchmark`
- `cassotis-quality-benchmark`
- `cassotis-completion-benchmark`
- `cassotis-candidate-regression`
- `cassotis-neural-runtime-smoke`
- `cassotis-neural-engine-smoke`
- `ibus-engine-cassotis`
- `libcassotis.so`
- `cassotis-control`
- `cassotis-ibus-smoke`
- `cassotis-fcitx5-smoke`

Compiled Pascal units are isolated under `build/units/`. Both directories are
ignored by Git.

## Release Artifacts

Build the supported Debian package and portable dual-framework binary archive
from final dictionary databases:

```bash
./scripts/build_release.sh \
  --dictionary /path/to/dict_sc.db \
  --dictionary-traditional /path/to/dict_tc.db

./scripts/validate_release_artifacts.sh \
  --artifacts ./build/release \
  --dictionary /path/to/dict_sc.db \
  --dictionary-traditional /path/to/dict_tc.db
```

Artifact names follow each packaging ecosystem's architecture convention:

| Native host | Debian package | Portable binary archive |
| --- | --- | --- |
| x86_64 | `cassotis-ime_<version>_amd64.deb` | `cassotis-ime-linux-<version>-x86_64.tar.gz` |
| aarch64 | `cassotis-ime_<version>_arm64.deb` | `cassotis-ime-linux-<version>-aarch64.tar.gz` |

The `.tar.gz` files contain prebuilt, dynamically linked binaries for the
named architecture. They are not source archives or distribution-independent
packages. Each artifact also contains the matching ONNX Runtime libraries,
the v1.19 Pinyin-conditioned long-sentence scorer and local-completion assets,
and the required third-party notices; end users do not install a separate
inference runtime.

The release builder does not produce RPM or Arch packages from Debian-built
binaries. Other distributions should build both native adapters from source.
See [RELEASE.md](RELEASE.md) for the full source-parity, corpus benchmark, and
desktop-framework release gate.

End-user settings and persistent data behavior are documented in
[CONFIGURATION.md](CONFIGURATION.md).

## IBus Desktop Install

After a successful build, install the IBus integration with a generated
Cassotis simplified dictionary:

```bash
./scripts/install_ibus.sh --dictionary /path/to/dict_sc.db
```

The rootless script stages the dictionary and binaries, runs an isolated
adapter-to-engine self-test, stops the active GNOME IBus service, gracefully
shuts down installed adapter and engine processes by exact executable path,
and atomically replaces each artifact. Do not layer this per-user installation
over the Debian package: IBus gives the system component with the same engine
identifier precedence. Remove the package first, or continue using its
system-wide installation. Because current IBus builds do not search user components by
default, it adds a private `IBUS_COMPONENT_PATH` environment and GNOME
user-service override that preserve the system component directory and refresh
the IBus registry when the daemon starts. Uninstall removes this override and
restores the distribution service definition. After the restart the installer
restores the exact GNOME input-source list, MRU order, and active index captured
before the stop, then adds Cassotis and creates an isolated context through the
real desktop IBus daemon to verify preedit, candidates, and raw commit. Failure
cleanup follows the same restore path. Pass
`--no-enable` to skip adding Cassotis or `--skip-build` to install
already-built binaries. The latter does not require IBus development headers
or `pkg-config`. The install also registers `Cassotis IME Settings` as both
the standard IBus setup action and a desktop application. Its GTK front end
uses the installed `cassotis-control` client to read and update the shared
engine state; it does not contain candidate or ranking logic. Remove the
integration with:

```bash
./scripts/uninstall_ibus.sh
```

Run both scripts as the desktop user, not through `sudo`. No root privileges
are required. Uninstall retains the dictionary and user database, restores all
unrelated GNOME sources after the IBus restart, and removes only the Cassotis
source while keeping the active-source index valid. The desktop verification
can also be repeated independently:

```bash
./scripts/verify_ibus.sh
```

On GNOME, this verification temporarily adds and selects Cassotis so the real
daemon assertions cannot race with another active engine. It restores the
complete source list, MRU order, and active index on both success and failure.

Run the broader automatic daemon matrix through the desktop-validation entry
point, or add the interactive GTK 3/4 checks:

```bash
./scripts/validate_desktop_apps.sh
./scripts/validate_desktop_apps.sh --interactive
```

The interactive mode opens a real GTK input field and waits for the user to
focus it before injecting `nihao` and Space through AT-SPI. This explicit focus
step is intentional: GNOME Wayland correctly prevents an SSH-launched process
from stealing application focus. A focus timeout therefore reports an
unexecuted application assertion rather than an input-method failure.

Run the bounded IBus transport and engine stress test with an installed or
explicit dictionary:

```bash
./scripts/stress_ibus.sh --skip-build
./scripts/stress_ibus.sh --dictionary /path/to/dict_sc.db
```

The test uses a process-private socket and temporary user database. It covers
eight input contexts, simultaneous adapter clients using the same wire context
id, per-connection disconnect cleanup, partial-frame isolation, fast and
malformed input, engine restart recovery, per-key IPC latency, and post-warmup
RSS growth without changing desktop input state or learned words.

The installed-daemon smoke test also shuts down the engine while its IBus
input context remains alive. The next input must reconnect, reconstruct the
connection-local engine context, and publish candidates before validation can
pass.

## Fcitx 5 Desktop Install

After the same build, install the native Fcitx 5 addon for the current user:

```bash
./scripts/install_fcitx5.sh --dictionary /path/to/dict_sc.db
```

The rootless installer runs the addon through Fcitx's isolated native test
frontend, stages and atomically replaces the addon, shared engine/control
tools, settings launcher, and dictionary, then adds Cassotis to the current
Fcitx input-method group. Pass `--no-enable` to leave the profile unchanged or
`--skip-build` to install existing outputs. Remove only the Fcitx integration
with:

```bash
./scripts/uninstall_fcitx5.sh
```

IBus and Fcitx installations may coexist and share the engine, settings, base
dictionary, and persistent user database. Each uninstaller retains those
shared files while the other adapter remains installed; neither uninstaller
deletes learned words.

Repeat the isolated installed-addon verification with:

```bash
./scripts/verify_fcitx5.sh --installed \
    --dictionary ~/.local/share/cassotis-ime/dict_sc.db
```

On a running graphical session, add `--desktop` to also start or reuse the
real Fcitx daemon, verify addon discovery across a reload, and restore the
pre-existing input framework before exit. An SSH-launched Wayland session may
have no focused Fcitx input context; in that case native key behavior remains
fully asserted by the isolated test frontend while desktop discovery is still
verified. If the check must temporarily stop GNOME IBus, it snapshots and
restores the complete GNOME input-source state only after the restarted IBus
daemon is reachable; a restore failure makes the verification fail instead of
silently leaving the desktop with a pruned source list.
