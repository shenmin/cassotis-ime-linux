# Changelog

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

The full release-gated desktop target is Ubuntu 26.04 x86_64 on GNOME Wayland.
ARM64 has passed native build, core/regression, artifact, package-installation,
and installed-engine validation; its complete desktop matrix and manual GUI
checks remain pending. Other Linux environments may build from source; their
status is tracked in [COMPATIBILITY.md](COMPATIBILITY.md).
