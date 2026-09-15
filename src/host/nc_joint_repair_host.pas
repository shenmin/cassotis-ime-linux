unit nc_joint_repair_host;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses nc_platform_compat, SysUtils, Generics.Collections,
    nc_dictionary_intf, nc_types, nc_local_repair_guard;

type
    TncJointRepairResult = record
        texts: TArray<string>;
        scores: TArray<Single>;
        features: TArray<Single>;
        selected: Integer;
        encoder_ms, proposal_ms, head_ms: Double;
        beam_ms, guard_ms, feature_ms: Double;
        total_ms, final_path_ms: Double;
        selected_path_valid: Boolean;
        audit_attempted: Boolean;
        audit_values: TArray<Single>;
        audited_selected: Integer;
        audit_ms: Double;
        path: TncValidatedRepairPath;
    end;
    TncJointRepairChooser = class
    public type
        TQuery = function(handle: Pointer; draft, pinyin: PInt64; count: Integer;
            logits: PSingle; readings: PInt64): Integer; cdecl;
        TScore = function(handle: Pointer; candidate: PInt64; ends, features: PSingle;
            valid: PByte; scores: PSingle): Integer; cdecl;
        TAudit = function(handle: Pointer; a, b, pinyin: PInt64; count: Integer;
            a_ends, b_ends, a_features, b_features: PSingle;
            a_score, b_score: Single; decision: PSingle): Integer; cdecl;
        TChoice = record text: string; gain: Double; end;
        TBeam = record
            text: string; score: Double; edits, spans: Integer; changed: Boolean;
        end;
        TPart = record first, finish, weight: Integer; end;
        TPlan = record valid: Boolean; score: Int64; parts: TArray<TPart>; end;
        TEntry = record found, is_user: Boolean; weight: Integer; end;
    private
        m_handle: Pointer;
        m_query: TQuery;
        m_score: TScore;
        m_audit: TAudit;
        m_dictionary: TncDictionaryProvider;
        m_vocab, m_pinyin: TDictionary<string, Integer>;
        m_inverse: TArray<string>;
        m_exact: TDictionary<string, TncCandidateList>;
        m_entries: TDictionary<string, TEntry>;
        m_segments: TDictionary<string, TPlan>;
        m_syllables: TArray<string>;
        m_score_agreement: Boolean;
        function word_weight(const first, finish: Integer; const text: string;
            out weight: Integer): Boolean;
        function entry(const query, text: string; out weight: Integer;
            out is_user: Boolean): Boolean;
        function segment(const text: string): TArray<TPart>;
    public
        constructor Create(const directory: string; const handle: Pointer;
            const query: TQuery; const score: TScore; const audit: TAudit;
            const score_agreement: Boolean = False);
        destructor Destroy; override;
        function run(const dictionary: TncDictionaryProvider;
            const draft, path, current, second: string;
            const syllables: TArray<string>): TncJointRepairResult;
    end;

function nc_joint_repair_proposal(const scores: TArray<Single>; const count: Integer;
    const score_agreement, audit_available: Boolean): Integer;

implementation

uses fpjson, jsonparser, nc_io_compat, Math,
    Generics.Defaults;

function compare_choices(constref a, b: TncJointRepairChooser.TChoice): Integer;
begin
    if a.gain > b.gain then Exit(-1);
    if a.gain < b.gain then Exit(1);
    Result := UnicodeCompareStr(a.text, b.text);
end;

function compare_beams(constref a, b: TncJointRepairChooser.TBeam): Integer;
begin
    if a.score > b.score then Exit(-1);
    if a.score < b.score then Exit(1);
    Result := UnicodeCompareStr(a.text, b.text);
end;

type
    TStopwatch = record
        class function GetTimeStamp: Int64; static;
        class function Frequency: Int64; static;
    end;

class function TStopwatch.GetTimeStamp: Int64;
begin
    QueryPerformanceCounter(Result);
end;

class function TStopwatch.Frequency: Int64;
begin
    QueryPerformanceFrequency(Result);
