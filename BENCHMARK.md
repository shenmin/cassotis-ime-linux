# Quality And Consistency Validation

English | [简体中文](BENCHMARK.CN.md)

The release gate combines mechanical source/data parity, native unit and
integration tests, bounded transport/memory stress tests, frozen candidate
parity, and corpus-scale quality and latency benchmarks. No single metric is
presented as proof of equivalence.

## Baseline

The current Linux engine is reviewed against:

- Cassotis IME v1.18.0 (`48b8bc21bc408faa32a756764b39cf109e4be0fc`)
- Cassotis Lexicon v1.18.0 (`51f41d211aa062cf70e96a017ee6e5b9d79474a7`)
- Simplified dictionary schema 24, SHA-256
  `db8a59c61fe8d306b33dd08a8932a17007fdab8ac0480f49389cc9430493cc07`
- Traditional dictionary schema 24, SHA-256
  `06b2cba302e61bd016e4a7f8e47ba2c317d18cdda32457ac8ad232585ce4c829`

`tools/parity/validate_source_parity.py` checks both reviewed revisions, a
manifest of the reviewed production engine, SQLite provider, pinyin parser,
fuzzy-pinyin and shuangpin sources on both platforms, all 42 generated model
units, expanded model evidence, and the frozen dictionary. It also binds the
Transformer and local-completion models, their runtime index and manifest,
the native inference bridge, and the architecture-specific ONNX Runtime
libraries. The manifest pins the reviewed Delphi and FPC adaptations
independently; it does not pretend that platform-specific source files are
textually identical.
The small `tests/cases/candidate_quality.tsv` and
`tests/cases/candidate_quality_tc.tsv` sets then guard known simplified and
traditional candidate behavior through the actual SQLite provider.
The full quality gate also hashes every non-Top1 case after excluding only the
host-dependent latency column. This freezes the exact per-case ranks and Top1
results without publishing the private benchmark corpus.

## Full Linux Benchmark

`cassotis-quality-benchmark` runs natively on Linux against the same final
dictionary and frozen case sets used by the Windows project:

- 16,300 long-sentence cases
- 65,000 short-word cases without context
- The same 65,000 short-word cases with their frozen left context

Build and run it directly:

```bash
./scripts/build.sh
./build/bin/cassotis-quality-benchmark \
  --dictionary /path/to/dict_sc.db \
  --long-cases /path/to/long_sentence_16300.tsv \
  --short-cases /path/to/word_input_yhwd_context.tsv \
  --neural-runtime ./build/bin \
  --report-dir ./quality-report

python3 tools/parity/validate_quality_report.py \
  --summary ./quality-report/quality-summary.txt \
  --dictionary /path/to/dict_sc.db \
  --long-cases /path/to/long_sentence_16300.tsv \
  --short-cases /path/to/word_input_yhwd_context.tsv \
  --baseline tests/baselines/quality-v1.18.0-linux-x86_64.txt
```

The long-sentence accuracy pass uses deterministic work limits and accepts a
completed Transformer decision without a wall-clock cutoff. A separate
production-mode pass measures latency with the deployed 30 ms neural-result
acceptance budget. Both passes use the same model and bounded search; this
separation prevents transient host load from changing the frozen accuracy
result while retaining realistic production latency behavior.

The runner reports Top1/Top2/Top5/Top9 counts, mean/P50/P95/maximum query
latency, and Linux process RSS/high-water marks. Memory events contain only
the track and case identifier, never the private query text. It writes every
non-Top1 result to `long-failures.tsv` or `short-failures.tsv`; those files are
diagnostics, not ignored failures and are not public release artifacts.

## Frozen v1.18.0 Port Results

The complete release run uses externally supplied frozen case files. They are
not redistributed by this repository because the source sentences are not
part of the public program distribution. The release record binds the inputs
by size and SHA-256, so a result cannot silently be reused with another case
set:

| Input | Cases | Bytes | SHA-256 |
| --- | ---: | ---: | --- |
| Long sentence | 16,300 | 2,673,936 | `3f50a9323ad798e691f86ea70c6dffa13b4a9f55b624fc3499a138258190ff0f` |
| Short word with frozen context | 65,000 | 9,200,779 | `cd02fc1a24e89a106c200f4864d5ad2c11afd4c8d784059a4b6e9a10c51fbab8` |

The Ubuntu 26.04 x86_64 and Ubuntu 26.04.1 aarch64 release hosts produced the
following native-engine results against the reviewed schema-24 simplified
dictionary. Candidate ranks come from the deterministic accuracy pass without
a neural wall-clock cutoff; latency columns come from the separate production
pass with the deployed 30 ms neural-result budget:

