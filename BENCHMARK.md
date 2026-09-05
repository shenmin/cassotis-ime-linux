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

- Cassotis IME v1.21.0 (`a06df4c9150ac4fcd140b8709c53c5b7bf7e1be4`)
- Cassotis Lexicon v1.21.0 (`63f4df366f3b62d4ebad2e3192811d5d1e4e3f2b`)
- Simplified dictionary schema 24, SHA-256
  `fc6800d88d67d3b68b6ccb1b9f1832cd5f5a17598c5b28a9109f9da12985ee37`
- Traditional dictionary schema 24, SHA-256
  `845d7c63de2d03ba6bacac66c699b99c5256afe58332eacb2326ca42a9682681`
- Simplified/traditional base entries: 213,233 / 216,385
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
Transformer scorer, constrained Pinyin and completion generators, their
runtime allow-list, index and manifest, the native inference bridge, three
reviewed native completion-selector source units, the
architecture-specific ONNX Runtime
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
an exact per-case signature. The v1.21 neural long-sentence track is guarded by
aggregate rank floors instead: repeated runs have shown a small number of
candidate differences. Floating-point and runtime behavior can contribute,
but the precise cause of each differing case has not been established. Its
failure TSV remains a complete local diagnostic; an unstable hash is not
presented as a reproducibility guarantee.

The published corpus comparison disables persisted user learning and external
document context, matching the Windows benchmark protocol. Document-local
adaptation is validated separately by model and service tests so text from one
application context cannot silently influence the frozen aggregate result.

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
  --baseline tests/baselines/quality-v1.21.0-linux-x86_64.txt
