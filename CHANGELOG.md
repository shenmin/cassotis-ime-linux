# Changelog

## 0.2.0 - 2026-08-28

- Ported the Cassotis IME and Cassotis Lexicon v1.18.0 behavior/data baseline,
  including schema-24 dictionary signals and all 42 generated ranking models.
- Added the compact long-sentence Transformer reranker through a native
  C++20/ONNX Runtime bridge for x86_64 and aarch64.
- Added constrained asynchronous local completion with generation-safe result
  polling in the shared service and both IBus and Fcitx 5 adapters.
- Bundled and checksum-gated the architecture-specific ONNX Runtime 1.20.1
  libraries, deployed models, runtime index, and third-party notices.
- Extended source, dictionary, quality, staged-payload, and release-artifact
  validation to cover the new neural runtime and model assets.
- Hardened rootless IBus upgrades with exact executable-path shutdown,
  persistent component-cache refresh, stale bus-address cleanup, and explicit
  rejection of mixed system-wide and per-user Cassotis installations.
- Completed the native v1.18.0 quality, memory, package-installation, and
  five-stage IBus/Fcitx release gates on both x86_64 and aarch64.
- Bound release manifests to runtime symlinks and hardened portable uninstall
  cleanup so package extraction and removal round trips leave no managed files
  or directories behind.

## 0.1.1 - 2026-08-27

- Fixed bare Shift mode switching in both IBus and Fcitx 5 so applications
  receive a balanced key press/release pair. This prevents the next character
  from being interpreted as Shift-modified, such as `.` becoming `>` after
  switching to English input mode.
- Added adapter-level regression coverage for the modifier-release contract on
  both supported input-method frameworks.

## 0.1.0 - 2026-08-25

First Linux release based on the Cassotis IME and Cassotis Lexicon v1.17.0
behavior/data baseline.

- Added one shared Free Pascal engine with complete short-word, long-sentence,
  completion, context ranking, and user-learning paths.
- Added full pinyin and six shuangpin schemes with controlled fuzzy pinyin.
- Added native IBus and Fcitx 5 adapters backed by the same engine, settings,
  dictionaries, and learned data.
- Added a GTK 3 settings application for supported cross-platform options.
- Added deterministic amd64 and arm64 Debian packages and portable binary
  archives, each containing both framework adapters.
- Made package installation/removal refresh desktop component caches while
  retaining user data and recommending IBus or Fcitx 5 as alternatives.
- Added source/data parity checks, frozen simplified/traditional candidate
  tests, native Linux corpus benchmarks, concurrent-engine stress tests, and
  a real-daemon framework matrix.
- Added clean-build release validation, exact packaged-dictionary integrity
  checks, and bounded-memory corpus runs for reproducible delivery artifacts.
- Hardened the shared adapter transport budget so valid bounded long-sentence
  queries are not mistaken for an unresponsive engine under load.

At the time of v0.1.0, the full release-gated desktop target was Ubuntu 26.04
x86_64 on GNOME Wayland. ARM64 had passed native build, core/regression,
artifact, package-installation, and installed-engine validation, but its
complete desktop matrix and manual GUI checks had not yet been completed for
that release. Current platform status is tracked in
[COMPATIBILITY.md](COMPATIBILITY.md).
