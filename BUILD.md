# Native Linux Build

## Requirements

Build on Linux x86_64 or aarch64 with Free Pascal 3.2.2, C/C++20 compilers,
Bash, SQLite 3, OpenCC, Python 3/PyGObject, GTK 3, and the IBus and Fcitx 5 development
headers. Both adapters are built; only one framework needs to be active.

On Ubuntu/Debian:

```bash
sudo apt install fpc gcc g++ pkg-config sqlite3 libsqlite3-dev libopencc-dev \
  libglib2.0-dev libibus-1.0-dev fcitx5 fcitx5-modules \
  libfcitx5core-dev libfcitx5config-dev python3 python3-gi \
  gir1.2-gtk-3.0 desktop-file-utils
./scripts/check_environment.sh
```

Set `FPC=/path/to/fpc` for a compiler outside PATH. Set
`CASSOTIS_SQLITE_LIBRARY` only for a nonstandard SQLite library location.
CMake, CUDA, a GPU, and a system ONNX Runtime installation are not required.
The repository includes the CPU runtime and model assets; SHA-256 checks in
`data/runtime-assets.sha256` are verified before compilation.
OpenCC's shared library and `s2t.json`/`t2s.json` conversion data are required
for displaying shared learned words in the selected simplified/traditional form.

## Build

```bash
./rebuild_all.sh
```

This checks the native environment, removes only `build/`, and rebuilds the
engine, both adapters, control client, and native inference bridge.

```bash
./build_all.sh          # incremental build
./build_all.sh --force  # rebuild referenced Pascal units
./clean_all.sh
```

Outputs in `build/bin/`:

| File | Purpose |
| --- | --- |
| `cassotis-engine` | Shared local engine service |
| `ibus-engine-cassotis` | IBus adapter |
| `libcassotis.so` | Fcitx 5 addon |
| `cassotis-control` | Settings and service-control client |
| `libcassotis_pinyin_transformer_ort.so` | Native inference bridge |
| `libonnxruntime.so*` and model directories | Bundled CPU inference runtime and models |

Settings are provided by `adapters/ibus/cassotis_settings.py`, installed as
`cassotis-settings`. Pascal compilation output stays under `build/units/`.

## Install From Source