end;

function nc_joint_repair_proposal(const scores: TArray<Single>; const count: Integer;
    const score_agreement, audit_available: Boolean): Integer;
var slot: Integer; margin: Double;
begin
    Result := 0;
    if (count < 2) or (count > 9) or (Length(scores) < count) then Exit;
    for slot := 0 to count - 1 do
        if IsNan(scores[slot]) or IsInfinite(scores[slot]) then Exit;
    for slot := 1 to count - 1 do
        if scores[slot] > scores[Result] then Result := slot;
    margin := scores[Result];
    margin := margin - scores[0];
    // A weak positive proposal is never sufficient without the frozen audit.
    if (margin < 1.0) and not (score_agreement and audit_available and (margin > 0)) then
        Result := 0;
end;

type
    TJointCachedDictionary = class(TncDictionaryProvider)
    private type
        TExact = record found: Boolean; items: TncCandidateList; end;
    private
        m_base: TncDictionaryProvider;
        m_exact: TDictionary<string, TExact>;
        m_readings: TDictionary<string, Boolean>;
        m_lm: TDictionary<string, Integer>;
    public
        constructor Create(const base: TncDictionaryProvider);
        destructor Destroy; override;
        procedure clear;
        procedure set_base(const value: TncDictionaryProvider);
        function lookup(const pinyin: string; out results: TncCandidateList): Boolean; override;
        function lookup_isolated_exact_component(const pinyin: string;
            out results: TncCandidateList): Boolean; override;
        function single_char_matches_pinyin(const pinyin, text: string): Boolean; override;
        function get_char_lm_continuation_scores(const context: string;
            const texts: TArray<string>; out scores: TArray<Integer>): Boolean; override;
    end;

constructor TJointCachedDictionary.Create(const base: TncDictionaryProvider);
begin
    inherited Create;
    m_base := base;
    m_exact := TDictionary<string, TExact>.Create;
    m_readings := TDictionary<string, Boolean>.Create;
    m_lm := TDictionary<string, Integer>.Create;
end;

destructor TJointCachedDictionary.Destroy;
begin m_lm.Free; m_readings.Free; m_exact.Free; inherited; end;

procedure TJointCachedDictionary.set_base(const value: TncDictionaryProvider);
begin m_base := value; clear; end;

procedure TJointCachedDictionary.clear;
begin m_exact.Clear; m_readings.Clear; m_lm.Clear; end;

function TJointCachedDictionary.lookup(const pinyin: string; out results: TncCandidateList): Boolean;
begin Result := m_base.lookup(pinyin, results); end;

function TJointCachedDictionary.lookup_isolated_exact_component(const pinyin: string;
    out results: TncCandidateList): Boolean;
var entry: TExact;
begin
    if not m_exact.TryGetValue(pinyin, entry) then
    begin
        entry.found := m_base.lookup_isolated_exact_component(pinyin, entry.items);
        m_exact.Add(pinyin, entry);
    end;
    results := entry.items;
    Result := entry.found;
end;

function TJointCachedDictionary.single_char_matches_pinyin(const pinyin, text: string): Boolean;
var key: string;
begin
    key := pinyin + #0 + text;
    if not m_readings.TryGetValue(key, Result) then
    begin Result := m_base.single_char_matches_pinyin(pinyin, text); m_readings.Add(key, Result); end;
end;

function TJointCachedDictionary.get_char_lm_continuation_scores(const context: string;
    const texts: TArray<string>; out scores: TArray<Integer>): Boolean;
var missing: TArray<string>;
    values: TArray<Integer>;
    i, count: Integer;