| Architecture | Track | Top1 | Top2 | Top5 | Top9 | Mean | P50 | P95 | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | Long sentence | 10,687/16,300 | 12,104/16,300 | 12,104 | 12,104 | 149.270 ms | 134 ms | 305 ms | 1,024 ms |
| x86_64 | Short word, context off | 60,346/65,000 | 63,163/65,000 | 64,498 | 64,619 | 9.038 ms | 7 ms | 23 ms | 67 ms |
| x86_64 | Short word, context on | 61,827/65,000 | 63,517/65,000 | 64,540 | 64,619 | 10.120 ms | 8 ms | 25 ms | 87 ms |
| aarch64 | Long sentence | 10,704/16,300 | 12,107/16,300 | 12,107 | 12,107 | 86.083 ms | 72 ms | 188 ms | 566 ms |
| aarch64 | Short word, context off | 60,346/65,000 | 63,163/65,000 | 64,498 | 64,619 | 5.394 ms | 4 ms | 13 ms | 42 ms |
| aarch64 | Short word, context on | 61,827/65,000 | 63,517/65,000 | 64,540 | 64,619 | 5.986 ms | 5 ms | 14 ms | 41 ms |

The 11,728 short-word rows marked as genuine competing-candidate cases score
8,737/10,528 Top1/Top2 without context and 9,596/10,775 with context on both
architectures. All short-word aggregate counts and per-case failure signatures
are identical across x86_64 and aarch64. The Windows v1.18.0 long-sentence
reference is 10,731 Top1 and 12,128 Top2. The reviewed Linux long-sentence
results are close but not byte-for-byte identical because ONNX Runtime and
floating-point evaluation can cross a small number of model decision
boundaries. The release therefore freezes a separate exact per-case signature
for each architecture; there is no architecture-specific ranking branch.
Latency is host-specific and must not be compared across different hardware as
an implementation-speed ratio.

The v0.2.0 release makes character-LM span scoring independent of n-grams
cached by earlier, unrelated queries. This reviewed runtime change required a
new long-sentence signature. Against the provisional signatures, the x86_64
transition corrected 23 Top1 cases and regressed 21, for a net gain of two;
the aarch64 transition corrected three and regressed two, for a net gain of
one. Aggregate quality floors were not lowered, and the short-word signatures
did not change.

The x86_64 and aarch64 benchmark processes reached 763,640 KiB and 866,268 KiB
maximum RSS/high-water mark respectively, below the 960 MiB release ceiling.
Each clean-build gate also passed all 129 FPCUnit tests, 22/22 simplified and
9/9 traditional frozen candidates, and the deterministic 500-case neural
completion exercise. The eight-context, 8,300-key transport run measured
21,274.350 microseconds mean and 101,198 microseconds maximum IPC key latency
on x86_64, with 8 KiB post-warmup RSS growth. On aarch64 it measured 12,847.534
microseconds mean and 50,152 microseconds maximum, with zero post-warmup RSS
growth. Both runs passed engine-restart recovery.

## Complete Release Gate

First create a source-parity report on a machine with the Windows and lexicon
checkouts:

```bash
python3 tools/parity/validate_source_parity.py \
  --windows-root /path/to/cassotis-ime \
  --lexicon-root /path/to/cassotis-lexicon \
  --dictionary /path/to/dict_sc.db \
  --dictionary-traditional /path/to/dict_tc.db \
  --report source-parity.json
```

Then run the Linux release gate inside the target desktop session:

```bash
./scripts/validate_release.sh \
  --dictionary /path/to/dict_sc.db \
  --dictionary-traditional /path/to/dict_tc.db \
  --long-cases /path/to/long_sentence_16300.tsv \
  --short-cases /path/to/word_input_yhwd_context.tsv \
  --source-parity-report /path/to/source-parity.json \
  --report-dir ./release-validation
```

The resulting `release-validation.json`, platform matrix, logs, benchmark
files, package checksums, and packages form one auditable release record.

The checked-in x86_64 and aarch64 baselines are release floors, not targets to
train against. They require complete case counts, bounded mean/P95/maximum
latency and peak memory, exact per-case failure signatures, and the reviewed
v1.18.0 neural-completion signature. Updating either file requires a new
frozen corpus, reviewed engine baseline, or documented runtime change; a
regression must not be hidden by lowering the thresholds.

## Interpretation

The benchmark measures synchronous engine query time, not key delivery,
candidate-window painting, desktop compositor latency, or network inference.
It intentionally uses no persistent user dictionary. Real user learning can
improve personal rankings and is validated separately by service and adapter
tests.
