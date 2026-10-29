# Dictionary And Ranking Boundary

Cassotis IME for Linux v2.5.0 uses the v2.5.0 releases of
[Cassotis IME](https://github.com/shenmin/cassotis-ime) and
[Cassotis Lexicon](https://github.com/shenmin/cassotis-lexicon).
The frozen releases are [v2.5.0](https://github.com/shenmin/cassotis-ime/releases/tag/v2.5.0)
(engine) and [v2.5.0](https://github.com/shenmin/cassotis-lexicon/releases/tag/v2.5.0)
(lexicon).
Base dictionaries are read-only. Learning, preferences, and completion feedback
are stored separately in a per-user SQLite database shared by IBus and Fcitx 5.

## Dictionary Compatibility

- Current schema: `24`; minimum readable schema: `18`.
- Simplified database SHA-256:
  `4b13bff070e7b006f0e592672ae30c0adadddc384c78fac595a6a6c23e9081c8`.
- Traditional database SHA-256:
  `9db30602f2a86c8fcbcc2d9b182b2fb69f168199cb4ce889f177f310ebdf07d6`.
- Simplified base: 261,149 rows, including 23,918 single-character rows and
  237,231 multi-character rows.
- Traditional base: 262,028 rows, including 24,181 single-character rows and
  237,847 multi-character rows.
- Simplified/traditional short-query promotion rows: 1,498 / 1,692.
- Simplified/traditional word-frequency rows: 199,072 / 198,640.
- Simplified/traditional LM-transition rows: 904,767 / 833,707.
- Simplified/traditional completion-competition rows: 42,453 / 42,448.
- Simplified/traditional completion pair-audit rows: 4,379 / 4,379.
- Simplified long-completion recall: 103,407 rows, including 41,244 visible paths.
- Traditional long-completion recall: 98,276 rows, including 38,302 visible paths.

These are database row counts, including distinct readings of the same text,
not counts of unique words. The schema version is stored in
`meta(key = 'schema_version')`. SQLite text is UTF-8.

Older supported schemas remain readable with their available optional signals;
they do not provide the complete v2.5.0 behavior. Release dictionaries must
include nonempty short-query promotion and word-frequency tables as well as
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
| Short exact input | Dictionary-backed no-context promotion and general-text word frequencies |
| One-key completion | Exact-prefix lookup, transitions, priors, competition, pair audits, and expanded long-completion recall |

Exact, alias, abbreviated-pinyin, prefix, segmented-path, and completion
queries use bounded, indexed lookups. The provider batches n-gram requests and
reuses query-local caches instead of repeatedly scanning the base dictionary.
LM-transition bonuses are fetched by query and cached with bounded query and
path counts, rather than loading every transition at startup. The short-word
ranker reads `dict_base_word_frequency`: `100 * log10(1 + occurrences)` from
general text, with zero for a missing word. This is distinct from the older
completion prior's corpus score.

## Candidate Pipeline

1. Decode full pinyin or one of six shuangpin schemes to canonical syllables,
   respecting explicit separators and supported reading aliases.
2. Recall exact and user entries, abbreviated pinyin, prefixes, stored paths,
   and dictionary-constrained sentence paths.
3. Keep short exact-input and long-sentence search distinct. Apply fixed exact
   preferences and user choices only where their matching rules permit.
4. Use one local character language model for sentence choice, short-word
   context ranking, completion, and pinyin-constrained correction. Seven compact
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
