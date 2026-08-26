# Quality And Consistency Validation

English | [简体中文](BENCHMARK.CN.md)

The release gate combines mechanical source/data parity, native unit and
integration tests, bounded transport/memory stress tests, frozen candidate
parity, and corpus-scale quality and latency benchmarks. No single metric is
presented as proof of equivalence.

## Baseline

The Linux v0.1.0 engine is reviewed against:

- Cassotis IME v1.17.0 (`e9056cefb479c2df778664ec49e6da2056c59525`)
- Cassotis Lexicon v1.17.0 (`a9a29c4a5d4679a65b34e9556decc31925a0857a`)
- Simplified dictionary schema 22, SHA-256
  `a07942f79fe607bdb7dad14e0b0e82b87fef47473380cf98eda415afc6a9c354`
- Traditional dictionary schema 22, SHA-256
  `3cb9de47d9ff3dbc9a517d53a64ac0a547ecd4c72b1767e26c13152a8963c17e`

`tools/parity/validate_source_parity.py` checks both reviewed revisions, a
manifest of the reviewed production engine, SQLite provider, pinyin parser,
fuzzy-pinyin and shuangpin sources on both platforms, all 40 generated model
units, expanded model evidence, and the frozen dictionary. The manifest pins
the reviewed Delphi and FPC adaptations independently; it does not pretend
that platform-specific source files are textually identical.
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
  --report-dir ./quality-report

python3 tools/parity/validate_quality_report.py \
  --summary ./quality-report/quality-summary.txt \
  --dictionary /path/to/dict_sc.db \
  --long-cases /path/to/long_sentence_16300.tsv \
  --short-cases /path/to/word_input_yhwd_context.tsv \
  --baseline tests/baselines/quality-v1.17.0-linux-x86_64.txt
```

The runner reports Top1/Top2/Top5/Top9 counts, mean/P50/P95/maximum query
latency, and Linux process RSS/high-water marks. Memory events contain only
the track and case identifier, never the private query text. It writes every
non-Top1 result to `long-failures.tsv` or `short-failures.tsv`; those files are
diagnostics, not ignored failures and are not public release artifacts.

## Frozen v0.1.0 Results

The complete release run uses externally supplied frozen case files. They are
not redistributed by this repository because the source sentences are not
part of the public program distribution. The release record binds the inputs
by size and SHA-256, so a result cannot silently be reused with another case
set:

| Input | Cases | Bytes | SHA-256 |
| --- | ---: | ---: | --- |
| Long sentence | 16,300 | 2,673,936 | `3f50a9323ad798e691f86ea70c6dffa13b4a9f55b624fc3499a138258190ff0f` |
| Short word with frozen context | 65,000 | 9,200,779 | `cd02fc1a24e89a106c200f4864d5ad2c11afd4c8d784059a4b6e9a10c51fbab8` |

The Ubuntu 26.04 x86_64 release host produced the following native-engine
results against the reviewed schema-22 simplified dictionary:

| Track | Top1 | Top2 | Top5 | Top9 | Mean | P50 | P95 | Max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Long sentence | 10,553/16,300 (64.74%) | 12,008/16,300 (73.67%) | 12,008 | 12,008 | 111.051 ms | 92 ms | 246 ms | 868 ms |
| Short word, context off | 60,346/65,000 (92.84%) | 63,163/65,000 (97.17%) | 64,498 | 64,619 | 7.602 ms | 6 ms | 19 ms | 169 ms |
| Short word, context on | 61,827/65,000 (95.12%) | 63,516/65,000 (97.72%) | 64,540 | 64,619 | 8.485 ms | 7 ms | 20 ms | 160 ms |

The 11,728 short-word rows marked as genuine competing-candidate cases score
8,737/10,528 Top1/Top2 without context and 9,596/10,775 with context. The
context-enabled short-word quality counts are identical to the Windows
v1.17.0 reference. The Windows long-sentence reference is 10,595 Top1 and
12,023 Top2. The Linux baseline retains the small reviewed compiler/runtime
difference but now permits no further regression in any recorded quality
count or substitution of different passing/failing cases. Latency is
host-specific and must not be compared across Windows and Linux hardware as an
implementation-speed ratio.

The single benchmark process reached 557,252 KiB maximum RSS/high-water mark,
below the 768 MiB release ceiling. The same clean-build gate also passed all
123 FPCUnit tests, 22/22 simplified and 9/9 traditional frozen candidates, and
an 8,300-key eight-context transport run. That transport run measured
19,855.531 microseconds mean and 152,703 microseconds maximum IPC key latency,
with 12 KiB post-warmup RSS growth and successful engine-restart recovery.

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

The checked-in x86_64 baseline is a release floor, not a target to train
against. It requires complete case counts, bounded mean/P95/maximum latency
and peak memory, and Top1/Top2 results close to the reviewed Windows v1.17.0
reference. Updating it requires a new frozen corpus or reviewed engine
baseline; a regression must not be hidden by lowering the thresholds.

## Interpretation

The benchmark measures synchronous engine query time, not key delivery,
candidate-window painting, desktop compositor latency, or network inference.
It intentionally uses no persistent user dictionary. Real user learning can
improve personal rankings and is validated separately by service and adapter
tests.