```

The long-sentence accuracy pass uses deterministic work limits, single-threaded
ONNX inference, and accepts a completed Transformer decision without a
wall-clock cutoff. A separate production-mode pass measures latency with the
deployed model concurrency and 30 ms diagnostic threshold. In v1.21, a
completed synchronous inference remains eligible even after that threshold;
it is not a cancellation deadline. Both passes use the same model and bounded
search. The separation reduces concurrency-related accuracy variation while
retaining realistic production latency, but does not guarantee bitwise-identical
neural decisions across runs or platforms. The separate asynchronous completion
benchmark still uses its deployed 40 ms result-acceptance deadline.

The runner reports Top1/Top2/Top5/Top9 counts, mean/P50/P95/maximum query
latency, and Linux process RSS/high-water marks. Memory events contain only
the track and case identifier. It writes every non-Top1 result to
`long-failures.tsv` or `short-failures.tsv`; those files are local diagnostics,
not ignored failures, and are not included in binary release assets.

## Frozen v1.21.0 Port Results

The v1.21.0 port uses the same separately supplied 16,300 long-sentence and
65,000 short-word cases as v1.20.0, with the input sizes and SHA-256 hashes
listed in the next section. The following qualification measurements were
made on Ubuntu 26.04.1 GNOME Wayland hosts on 2026-09-05. Release packages
must pass the complete gate again from their exact source revision; these
measurements do not replace the per-release validation records.

| Architecture | Long Top1 | Long Top2 / Top5 / Top9 | Mean | P50 | P95 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 11,094/16,300 | 12,403/16,300 | 187.938 ms | 181 ms | 371 ms | 1,001 ms |
| aarch64 | 11,090/16,300 | 12,412/16,300 | 76.876 ms | 72 ms | 142 ms | 622 ms |

Windows v1.21.0 publishes Top1 11,080 and Top2 12,395. The Linux counts are
higher by 14/8 cases on x86_64 and 10/17 on aarch64. The release floors require
at least the published Windows counts on each architecture, not reduced
platform-specific accuracy targets. This is aggregate parity, not per-case
identity: compared with a rerun of the exact Windows tag, aarch64 gained 69
Top1 cases and lost 59, with 170 differing target ranks overall. The cause
of every neural difference has not been established. Timing is host-dependent
and must not be interpreted as a cross-platform implementation speed ratio.

The complete short-word tracks have the same counts on both Linux
architectures and Windows:

| Track | Top1 / 65,000 | Top2 / 65,000 | Top5 | Top9 | Contested Top1 / 11,728 | Contested Top2 / 11,728 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Context disabled | 60,346 | 63,163 | 64,499 | 64,620 | 8,737 | 10,528 |
| Context enabled | 61,827 | 63,517 | 64,541 | 64,620 | 9,596 | 10,775 |

The exact short-word failure signature is 7,827 rows with SHA-256
`18cad226349cbfd1451c35c25f9572b3e004f121c79c5c22658fe47b970b207b`.
The long-sentence process reached RSS/high-water marks of 1,005,416 KiB on
x86_64 and 792,300 KiB on aarch64, both below the existing 1,048,576 KiB gate.
Both architectures passed 146 FPCUnit tests, 22 simplified and 9 traditional
candidate regressions, and the five-stage automated IBus/Fcitx matrix.

Short-word one-key completion now has a native benchmark using the same
12,831 incremental-prefix opportunities and frozen left context as Windows:

| Architecture | Completion Hit | Avg Keys Saved | Stability | P95 |
| --- | ---: | ---: | ---: | ---: |
| x86_64 | 9,420/12,831 | 2.548 | 1,691/1,749 | 3 ms |
| aarch64 | 9,420/12,831 | 2.548 | 1,691/1,749 | 2 ms |

Both architectures save 24,006 keys and produce the exact visible-decision
signature `D33AC07C1551CAA1`, matching the rerun of the exact Windows v1.21.0
tag. The Windows README's published historical row reports 9,419 hits and
2.549 average keys saved; that published value is not silently replaced by
the one-case-higher rerun.

The separate 16,300-case production long-completion track retains the real
40 ms asynchronous result-acceptance deadline:

| Architecture | Local Completion Hit | Prompt Coverage | Total Keys Saved | P95 |
| --- | ---: | ---: | ---: | ---: |
| x86_64 | 275/16,300 | 5,101/16,300 | 700 | 141 ms |
| aarch64 | 348/16,300 | 6,281/16,300 | 825 | 100 ms |

Windows publishes 357 hits, 6,475 prompts and 861 keys saved. This timed
background track does not match those counts on the validation hosts, unlike
the deterministic short-completion track. Results arriving after the deployed
deadline remain rejected; the gate does not increase the deadline to manufacture
matching results. The 500-case deadline-free smoke uses the exact per-architecture
signatures `7190F18DE6E96FEC` (x86_64) and `BB58A43A76877A5B` (aarch64).

## Frozen v1.20.0 Port Results

The v1.20.0 validation reuses the same separately supplied frozen corpus files
as v1.19.0. They are not redistributed by this repository and remain bound by
size and SHA-256:

| Input | Cases | Bytes | SHA-256 |
| --- | ---: | ---: | --- |
| Long sentence | 16,300 | 2,673,936 | `3f50a9323ad798e691f86ea70c6dffa13b4a9f55b624fc3499a138258190ff0f` |
| Short word with frozen context | 65,000 | 9,200,779 | `cd02fc1a24e89a106c200f4864d5ad2c11afd4c8d784059a4b6e9a10c51fbab8` |

Ubuntu 26.04.1 x86_64 and Ubuntu 26.04.1 aarch64 produced the following native
results with the reviewed v1.20.0 engine, schema-24 dictionary, document-local
adaptation, conditional Transformer, and constrained candidate generators.
External document context is disabled for this corpus comparison. Accuracy is
deterministic and latency uses the deployed 30 ms neural-result budget:

| Architecture | Track | Top1 | Top2 | Top5 | Top9 | Mean | P50 | P95 | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | Long sentence | 11,088/16,300 | 12,402/16,300 | 12,402 | 12,402 | 184.969 ms | 180 ms | 363 ms | 936 ms |
| x86_64 | Short word, context off | 60,346/65,000 | 63,163/65,000 | 64,498 | 64,619 | 8.967 ms | 7 ms | 23 ms | 68 ms |
| x86_64 | Short word, context on | 61,827/65,000 | 63,517/65,000 | 64,540 | 64,619 | 10.059 ms | 8 ms | 25 ms | 66 ms |
| aarch64 | Long sentence | 11,068/16,300 | 12,393/16,300 | 12,393 | 12,393 | 104.667 ms | 91 ms | 221 ms | 612 ms |
| aarch64 | Short word, context off | 60,346/65,000 | 63,163/65,000 | 64,498 | 64,619 | 5.957 ms | 5 ms | 15 ms | 44 ms |
| aarch64 | Short word, context on | 61,827/65,000 | 63,517/65,000 | 64,540 | 64,619 | 6.617 ms | 5 ms | 16 ms | 45 ms |

The published Windows v1.20.0 reference is 11,065 Top1 and 12,376 Top2. Linux
x86_64 is 23/26 cases higher and aarch64 is 3/17 cases higher. Relative to the
frozen Linux v1.19.0 results, v1.20.0 gains 147 Top1 and 142 Top2 cases on
x86_64, and 152 Top1 and 141 Top2 cases on aarch64. The 65,000-case short-word
counts and exact failure signature remain identical on Windows, x86_64, and
aarch64.

Quality-run maximum RSS/high-water marks were 843,860/865,160 KiB on x86_64
and 936,084/967,068 KiB on aarch64. The full completion processes peaked at
976,620 KiB and 946,128 KiB respectively. Every value remains below the
983,040 KiB release ceiling. Both clean native builds passed all 141 FPCUnit
tests, the 22 simplified and 9 traditional candidate regressions, and the
eight-context 8,300-key transport/restart stress test.

The complete one-key-completion track continues to use the production 40 ms
local-result acceptance limit:

| Architecture | Local completion hit | Prompt coverage | Total keys saved | P95 |
| --- | ---: | ---: | ---: | ---: |
| x86_64 | 303/16,300 (1.86%) | 5,510/16,300 (33.80%) | 724 | 141 ms |
| aarch64 | 349/16,300 (2.14%) | 6,283/16,300 (38.55%) | 829 | 99 ms |

The Windows v1.20.0 publication records 357 hits, 6,475 prompts, 861 saved
keys, and 42.672 ms P95. The slower x86_64 validation host crosses the fixed
40 ms background-result boundary more often than aarch64, so its accepted
prompt and hit counts are lower without changing the generator, confidence
policy, or user-facing timeout. The range gate records this production
behavior instead of increasing the timeout to manufacture parity.

The separate deterministic 500-case neural smoke disables wall-clock cutoffs
and freezes `A53F2BCDD29A210C` on x86_64 and `BB58A43A76877A5B` on aarch64.
Unlike v1.19.0, v1.20.0 exercises a generative ONNX path whose beam decisions
can cross floating-point boundaries between architectures. Each architecture
therefore has its own exact smoke baseline while sharing the same model,
allowed-output table, validation policy, and aggregate release floors.

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
