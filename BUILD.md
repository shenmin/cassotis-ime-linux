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
