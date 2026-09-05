# Changelog

## Unreleased

## 0.5.0 - 2026-09-05

- Advanced the reviewed engine and dictionary baseline to Cassotis IME and
  Cassotis Lexicon v1.21.0 with matching schema-24 dictionaries.
- Added bounded exact-text prefix resolution and retained complete exact
  lexicon paths while the next syllable is still partial.
- Expanded one-key completion recall with lexical and phonetic-repair
  selectors, then applied the same deterministic full-query work budget and
  final arbitration used by the Windows baseline.
- Added document-local continuation and copy completion with scoped positive
  and negative feedback. Evidence is derived only from text already exposed
  by the active framework, stays in memory, and is never persisted.
- Preserved document evidence across ordinary composition resets while
  clearing it on context teardown, and resolved copied completion anchors to
  their complete dictionary Pinyin before learning subsequent feedback.
- Made completed local model inference remain eligible after a diagnostic wait
  expires; unavailable, stale, or still-running work continues to fail closed.
- Added exact short-word completion result signatures to the native release
  gate alongside the existing long/short quality and production completion
  benchmarks.
- Made the long-sentence accuracy track use deterministic work limits and one
  ONNX inference thread to reduce concurrency-related variation; the separate
  latency track continues to exercise deployed inference concurrency.
- Initialized shared long-search cache and expansion state before fast paths,
  fixing candidate changes caused by undefined local values. Release validation
  now compares recorded 500-case candidate/completion traces across fresh
  process layouts.
- Prevented saturating quantized inference on x86 CPUs without VNNI using the
  runtime's precision mode, with an exact integer-arithmetic regression test.
  Deployed models, dictionary weights, and candidate ranking policy are unchanged.
- Hardened release validation so source-parity reports must match the current
  reviewed revisions and dictionary hashes, and artifact extraction uses a
  disk-backed, uniquely scoped temporary directory.

## 0.4.0 - 2026-08-31

- Advanced the reviewed engine and dictionary baseline to Cassotis IME and
  Cassotis Lexicon v1.20.0 with matching schema-24 dictionaries.
- Added bounded document-local term and transition adaptation from framework
  surrounding-text snapshots without persisting document contents.
- Added the constrained Pinyin-aligned long-candidate generator and its
  learned invocation/fusion gates to the existing final ranking pipeline.
- Added the constrained local-completion fallback generator while preserving
  the existing asynchronous, generation-safe timeout and abstention behavior.
- Extended source, model, staged-payload, and runtime smoke validation to bind
  and execute every newly deployed v1.20 asset on x86_64 and aarch64.
- Bounded generator-session memory on glibc hosts by avoiding retained
  peak-shape ONNX arenas and returning freed session pages at runtime lifecycle
  boundaries, without adding work to the key-processing path.

## 0.3.0 - 2026-08-30

- Advanced the development baseline to Cassotis IME and Cassotis Lexicon
  v1.19.0 with the matching schema-24 dictionaries.
- Ported the Pinyin-conditioned 16-candidate Transformer scorer and its learned
  runtime gate and fusion decision to the Linux host on x86_64 and aarch64.
- Expanded constrained one-key completion with the v2 multi-level suffix index
  and native recall selector.
- Preserved strong four-syllable compound prefixes under controlled suffixes
  and rejected divergent completion prefixes that only share a trailing
  anchor.
- Bound cleanly rebuilt schema-24 dictionaries by hash and by lexical,
  completion-competition, pair-audit, and long-completion row counts so stale
  importer output cannot pass the release gate.
- Added a full 16,300-case static-plus-neural completion benchmark and
  architecture-specific quality/latency gates alongside the deterministic
  neural lifecycle smoke test.
- Made deterministic completion validation disable both neural wall-clock
  cutoffs and run both ONNX paths single-threaded, while retaining deployed
  concurrency and aggregate gates for neural long-sentence decisions whose
  exact boundary cases can vary across equivalent ONNX evaluations.

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
- Made character-LM span scoring independent of unrelated query-cache history
  and re-froze the audited per-architecture long-sentence signatures without
  lowering aggregate quality floors.
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