begin
    if context <> '' then Exit(m_base.get_char_lm_continuation_scores(context, texts, scores));
    SetLength(scores, Length(texts)); SetLength(missing, Length(texts)); count := 0;
    for i := 0 to High(texts) do
        if not m_lm.TryGetValue(texts[i], scores[i]) then
        begin missing[count] := texts[i]; Inc(count); end;
    SetLength(missing, count);
    if count > 0 then
    begin
        if not m_base.get_char_lm_continuation_scores('', missing, values) or
            (Length(values) <> count) then Exit(False);
        for i := 0 to count - 1 do m_lm.AddOrSetValue(missing[i], values[i]);
        for i := 0 to High(texts) do scores[i] := m_lm[texts[i]];
    end;
    Result := True;
end;

constructor TncJointRepairChooser.Create(const directory: string;
    const handle: Pointer; const query: TQuery; const score: TScore; const audit: TAudit;
    const score_agreement: Boolean);
var vocabulary, values: TJSONObject; index, i: Integer; key: string;
begin
    inherited Create;
    m_handle := handle; m_query := query; m_score := score; m_audit := audit;
    if (handle = nil) or not Assigned(query) or not Assigned(score) or not Assigned(audit) then
        raise Exception.Create('Incomplete joint repair ABI');
    m_score_agreement := score_agreement;
    m_dictionary := TJointCachedDictionary.Create(nil);
    m_vocab := TDictionary<string, Integer>.Create;
    m_pinyin := TDictionary<string, Integer>.Create;
    m_exact := TDictionary<string, TncCandidateList>.Create;
    m_entries := TDictionary<string, TEntry>.Create;
    m_segments := TDictionary<string, TPlan>.Create;
    vocabulary := GetJSON(UTF8Encode(TncFile.ReadAllText(
        IncludeTrailingPathDelimiter(directory) + 'local_repair/vocab.json',
        TEncoding.UTF8))) as TJSONObject;
    try
        values := vocabulary.Objects['char'];
        SetLength(m_inverse, values.Count);
        for i := 0 to values.Count - 1 do
        begin
            index := values.Items[i].AsInteger;
            if (index < 0) or (index >= Length(m_inverse)) then
                raise Exception.Create('Invalid joint repair character ID');
            key := UTF8Decode(values.Names[i]);
            m_vocab.Add(key, index);
            m_inverse[index] := key;
        end;
        values := vocabulary.Objects['pinyin'];
        for i := 0 to values.Count - 1 do
            m_pinyin.Add(UTF8Decode(values.Names[i]), values.Items[i].AsInteger);
    finally vocabulary.Free; end;
end;

destructor TncJointRepairChooser.Destroy;
begin
    m_exact.Free;
    m_entries.Free;
    m_segments.Free;
    m_pinyin.Free;
    m_vocab.Free;
    m_dictionary.Free;
    inherited;
end;

function TncJointRepairChooser.word_weight(const first, finish: Integer;
    const text: string; out weight: Integer): Boolean;
var query: string;
    i: Integer;
    is_user: Boolean;
begin
    query := '';
    for i := first to finish - 1 do query := query + m_syllables[i];
    Result := entry(query, text, weight, is_user) and not is_user;
end;

function TncJointRepairChooser.entry(const query, text: string; out weight: Integer;
    out is_user: Boolean): Boolean;
var key: string;
    items: TncCandidateList;
    item: TncCandidate;
    cached: TEntry;
begin
    key := query + #0 + text;
    if m_entries.TryGetValue(key, cached) then
    begin weight := cached.weight; is_user := cached.is_user; Exit(cached.found); end;
    if not m_exact.TryGetValue(query, items) then
    begin
        m_dictionary.lookup_isolated_exact_component(query, items);
        if m_exact.Count >= 32768 then m_exact.Clear;
        m_exact.Add(query, items);
    end;
    Result := False;
    is_user := False;
    weight := Low(Integer);
    for item in items do
        if (item.text = text) and (item.comment = '') then
        begin
            Result := True;
            is_user := is_user or (item.source = cs_user);
            if item.has_dict_weight then weight := Max(weight, item.dict_weight)
            else weight := Max(weight, item.score);
        end;
    cached.found := Result; cached.weight := weight; cached.is_user := is_user;
    m_entries.Add(key, cached);
end;

