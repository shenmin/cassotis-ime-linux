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

## Frozen v2.4.0 Baseline

Linux v2.1.0 targets the final v2.4.0 engine and lexicon tags. The current
validation uses newly built dictionaries and the revised benchmark readings.
Corpus sizes remain unchanged, but the revised short-case classifications have
11,685 contested cases instead of 11,728. Historical measurements retain their
original inputs and dates; they are not paired results on the revised cases.

- [Cassotis IME v2.4.0](https://github.com/shenmin/cassotis-ime/tree/v2.4.0),
  including incremental prefix retention, canonical reading checks, traditional
  model views, corpus-aware context-free word selection and short-phrase ranking.
- [Cassotis Lexicon v2.4.0](https://github.com/shenmin/cassotis-lexicon/tree/v2.4.0)
- Simplified dictionary schema 24, SHA-256
  `d301dc9370a3f476abb9d221a86b3018f7045e94ccaa95137caf9c790e189766`
- Traditional dictionary schema 24, SHA-256
  `465318995f0b5f4447c12c108317f2b09c21388fd5c528e9a096f13ae42739ea`
- Simplified dictionary: 259,524 text-reading records, including 23,918
  single-character and 235,606 multi-character records
- Traditional dictionary: 260,404 text-reading records, including 24,181
  single-character and 236,223 multi-character records
- Simplified/traditional short-word promotion rows: 1,489 / 1,672
- Simplified/traditional completion competition rows: 42,453 / 42,448
- Simplified/traditional completion pair-audit rows: 4,379 / 4,379
- Simplified long-completion tables: 41,244 visible paths and 103,407 total
  text-recall rows
- Traditional long-completion tables: 38,302 visible paths and 98,276 total
  text-recall rows

Both databases include all 5,821 reviewed poetry next-line records. Counts and
compatibility are detailed in [Dictionary Compatibility](docs/DICTIONARY.md#dictionary-compatibility).

Source and data consistency checks cover the engine, parsers, input schemes,
models, and dictionaries, distinguishing platform adaptations from candidate
behavior differences.

Traditional input is scored through a simplified-text model view while preserving
traditional candidates and commits. Both foreground decisions and background
completion use this view. Next-character queries share the text-scoring graph
run; unknown, omitted and unscored query slots cannot introduce a false penalty.
The model graph, vocabulary, reading map and seven compact ranking units are
unchanged from v2.0.0.

The v2.0.0 port uses one approximately 150-million-parameter character language
model for long sentences, short words, phrase correction and both forms of Tab
completion. It replaces the previous separate neural graphs; seven compact
generated ranking units remain. Scoring and correction share one native session
and bounded token caches. The native ABI uses explicit UTF-16 code
units rather than Linux `wchar_t`; tests cover supplementary characters,
invalid or truncated input, bounded inference, next-character scoring and
recovery after repeated cancelled inferences. Production model
loading remains lazy and asynchronous, with dictionary-only fallback while a
model is unavailable. Benchmark initialization waits for models separately from
query timing.

Foreground character-LM scoring retains a 100 ms cancellation budget.
This is not a fixed delay: completed inference returns immediately, and
cancellation keeps the original candidate order. Linux uses an absolute
monotonic deadline and rejects a late result even if the cancellation worker
was scheduled late. Model loading remains asynchronous. Short Tab reranking
runs in the background, with foreground scoring taking priority and stale
context/generation results discarded. The long-completion acceptance deadline
is separate. These production deadlines do not apply to the corpus benchmarks
described below.
The inference budget is not a hard ceiling on the full query or end-to-end key
latency, which also includes dictionary, candidate and framework work.

The native runtime also has an exact integer-arithmetic regression for
quantized inference. All inference sessions enable ONNX Runtime's x86
quantization precision mode to avoid saturating intermediate products on CPUs
without VNNI. This does not change the model files or quantization scales.
On ARM64, the shared character model's FastGelu activation preserves the
Windows kernel's fused/unfused arithmetic sequence. Tiny rounding differences
can change decisions near a ranking margin. The v2.0.0 model uses fixed int8
activation ranges, not the earlier dynamic quantization. A synthetic bitwise regression
checks this sequence separately from corpus accuracy; model weights, graphs,
vocabulary and ranking coefficients are unchanged.
The correction ABI tests additionally exercise phonetic output constraints,
finite confidence values, and context-cache reuse, replacement and clearing.
TrieAttention batches prefixes without allowing one candidate's branch to
affect another. Tests compare individual, reordered, batched and cached scores.
The current graph is reconstructed from four numbered, checksum-verified parts;
obsolete graphs and owned weight sidecars are removed on upgrade. The graph,
vocabulary and reading map are identical to the frozen model inputs.

Cold-start validation deliberately blocks native model initialization while
testing the production IPC service: first-key candidates, selection/commit,
static Tab completion, long-input fallback and polling must remain responsive.
It then releases the barrier and verifies input again after real background
loading. A separate new-process trial records startup and key latency without
the barrier. This is process-cold testing, not a claim that OS file caches were
dropped. The test interposer is never included in installable packages.

The published corpus comparison disables persisted user learning and external
document context, matching the Windows benchmark protocol. Document-local
adaptation is validated separately by model and service tests so text from one
application context cannot silently influence the frozen aggregate result.

## Full Linux Benchmark

Evaluation runs natively on Linux against the same final dictionary and frozen
case sets used by the Windows project:

- 16,300 long-sentence cases
- 65,000 short-word cases without context
- The same 65,000 short-word cases with their frozen left context

This document publishes the methodology and aggregate results. Evaluation
tools, corpora, and per-case reports are not distributed with the project.

From 2026-10-17, all corpus benchmarks disable wall-clock search, model scoring
and completion-acceptance deadlines. Long sentences, short words and both forms
of completion use deterministic work limits and eight model threads on both
architectures. Accuracy and latency come from the same query: a slow completed
answer remains part of both measurements rather than being replaced by a timed
fallback. The long-sentence report identifies this policy as
`same_query_deadline_free_v1`. Deterministic search bounds, the model and ranking
rules are unchanged; this is not an unbounded search.

Long completion runs once over all 16,300 cases, with foreground and background
model deadlines and the result-acceptance cutoff disabled. Both completion
benchmarks include the time spent waiting for a finished evaluation even when
it leaves the visible result unchanged (`all_finished_requests_v1`). A slow
worker emits progress instead of hitting a fixed per-request wait limit.
Infrastructure errors fail the run; a stalled or interrupted run remains
incomplete rather than being counted as ordinary incorrect answers.

This protocol changes benchmarks, not the installed input method. Production
retains its foreground 100 ms and background 120 ms safeguards, lazy model
loading and architecture-specific thread selection. Separate production service,
cancellation and cold-start tests check those behaviors. Deadline-free corpus
accuracy does not claim that the timed production path always returns identical
candidates. Repeated-process checks guard same-platform stability;
bitwise-identical neural decisions across CPU architectures are not assumed.

The completion runner resolves the final candidate list before asking the shared
model for a continuation, matching v2.0.0's
`shared_lm_after_final_candidates_v2` protocol. The old raw-model prefetch stage
is removed. Background results still apply only to the matching input generation.

Visible predictive continuations use the v1.30+ scoring rule: a result must
extend the typed prefix while remaining a prefix of the reference sentence;
the same-position pronouns 他 and 她 are equivalent. The strict oracle remains
a separate diagnostic. Short Tab reports both synchronous keystroke latency
and settled-display latency after background reranking finishes; the latter
includes that work even when the visible completion does not change.

Since the v1.24.0 port, long-completion timing includes decoding and resolving
the final visible candidate list before resolving the Tab result, matching the
updated Windows benchmark. Reports identify this scope as
`decode_final_candidates_visible_completion_v1` and break out all three stages.
Older completion timings omitted final-candidate work and are not directly
comparable. The post-sample oracle remains outside the measured interval.
The gate validates the scope, per-case trace signature, counts, and timing
totals. It recomputes decoding-plus-visible-completion mean/median/P95/maximum
from each sample and checks final-candidate work and the full visible interval
separately, so a subtotal cannot hide an end-to-end slowdown. Corpus latency is
reported, not used as a deadline or a pass/fail ceiling under the new protocol.
Earlier latency ceilings remain historical metadata; accuracy, coverage and
memory gates are unchanged. Published tables report measured mean, median, P95
and maximum latency. Historical timed measurements remain labeled as such and
are not relabeled as deadline-free results.

Long-sentence scoring reports visible complete-candidate Top1/Top2; the redundant
long Top5/Top9 metrics were removed with the v1.27.0 protocol. Short-word
diagnostics retain Top1/Top2/Top5/Top9. The runner reports mean/P50/P95/maximum query
latency, and Linux process RSS/high-water marks. Memory events contain only
the track and case identifier. It writes every non-Top1 result to
`long-failures.tsv` or `short-failures.tsv`; those files are local diagnostics,
not ignored failures, and are not included in binary release assets.

## v2.1.0 Native Measurements

Measured on 2026-10-25 (UTC+8), with the frozen v2.4.0 engine, dictionaries
and revised cases above. The x86_64 host is Ubuntu 26.04.1 in an eight-vCPU,
16 GiB virtual machine on an Intel Core i5-12600K. The aarch64 VM uses eight
vCPUs and 8 GiB on Apple silicon. Runners execute sequentially
with eight model threads and no search, inference or completion wall-clock
deadline; deterministic work bounds and ranking rules are unchanged.

Both architectures have passed all four corpus suites and installed-package checks.
Results below are native measurements, not estimates or results borrowed from the
previous release. The revised inputs also mean that the
historical tables are not paired comparisons.

### Candidate Selection

Accuracy and latency are measured on the same complete queries. Times are in ms.

| Architecture | Track | Top1 | Top2 | Mean | Median | P95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | Long sentences | 13,435/16,300 | 14,314/16,300 | 150.925 | 151 | 227 | 536 |
| aarch64 | Long sentences | 13,435/16,300 | 14,313/16,300 | 117.718 | 115 | 189 | 581 |
| x86_64 | Short, no context | 61,235/65,000 | 63,701/65,000 | 4.827 | 3 | 12 | 71 |
| aarch64 | Short, no context | 61,235/65,000 | 63,701/65,000 | 4.967 | 3 | 13 | 52 |
| x86_64 | Short, context | 63,455/65,000 | 64,423/65,000 | 8.491 | 5 | 24 | 79 |
| aarch64 | Short, context | 63,454/65,000 | 64,423/65,000 | 7.988 | 5 | 22 | 68 |

Among 11,685 contested short cases, Top1/Top2 are 8,940/10,652 without context
on both architectures. With context they are 10,539/11,225 on x86_64 and
10,538/11,225 on aarch64. Process high-water marks are 431,208 KiB (421.1 MiB)
and 433,388 KiB (423.2 MiB), respectively; these are measured peaks, not universal
memory limits. Production foreground/background model safeguards remain
100/120 ms, so these deadline-free
results do not imply that every production request returns the same candidates.

The previous v2.3.0-aligned development build scored 61,189/63,752 without
context on the same cases. This update gains 46 first choices but loses 51
Top2 hits on each architecture. The new corpus-prior guard retains the original
order when a substantially less frequent word would otherwise be promoted;
this is a ranking tradeoff, not an improvement in every metric.

### Completion

On both architectures, all 65,000 short cases and 16,300 long cases completed.
The short suite yields 12,831 completion opportunities; average saved keys are
per successful hit.

| Architecture | Track | Hits | Saved keys | Stability / coverage | Mean | Median | P95 | Maximum |
| --- | --- | ---: | ---: | --- | ---: | ---: | ---: | ---: |
| x86_64 | Short completion | 10,512/12,831 | 27,706; 2.636 per hit | 2,152/2,215 stable adjacent keys | 18.105 | 16.897 | 54.492 | 155.483 |
| aarch64 | Short completion | 10,513/12,831 | 27,708; 2.636 per hit | 2,153/2,216 stable adjacent keys | 13.080 | 12.540 | 37.961 | 99.898 |
| x86_64 | Long continuation | 3,876/16,300 | 9,576 | 16,147/16,300 predictive prompts | 160.186 | 156 | 251 | 549 |
| aarch64 | Long continuation | 3,883/16,300 | 9,591 | 16,142/16,300 predictive prompts | 124.117 | 118 | 202 | 518 |

Short-completion key P95 is 2.166 ms on x86_64 and 2.100 ms on aarch64. The
remaining latency columns include the completed background evaluation, even when the displayed hint does not
change. Long continuation includes final candidate selection and the displayed
completion; its mean decomposes into 7.542 ms of decoding, 82.866 ms of final
candidate work and 69.779 ms of completion on x86_64. The aarch64 means are
7.481, 65.162 and 51.475 ms, respectively. Complete-sentence hits are 208 on
x86_64 and 209 on aarch64. Prompt coverage is not precision.

All corpus validators pass on both architectures without relaxing their accuracy
requirements. Both installed-package desktop matrices and the SteamOS
user-installation checks also pass; see [Compatibility](COMPATIBILITY.md) for
their scope. These measurements apply to the v2.1.0 engine and dictionaries; historical
release results below retain their original inputs and dates.

## v2.0.0 Deadline-Free Measurements

Both architectures completed all four corpus groups on 2026-10-17 (UTC+8),
against its frozen v2.2.0 inputs. Both use eight model threads, deterministic
search bounds and no inference or completion-acceptance deadline. The same query
supplies each accuracy result and its latency; timing is not borrowed from a
different, faster run. Long accuracy and latency traces were checked row for row.

The machines are Ubuntu 26.04.1 VMs with eight vCPUs: x86_64 has 16 GiB RAM on
an Intel Core i5-12600K host; aarch64 has 8 GiB RAM on Apple silicon. One model
runner runs at a time on each host. These are separate machine measurements,
not a controlled hardware comparison. All times below are in milliseconds.

### Deadline-Free Candidate Selection

| Architecture | Track | Top1 | Top2 | Mean | Median | P95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | Long | 13,397/16,300 | 14,281/16,300 | 147.952 | 148 | 223 | 1,061 |
| aarch64 | Long | 13,399/16,300 | 14,282/16,300 | 115.221 | 112 | 185 | 536 |
| x86_64 | Short, no context | 61,173/65,000 | 63,618/65,000 | 4.977 | 3 | 13 | 95 |
| aarch64 | Short, no context | 61,173/65,000 | 63,618/65,000 | 4.976 | 3 | 13 | 73 |
| x86_64 | Short, context | 63,364/65,000 | 64,292/65,000 | 8.637 | 5 | 25 | 113 |
| aarch64 | Short, context | 63,361/65,000 | 64,291/65,000 | 7.909 | 5 | 21 | 84 |

Among 11,728 contested short cases, both architectures score 8,926/10,717
without context. With context, x86_64 scores 10,533/11,244 and aarch64 scores
10,532/11,244. Candidate-run process high-water marks are 440,388 KiB
(430.1 MiB) and 444,484 KiB (434.1 MiB); these are measured peaks, not an
idle-memory or universal maximum claim.

### Deadline-Free Long Completion

| Architecture | Hits | Predictive prompts | Saved keys | Mean | Median | P95 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 3,766/16,300 | 16,121/16,300 | 9,271 | 158.600 | 154 | 251 | 565 |
| aarch64 | 3,778/16,300 | 16,114/16,300 | 9,298 | 118.491 | 113 | 194 | 491 |

The respective mean decode/final-candidate/completion intervals are
7.735/82.601/68.263 ms and 7.366/62.094/49.031 ms. Whole-sentence hits are
189 and 191. Every finished background request is timed, including evaluations
that retain the visible hint; there is no fixed worker-wait cutoff. Both the
platform and reference-count validators check this same complete trace.

### Deadline-Free Short Completion

Each run covers 65,000 cases, yielding 12,831 completion opportunities and
12,781 visible prompts. Settled timing includes the completed background
evaluation even if it does not change the hint; initial static hints remain
available without waiting in normal input.

| Architecture | Hits | Saved keys | Average saved keys per hit | Mean | Median | P95 | Maximum | Key P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 10,456/12,831 | 27,520 | 2.632 | 18.988 | 17.723 | 58.125 | 145.379 | 2.137 |
| aarch64 | 10,458/12,831 | 27,525 | 2.632 | 19.511 | 16.730 | 59.205 | 1,738.571 | 2.137 |

Keystroke stability is 2,131/2,193 and 2,133/2,195, respectively. Output
signatures match each architecture's earlier short-completion run; the higher
settled timings reflect the expanded measurement scope, not changed candidates.
The aarch64 maximum is retained, not trimmed as an outlier. Earlier timings only
included background work when it changed the hint and are not directly comparable.

### v2.0.0 Corpus Gate Status

All full-corpus accuracy, coverage and memory checks pass on both architectures.
The existing count floors were not lowered. Latency is published without a
pass/fail ceiling under the new policy. This completes corpus validation, not
binary-package installation acceptance or publication. The installed input method
still uses its foreground 100 ms and background 120 ms safeguards; the earlier
timed x86_64 long-candidate difference remains recorded below and was not fixed
by changing the benchmark protocol. Production cancellation, cold-start and
desktop checks remain separate release requirements.

## Historical v2.0.0 Timed And Diagnostic Measurements

This section preserves the earlier timed runs and separate deadline-free
diagnostics. Their timing scope predates `all_finished_requests_v1`; they are
not the replacement measurements above.

These runs started on 2026-10-17 (UTC+8), using the final v2.2.0 tagged inputs.
Both machines run Ubuntu 26.04.1 with eight vCPUs: x86_64 has 16 GiB RAM on an
Intel Core i5-12600K host; aarch64 has 8 GiB RAM on Apple silicon. These are
independent VM measurements, not a controlled hardware comparison. Only one
model runner runs on each host at a time.

### Candidate Selection

Production accuracy and complete-query latency, in milliseconds:

| Architecture | Track | Top1 | Top2 | Mean | Median | P95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | Long | 13,360/16,300 | 14,245/16,300 | 120.038 | 118 | 190 | 470 |
| aarch64 | Long | 13,399/16,300 | 14,282/16,300 | 115.148 | 112 | 185 | 537 |
| x86_64 | Short, no context | 61,173/65,000 | 63,618/65,000 | 4.973 | 3 | 13 | 268 |
| aarch64 | Short, no context | 61,173/65,000 | 63,618/65,000 | 4.971 | 3 | 13 | 85 |
| x86_64 | Short, context | 63,364/65,000 | 64,292/65,000 | 8.068 | 5 | 22 | 95 |
| aarch64 | Short, context | 63,361/65,000 | 64,291/65,000 | 7.775 | 5 | 21 | 82 |

The separate deadline-free long pass scores 13,397/14,281 Top1/Top2 on x86_64
and 13,399/14,282 on aarch64. The x86_64 production run loses 37 Top1 and 36
Top2 against its deadline-free run, outside the existing nine-case allowance.
**Its production long-candidate quality gate did not pass in this round.** The
separate deadline-free result did not replace it. The aarch64 counts met the frozen floors;
no production deadline or quality threshold was relaxed.

Among 11,728 contested short cases, both architectures score 8,926/10,717
without context. With context, x86_64 scores 10,533/11,244 and aarch64 scores
10,532/11,244. Candidate-run process high-water marks are 442,232 KiB
(431.9 MiB) and 448,936 KiB (438.4 MiB). These are measured process peaks,
not idle-memory or universal maximum claims.

### Production Long Completion

Each architecture processes all 16,300 cases with the deployed 120 ms background
budget. Times include decoding, final-candidate work and visible completion.

| Architecture | Hits | Predictive prompts | Saved keys | Mean | Median | P95 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 3,766/16,300 | 16,121/16,300 | 9,271 | 119.698 | 115 | 200 | 468 |
| aarch64 | 3,778/16,300 | 16,114/16,300 | 9,298 | 119.364 | 114 | 195 | 518 |

The respective mean decode/final-candidate/completion intervals are
7.562/63.048/49.088 ms and 7.411/63.144/48.810 ms. Both production completion
runs meet the frozen count floors. Whole-sentence hits are 189 and 191.

### Deadline-Free Long Completion

Both architectures also process the full 16,300 cases with eight inference
threads and no result or character-LM deadline. These are diagnostic timings,
not the deployed completion latency.

| Architecture | Hits | Predictive prompts | Saved keys | Mean | Median | P95 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 3,766/16,300 | 16,121/16,300 | 9,271 | 155.535 | 151 | 247 | 1,892 |
| aarch64 | 3,778/16,300 | 16,114/16,300 | 9,298 | 118.654 | 114 | 194 | 500 |

The respective mean decode/final-candidate/completion intervals are
7.609/81.301/66.625 ms and 7.364/62.636/48.655 ms. Aggregate counts match each
architecture's production completion run; that does not imply all hints are
identical. The x86_64 production/deadline-free trace signatures differ, whereas
the aarch64 signatures match. Both tracks remain separately recorded.

### Short Completion

Each run processes 65,000 cases, giving 12,831 completion opportunities and
12,781 visible prompts. The 120 ms background budget is unchanged. Times are
in milliseconds; settled latency includes a background replacement when one
changes the displayed completion.

| Architecture | Hits | Saved keys | Average saved keys per hit | Mean | Median | P95 | Maximum | Key P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 10,456/12,831 | 27,520 | 2.632 | 5.913 | 0.842 | 30.467 | 104.601 | 2.072 |
| aarch64 | 10,458/12,831 | 27,525 | 2.632 | 6.073 | 0.773 | 30.675 | 96.729 | 2.033 |

Keystroke stability is 2,131/2,193 on x86_64 and 2,133/2,195 on aarch64.
Both short-completion gates pass. The output signatures are
`A34F731642F4DE48` and `B6E52B699366BAFF`, respectively.

### Cold Start And Memory

These checks use fresh production service processes without dropping OS file
caches. Startup is measured to IPC readiness; key timings begin after that
readiness, rather than hiding startup inside a first-key measurement. The
blocked trial holds model initialization deliberately and releases it before
checking ready-model input.

| Architecture | Process-cold IPC ready (ms) | Process-cold first key (ms) | Process-cold maximum key (ms) | Blocked-model first / maximum key (ms) |
| --- | ---: | ---: | ---: | ---: |
| x86_64 | 930.149 | 4.222 | 31.755 | 4.134 / 27.444 |
| aarch64 | 1,172.148 | 4.003 | 27.057 | 4.442 / 26.640 |

| Architecture | Loaded RSS (KiB) | RSS after five idle seconds (KiB / MiB) | Idle trim (ms) | Resume first / maximum key (ms) |
| --- | ---: | ---: | ---: | ---: |
| x86_64 | 321,724 | 318,380 / 310.9 | 0.318 | 3.472 / 73.985 |
| aarch64 | 330,644 | 327,332 / 319.7 | 0.700 | 13.748 / 85.791 |

Both cold-start and idle-memory checks pass without unloading the model during
idle reclamation. They measure the tested service and input sequence, not every
application's latency or a universal memory bound. Framework regression coverage
and the distinction from installed-package acceptance are in
[COMPATIBILITY.md](COMPATIBILITY.md).

### Historical Gate Status

In this earlier round all four full benchmark groups passed on aarch64. On x86_64, the only failed
quality fields are production long Top1 and Top2; short candidates, all three
completion tracks, latency, memory and lifecycle gates pass. Three fresh-process
replays of 500 cases also produce identical candidate/completion traces within
each architecture. New binary-package installation acceptance is still separate.

A subsequent 295-case x86_64 diagnostic includes changed candidates from the
full run and regularly spaced controls. With six threads its deterministic
deadline-free first candidates match the full eight-thread reference exactly
(225 correct). A 100 ms model deadline yields 223 correct; production search
yields 222 in both diagnostic processes, although seven first texts differ
between those processes. The original full production run scores 188 on that
selected subset. This shows timing sensitivity but does not fully reproduce or
explain the sustained-run gap. Subset results do not replace full-run scores,
and did not resolve the x86_64 production long gate. The later deadline-free
corpus policy and its results are documented separately above.

## Earlier v2.0.0 Measurements Against v2.1.0

These earlier measurements use the v2.1.0 engine and dictionaries,
with the same shared model and unchanged 100/120 ms foreground/background
budgets. Runs started on 2026-10-14 (UTC+8), using Ubuntu 26.04.1 virtual
machines with eight vCPUs. The x86_64 machine has 16 GiB RAM on an Intel Core
i5-12600K host; aarch64 has 8 GiB RAM on Apple silicon. These are independent
machine measurements, not a controlled hardware comparison.

The earlier SC/TC dictionaries contained 249,876 / 253,088 text-reading records,
with SHA-256 `1157f46aa08a80acb405070aa255b3a2e8b26693a81cd5be91c915e95632e1f7`
and `eaea45e13b6dbf4cdfc07ceccc703a66210ebd0be7e4c183f735741a469282b2`.
They did not include the final v2.2.0 updates or the 43 corrected benchmark cases.

All four full benchmark groups passed on both architectures, as did isolated
IBus/Fcitx 5, cold-start and idle-memory checks. Quality tolerances, latency and
memory ceilings and production budgets were not widened. See
[COMPATIBILITY.md](COMPATIBILITY.md) for the scope of framework and package
checks; earlier installed-desktop checks are not relabeled as this run.

### Candidate Selection

The table reports production accuracy and complete-query latency in milliseconds.
Long input covers 16,300 cases; short input covers 65,000 cases per context mode.

| Architecture | Track | Top1 | Top2 | Mean | Median | P95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | Long | 13,372/16,300 | 14,264/16,300 | 115.642 | 114 | 181 | 492 |
| aarch64 | Long | 13,383/16,300 | 14,271/16,300 | 113.221 | 111 | 179 | 491 |
| x86_64 | Short, no context | 61,160/65,000 | 63,607/65,000 | 4.840 | 3 | 12 | 71 |
| aarch64 | Short, no context | 61,160/65,000 | 63,610/65,000 | 4.549 | 3 | 12 | 68 |
| x86_64 | Short, context | 63,363/65,000 | 64,291/65,000 | 7.756 | 5 | 21 | 118 |
| aarch64 | Short, context | 63,360/65,000 | 64,290/65,000 | 7.363 | 5 | 20 | 69 |

The separate deadline-free long pass scored 13,380/14,270 Top1/Top2 on x86_64
and 13,383/14,271 on aarch64. Both deterministic and production candidate
gates passed. These are the first complete runs after the code/data alignment;
the earlier pre-alignment failures are retained below, not selected away by
repeated-run best scores.

For the 11,728 contested short-word cases, both machines scored 8,929/10,718
without context. With context, x86_64 scored 10,533/11,244 and aarch64 scored
10,532/11,244. Candidate-benchmark process high-water marks were 444,944 KiB
(434.5 MiB) and 446,076 KiB (435.6 MiB), respectively. These are measured
process peaks, not idle-memory or universal maximum claims.

### x86_64 Completion And Lifecycle

The short-completion run processes 65,000 cases; long completion processes
16,300 cases. Latency is in milliseconds.

| Completion track | Hits | Saved keys | Mean | Median | P95 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Short, settled display | 10,440/12,831 opportunities | 27,486 | 5.554 | 0.790 | 27.904 | 100.281 |
| Long, production full visible interval | 3,758/16,300 | 9,273 | 115.514 | 111 | 193 | 523 |

Short completion has keystroke P95 1.978 ms, 2.633 saved keys per hit and
2,124/2,186 stable pairs. Production long completion shows 16,123 predictive
prompts and completes 194 whole reference sentences. The mean decode,
final-candidate and completion intervals are 7.457, 60.468 and 47.589 ms.
The separate deadline-free completion run has 3,759 hits and 9,274 saved keys,
with mean/median/P95/maximum 160.898/157/258/517 ms. The production track uses
six inference threads; the diagnostic uses eight and no wall-clock cutoffs.
Its latency is not substituted for the production table.

With native model initialization deliberately blocked, first-key latency is
3.862 ms and the maximum over 41 keys is 28.225 ms. An independent new-process
trial gives 3.746/30.341 ms; socket readiness takes 0.941/0.910 seconds in the
two trials. OS file caches were not dropped. Loaded RSS is 325,316 KiB and
falls to 322,820 KiB (315.3 MiB) after five seconds idle. Resumed first/maximum
key latency is 3.476/84.891 ms, without unloading the model.

### aarch64 Completion And Lifecycle

All four complete benchmark groups and isolated IBus/Fcitx 5 checks passed.
The short-completion run processes 65,000 cases; long completion processes
16,300 cases. Latency is in milliseconds.

| Completion track | Hits | Saved keys | Mean | Median | P95 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Short, settled display | 10,442/12,831 opportunities | 27,491 | 5.888 | 0.701 | 30.007 | 97.888 |
| Long, production full visible interval | 3,767/16,300 | 9,291 | 118.191 | 115 | 194 | 464 |

Short completion has keystroke P95 1.923 ms, 2.633 saved keys per hit and
2,126/2,188 stable pairs. Production long completion shows 16,117 predictive
prompts and completes 195 whole reference sentences. The mean decode,
final-candidate and completion intervals are 7.060, 62.703 and 48.428 ms.
The separate deadline-free completion run also has 3,767 hits and 9,291 saved
keys, with mean/median/P95/maximum 116.430/113/191/479 ms. Deadline-free timing is not
substituted for the production table.

With native model initialization deliberately blocked, first-key latency is
3.854 ms and the maximum over 41 keys is 25.449 ms. An independent new-process
trial gives 3.469/25.829 ms; socket readiness takes 1.015/1.053 seconds in the
two trials. OS file caches were not dropped. Loaded RSS is 333,924 KiB and
falls to 330,696 KiB (322.9 MiB) after five seconds idle. Resumed first/maximum
key latency is 11.517/96.403 ms, without unloading the model.

## Historical v2.0.0 Pre-Alignment Measurements

The following measurements use the earlier v2.0.0 source/data inputs and predate
the Windows v2.1.0 alignment. Their failures and original results remain recorded.

Follow-up measurements were completed on 2026-10-13 and 2026-10-14 (UTC+8).
All four full benchmark groups passed on aarch64. On x86_64, short-word and
completion gates passed, but production long-sentence accuracy was below
the unchanged gate. That pre-alignment build was not fully release-qualified.
Package and desktop checks are documented separately in
[COMPATIBILITY.md](COMPATIBILITY.md). Deadline-free diagnostic results are
reported separately and do not substitute for production accuracy.

### x86_64 Measurements

These runs use Ubuntu 26.04.1 with eight virtual CPUs and 16 GiB RAM on an Intel
Core i5-12600K host. The shared model uses six production inference threads,
bounded by process CPU affinity, with the unchanged 100 ms foreground budget.
The table reports production accuracy and latency; latency is in milliseconds.

| Candidate track | Top1 | Top2 | Mean | Median | P95 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Long | 13,363/16,300 | 14,249/16,300 | 113.666 | 112 | 180 | 495 |
| Short, no context | 61,162/65,000 | 63,608/65,000 | 4.916 | 3 | 13 | 85 |
| Short, context | 63,363/65,000 | 64,291/65,000 | 7.923 | 5 | 21 | 71 |

The independent deadline-free long pass scored 13,379 Top1 and 14,268 Top2.
For the 11,728 contested short-word cases with context, Top1/Top2 were
10,533/11,244. The candidate benchmark process had a 445,112 KiB RSS high-water
mark (434.7 MiB), not an idle-memory or universal maximum claim.

The first full run had production Top1/Top2 13,376/14,257; an independent full
confirmation is shown above. Neither met the 13,371/14,259 production floors.
Both complete reports are retained. The model, thread policy, inference budgets
and gates were unchanged between runs; no repeated-run best score is selected
as a pass. Deadline-free scores do not waive this production-quality failure.

| Completion track | Hits | Saved keys | Mean | Median | P95 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Short, settled display | 10,440/12,831 opportunities | 27,486 | 5.512 | 0.788 | 28.011 | 103.051 |
| Long, full visible interval | 3,756/16,300 | 9,267 | 113.626 | 109 | 189 | 445 |

Short completion processed all 65,000 cases, with keystroke P95 1.979 ms,
2.633 saved keys per hit, and 2,124/2,186 stable pairs. Long completion uses
the deployed 120 ms background budget, shows 16,122 predictive prompts and
completes 194 entire reference sentences. Its mean decode/final-candidate/
completion intervals are 7.481/59.380/46.765 ms. Decode plus completion has
mean/median/P95 54.246/54/74 ms; it is not the full visible interval.

The separate eight-thread, deadline-free completion pass also has 3,756 hits
and 9,267 saved keys. Its mean/median/P95/maximum is 155.879/153/251/542 ms;
these diagnostic timings are not substituted for the production table above.

A fresh x86_64 lifecycle check measured 3.836 ms first-key latency and
27.541 ms maximum over 41 key events while model initialization was deliberately
blocked. An independent new-process trial measured 4.150/32.001 ms; service
startup was separately measured at 0.936/0.896 s. OS caches were not dropped.
After loading, RSS was 325,456 KiB, falling to 322,860 KiB (315.3 MiB) after five
seconds idle. Resumed first/maximum key latency was 3.715/72.383 ms, without
unloading the shared model. This lifecycle measurement is not a sustained-load
memory bound.

### aarch64 Measurements

These runs use Ubuntu 26.04.1 with eight virtual CPUs and 8 GiB RAM on an Apple
silicon host, the schema-24 dictionaries above, and the v2.0.0 shared model.
Production budgets are 100 ms for foreground model scoring and 120 ms for
background completion. All latency columns below are in milliseconds.

| Candidate track | Top1 | Top2 | Mean | Median | P95 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Long | 13,382/16,300 | 14,269/16,300 | 113.196 | 111 | 179 | 472 |
| Short, no context | 61,162/65,000 | 63,611/65,000 | 4.609 | 3 | 12 | 71 |
| Short, context | 63,360/65,000 | 64,290/65,000 | 7.354 | 5 | 20 | 71 |

The independent deadline-free long pass also scored 13,382 Top1 and 14,269 Top2.
For the 11,728 contested short-word cases with context, Top1/Top2 were
10,532/11,244. The full candidate run peaked at 446,180 KiB RSS (435.7 MiB);
this is the benchmark process peak, not an idle-memory or universal maximum claim.

| Completion track | Hits | Saved keys | Mean | Median | P95 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Short, settled display | 10,442/12,831 opportunities | 27,491 | 5.860 | 0.699 | 29.908 | 100.519 |
| Long, full visible interval | 3,764/16,300 | 9,284 | 116.442 | 112 | 190 | 478 |

Short completion processed all 65,000 cases, with keystroke P95 1.932 ms,
2.633 saved keys per hit, and 2,126/2,188 stable pairs. Long completion showed
16,117 predictive prompts and completed 195 entire reference sentences. Its
deadline-free diagnostic pass also had 3,764 hits and 9,284 saved keys.

A fresh aarch64 lifecycle check measured 3.627 ms first-key latency and
25.800 ms maximum over 41 key events while model initialization was deliberately
blocked. An independent new-process trial measured 3.461/25.801 ms; service
startup was separately measured at 1.024/0.981 s. OS caches were not dropped.
After loading, RSS was 333,328 KiB, falling to 330,084 KiB (322.3 MiB) after five
seconds idle. Resumed first/maximum key latency was 11.807/81.631 ms, without
unloading the shared model. This lifecycle measurement is not a sustained-load
memory bound.

The compatibility adaptation pins the existing glibc `sqrtf` ABI for older
systems. It does not change floating-point options, model parameters or budgets.
Instruction comparison, excluding relocated external-call addresses, and
byte-identical constants verify the unchanged inference implementation; native
model checks and an identical 500-case replay passed on each architecture.
Those compatibility replays belong to the initial port. The full follow-up
measurements above were rerun using the compatible runtime; the x86_64
production-quality failure is recorded separately, not hidden by those replays.

The following historical measurements retain their original versions and dates;
they are not v2.0.0 results.

## v1.0.0 Native Measurements

Complete native runs on 2026-10-04 use the v1.31.0 engine and dictionaries.
Both Ubuntu 26.04.1 guests have eight virtual CPUs: x86_64 has 16 GiB RAM and
aarch64 has 8 GiB. The x86_64 guest runs under VMware Workstation Pro 26.0.1
on an Intel Core i5-12600K host, with AVX2/FMA but no exposed VNNI. The aarch64
guest runs on Apple silicon with ARM dot-product instructions. These are
measurements of the tested virtual machines, not a controlled CPU comparison.
The four complete benchmark groups passed; final package and desktop acceptance
are tracked separately in [COMPATIBILITY.md](COMPATIBILITY.md).

### Cold Start And Idle Memory

The v1.0.0 aarch64 qualification repeat measured 17.565 ms for the first key
and 58.464 ms maximum across 41 key events with initialization held. The
independent process-cold trial measured 17.643/95.534 ms. These key timings
exclude the separately recorded service startup (1.091/1.050 s, including
dictionary opening and cache preparation); they are not process-launch times.
RSS was 457,976 KiB after model loading and 446,952 KiB (436.5 MiB) after five
seconds idle. Resumed first/maximum key latency was 26.667/79.059 ms.

The corresponding x86_64 repeat measured 12.081/27.328 ms with loading blocked
and 15.521/40.056 ms in the independent process-cold trial. Service startup was
0.862/0.851 s. Loaded RSS was 452,204 KiB, falling to 447,048 KiB (436.6 MiB)
after five seconds idle; resumed first/maximum key latency was 14.720/59.104 ms
without unloading models. These 41-key lifecycle checks did not drop OS caches
and do not replace sustained-query memory qualification.

### Candidate Quality

Production settings retain the 100 ms foreground character-LM deadline.
Long input covers 16,300 cases; each short-input track covers 65,000.
Latencies include candidate processing, not model inference alone, and are in ms.

| Architecture | Track | Top1 | Top2 | Mean | Median | P95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| x86_64 | Long | 12,940/16,300 (79.39%) | 13,534/16,300 (83.03%) | 114.695 | 114 | 178 | 486 |
| aarch64 | Long | 12,946/16,300 (79.42%) | 13,537/16,300 (83.05%) | 98.099 | 97 | 159 | 472 |
| x86_64 | Short, no context | 60,391/65,000 (92.91%) | 63,212/65,000 (97.25%) | 4.105 | 3 | 10 | 29 |
| aarch64 | Short, no context | 60,391/65,000 (92.91%) | 63,212/65,000 (97.25%) | 3.950 | 3 | 10 | 27 |
| x86_64 | Short, context | 63,036/65,000 (96.98%) | 64,104/65,000 (98.62%) | 8.286 | 8 | 20 | 42 |
| aarch64 | Short, context | 63,038/65,000 (96.98%) | 64,104/65,000 (98.62%) | 6.638 | 6 | 16 | 31 |

The separate single-threaded, deadline-free long accuracy pass records
12,941/13,535 Top1/Top2 on x86_64 and 12,946/13,537 on aarch64. Production
results are shown independently above, rather than combining accuracy-only
counts with production latency.

The ambiguous short-word subset contains 11,728 cases:

| Architecture | Context | Top1 | Top2 |
| --- | --- | ---: | ---: |
| x86_64 | Off | 8,738/11,728 (74.51%) | 10,528/11,728 (89.77%) |
| aarch64 | Off | 8,738/11,728 (74.51%) | 10,528/11,728 (89.77%) |
| x86_64 | On | 10,491/11,728 (89.45%) | 11,196/11,728 (95.46%) |
| aarch64 | On | 10,489/11,728 (89.44%) | 11,197/11,728 (95.47%) |

Candidate-suite peak RSS/high-water marks are 507,800/511,428 KiB on x86_64
and 509,348/513,060 KiB on aarch64. These describe this particular benchmark,
not idle memory or a universal process-peak bound.

### Short One-Key Completion

All 65,000 short-word cases produce 12,831 eligible completion opportunities.
The background character-LM deadline remains 120 ms.

| Architecture | Hits | Saved keys | Average saved keys per hit | Stable / eligible pairs |
| --- | ---: | ---: | ---: | ---: |
| x86_64 | 10,336/12,831 (80.55%) | 27,262 | 2.638 | 2,123/2,185 (97.16%) |
| aarch64 | 10,336/12,831 (80.55%) | 27,267 | 2.638 | 2,122/2,185 (97.12%) |

| Architecture | Key P95 | Settled mean | Settled median | Settled P95 | Settled maximum |
| --- | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 1.441 ms | 2.926 ms | 0.776 ms | 16.180 ms | 30.855 ms |
| aarch64 | 1.306 ms | 2.247 ms | 0.670 ms | 12.302 ms | 26.804 ms |

Settled-display latency includes an applied asynchronous rerank; it is not a
synchronous keystroke stall.

### Long One-Key Completion

Each track covers all 16,300 cases. Production retains the 120 ms background
result deadline; deadline-free runs are separate accuracy diagnostics.
The production results below come from complete verification runs, not the
earlier latency-calibration run.

| Architecture | Track | Predictive prompts | Hits | Saved keys |
| --- | --- | ---: | ---: | ---: |
| x86_64 | Production, 120 ms | 15,814/16,300 (97.02%) | 3,514/16,300 (21.56%) | 7,479 |
| aarch64 | Production, 120 ms | 15,816/16,300 (97.03%) | 3,536/16,300 (21.69%) | 7,508 |
| x86_64 | Deadline-free | 15,814/16,300 (97.02%) | 3,513/16,300 (21.55%) | 7,478 |
| aarch64 | Deadline-free | 15,816/16,300 (97.03%) | 3,536/16,300 (21.69%) | 7,508 |

Full visible-completion latency includes decoding, final-candidate processing
and resolving the visible completion. It excludes post-sample oracle work.
All values below are in ms.

| Architecture | Track | Mean | Median | P95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: |
| x86_64 | Production, 120 ms | 111.048 | 112 | 196 | 416 |
| aarch64 | Production, 120 ms | 87.549 | 85 | 164 | 402 |
| x86_64 | Deadline-free | 235.263 | 247 | 380 | 618 |
| aarch64 | Deadline-free | 154.919 | 161 | 262 | 490 |

Both architectures pass the complete production and deadline-free completion
gates with unchanged quality floors. The calibrated latency ceilings are not
runtime settings and do not extend either production inference budget.

## v0.9.1 Native Measurements

Native pre-release measurements on 2026-09-29 retained the v1.29.0 dictionary,
model values and ranking policy. The only approved acceptance exception is the
two-key production-completion difference documented below. The service
test kept three input contexts alive through 11,000 queries (101,364 key
events), mixing 10,000 short queries and 1,000 interleaved long queries.
Models remained loaded. After six seconds without input, process RSS was:

| Architecture | Active snapshot | Idle, contexts still alive | Idle PSS | Swap |
| --- | ---: | ---: | ---: | ---: |
| x86_64 | 539.7 MiB | 495.8 MiB | 489.1 MiB | 0 |
| aarch64 | 540.0 MiB | 494.6 MiB | 487.4 MiB | 0 |

These are workload measurements, not a universal 500 MiB cap. The active snapshot
is not a peak measurement. Releasing file-backed pages reduces process residency
but does not force the operating system to discard its shared file cache.
Idle reclamation runs once after five seconds without input, retains model
sessions and live context, and yields to new input. An independent 41-key resume
check measured first-key/maximum latency of 18.029/73.777 ms on x86_64 and
24.051/32.999 ms on aarch64. Process-cold tests did not clear OS file caches.

Complete 16,300-case long and 65,000-case short tests, both with and without
context, reproduced the v0.9.0 Top1/Top2 counts and every stable failure record.
Both complete 16,300-case long-completion tracks and the 65,000-case
short-completion test also ran; their results are reported separately below.

| Architecture | Track | Top1 | Top2 | Mean | P95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| x86_64 | Long | 11,998 | 12,970 | 173.661 ms | 320 ms | 912 ms |
| x86_64 | Short, no context | 60,384 | 63,212 | 7.099 ms | 19 ms | 53 ms |
| x86_64 | Short, context | 61,971 | 63,568 | 13.568 ms | 38 ms | 91 ms |
| aarch64 | Long | 11,992 | 12,969 | 64.522 ms | 118 ms | 416 ms |
| aarch64 | Short, no context | 60,384 | 63,212 | 3.831 ms | 10 ms | 24 ms |
| aarch64 | Short, context | 61,975 | 63,568 | 5.405 ms | 14 ms | 29 ms |

Long-query mean latency increased by 7.9% / 3.9% compared with the previous
x86_64 / aarch64 measurements; all unchanged candidate-quality and latency
gates passed. Each architecture passed 507 native unit tests. Package and desktop
coverage is recorded separately in [COMPATIBILITY.md](COMPATIBILITY.md).

| Architecture | Long-completion deadline | Hits | Saved keys | Mean | P95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| x86_64 | 50 ms, production | 421 | 977 | 101.776 ms | 277 ms | 640 ms |
| x86_64 | 0, accuracy | 423 | 984 | 101.482 ms | 277 ms | 604 ms |
| aarch64 | 50 ms, production | 423 | 979 | 40.853 ms | 101 ms | 338 ms |
| aarch64 | 0, accuracy | 423 | 979 | 39.775 ms | 98 ms | 326 ms |

The x86_64 production run saved two fewer keys than v0.9.0 (977 versus 979),
one below the standing 978-key floor. This measured difference was explicitly
accepted for v0.9.1 on 2026-09-29, with the original failed report retained.
Only this release's x86_64 production saved-key check has an exception; the
shared baseline, runtime deadlines, ranking policy and all other thresholds
are unchanged. Deadline-free results remain within the original allowance
against the Windows reference of 424 hits / 987 saved keys. Completion results
are therefore not claimed to be identical to v0.9.0.

Short completion remains unchanged on both architectures: 9,420 hits and
24,006 saved keys, result signature `1349AAD4C2D7416C`. Mean/P95/maximum query
latencies are 0.860/2/22 ms on x86_64 and 0.431/1/11 ms on aarch64.

## v0.9.0 Native Measurements

The full native runs on 2026-09-28 use the frozen v1.29.0 inputs listed above,
fresh product builds, the deployed 60 ms short-context inference budget and
both complete long-completion tracks. Package and desktop coverage is recorded
separately in [COMPATIBILITY.md](COMPATIBILITY.md).

| Platform | Long Top1 / 16,300 | Long Top2 / 16,300 | Short Top1, context off / 65,000 | Short Top1, context on / 65,000 | Short Top2, context on / 65,000 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Windows v1.29.0 reference | 11,997 | 12,970 | - | 61,971 | 63,568 |
| Linux x86_64 | 11,998 | 12,970 | 60,384 | 61,971 | 63,568 |
| Linux aarch64 | 11,992 | 12,969 | 60,384 | 61,975 | 63,568 |

Both architectures have short context-off Top2/Top5/Top9 of
63,212/64,549/64,670 and context-on Top5/Top9 of 64,591/64,670.
The contextual competition subset has 9,675/10,776 Top1/Top2 on x86_64 and
9,677/10,776 on aarch64 out of 11,728 cases. Matching aggregate counts do not
imply identical per-case predictions. Relative to its earlier 30 ms run, x86_64
has 92 Top1 gains and 21 losses, a net gain of 71; aarch64 target ranks are
unchanged. Model parameters and quality/latency/memory gates were not relaxed.

Production-mode query latency is measured separately from long accuracy:

| Architecture | Track | Mean | P50 | P95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: |
| x86_64 | Long sentence | 160.922 ms | 177 ms | 292 ms | 808 ms |
| x86_64 | Short, context off | 6.960 ms | 5 ms | 20 ms | 56 ms |
| x86_64 | Short, context on | 12.791 ms | 8 ms | 36 ms | 88 ms |
| aarch64 | Long sentence | 62.126 ms | 60 ms | 118 ms | 414 ms |
| aarch64 | Short, context off | 3.757 ms | 3 ms | 10 ms | 25 ms |
| aarch64 | Short, context on | 5.281 ms | 4 ms | 14 ms | 31 ms |

Full quality-process high-water marks are 990,440 KiB and 991,168 KiB respectively,
below the unchanged 1,048,576 KiB ceiling.
These are different hosts, not a controlled architecture speed comparison.

Both long-completion tracks run all 16,300 cases:

| Platform and deadline | Hits / 16,300 | Saved keys |
| --- | ---: | ---: |
| Windows v1.29.0 reference, unlimited | 424 | 987 |
| Linux x86_64, unlimited | 424 | 987 |
| Linux aarch64, unlimited | 423 | 979 |
| Linux x86_64, production 50 ms | 423 | 979 |
| Linux aarch64, production 50 ms | 423 | 979 |

The aarch64 accuracy deficit is one hit and eight saved keys, within the
nine-count allowance. Both production runs have the same deficit; the x86_64
deadline-free run matches Windows. Short completion matches on both architectures: 12,831 opportunities,
12,775 prompts, 9,420 hits, 24,006 saved keys and 1,691/1,749 stable pairs.
An independent replay of the original Windows v1.29.0 runner confirms the
updated exact signature `1349AAD4C2D7416C`; historical signatures were retained.

Production completion total mean/P50/P95/maximum is 88.632/46/244/576 ms on
x86_64 and 36.767/31/90/319 ms on aarch64, including final-candidate work.
Short completion measures 0.806/1/2/18 ms and 0.433/0/1/12 ms respectively.

Both rebuilt core suites pass 491 tests. With native model initialization held,
first-key/maximum latency is 20.545/45.068 ms on x86_64 and 13.609/45.690 ms on
aarch64. Separate process-cold trials measure 32.554/100.270 ms and
20.441/74.212 ms. OS caches were not dropped; these key timings exclude service
startup, measured separately at about 2.29 s and 1.41 s. Ordinary input therefore
does not wait for model initialization, but service launch is not instantaneous.

## Historical v1.27.0 Qualification

Native qualification on 2026-09-17/18 uses freshly imported v1.27.0
dictionaries and the unchanged frozen cases. The results below are from the
complete quality and completion runs, not extrapolated samples. Package and
desktop coverage is recorded separately in [COMPATIBILITY.md](COMPATIBILITY.md).

| Platform | Long Top1 / 16,300 | Long Top2 / 16,300 | Short Top1, context off / 65,000 | Short Top1, context on / 65,000 |
| --- | ---: | ---: | ---: | ---: |
| Windows v1.27.0 reference | 11,978 | 12,955 | 60,378 | 61,860 |
| Linux x86_64 | 11,979 | 12,954 | 60,378 | 61,860 |
| Linux aarch64 | 11,975 | 12,954 | 60,378 | 61,860 |

Short context-off Top2/Top5/Top9 are 63,194/64,531/64,652; context-on counts
are 63,549/64,573/64,652 on both architectures. The contextual competition
subset is 9,596 Top1 and 10,775 Top2 out of 11,728. Both short failure traces
have 7,762 rows and SHA-256
`75ff9950bbd354d1b4a75885046041234b5e5deb43ff0a753e51f482dcb2d43e`.
Only one case's target rank changes from 3 to 4 in each context mode compared
with v1.26.1, due to a newly added lexicon entry. A native Windows v1.27.0
replay independently confirms it; the aggregate short scores do not change.

Production-mode query latency is measured separately from long accuracy:

| Architecture | Track | Mean | P50 | P95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: |
| x86_64 | Long sentence | 195.313 ms | 206 ms | 347 ms | 1,224 ms |
| x86_64 | Short, context off | 10.664 ms | 8 ms | 27 ms | 69 ms |
| x86_64 | Short, context on | 11.819 ms | 9 ms | 29 ms | 73 ms |
| aarch64 | Long sentence | 80.641 ms | 75 ms | 146 ms | 586 ms |
| aarch64 | Short, context off | 5.978 ms | 5 ms | 14 ms | 37 ms |
| aarch64 | Short, context on | 6.552 ms | 5 ms | 16 ms | 36 ms |

Quality-process peak HWM is 928,340 KiB on x86_64 and 921,980 KiB on aarch64,
below the retained 1,048,576 KiB ceiling. These host-specific timings are not
a controlled cross-architecture speed comparison.

Long predictive completion runs all 16,300 cases in each track:

| Platform and deadline | Predictive prompts | Hits | Saved keys | Stable / comparable pairs |
| --- | ---: | ---: | ---: | ---: |
| Windows v1.27.0 reference, unlimited | 6,769 | 425 | 987 | - |
| Linux x86_64, unlimited | 6,770 | 425 | 987 | 27 / 768 |
| Linux aarch64, unlimited | 6,772 | 425 | 981 | 27 / 770 |
| Linux x86_64, production 50 ms | 6,758 | 425 | 987 | 27 / 767 |
| Linux aarch64, production 50 ms | 6,770 | 425 | 982 | 27 / 770 |

Both architectures match the Windows hit count. The aarch64 saved-key loss is
six without the deadline and five in production, within the nine-key allowance.
Production decode/final-candidate/visible-completion total mean/P50/P95/maximum
is 116.358/76/286/873 ms on x86_64 and 48.713/43/107/496 ms on aarch64.
The separately checked decoding-plus-visible-completion mean is 29.758 ms and
18.899 ms respectively; neither its budgets nor the final-candidate budgets
were relaxed.

The separate 65,000-case short-completion track matches on both architectures:
12,831 opportunities, 12,775 prompts, 9,420 hits, 24,006 saved keys and
1,691 stable pairs out of 1,749. Its exact signature remains
`0F85F09476081967`. Mean/P50/P95/maximum is 1.342/1/3/20 ms on x86_64 and
0.698/1/2/11 ms on aarch64.

Targeted incremental candidate checks use fixed search work in both static
and fully initialized neural modes, so model startup scheduling does not decide
a strict rank assertion. Production IPC, blocked-model cold start and
wall-clock latency are tested separately; this does not change runtime limits.

The new `predictive_continuations_v1` completion scope excludes exact-tail
conversion from predictive prompts, hits, misses and saved keys. It records all
displayed hints and exact-tail prefix matches separately. Conversion acceptance
is still tested, including full syllable alignment and no automatic learning.
The accuracy and production tracks use the same classification. Old completion
coverage figures must not be treated as measurements under this new protocol.

The separate deterministic 500-case request-only neural check has 380 requests,
170 accepted results, 123 applied/visible completions, 12 hits, 18 saved keys
and signature `528E47C7FFCA2EE3`. Its changed v1.27.0 signature was independently
reproduced by an unmodified Windows engine: all 500 query, request-path and
completion records match ARM64. This check does not resolve the final candidate
list, so it must not be confused with the complete completion benchmark above.

## Historical v1.26.1 Qualification

The first qualification below predates the aarch64 signed-score correction.
It is retained as diagnostic evidence, not as the final v0.8.0 acceptance.
FPC 3.2.2 on aarch64 miscompiles ordered comparisons against the minimum
32-bit integer, causing reachable subspan scores to be treated as unreachable.
Equivalent sentinel equality checks correct this without changing weights,
models or search limits. A focused engine regression fails before the fix
on aarch64 and passes afterwards; x86_64 passes both versions. The correction
is retained in the v1.27.0 port; the historical figures below do not replace its
new quality and completion runs.

### First Qualification, Before The Score Correction

Native qualification on 2026-09-16 used the v1.26.1 models and dictionaries
(213,359 simplified and 216,574 traditional entries), with unchanged frozen
cases. The published Windows reference is
retained as published, not replaced with a Linux-specific target:

| Platform | Long Top1 / 16,300 | Long Top2 / 16,300 | Short Top1, context off / 65,000 | Short Top1, context on / 65,000 |
| --- | ---: | ---: | ---: | ---: |
| Windows v1.26.1 reference | 11,974 | 12,947 | 60,378 | 61,860 |
| Linux x86_64 | 11,978 | 12,953 | 60,378 | 61,860 |
| Linux aarch64 | 11,973 | 12,956 | 60,378 | 61,860 |

Both complete short tracks preserve the target ranks and first-candidate
failure signature: 7,762 rows, SHA-256
`532743c51052f0fe2fb7b66ea6bc50a8a84f6db025a06fb514cb7cc3b85fa4a4`.
Context-off Top2/Top5/Top9 are 63,194/64,531/64,652; context-on counts are
63,549/64,573/64,652. The context-on competition subset remains
9,596 Top1 and 10,775 Top2 out of 11,728. Long Top5 and Top9 equal Top2.
These aggregate long results do not imply case-by-case identity across CPUs.

Production-mode query latency is measured separately from long accuracy:

| Architecture | Track | Mean | P50 | P95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: |
| x86_64 | Long sentence | 196.973 ms | 210 ms | 346 ms | 1,075 ms |
| x86_64 | Short, context off | 10.702 ms | 8 ms | 27 ms | 68 ms |
| x86_64 | Short, context on | 11.823 ms | 9 ms | 29 ms | 69 ms |
| aarch64 | Long sentence | 90.257 ms | 84 ms | 166 ms | 672 ms |
| aarch64 | Short, context off | 6.787 ms | 5 ms | 16 ms | 42 ms |
| aarch64 | Short, context on | 7.447 ms | 6 ms | 18 ms | 42 ms |

The quality-process peak HWM is 927,692 KiB on x86_64 and 958,052 KiB on
aarch64, below the retained 1,048,576 KiB ceiling. Different host timings must
not be interpreted as a compiler speed comparison.

Full long completion, with 16,300 cases in each track:

| Platform and completion deadline | Prompts | Hits | Saved keys | Stable / eligible pairs |
| --- | ---: | ---: | ---: | ---: |
| Windows v1.26.1 reference, no deadline | 6,488 | 410 | 967 | - |
| Linux x86_64, no deadline | 6,489 | 409 | 959 | 27 / 741 |
| Linux aarch64, no deadline | 6,491 | 413 | 953 | 25 / 739 |
| Linux x86_64, production 50 ms | 6,484 | 410 | 967 | 27 / 739 |
| Linux aarch64, production 50 ms | 6,490 | 413 | 953 | 25 / 739 |

The aarch64 result has three more correct completions but saves 14 fewer keys
than Windows. These are different metrics: a correct continuation may complete
a shorter suffix. This difference exceeds the default nine-key comparison
allowance; it is not hidden by the higher hit count or by the production gate.
In this first run, deadline 0 had not yet been propagated to the upstream
local-repair stage; the corrected accuracy protocol above applies to the rerun.
The x86_64 deadline-free result is one hit and eight keys lower. Timed and
deadline-free runs can also diverge through result acceptance and cache state.
Total production mean/P95/maximum, including decoding, final candidates and
visible completion, is 111.375/282/847 ms on x86_64 and 54.785/122/580 ms on
aarch64. Neither inference deadlines nor latency budgets were relaxed.

Short completion matches on both architectures: 9,420 hits, 12,775 prompts,
24,006 saved keys, 1,691/1,749 stable pairs and signature `0F85F09476081967`.
Its mean/P95/maximum is 1.255/3/22 ms on x86_64 and 0.791/2/15 ms on aarch64.
The previously published Windows short-completion table records 9,419 hits;
the same-input replay records 9,420, as in the earlier baseline comparison.

With model initialization held, first/max key times are 28.447/76.673 ms on
x86_64 and 11.185/53.597 ms on aarch64. Separate process-cold trials measure
17.865/79.160 ms and 18.601/48.208 ms. Service startup is separate, approximately
2.5 s and 1.6 s; OS file caches were not dropped. The eight-context, 8,300-key
transport checks show post-warmup RSS growth of 8 KiB and 0 KiB respectively,
with restart recovery passing. Both native suites pass 384 unit tests and the
five-stage IBus/Fcitx framework matrix. Package and visual application checks
are reported separately in [COMPATIBILITY.md](COMPATIBILITY.md).

## Historical v1.25.0 Port Results

Qualification on 2026-09-10/11 uses the exact v1.25.0 sources, models,
the v1.25.0 dictionaries and unchanged frozen corpora. These are historical
v0.7.0 measurements, not results for the current v0.8.0 input hashes. The
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

Per-case diagnostic reports are recorded after each sample's timed work.
They record the static and final
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

All eight model sessions avoid retaining peak-sized CPU arenas. Free glibc pages
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
syllable protocol as Windows and includes both static and neural completion.

The measurement applies the same 40 ms local-result acceptance limit as the
production host and the Windows benchmark. It performs the same post-sample,
read-only oracle pass as the
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
The deterministic neural check disables both neural wall-clock cutoffs, isolates
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

Release qualification combines source/data parity, native unit and integration
tests, the IBus/Fcitx 5 platform matrix, corpus-scale quality and latency
measurements, and package checks. Results are retained with the package
checksums for each release.

The x86_64 and aarch64 acceptance baselines are release floors, not targets to
train against. They require complete case counts, bounded mean/P95/maximum
latency and peak memory, aggregate long- and short-word rank floors, and
bounded full-corpus completion quality and latency. The v2.0.0 comparison
allows at most nine fewer reference hits or saved keys for the corresponding
metrics, rather than assuming cross-architecture bitwise identity. Full traces
are retained and independently recounted. Exact failure and 500-case completion
signatures quoted in historical sections apply to those releases, not as a
substitute for the current full-corpus tracks. Updating a baseline requires a
new frozen corpus, reviewed engine
baseline, or documented runtime change; a regression must not be hidden by
lowering the thresholds.

## Interpretation

The benchmark measures synchronous engine query time, not key delivery,
candidate-window painting, desktop compositor latency, or network inference.
It intentionally uses no persistent user dictionary. Real user learning can
improve personal rankings and is validated separately by service and adapter
tests.
