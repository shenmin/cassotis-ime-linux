# Release Guide

This guide produces the supported Debian and portable artifacts and one
machine-readable validation record. Run it as the graphical desktop user on
the Ubuntu release machine; use `sudo` only when manually installing a final
package.

The full release-gated target is Ubuntu 26.04 x86_64 on GNOME Wayland. Do not
publish a binary for another architecture/session merely because it compiles.
At minimum, run the native test suite, simplified/traditional regressions,
artifact validation, package installation, and installed-engine self-test,
then state any missing desktop-matrix or manual-GUI coverage explicitly. Do
not describe another target as fully release-gated until it passes the same
desktop matrix and manual checks.

## 1. Freeze Inputs

Update `VERSION`, `src/common/nc_version.pas`,
`porting/windows-baseline.txt`, and `porting/windows-map.yml` together. Build
the final simplified and traditional databases from the tagged Cassotis
Lexicon release. Do not substitute a database after validation.

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

1. Native build with fatal C/C++ warnings.
2. FPCUnit, native geometry/shortcut tests, and engine/socket tests.
3. Frozen simplified and traditional candidate parity.
4. Multi-client IBus transport, malformed-frame, restart, latency, and
   bounded-memory stress tests against an isolated socket and user database.
5. Complete 16,300 + 65,000 x 2 quality, latency, and peak-memory benchmark.
6. Portable and Debian payload extraction, exact simplified/traditional
   dictionary hashes, checksums, dependencies, desktop-entry metadata,
   install/uninstall round-trip, and isolated adapter execution.
7. IBus and Fcitx 5 desktop platform matrix with state restoration.

`release-validation/STATUS` must contain `passed` and
`release-validation.json` must contain `"ok": true`.

If a long benchmark must be resumed, `--skip-benchmark` is accepted only when
the saved benchmark manifest exactly matches the current benchmark binary,
dictionary, long cases, and short cases by SHA-256.

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
validated Ubuntu/GNOME/Wayland target, and state that candidate appearance is
provided by the active framework. Do not claim KDE or X11 desktop validation,
or RPM or Arch binary validation, until the corresponding matrix has passed.
Describe ARM64 as natively package-validated, not fully desktop-release-gated,
until its complete framework matrix and manual GUI checks pass.