function TncJointRepairChooser.segment(const text: string): TArray<TPart>;
var states: TArray<TPlan>;
    first, finish, weight, n: Integer;
    score: Int64;
    prefix: string;
begin
    Result := nil;
    SetLength(states, Length(text) + 1);
    states[0].valid := True;
    for finish := 1 to Length(text) do
    begin
        // Plans depend only on the exact text/pinyin prefix in this query.
        // Reuse unchanged prefixes across alternatives without pruning any plan.
        prefix := Copy(text, 1, finish);
        if m_segments.TryGetValue(prefix, states[finish]) then Continue;
        for first := Max(0, finish - 4) to finish - 1 do
        begin
            if not states[first].valid or
                not word_weight(first, finish, Copy(text, first + 1, finish - first), weight) then Continue;
            score := states[first].score + (finish - first - 1) * 10000 + Min(9999, Max(0, weight));
            if states[finish].valid and (score <= states[finish].score) then Continue;
            states[finish].valid := True;
            states[finish].score := score;
            states[finish].parts := Copy(states[first].parts);
            n := Length(states[finish].parts);
            SetLength(states[finish].parts, n + 1);
            states[finish].parts[n].first := first;
            states[finish].parts[n].finish := finish;
            states[finish].parts[n].weight := weight;
        end;
        m_segments.Add(prefix, states[finish]);
    end;
    if states[Length(text)].valid then Result := states[Length(text)].parts;
end;

function TncJointRepairChooser.run(const dictionary: TncDictionaryProvider;
    const draft, path, current, second: string;
    const syllables: TArray<string>): TncJointRepairResult;
var
    draft_ids, py_ids, reading_ids, candidate_ids: TArray<Int64>;
    logits, ends, feature, scores: TArray<Single>;
    valid: TArray<Byte>;
    maps: TArray<TDictionary<string, Double>>;
    options: TArray<TArray<TChoice>>;
    candidates: TDictionary<string, Double>;
    choices, ordered: TList<TChoice>;
    states, expanded: TList<TBeam>;
    texts: TList<string>;
    state, next: TBeam;
    choice: TChoice;
    part: TPart;
    parts: TArray<TPart>;
    validated: TncValidatedRepairPath;
    lm_texts: TArray<string>;
    lm_scores: TArray<Integer>;
    text, old, aligned, word: string;
    n, i, j, slot, token, edit_count, span_count, count, position, coverage, boundary_changes: Integer;
    old_score, gain, minimum, maximum, negative, weight, min_weight, sum_weight: Double;
    old_ends: TArray<Boolean>;
    changed, previous: Boolean;
    start, finish, stage, total_start: Int64;
    function elapsed(const first, last: Int64): Double;
    begin Result := (last - first) * 1000.0 / TStopwatch.Frequency; end;
    function admissible(const value: string): Boolean;
    var k, edits, spans: Integer; last, different: Boolean;
    begin
        Result := False;
        if Length(value) <> n then Exit;
        edits := 0; spans := 0; last := False;
        for k := 0 to n - 1 do
        begin
            if not maps[k].ContainsKey(value[k+1]) then Exit;
            different := value[k+1] <> draft[k+1];
            if different then Inc(edits);
            if different and not last then Inc(spans);
            last := different;
        end;
        Result := (edits <= 4) and (spans <= 2);
    end;
    procedure add_guarded(const value: string);
    var local: TncValidatedRepairPath; k: Integer; total: Double;
    begin
        local := validate_local_repair_path(m_dictionary, draft, value, path, aligned, 0.01, True, False, entry);
        if not admissible(local.text) then Exit;
        total := 0;
        for k := 0 to n - 1 do total := total + maps[k][local.text[k+1]];
        candidates.AddOrSetValue(local.text, total);
    end;
    function upper_bound(const value: string): Double;
    var k: Integer;
    begin
        Result := 0;
        for k := 0 to n - 1 do Result := Result + Max(0, maps[k][value[k+1]]);
    end;
    function below_retained_bound(const value: string): Boolean;
    var gains: TList<Double>; key: string;
    begin
        Result := False;
        if candidates.Count < 9 then Exit;
        gains := TList<Double>.Create;
        try
            for key in candidates.Keys do if key <> draft then gains.Add(candidates[key]);
            gains.Sort;
            Result := upper_bound(value) + 1E-7 < gains[gains.Count - 8];
        finally gains.Free; end;
    end;
