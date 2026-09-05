# Release Guide

This guide produces the supported Debian and portable artifacts and one
machine-readable validation record. Run it as the graphical desktop user on
the Ubuntu release machine; use `sudo` only when manually installing a final
package.

The full automated release-gated targets are Ubuntu 26.04.1 x86_64 and Ubuntu
26.04.1 aarch64 on GNOME Wayland. Do not publish a binary for another
architecture/session merely because it compiles. The complete release process
must include the native test suite, simplified/traditional regressions,
quality and memory gates, artifact validation, final-package installation,
installed-engine self-test, and the complete desktop matrix. The automated
gate validates the staged Debian payload; installing its final package is part
of the subsequent manual host check. State any missing manual-GUI coverage
explicitly; manual application checks remain required for both current
architectures.

## 1. Freeze Inputs

Update `VERSION`, `src/common/nc_version.pas`,
`porting/windows-baseline.txt`, and `porting/windows-map.yml` together. Build
the final simplified and traditional databases from the tagged Cassotis
Lexicon release into empty target files with the current importer. Do not
enrich or reuse a database created by an older importer: source parity checks
the base, completion-competition, pair-audit, and long-completion row counts
in addition to the complete file hashes. The v1.21 gate also freezes the
conditional Transformer model, constrained candidate generator, generated
invocation/fusion gates, local-completion models/index/manifest, all three
reviewed native recall-selector source units, architecture-specific ONNX
Runtime libraries, and the native runtime bridge. Do not substitute any
database, model, or runtime artifact after validation.

## 2. Source And Dictionary Parity

```bash
python3 tools/parity/validate_source_parity.py \
  --windows-root /path/to/cassotis-ime \
  --lexicon-root /path/to/cassotis-lexicon \
  --dictionary /path/to/dict_sc.db \
  --dictionary-traditional /path/to/dict_tc.db \
  --report source-parity.json
```

Both referenced repositories must be at the recorded revisions with clean
worktrees, and the command must report `"ok": true`. The official release
package must use the matching simplified and traditional databases from the
same lexicon release; the full gate rejects a missing traditional database.
The full gate also rechecks the report's Windows and lexicon revisions and
both database hashes against `porting/windows-baseline.txt`, so a successful
report from an older baseline cannot be reused.

Keep the resulting report with the release. The full gate binds its dictionary
hash to this report, so a report from another database cannot be reused.

## 3. Full Validation

```bash
./scripts/validate_release.sh \
  --dictionary /path/to/dict_sc.db \
  --dictionary-traditional /path/to/dict_tc.db \
  --long-cases /path/to/long_sentence_16300.tsv \
  --short-cases /path/to/word_input_yhwd_context.tsv \
  --source-parity-report ./source-parity.json \
  --report-dir ./release-validation
```

The command first removes the complete `build/` tree and rebuilds every
Pascal unit and native adapter. This is intentional: a release must never
reuse an older PPU whose timestamp happens to look newer than synchronized
source. The command is successful only after all of these pass:

1. Native build with fatal C/C++ warnings and SHA-256 validation of every
   bundled model and architecture-specific runtime artifact.
2. FPCUnit, native geometry/shortcut and exact quantized-integer arithmetic
   tests, engine/socket tests, direct ONNX
   runtime smoke, and a real-engine asynchronous completion smoke. The 500-case
   deterministic smoke is also repeated in three fresh processes with different
   argument/environment layouts against the same read-only dictionary. The
   recorded candidate paths and completion decisions must agree, not only totals.
3. Frozen simplified and traditional candidate parity.
4. Multi-client IBus transport, malformed-frame, restart, latency, and
   bounded-memory stress tests against an isolated socket and user database.
5. Complete 16,300 + 65,000 x 2 quality, latency, and peak-memory benchmark;
   the deterministic long-sentence accuracy pass must use one ONNX inference
   thread, while the latency pass retains deployed concurrency.
6. Complete 12,831-opportunity short-word one-key-completion benchmark with
   exact visible-result signature and architecture-specific latency bounds.
7. Complete 16,300-case static-plus-neural one-key-completion benchmark with
   the deployed 40 ms result budget and architecture-specific quality/latency
   floors.
8. Portable and Debian payload extraction, exact simplified/traditional
   dictionary hashes, checksums, dependencies, desktop-entry metadata,
   install/uninstall round-trip, and isolated adapter execution.
9. IBus and Fcitx 5 desktop platform matrix with state restoration.

`release-validation/STATUS` must contain `passed` and
`release-validation.json` must contain `"ok": true`.

Release-artifact extraction uses the disk-backed
`build/release-validation-tmp/` directory by default rather than the system
`/tmp`, which may be a small tmpfs. Set `CASSOTIS_RELEASE_TMPDIR` to another
disk-backed directory when needed. The validator creates one unique child
directory there and removes only that child when it exits.

If a long benchmark must be resumed, `--skip-benchmark` is accepted only when
all three saved benchmark reports exist and the saved benchmark manifest
exactly matches the current quality, long-completion, and short-completion
benchmark binaries, dictionary, long cases, short cases, native bridge, ONNX
Runtime libraries, Transformer model, and Transformer vocabulary by SHA-256.

## 4. Manual Desktop Check

Perform the short checklist in [COMPATIBILITY.md](COMPATIBILITY.md). Record the
desktop, session type, architecture, and result in the release notes.

## 5. Publish

Before tagging, confirm the worktree contains the intended executable bits for
all `.sh` entry points, the values in `VERSION` and
`src/common/nc_version.pas` match, and the committed tree is the tree that
produced the validation record.

Upload only these files from `release-validation/artifacts/`:

- `cassotis-ime_<version>_<arch>.deb`
- `cassotis-ime-linux-<version>-<arch>.tar.gz`

GitHub records a SHA-256 digest for every uploaded release asset. Keep the
generated `SHA256SUMS` with the validation record. If one checksum file is
also published for a multi-architecture release, merge the per-architecture
manifests first so the uploaded file covers every binary asset.

Also archive the validation JSON, benchmark summary, and platform matrix with
the release record. RPM and Arch packages must be built natively from source;
do not rename or repackage the Debian binaries for those distributions.

The release notes should link [CHANGELOG.md](CHANGELOG.md), identify the
validated Ubuntu/GNOME/Wayland targets, and state that candidate appearance is
provided by the active framework. Do not claim KDE or X11 desktop validation,
or RPM or Arch binary validation, until the corresponding matrix has passed.
For each architecture, distinguish the complete automated framework matrix
from the manual application-focus, rendering, and appearance checks. ARM64 has
passed the same five-stage automated IBus/Fcitx matrix as x86_64; manual GUI
checks remain release checklist items on both architectures.
