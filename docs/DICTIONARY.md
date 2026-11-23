# Dictionary And Ranking Boundary

Cassotis IME for Linux v2.9.0 uses the v2.9.0 releases of
[Cassotis IME](https://github.com/shenmin/cassotis-ime) and
[Cassotis Lexicon](https://github.com/shenmin/cassotis-lexicon).
The frozen releases are [v2.9.0](https://github.com/shenmin/cassotis-ime/releases/tag/v2.9.0)
(engine) and [v2.9.0](https://github.com/shenmin/cassotis-lexicon/releases/tag/v2.9.0)
(lexicon).
Base dictionaries are read-only. Learning, preferences, and completion feedback
are stored separately in a per-user SQLite database shared by IBus and Fcitx 5.

## Dictionary Compatibility

- Current schema: `24`; minimum readable schema: `18`.
- Simplified database SHA-256:
  `49e041fb320865f66a3ae79d6f19c60e6f1a9d5d90ee2e56b14cf0d43aef1865`.
- Traditional database SHA-256:
  `b2d2cd8ed808b121e5e68bb1d8268095c0e1cc7412ed1e530aa1f8b291dc28e9`.
- Simplified base: 269,924 rows, including 24,163 single-character rows and
  245,761 multi-character rows.
- Traditional base: 272,681 rows, including 24,353 single-character rows and
  248,328 multi-character rows.
- Simplified/traditional short-query promotion rows: 1,621 / 1,876.
- Simplified/traditional word-frequency rows: 207,342 / 209,226.
- Simplified/traditional conversation-frequency rows: 110,903 / 111,591.
- Simplified/traditional LM-transition rows: 904,762 / 833,694.
- Simplified/traditional completion-competition rows: 42,453 / 42,448.
- Simplified/traditional completion pair-audit rows: 4,379 / 4,379.
- Simplified long-completion recall: 103,407 rows, including 41,244 visible paths.
- Traditional long-completion recall: 98,276 rows, including 38,302 visible paths.

These are database row counts, including distinct readings of the same text,
not counts of unique words. The schema version is stored in
`meta(key = 'schema_version')`. SQLite text is UTF-8.

Older supported schemas remain readable with their available optional signals;
they do not provide the complete v2.9.0 behavior. Release dictionaries must
include nonempty short-query promotion, word-frequency and conversation-frequency tables as well as
all other required data. Staging rejects missing tables or active journals.
Promotion entries are checked against the corresponding words and base weights
so a stale promotion file cannot silently change ranking.

## Dictionary Signals

| Area | Main data |
| --- | --- |
| Lexical recall | `dict_base`, pinyin aliases, `dict_jianpin` |
| Segmented paths | Query-path priors and word transitions |
| Statistical language evidence | Forward and reverse character n-grams |
| Popularity | Text and substring popularity priors |
| Short exact input | Dictionary-backed no-context promotion, general-text and conversation word frequencies |
| One-key completion | Exact-prefix lookup, transitions, priors, competition, pair audits, and expanded long-completion recall |

Exact, alias, abbreviated-pinyin, prefix, segmented-path, and completion
queries use bounded, indexed lookups. The provider batches n-gram requests and
reuses query-local caches instead of repeatedly scanning the base dictionary.
LM-transition bonuses are fetched by query and cached with bounded query and
path counts, rather than loading every transition at startup. The short-word
ranker reads `dict_base_word_frequency`: `100 * log10(1 + occurrences)` from
general text, with zero for a missing word. This is distinct from the older
completion prior's corpus score. Counts use non-overlapping word segmentation.
Long-sentence ranking uses a non-overlapping path through those frequencies,
without counting the same characters repeatedly. Frequency queries reuse one
prepared SQLite statement, which is reset between reads and closed with its
database; reopening clears both the statement and its result cache.

The conversation table uses the same logarithmic scale and a separate prepared
statement. Without preceding text, it can preserve the leading dictionary word
when conversational evidence strongly favors it and general-text frequency and
base weight do not contradict that choice. A missing conversational count is not
treated as evidence against a word.

## Candidate Pipeline

1. Decode full pinyin or one of seven shuangpin schemes to canonical syllables,
   respecting explicit separators and supported reading aliases.
2. Recall exact and user entries, abbreviated pinyin, prefixes, stored paths,
   and dictionary-constrained sentence paths.
3. Keep short exact-input and long-sentence search distinct. Apply fixed exact
   preferences and user choices only where their matching rules permit.
4. Use one local character language model for sentence choice, short-word
   context ranking, completion, and pinyin-constrained correction. Nine compact
   generated ranking units combine its scores with the relevant lexical,
   path, or completion evidence. The previous separate neural generators,
   repair graphs, and layered residual rankers are no longer runtime assets.
5. For three-to-five-syllable input without an exact entry, score complete
   phrase drafts and correct aligned homophones with the same model. An
   explicit selection can be learned; generating a draft alone does not add
   it to the user dictionary.
6. Return the ordered candidate list and a separate one-key completion.
   Keep selection indices, paging, and committed text consistent after repair.

The model is loaded asynchronously and shared by foreground ranking and
background completion. Invalid or unavailable model data must not block
ordinary dictionary input. Background tasks are bounded and discarded when
their query or document generation is no longer current.

Source parameters, model parts, vocabulary, readings, and final dictionary
artifacts are checked for consistency. Corpus-scale behavior and measurement
definitions are documented in [BENCHMARK.md](../BENCHMARK.md) /
[BENCHMARK.CN.md](../BENCHMARK.CN.md).

## User Database

The user database records learned exact/literal candidates, aggregate usage,
query and context choices, path preferences, n-gram evidence, fuzzy choices,
and completion feedback. Writes use short transactions and WAL. Framework
contexts observe the same engine-owned state; base dictionary language models
are not invalidated by user-data updates.

The previous and last use of an exact key/word pair distinguish recent
repeated choices from lifetime frequency. Existing user databases gain the
previous-use column in place. A historical total alone is not evidence of
two recent selections.

An import retains the counts but places the last use outside the recent-choice
window and clears the previous-use timestamp. Export returns a deduplicated
list of multi-character, full-pinyin entries in the active script. Forgetting
a displayed row removes its learned spellings for that reading and associated
preferences, without changing the base tables or writing a ranking penalty.

Only candidates backed by removable persistent user data carry the deletable
flag. Ordinary base entries and unlearned generated or partially composed
candidates do not expose a delete control.

## One-Key Completion

An exact custom shortcut takes priority over predictive completion. It matches
the raw keystrokes, independent of the selected Pinyin scheme, and commits the
configured text literally without learning. These entries are settings rather
than dictionary words; see [Custom Phrases](../CONFIGURATION.md#custom-phrases).

Completion does not reorder the ordinary candidates. A complete prefix of at
least two syllables can use exact/user continuation, transitions, and bounded
long-prefix recall. The shared language model scores tail/next-word proposals
and can offer a confident continuation. Re-read typed tails must still match
the input syllables; arbitrary text generation is not accepted as a rewrite.

When a complete dictionary line has a stored next-line continuation, completion
uses that line's own continuation rather than generating a competing suffix.
Classical poetry entries also participate in prefix completion. Source and
license details are in [Lexicon Attribution](LEXICON_ATTRIBUTION.md).

The static hint remains available while a background request is pending.
Expired or stale results are discarded, and identical results do not cause
an unnecessary refresh. Completion feedback is separate from ordinary
candidate learning.

When no predictive hint exists, full-pinyin input can combine the settled
visible prefix with one exact dictionary tail. Both parts must match complete
input syllables and explicit boundaries. This fallback neither recursively
assembles a sentence nor creates a learned word or positive completion feedback.
Predictive hints carry an arrow; exact-tail conversion does not.

Tab or backtick commits the displayed completion. The settings reject a paging
shortcut that conflicts with the selected completion key.

## Runtime Paths

Base dictionaries belong to the running installation. System packages read
`/usr/share/cassotis-ime/dict_sc.db` and `dict_tc.db`; relocated installations
read `share/cassotis-ime` beneath their own prefix. Old base dictionary copies
in the user data directory do not override these files after an upgrade.

User-directory installations read the base dictionaries from
`$XDG_DATA_HOME/cassotis-ime` (default `~/.local/share/cassotis-ime`), including
when the data directory is separate from `~/.local/libexec/cassotis-ime`.
A development executable without accompanying dictionaries may also use this
user data directory, then fall back to `/usr/share/cassotis-ime`.

`CASSOTIS_DICTIONARY` and `CASSOTIS_DICTIONARY_TC` explicitly override the
simplified and traditional base paths; the engine's command-line dictionary
options take precedence over these environment variables.

The user dictionary stays at `$XDG_DATA_HOME/cassotis-ime/user_dict.db`, or at
`CASSOTIS_USER_DICTIONARY` when explicitly set. Changing the base dictionary
selection neither moves nor deletes personal data. User data is never written
into the base artifacts.

To inspect a dictionary without starting an input framework:

```bash
sqlite3 -readonly /path/to/dict_sc.db \
  "SELECT pinyin, text, weight FROM dict_base WHERE pinyin = 'shijie' ORDER BY weight DESC LIMIT 9;"
```