begin
    Result := Default(TncJointRepairResult);
    total_start := TStopwatch.GetTimeStamp;
    try
    Result.texts := TArray<string>.Create(current);
    n := Length(draft);
    if (dictionary = nil) or (Length(current) <> n) or (n < 6) or (n > 40) or (Length(syllables) <> n) or
        (UnicodeStringReplace(path, #3, '', [rfReplaceAll]) <> draft) then Exit;
    m_syllables := syllables;
    SetLength(draft_ids, n); SetLength(py_ids, n);
    for i := 0 to n - 1 do
    begin
        if not m_vocab.ContainsKey(draft[i+1]) or not m_pinyin.ContainsKey(syllables[i]) then Exit;
        draft_ids[i] := m_vocab[draft[i+1]];
        py_ids[i] := m_pinyin[syllables[i]];
    end;
    SetLength(logits, n * 99); SetLength(reading_ids, n * 99);
    start := TStopwatch.GetTimeStamp;
    if m_query(m_handle, @draft_ids[0], @py_ids[0], n, @logits[0], @reading_ids[0]) <> 1 then
        Exit;
    finish := TStopwatch.GetTimeStamp;
    Result.encoder_ms := elapsed(start, finish);
    start := finish;
    // Only share evidence within this immutable query, never across user updates.
    TJointCachedDictionary(m_dictionary).set_base(dictionary);
    m_exact.Clear;
    m_entries.Clear;
    m_segments.Clear;
    SetLength(maps, n); SetLength(options, n);
    choices := TList<TChoice>.Create;
    ordered := TList<TChoice>.Create;
    states := TList<TBeam>.Create;
    expanded := TList<TBeam>.Create;
    texts := TList<string>.Create;
    candidates := TDictionary<string, Double>.Create;
    try
        aligned := nc_join_strings(#3, syllables);
        for i := 0 to n - 1 do
        begin
            maps[i] := TDictionary<string, Double>.Create;
            old := draft[i+1];
            old_score := 0;
            for j := 0 to 98 do
                if reading_ids[i * 99 + j] = draft_ids[i] then old_score := logits[i * 99 + j];
            choices.Clear;
            for j := 0 to 98 do
            begin
                token := reading_ids[i * 99 + j];
                if (token < 4) or (token >= Length(m_inverse)) or (logits[i * 99 + j] <= -9999) then Continue;
                choice.text := m_inverse[token];
                choice.gain := logits[i * 99 + j];
                choice.gain := choice.gain - old_score;
                if maps[i].ContainsKey(choice.text) then Continue;
                maps[i].Add(choice.text, choice.gain);
                choices.Add(choice);
            end;
            if not maps[i].ContainsKey(old) then Exit;
            choices.Sort(TComparer<TChoice>.Construct(compare_choices));
            SetLength(options[i], Min(4, choices.Count));
            changed := False;
            for j := 0 to High(options[i]) do
            begin options[i][j] := choices[j]; changed := changed or (choices[j].text = old); end;
            if not changed then
            begin
                count := Length(options[i]); SetLength(options[i], count + 1);
                options[i][count].text := old; options[i][count].gain := 0;
            end;
        end;
        if not admissible(current) then Exit;
        validated := validate_local_repair_path(m_dictionary, draft, current, path, aligned, 0.01, True, False, entry);
        if validated.text <> current then Exit;
        state := Default(TBeam); states.Add(state);
        for i := 0 to n - 1 do
        begin
            expanded.Clear;
            for state in states do
                for choice in options[i] do
                begin
                    next := state;
                    next.text := state.text + choice.text;
                    next.score := state.score + choice.gain;
                    next.changed := choice.text <> draft[i+1];
                    if next.changed then Inc(next.edits);
                    if next.changed and not state.changed then Inc(next.spans);
                    if (next.edits <= 4) and (next.spans <= 2) then expanded.Add(next);
                end;
            expanded.Sort(TComparer<TBeam>.Construct(compare_beams));
            states.Clear;
            for j := 0 to Min(32, expanded.Count) - 1 do states.Add(expanded[j]);
        end;
        stage := TStopwatch.GetTimeStamp;
        Result.beam_ms := elapsed(start, stage);
        candidates.Add(draft, 0);
        // A guard only reverts proposed characters. Its score cannot exceed
        // the sum of positive gains; skip only provably noncompetitive plans.
        for i := 0 to states.Count - 1 do
        begin state := states[i]; state.score := upper_bound(state.text); states[i] := state; end;
        states.Sort(TComparer<TBeam>.Construct(compare_beams));
        for state in states do
            if (state.text <> draft) and not below_retained_bound(state.text) then add_guarded(state.text);
        if admissible(second) then add_guarded(second);
        for text in candidates.Keys do
            if text <> draft then
            begin choice.text := text; choice.gain := candidates[text]; ordered.Add(choice); end;
        ordered.Sort(TComparer<TChoice>.Construct(compare_choices));
        texts.Add(current);
        if draft <> current then texts.Add(draft);
        // The Python pool is truncated before the current KEEP is prepended.
        for j := 0 to Min(8, ordered.Count) - 1 do
            if (texts.Count < 9) and (ordered[j].text <> current) then texts.Add(ordered[j].text);
        Result.texts := texts.ToArray;
        if texts.Count <= 1 then Exit;
        finish := TStopwatch.GetTimeStamp;
        Result.guard_ms := elapsed(stage, finish);
        stage := finish;
        SetLength(candidate_ids, 9 * 40); SetLength(ends, 9 * 40);
        SetLength(feature, 9 * 16); SetLength(valid, 9); SetLength(scores, 9);
        SetLength(old_ends, n);
        position := 0;
        for word in path.Split([#3], TStringSplitOptions.ExcludeEmpty) do
        begin Inc(position, Length(word)); old_ends[position-1] := True; end;
        SetLength(lm_texts, texts.Count + 1);
        lm_texts[0] := draft;
        for i := 0 to texts.Count - 1 do lm_texts[i + 1] := texts[i];
        if not m_dictionary.get_char_lm_continuation_scores('', lm_texts, lm_scores) then
            raise Exception.Create('Native LM evidence unavailable');
        for slot := 0 to 8 do
            for i := 0 to n - 1 do candidate_ids[slot * 40 + i] := draft_ids[i];
        for slot := 0 to texts.Count - 1 do
        begin
            valid[slot] := 1; text := texts[slot];
            edit_count := 0; span_count := 0; gain := 0; minimum := 1E30; maximum := -1E30; negative := 0;
            previous := False;
            for i := 0 to n - 1 do
            begin
                candidate_ids[slot * 40 + i] := m_vocab[text[i+1]];
                changed := text[i+1] <> draft[i+1];
                if changed then
                begin
                    Inc(edit_count); if not previous then Inc(span_count);
                    weight := maps[i][text[i+1]];
                    gain := gain + weight; minimum := Min(minimum, weight); maximum := Max(maximum, weight);
                    negative := negative + Min(0, weight);
                end;
                previous := changed;
            end;
            if edit_count = 0 then begin minimum := 0; maximum := 0; end;
            parts := segment(text); coverage := 0; min_weight := 1E30; sum_weight := 0;
            for part in parts do
            begin
                ends[slot * 40 + part.finish - 1] := 1;
                if part.finish - part.first > 1 then Inc(coverage, part.finish - part.first);
                weight := Ln(1.0 + Max(0, part.weight));
                min_weight := Min(min_weight, weight); sum_weight := sum_weight + weight;
            end;
            if Length(parts) = 0 then min_weight := 0;
            boundary_changes := 0;
            for i := 0 to n - 1 do if old_ends[i] <> (ends[slot * 40 + i] = 1) then Inc(boundary_changes);
            feature[slot*16] := edit_count; feature[slot*16+1] := span_count;
            feature[slot*16+2] := gain; feature[slot*16+3] := minimum; feature[slot*16+4] := maximum;
            feature[slot*16+5] := gain / Max(1, edit_count); feature[slot*16+6] := negative;
            feature[slot*16+7] := lm_scores[slot+1] - lm_scores[0];
            feature[slot*16+8] := coverage / n; feature[slot*16+9] := Length(parts);
            feature[slot*16+10] := min_weight; feature[slot*16+11] := sum_weight / Max(1, Length(parts));
            feature[slot*16+12] := Ord(text = second); feature[slot*16+13] := n;
            feature[slot*16+14] := boundary_changes; feature[slot*16+15] := gain / n;
        end;
        finish := TStopwatch.GetTimeStamp;
        Result.feature_ms := elapsed(stage, finish);
        Result.proposal_ms := elapsed(start, finish);
        start := finish;
        if m_score(m_handle, @candidate_ids[0], @ends[0], @feature[0], @valid[0], @scores[0]) <> 1 then
            raise Exception.Create('Native joint head failed');
        Result.head_ms := elapsed(start, TStopwatch.GetTimeStamp);
        Result.scores := scores;
        Result.features := feature;
        Result.selected := nc_joint_repair_proposal(scores, texts.Count,
            m_score_agreement, Assigned(m_audit));
        if Result.selected <> 0 then
        begin
            stage := TStopwatch.GetTimeStamp;
            validated := validate_local_repair_path(m_dictionary, draft,
                Result.texts[Result.selected], path, aligned, 0.01, True, True, entry);
            Result.selected_path_valid := validated.exact_path and
                (validated.text = Result.texts[Result.selected]) and
                (validated.aligned_pinyin = aligned) and
                (UnicodeStringReplace(validated.segment_path, #3, '', [rfReplaceAll]) = validated.text);
            Result.final_path_ms := elapsed(stage, TStopwatch.GetTimeStamp);
            if Result.selected_path_valid then
            begin
                Result.path := validated;
                Result.audited_selected := Result.selected;
                if Assigned(m_audit) then
                begin
                    stage := TStopwatch.GetTimeStamp;
                    Result.audit_attempted := True;
                    SetLength(Result.audit_values, 2);
                    if m_audit(m_handle, @candidate_ids[0], @candidate_ids[Result.selected*40],
                        @py_ids[0], n, @ends[0], @ends[Result.selected*40],
                        @feature[0], @feature[Result.selected*16], scores[0], scores[Result.selected],
                        @Result.audit_values[0]) <> 1 then
                        raise Exception.Create('Native bilateral audit failed');
                    // Frozen dev policy: preference >=0, no extra reliability cutoff.
                    if IsNan(Result.audit_values[0]) or IsInfinite(Result.audit_values[0]) or
                        IsNan(Result.audit_values[1]) or IsInfinite(Result.audit_values[1]) or
                        (Result.audit_values[0] < 0) then Result.audited_selected := 0;
                    Result.audit_ms := elapsed(stage, TStopwatch.GetTimeStamp);
                end;
            end;
        end;
    finally
        for i := 0 to High(maps) do maps[i].Free;
        candidates.Free; texts.Free; expanded.Free; states.Free; ordered.Free; choices.Free;
    end;
    finally
        // Include bypasses, preparation and explicit cleanup, not just ORT Run.
        TJointCachedDictionary(m_dictionary).set_base(nil);
        m_exact.Clear; m_entries.Clear; m_segments.Clear; m_syllables := nil;
        Result.total_ms := elapsed(total_start, TStopwatch.GetTimeStamp);
    end;
end;

end.
