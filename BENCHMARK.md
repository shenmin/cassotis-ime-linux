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

- Cassotis IME v1.25.0 (`d72f2d024f257f8699851da276dad8dbdc0371c7`)
- Cassotis Lexicon v1.25.0 (`cd8aed88e86ff0377cc6accd1881d93e25253d50`)
- Simplified dictionary schema 24, SHA-256
  `ddec15f2015c3182d971e90656a568d9ec434794dadcf822f3abd77ff0d91acd`
- Traditional dictionary schema 24, SHA-256
  `f310600f824c062c875b73e19a982f0e129730907d10ef20f0455c4de19bb6a3`
- Simplified/traditional base entries: 213,290 / 216,505
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
reviewed native completion-selector source units, the two local-repair graphs
and their vocabulary, reading constraints and decision manifest, the
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
an exact per-case signature. The neural long-sentence track must meet the
reviewed architecture-specific rank floors, recorded alongside the Windows
reference below. Before the full benchmark, a separate
500-case check repeats the deterministic candidate/completion trace in three
fresh processes with different argument and environment layouts. Any difference
in the recorded candidates, paths, or completion decisions fails that check;
uninitialized search state is not treated as an acceptable runtime variation.
The complete long-sentence failure TSV is retained to diagnose cross-platform
differences rather than claiming per-case equivalence from aggregate counts.

The native runtime also has an exact integer-arithmetic regression for
quantized inference. All six model sessions enable ONNX Runtime's x86
quantization precision mode to avoid saturating intermediate products on CPUs
without VNNI. This does not change the model files or quantization scales.
The local-repair ABI tests additionally exercise phonetic output constraints,
finite confidence values, and context-cache reuse, replacement and clearing.

Cold-start validation deliberately blocks native model initialization while
testing the production IPC service: first-key candidates, selection/commit,
static Tab completion, long-input fallback and polling must remain responsive.
It then releases the barrier and verifies input again after real background
loading. A separate new-process trial records startup and key latency without
the barrier. This is process-cold testing, not a claim that OS file caches were
dropped. The test interposer is never included in installable packages.
A v0.6.0 aarch64 qualification repeat measured 14.701 ms for the first key and
48.448 ms maximum across 34 key events with initialization held. The independent
process-cold trial measured 12.296 ms / 55.269 ms. These key timings exclude
the separately recorded service startup (about 1.45 s, including dictionary
opening and cache preparation); they are not end-to-end process-launch times.

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
  --baseline tests/baselines/quality-v1.25.0-linux-x86_64.txt
