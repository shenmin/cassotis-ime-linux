# Quality And Consistency Validation

English | [简体中文](BENCHMARK.CN.md)

The release gate combines mechanical source/data parity, native unit and
integration tests, bounded transport/memory stress tests, frozen candidate
parity, and corpus-scale quality and latency benchmarks. No single metric is
presented as proof of equivalence.

## Shared Corpus Source

The corpus-scale Linux quality gate uses the same fixed long-sentence and
short-word benchmark cases documented by
[Cassotis IME for Windows](https://github.com/shenmin/cassotis-ime/blob/master/BENCHMARK.md).
Both benchmarks are derived from the developer's own novel,
[**Elegance in Timelessness**](https://www.qidian.com/book/1037259117/)
(Chinese title: **永恒的舞动**). Benchmark cases are kept separate from the
corresponding model-training data.

## Baseline

The current Linux engine is reviewed against:

- Cassotis IME v1.19.0 (`089f63859eb73ac3d7355d8c5623c3ab70287266`)
- Cassotis Lexicon v1.19.0 (`e66619094effccf5d4265ce4e716a50e9897d75c`)
- Simplified dictionary schema 24, SHA-256
  `e7f02bff9a334ff2289b7cdc0e32a2cc83abd5d2416d9ed4d5885e4c3cf9f77c`
- Traditional dictionary schema 24, SHA-256
  `d54dbe54f314e6da350e9d7a4bddb269c0b268cfcd56fb48c9025b22dcde86ae`
- Simplified/traditional base entries: 213,028 / 216,180
- Simplified/traditional completion competition rows: 42,453 / 42,448
- Simplified/traditional completion pair-audit rows: 4,379 / 4,379
- Simplified long-completion tables: 35,423 visible paths and 97,589 total
  text-recall rows
- Traditional long-completion tables: 32,481 visible paths and 92,457 total
  text-recall rows

`tools/parity/validate_source_parity.py` checks both reviewed revisions, a
manifest of the reviewed production engine, SQLite provider, pinyin parser,
fuzzy-pinyin and shuangpin sources on both platforms, all 42 generated model
units, expanded model evidence, and the frozen dictionary. It also binds the
Transformer and local-completion models, their runtime index and manifest,
the native inference bridge, the architecture-specific ONNX Runtime
libraries, and the required lexical, completion-competition, pair-audit, and
long-completion table populations. The manifest
pins the reviewed Delphi and FPC adaptations
independently; it does not pretend that platform-specific source files are
textually identical.
The small `tests/cases/candidate_quality.tsv` and
`tests/cases/candidate_quality_tc.tsv` sets then guard known simplified and
traditional candidate behavior through the actual SQLite provider.
The full quality gate also computes canonical failure signatures after
excluding host-dependent latency. The deterministic short-word track requires
an exact per-case signature. The v1.19 neural long-sentence track is guarded by
aggregate rank floors instead: repeated equivalent ONNX Runtime evaluations
can move a few samples across floating-point decision boundaries. Its failure
TSV remains a complete local diagnostic, but an unstable hash is not presented
as a reproducibility guarantee.

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
  --baseline tests/baselines/quality-v1.19.0-linux-x86_64.txt
```

The long-sentence accuracy pass uses deterministic work limits and accepts a
completed Transformer decision without a wall-clock cutoff. A separate
production-mode pass measures latency with the deployed 30 ms neural-result
acceptance budget. Both passes use the same model and bounded search; this
separation prevents transient host load from changing the frozen accuracy
result while retaining realistic production latency behavior.

The runner reports Top1/Top2/Top5/Top9 counts, mean/P50/P95/maximum query
latency, and Linux process RSS/high-water marks. Memory events contain only
the track and case identifier. It writes every non-Top1 result to
`long-failures.tsv` or `short-failures.tsv`; those files are local diagnostics,
not ignored failures, and are not included in binary release assets.

## Frozen v1.19.0 Port Results

The v1.19.0 validation reuses the same separately supplied frozen corpus files
as v1.18.0. They are not redistributed by this repository and remain bound by
size and SHA-256:

| Input | Cases | Bytes | SHA-256 |
| --- | ---: | ---: | --- |
| Long sentence | 16,300 | 2,673,936 | `3f50a9323ad798e691f86ea70c6dffa13b4a9f55b624fc3499a138258190ff0f` |
| Short word with frozen context | 65,000 | 9,200,779 | `cd02fc1a24e89a106c200f4864d5ad2c11afd4c8d784059a4b6e9a10c51fbab8` |

Ubuntu 26.04.1 x86_64 and Ubuntu 26.04.1 aarch64 produced the following native
results with the reviewed v1.19.0 engine, schema-24 dictionary, conditional
Transformer, learned gate/fusion parameters, and completion index v2. As in
the previous gate, accuracy is deterministic and latency uses the deployed
30 ms neural-result budget:

| Architecture | Track | Top1 | Top2 | Top5 | Top9 | Mean | P50 | P95 | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | Long sentence | 10,941/16,300 | 12,260/16,300 | 12,260 | 12,260 | 183.438 ms | 175 ms | 364 ms | 1,023 ms |
| x86_64 | Short word, context off | 60,346/65,000 | 63,163/65,000 | 64,498 | 64,619 | 9.248 ms | 7 ms | 24 ms | 89 ms |
| x86_64 | Short word, context on | 61,827/65,000 | 63,517/65,000 | 64,540 | 64,619 | 10.365 ms | 8 ms | 26 ms | 81 ms |
| aarch64 | Long sentence | 10,916/16,300 | 12,252/16,300 | 12,252 | 12,252 | 103.540 ms | 89 ms | 219 ms | 664 ms |
| aarch64 | Short word, context off | 60,346/65,000 | 63,163/65,000 | 64,498 | 64,619 | 5.933 ms | 5 ms | 14 ms | 47 ms |
| aarch64 | Short word, context on | 61,827/65,000 | 63,517/65,000 | 64,540 | 64,619 | 6.592 ms | 5 ms | 16 ms | 47 ms |

The published Windows v1.19.0 reference is 10,917 Top1 and 12,248 Top2. Linux
x86_64 is 24/12 cases higher and aarch64 is one case lower/four cases higher.
Both architectures therefore satisfy the Windows aggregate quality target.
Their small per-case difference remains an ONNX Runtime and floating-point
decision boundary, not an architecture-specific ranking policy. The
65,000-case short-word counts and exact failure signature are identical on
Windows, x86_64, and aarch64.

Relative to the frozen Linux v1.18.0 results, v1.19.0 gains 254 Top1 and 156
Top2 long-sentence cases on x86_64, and 212 Top1 and 145 Top2 cases on
aarch64. Peak RSS/high-water marks were 850,120 KiB and 869,564 KiB
respectively, both below the 960 MiB release ceiling. Both clean native builds
passed all 132 FPCUnit tests. Host-specific latency must not be interpreted as
a direct implementation-speed comparison between different machines.

The complete one-key-completion measurement uses the same omitted-four-
syllable protocol as Windows and includes both static and neural completion:

```bash
./build/bin/cassotis-completion-benchmark \
  /path/to/dict_sc.db /path/to/long_sentence_16300.tsv 16300 40 500
```

The fourth argument applies the same 40 ms local-result acceptance limit as the
production host and the Windows benchmark; the fifth prints progress every 500
cases. The runner performs the same post-sample, read-only oracle pass as the
Windows benchmark so its cache-warming order is comparable without changing
the timed production result.

| Architecture | Local completion hit | Prompt coverage | Total keys saved | P95 |
| --- | ---: | ---: | ---: | ---: |
| x86_64 | 194/16,300 (1.19%) | 3,719/16,300 (22.82%) | 556 | 140 ms |
| aarch64 | 191/16,300 (1.17%) | 3,726/16,300 (22.86%) | 548 | 95 ms |

The Windows v1.19.0 publication records 202 hits, 3,834 prompts, 571 saved
keys, and 38.452 ms P95 under the same 40 ms protocol. Linux produces the same
deterministic completion decision signature when wall-clock cutoffs are
disabled, while its production track accepts fewer background results because
inference crosses the 40 ms boundary more often. The gate therefore preserves
the production timeout and records the measured difference instead of raising
the timeout to manufacture equal counts.

This full production-mode track is intentionally governed by quality and
latency ranges rather than an exact completion signature. Host scheduling can
change whether a background result crosses the 40 ms boundary and can then
change the cache state seen by a later case. The separate 500-case deterministic
`cassotis-neural-engine-smoke` disables both neural wall-clock cutoffs, isolates
the neural fallback lifecycle, and requires the same exact
`DCB3F73CD5277B97` signature on x86_64 and aarch64.

## Frozen v1.18.0 Port Results

The complete release run uses separately supplied frozen corpus files. The
source novel text is not part of the software distribution, so these files are
not redistributed by this repository. The release record binds the inputs by
size and SHA-256, so a result cannot silently be reused with another case set:

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
19,472.237 microseconds mean and 129,987 microseconds maximum IPC key latency
on x86_64, with 8 KiB post-warmup RSS growth. On aarch64 it measured 11,604.921
microseconds mean and 41,059 microseconds maximum, with zero post-warmup RSS
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
latency and peak memory, an exact short-word failure signature, the exact
deterministic 500-case neural-completion signature, aggregate neural
long-sentence rank floors, and bounded full-corpus completion quality and
latency. Updating a baseline requires a new frozen corpus, reviewed engine
baseline, or documented runtime change; a regression must not be hidden by
lowering the thresholds.

## Interpretation

The benchmark measures synchronous engine query time, not key delivery,
candidate-window painting, desktop compositor latency, or network inference.
It intentionally uses no persistent user dictionary. Real user learning can
improve personal rankings and is validated separately by service and adapter
tests.