Obtain matching simplified/traditional SQLite databases from
[Cassotis Lexicon](https://github.com/shenmin/cassotis-lexicon), then choose
the installer for your desktop framework:

```bash
./scripts/install_ibus.sh --dictionary /path/to/dict_sc.db \
  --dictionary-traditional /path/to/dict_tc.db
# Or:
./scripts/install_fcitx5.sh --dictionary /path/to/dict_sc.db \
  --dictionary-traditional /path/to/dict_tc.db
```

Run these as the desktop user, not through sudo. They stage and atomically
install the selected adapter, shared engine, settings, and dictionaries.
`--skip-build` reuses compiled outputs; `--no-enable` leaves the input-source
or Fcitx profile list unchanged. Select Cassotis with your desktop's input
switcher. Settings are available through the framework's preferences action
or Ctrl+Shift+F10.

Do not layer the per-user IBus installation over a Cassotis Debian package.
Remove that package first or continue using the system-wide installation.
The IBus installer refreshes the registry and preserves other GNOME sources.
The Fcitx installer adds Cassotis to the current group but does not select
Fcitx as your desktop's input framework.

```bash
./scripts/uninstall_ibus.sh
./scripts/uninstall_fcitx5.sh
```

Uninstallers retain learned words and keep shared files while the other
adapter remains installed.

## Portable User Installation

An extracted binary archive can install to a writable home directory, even
when `/usr` is read-only. This does not require a compiler or root access:

```bash
./install.sh --user --framework fcitx5 --check
./install.sh --user --framework fcitx5
# Or choose --framework ibus for an IBus desktop session.
```

Do not use `sudo`/`su`, `DESTDIR`, or disable the OS's read-only protection.
`DESTDIR` is only a staging tree for system packages, not a live relocation.
The `--user` option requires an archive containing `install-support/`; older
archives without that directory do not support this installation mode.

The runtime requires Python 3.9+, PyGObject/GTK 3, SQLite 3, and the selected
framework's runtime libraries. A working system OpenCC and its conversion
data take precedence; the portable bundle includes a private OpenCC/MARISA
fallback for systems without them. The `.deb` uses system OpenCC dependencies.
`ldd` is
required for preflight checks. `--check` verifies bundle checksums, CPU
architecture, native symbol dependencies, the compiled Fcitx minimum version,
dynamic engine dependencies, destination ownership and available space. It
does not install files or change desktop settings. No dependencies are
downloaded or installed automatically.

| Content | User location |
| --- | --- |
| Engine, settings, inference runtime and models | `~/.local/libexec/cassotis-ime/` |
| Fcitx 5 native addon | `~/.local/lib/fcitx5/libcassotis.so` |
| Dictionaries and installation receipt | `$XDG_DATA_HOME/cassotis-ime/` |
| Framework metadata, desktop launcher and icon | Subdirectories of `$XDG_DATA_HOME/` |
| IBus discovery environment | `$XDG_CONFIG_HOME/environment.d/`, GNOME user-service drop-in and Plasma environment script |

Unset `XDG_DATA_HOME` and `XDG_CONFIG_HOME` default to `~/.local/share` and
`~/.config`. Keep these paths unchanged during upgrades. The installer
relocates framework registration and settings launchers, not just binaries.
It can refresh the current user's running framework and add Cassotis to its
list, but does not switch the desktop between IBus and Fcitx 5 or configure
application input-method environment variables. Install from a terminal in
the graphical desktop session, after finishing any pending composition.
Use `--no-refresh` to defer framework restart and input-list changes; then
restart the framework or sign out and back in, and add Cassotis manually.

To upgrade, extract the new archive and run `./install.sh --user` again. Auto
selection retains the previously installed framework(s); `--framework both`
installs both adapters, not two active desktop input frameworks. Changed
package files are replaced with rollback on copy failure; unlisted files,
settings and learned words are retained. If a tracked file was edited or an
unmanaged installation conflicts, the installer stops rather than overwriting
it. Remove that older installation with its original uninstaller first.

```bash
./uninstall.sh --user
```

Run removal as the same desktop user, without sudo. It uses the installed
receipt rather than the archive's old manifest, so it also covers files from
subsequent upgrades. Modified package files are reported and retained for
manual review. System/package installations still require their respective
system uninstaller or package manager.

SteamOS and other immutable systems may have different glibc, libstdc++ and
Fcitx versions from the binary build host. Passing the writable-directory
check does not establish binary compatibility. A failed ABI preflight needs
a compatible native build, not root privileges or forced dependency changes.
SteamOS Gaming Mode and hardware-specific integration are not validated.
See [COMPATIBILITY.md](COMPATIBILITY.md) for the tested SteamOS desktop setup.

## Build Packages

```bash
./scripts/build_release.sh \
  --dictionary /path/to/dict_sc.db \
  --dictionary-traditional /path/to/dict_tc.db
```

| Host | Debian package | Portable binary archive |
| --- | --- | --- |
| x86_64 | `cassotis-ime_<version>_amd64.deb` | `cassotis-ime-linux-<version>-x86_64.tar.gz` |
| aarch64 | `cassotis-ime_<version>_arm64.deb` | `cassotis-ime-linux-<version>-aarch64.tar.gz` |

Artifacts under `build/release/` contain the matching runtime, models,
dictionaries, and licenses. The tarballs contain dynamically linked binaries,
not source code or distribution-independent packages. Other distributions
may need native builds against their framework and C library versions.

See [compatibility](COMPATIBILITY.md), [configuration](CONFIGURATION.md),
and [benchmark results](BENCHMARK.md) / [Chinese](BENCHMARK.CN.md).