```

The long-sentence accuracy pass uses deterministic work limits, single-threaded
ONNX inference, and accepts a completed Transformer decision without a
wall-clock cutoff. A separate production-mode pass measures latency with the
deployed model concurrency and 30 ms diagnostic threshold. Since v1.21, a
completed synchronous inference remains eligible even after that threshold;
it is not a cancellation deadline for the conditional reranker. The separate
local-repair stage retains the Windows policy of discarding a repair whose
completed query exceeded its configured timeout; timeout 0 disables that
cutoff in the accuracy pass. Both passes use the same models and bounded
search. The separation reduces concurrency-related accuracy variation while
retaining realistic production latency. The repeated-process check above guards
same-platform stability; bitwise-identical neural decisions across CPU
architectures are not assumed.

Long completion has two full 16,300-case tracks. The production track uses
the deployed 50 ms result-acceptance deadline, increased from 40 ms for Linux
v0.7.0, without relaxing quality floors or latency budgets. This is an
asynchronous result cutoff, not a synchronous wait for each keystroke; model
loading remains asynchronous too. The accuracy track uses deadline 0, matching
the Windows completion runner's deterministic-benchmark mode, and compares hits and saved
keys with the Windows reference. Both request four completion inference threads;
the Linux runtime caps this at the available CPU count (two on the qualification
VMs).
Deadline-free accuracy does not replace the production check or change the
input method's runtime settings. In both tracks the conditional reranker and
local-repair stage retain their normal configuration; the completion deadline
argument does not change the separate local-repair timeout.

Since the v1.24.0 port, long-completion timing includes decoding and resolving
the final visible candidate list before resolving the Tab result, matching the
updated Windows benchmark. Reports identify this scope as
`decode_final_candidates_visible_completion_v1` and break out all three stages.
Older completion timings omitted final-candidate work and are not directly
comparable. The post-sample oracle remains outside the measured interval.
The gate validates the scope, per-case trace signature, counts, and timing
totals. It recomputes decoding-plus-visible-completion mean/median/P95/maximum
from each sample and retains their previous budgets. The new final-candidate
phase uses the existing long-query mean/P95/maximum budgets. The prior total
maximum is also retained, so adding a phase cannot hide a slowdown in the
previously measured work or silently admit a larger worst-case delay.

The runner reports Top1/Top2/Top5/Top9 counts, mean/P50/P95/maximum query
latency, and Linux process RSS/high-water marks. Memory events contain only
the track and case identifier. It writes every non-Top1 result to
`long-failures.tsv` or `short-failures.tsv`; those files are local diagnostics,
not ignored failures, and are not included in binary release assets.

## v1.25.0 Port Results

Qualification on 2026-09-10/11 uses the exact v1.25.0 sources, models,
newly built dictionaries and unchanged frozen corpora listed above. The
Windows reference is compiled with Delphi from the exact tag and replayed
against the same database and cases, without user learning. Its long-accuracy
totals reproduce the published Windows table:

| Platform | Long Top1 / 16,300 | Long Top2 / 16,300 | Short Top1, context off / 65,000 | Short Top1, context on / 65,000 |
| --- | ---: | ---: | ---: | ---: |
| Windows v1.25.0 published and same-input replay | 11,698 | 12,830 | 60,378 | 61,859 |
| Linux x86_64 | 11,696 | 12,831 | 60,378 | 61,859 |
| Linux aarch64 | 11,696 | 12,833 | 60,378 | 61,859 |

Both complete short tracks match the Windows target ranks and first candidates
case by case. Their combined 7,763-row failure signature is
`86a271df3a5b6b97bb510ad39d3c9f3f81eeda412181183dd02f6e211519573a`.
Top2 is 63,194 without context and 63,549 with context. The context-on
competition subset remains 9,596 Top1 / 10,775 Top2 out of 11,728 cases.
Short completion also matches the replayed Windows visible-result signature,
`0F85F09476081967`: 9,420 hits, 12,775 prompts, 24,006 saved keys, and
1,691 stable pairs out of 1,749. The previously published Windows short-
completion table reports 9,419 hits; the exact-tag replay with these frozen
inputs reports 9,420. This distinction is retained rather than rewriting the
published table.

Long results are not case-identical. x86_64 has eight target-rank differences
(three Top1 gains, five losses); aarch64 has 97 (39 gains, 41 losses). Complete
per-case reports are retained. The Linux span-cache correction, stable ordering
and quantized-runtime precision policy remain enabled. Not every individual
cross-platform difference has been attributed to a single cause.

Production-mode long-query latency is measured separately from accuracy:

| Architecture | Mean | P50 | P95 | Max | Quality-process peak HWM |
| --- | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 193.402 ms | 202 ms | 354 ms | 1,050 ms | 973,480 KiB |
| aarch64 | 84.179 ms | 78 ms | 156 ms | 604 ms | 933,716 KiB |

These different hosts are not a compiler-performance comparison. Existing
memory and long/short-query latency ceilings are unchanged. A separate
eight-second Windows diagnostic build overlapped the exploratory x86_64 short
track; final release measurements must run without competing benchmark/build
processes. Both native suites pass 335 FPCUnit tests, 23 simplified and nine
traditional candidate assertions, and all five IBus/Fcitx matrix stages.
Three fresh-process 500-case candidate/completion trials agree per architecture.

With model initialization blocked, first/max key latencies are 15.042/77.040 ms
on x86_64 and 12.973/50.969 ms on aarch64. Independent process-cold trials
measure 33.054/160.753 ms and 15.985/58.672 ms. Service startup is measured
separately at approximately 2.7 s and 1.6 s; these are not disk-cold tests.
Eight-context, 8,300-key transport checks report RSS growth of 8 KiB on x86_64
and 0 KiB on aarch64, with restart recovery passing.

Full long-completion results, each covering all 16,300 cases:

| Platform and completion deadline | Prompts | Hits | Saved keys | Stable / eligible pairs |
| --- | ---: | ---: | ---: | ---: |
| Windows v1.25.0 replay, no deadline | 6,489 | 409 | 959 | 28 / 740 |
| Linux x86_64, no deadline | 6,488 | 408 | 956 | 28 / 740 |
| Linux aarch64, no deadline | 6,491 | 412 | 946 | 26 / 738 |
| Linux x86_64, production 40 ms | 6,266 | 398 | 934 | 22 / 710 |
| Linux aarch64, production 40 ms | 6,491 | 412 | 946 | 26 / 738 |
| Linux x86_64, production 50 ms | 6,478 | 407 | 955 | 28 / 735 |
| Linux aarch64, production 50 ms | 6,492 | 412 | 945 | 26 / 738 |

The deadline-free x86_64 trace has six differing suggestions and one lost hit.
The aarch64 trace has 441 differing suggestions, 15 hit gains and 12 losses.
More hits can still save fewer keys because correct continuations have
different lengths. Production mean/P95/max completion times are
110.424/280/860 ms on x86_64 and 51.937/116/565 ms on aarch64, including all
three measured phases.

These initial 40 ms trials identified two qualification gaps: aarch64 saves
13 fewer keys than Windows, beyond the original nine-key allowance, and
x86_64 stability is 22 pairs against the old minimum of 25. The eligible
denominator changes with available prompts; the no-deadline x86_64 result
matches Windows at 28/740. Fresh 50 ms production measurements on 2026-09-11
pass every existing production quality floor and latency budget on both
architectures. x86_64 stability is now 28 pairs, exceeding the retained
minimum of 25. Total mean/P95/max is 110.252/275/862 ms on x86_64 and
52.031/117/580 ms on aarch64. The earlier 40 ms results remain as a comparison;
timed measurements can also vary with scheduling and earlier pipeline stages.
The separate deadline-free aarch64 thirteen-key deficit was accepted for this
release on 2026-09-11: its saved-key floor is 946 against Windows' 959. This
architecture-specific exception does not change the nine-hit allowance, the
x86_64 accuracy comparison, or any production quality or latency requirement.

Both native 50 ms builds pass 335 FPCUnit cases and the executable-default
check. With model initialization deliberately blocked, first/max key times
are 27.285/76.910 ms on x86_64 and 12.983/42.879 ms on aarch64. Independent
process-cold input measures 18.163/142.836 ms and 11.436/58.004 ms respectively;
the system file cache was not dropped. Input completes while initialization
is still blocked, then real model loading recovers successfully.
These measurements do not replace the final exact-commit release gate,
package installation or application UI acceptance.

## v1.24.0 Port Results

The earlier v1.24.0 qualification used the same frozen 16,300 long and 65,000
short cases, that version's schema-24 dictionaries (213,315 simplified and
216,467 traditional base entries), and its reviewed model files.
Native measurements on Ubuntu 26.04.1 on 2026-09-09 produced:

| Platform | Long Top1 / 16,300 | Long Top2 / 16,300 | Short Top1, context off / 65,000 | Short Top1, context on / 65,000 |
| --- | ---: | ---: | ---: | ---: |
| Windows v1.24.0 published table | 11,679 | 12,813 | 60,346 | 61,827 |
| Windows v1.24.0 same-input accuracy replay, timeout 0 | 11,696 | 12,829 | - | - |
| Linux x86_64 | 11,696 | 12,831 | 60,346 | 61,827 |
| Linux aarch64 | 11,696 | 12,833 | 60,346 | 61,827 |

The replay builds the Windows v1.24.0 tag with Delphi and uses exactly the
same fresh simplified database, frozen corpus and matching runtime/model
assets, with user learning and external context disabled and
`--neural-result-timeout-ms=0`, matching the Linux accuracy track. This also
removes the local-repair time cutoff; the difference from the published table
has not been attributed solely to the new dictionary. The replay must not be
confused with the earlier published result. Both Linux Top1 totals
equal this replay; Top2 is two/four cases higher. This is aggregate parity,
not per-case identity: x86_64 has six target-rank differences (three Top1
gains and three losses), and aarch64 has 95 (39 Top1 gains and 39 losses).
All differences are retained for diagnosis. The earlier Linux span-cache-miss
correctness fix, stable sorting and quantized-runtime precision policy remain
enabled; they are not reverted to reproduce another platform's output.

Both complete short tracks keep the exact Windows failure signature:
7,827 rows, SHA-256
`18cad226349cbfd1451c35c25f9572b3e004f121c79c5c22658fe47b970b207b`.
Top2 is 63,163 without context and 63,517 with context. The context-on
competition subset remains 9,596 Top1 / 10,775 Top2 out of 11,728 cases.
Short completion remains 9,420 hits out of 12,831 opportunities, 24,006 saved
keys and exact signature `D33AC07C1551CAA1` on both architectures.

Production-mode long-query latency is measured separately from accuracy:

| Architecture | Mean | P50 | P95 | Max | Quality-process peak HWM |
| --- | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 188.170 ms | 200 ms | 338 ms | 1,019 ms | 961,140 KiB |
| aarch64 | 82.259 ms | 77 ms | 151 ms | 642 ms | 948,724 KiB |

These are measurements on different machines, not a compiler speed comparison.
The 1 GiB memory ceiling and existing long/short-query latency ceilings are
unchanged. Both native builds pass 200 FPCUnit tests. Three fresh-process
500-case trials produce identical candidate/completion traces per architecture;
the deadline-free completion signatures remain `B8AADBA2B20D3B4F` on x86_64
and `CC52A67DE3040900` on aarch64.

With model initialization deliberately blocked, first-key/max key latencies
are 21.992/73.923 ms on x86_64 and 11.438/47.057 ms on aarch64. Independent
process-cold trials measure 36.922/181.999 ms and 19.113/54.056 ms. These key
timings exclude service startup, approximately 2.4-2.5 seconds and 1.4 seconds
respectively, and do not imply that the OS file cache was dropped. Final
release packages must additionally pass the complete gate from their exact
source revision, including both input frameworks and package validation.

The optional seventh argument to `cassotis-completion-benchmark` writes a
per-case TSV after each sample's timed work. It records the static and final
suggestions, request/accept/apply decisions, hits, saved keys and timing phases.
It is diagnostic output, not an input to candidate selection, and is retained
with validation reports rather than shipped in binary packages.

Full long-completion qualification uses all 16,300 cases. With the completion
deadline disabled, the same-input comparison is:

| Platform | Prompts | Hits | Saved keys |
| --- | ---: | ---: | ---: |
| Windows v1.24.0 replay | 6,474 | 407 | 953 |
| Linux x86_64 | 6,473 | 406 | 950 |
| Linux aarch64 | 6,480 | 411 | 942 |

x86_64 has six differing suggestions and one lost hit; aarch64 has 445 differing
suggestions, 16 hit gains and 12 losses. More hits do not necessarily save more
keys: each correct suggestion can complete a different suffix length. The
aarch64 eleven-key deficit exceeded the original nine-key comparison allowance.
It was subsequently accepted for that baseline; the v1.25.0 comparison is
measured independently and does not inherit that exception.

The separate 40 ms production trials yielded 396 hits / 925 saved keys and
394 / 933 on x86_64, and 409 / 937 and 410 / 939 on aarch64. The first x86_64
trial missed the unchanged 930-key floor. The traced x86_64 trial met the count
floors but failed the 1,200 ms overall maximum with one 1,748 ms sample
(14 ms decoding, 1,734 ms final candidates). Its other phase budgets passed;
mean/P95 were 109.696/272 ms. The traced aarch64 production trial passed all
existing floors, with mean/P95/max 50.817/114/563 ms. All runs are retained;
a diagnostic replay or a better repeat does not replace the final full gate.
The fixed window around the x86_64 spike was then replayed in three fresh
processes: the affected sample took 170/179/215 ms, and the window maxima were
274/298/282 ms. The spike was not reproduced; its cause remains unconfirmed.

## v1.22.0 Port Results

The same frozen 16,300 long and 65,000 short cases are used with the reviewed
v1.22.0 models and freshly rebuilt schema-24 dictionaries. Native qualification
on Ubuntu 26.04.1 produced these deterministic counts:

| Platform | Long Top1 / 16,300 | Long Top2 / 16,300 | Short Top1, context off / 65,000 | Short Top1, context on / 65,000 |
| --- | ---: | ---: | ---: | ---: |
| Windows v1.22.0 reference | 11,672 | 12,809 | 60,346 | 61,827 |
| Linux x86_64 | 11,671 | 12,810 | 60,346 | 61,827 |
| Linux aarch64 | 11,669 | 12,810 | 60,346 | 61,827 |

These small long-sentence differences are recorded, not described as exact
parity. A controlled replay identified the pre-existing Linux span-cache-miss
fix as the cause of all three x86_64 Top1 losses against Windows: loading the
same dictionary evidence removes query-history dependence. That fix is retained.
Additional aarch64 differences include model score/decision boundaries and
upstream candidate differences; not every individual cause has been established.
New architecture-specific floors freeze the counts above. The 1 GiB process
memory ceiling and existing latency ceilings are unchanged.

Both complete short tracks retain the same Top1/Top2/Top5/Top9 counts and
7,827-row failure signature recorded for v1.21.0 below. Short completion remains
9,420 hits, 24,006 saved keys and exact signature `D33AC07C1551CAA1`.
Three independent deadline-free 500-case completion traces freeze
`B8AADBA2B20D3B4F` on x86_64 and `CC52A67DE3040900` on aarch64.

The production 40 ms completion track measured 397 hits / 937 saved keys on
x86_64 and 410 / 939 on aarch64, against the Windows reference of 407 / 953.
A fresh aarch64 repeat produced 410 / 940. Timed acceptance is not an exact
signature: the gate requires at least 390/400 hits respectively and 930 saved
keys, along with prompt/error, stability, request-chain and latency checks.
Static-result challenges increase the number of model requests; pipeline
throughput is not capped merely to reproduce older request counts.

All six model sessions avoid retaining peak-sized CPU arenas. Free glibc pages
are returned after model initialization and destruction, never on each key.
The complete aarch64 allocation-policy recheck preserved all 16,300 first
candidate texts and target ranks and reached 960,956 KiB peak HWM, with
80.228 ms mean, 146 ms P95 and 615 ms maximum. These are native qualification
measurements; final-source release gates also validate packages and both
frameworks and must pass separately.

## Frozen v1.21.0 Port Results

The v1.21.0 port uses the same separately supplied 16,300 long-sentence and
65,000 short-word cases as v1.20.0, with the input sizes and SHA-256 hashes
listed in the next section. The following qualification measurements were
made on Ubuntu 26.04.1 GNOME Wayland hosts on 2026-09-05. Release packages
must pass the complete gate again from their exact source revision; these
measurements do not replace the per-release validation records.

| Architecture | Long Top1 | Long Top2 / Top5 / Top9 | Mean | P50 | P95 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 11,080/16,300 | 12,396/16,300 | 150.750 ms | 158 ms | 275 ms | 913 ms |
| aarch64 | 11,088/16,300 | 12,412/16,300 | 76.522 ms | 72 ms | 141 ms | 574 ms |

Windows v1.21.0 publishes Top1 11,080 and Top2 12,395. Linux x86_64 matches
Top1 and gains one Top2 case; aarch64 gains 8/17 cases. The release floors require
at least the published Windows counts on each architecture, not reduced
platform-specific accuracy targets. This is aggregate parity, not per-case
identity: compared with a rerun of the exact Windows tag, x86_64 gained two
Top1 cases and lost two, with seven differing target ranks; aarch64 gained 50
and lost 42, with 114 differing target ranks overall. The cause
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
The long-sentence process reached RSS/high-water marks of 825,004 KiB on
x86_64 and 810,712 KiB on aarch64, both below the existing 1,048,576 KiB gate.
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
| x86_64 | 280/16,300 | 5,249/16,300 | 703 | 69 ms |
| aarch64 | 362/16,300 | 6,478/16,300 | 853 | 45 ms |

Windows publishes 357 hits, 6,475 prompts and 861 keys saved. This timed
background track does not match those counts on the validation hosts, unlike
the deterministic short-completion track. Results arriving after the deployed
deadline remain rejected; the gate does not increase the deadline to manufacture
matching results. The 500-case deadline-free smoke uses the exact per-architecture
signatures `06E92EB69EB24518` (x86_64) and `4775EE37F80823C9` (aarch64).

On aarch64, 3,209 neural results were accepted and applied. These are pipeline
counts, not correct-hit counts. The former fixed upper bounds of 3,200 were
removed after review: increased throughput alone is not a quality regression.
Minimum pipeline counts, request-chain invariants, hit/error/coverage bounds,
saved-key and latency requirements, and the 40 ms deadline remain unchanged.
The original reports pass the revised completion checks on both architectures;
this revalidation does not replace the complete final-source release gate.
The maximum completion-process RSS on aarch64 was 809,832 KiB. A separate
repeat of the first 5,000 complete long queries also produced identical Top1
text and target ranks on aarch64.

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
