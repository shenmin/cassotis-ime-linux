unit nc_pinyin_parser;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils;

type
    // Pinyin input is ASCII; offsets are zero-based positions in the original input.
    TncPinyinSyllable = record
        text: string;
        start_index: Integer;
        length: Integer;
    end;

    TncPinyinParseResult = array of TncPinyinSyllable;

    TncPinyinParser = class
    public
        function parse(const input_text: string): TncPinyinParseResult;
    end;

function nc_is_pinyin_spelling_helper_compatible(const initial_value: string;
    const final_value: string): Boolean;
function nc_is_canonical_pinyin_syllable(const value: string): Boolean;

implementation

type
    TncIntegerArray = array of Integer;
    TncStringArray = array of string;
    TncBooleanArray = array of Boolean;

const
    c_initials: array[0..22] of string = (
        'zh', 'ch', 'sh',
        'b', 'p', 'm', 'f', 'd', 't', 'n', 'l', 'g', 'k', 'h',
        'j', 'q', 'x', 'r', 'z', 'c', 's', 'y', 'w'
    );
    c_finals: array[0..35] of string = (
        'iang', 'iong', 'uang',
        'uai', 'uan', 'iao', 'ian', 'ing', 'ang', 'eng', 'ong',
        'ai', 'an', 'ao', 'ei', 'en', 'er', 'ou',
        'ia', 'ie', 'in', 'iu', 'ua', 'ui', 'un', 'uo',
        've', 'van', 'vn', 'ue',
        'a', 'e', 'i', 'o', 'u', 'v'
    );
    // Finals allowed when there is no explicit initial.
    // Keep this conservative to avoid incorrect greedy splits like:
    // "danian" -> "dan + ian" (expected "da + nian").
    c_finals_no_initial: array[0..12] of string = (
        'ang', 'eng',
        'ai', 'an', 'ao', 'ei', 'en', 'er', 'ou',
        'a', 'e', 'o', 'r'
    );

function nc_is_pinyin_spelling_helper_compatible(const initial_value: string;
    const final_value: string): Boolean;
begin
    if initial_value = 'y' then
    begin
        Exit((final_value = 'a') or (final_value = 'an') or
            (final_value = 'ang') or (final_value = 'ao') or
            (final_value = 'e') or (final_value = 'i') or
            (final_value = 'in') or (final_value = 'ing') or
            (final_value = 'o') or (final_value = 'ong') or
            (final_value = 'ou') or (final_value = 'u') or
            (final_value = 'ue') or (final_value = 'uan') or
            (final_value = 'un'));
    end;

    if initial_value = 'w' then
    begin
        Exit((final_value = 'a') or (final_value = 'ai') or
            (final_value = 'an') or (final_value = 'ang') or
            (final_value = 'ei') or (final_value = 'en') or
            (final_value = 'eng') or (final_value = 'o') or
            (final_value = 'u'));
    end;

    Result := True;
end;

function is_initial_final_compatible_common(const initial_value: string;
    const final_value: string): Boolean;
begin
    if final_value = 'er' then
    begin
        Exit(False);
    end;

    if ((initial_value = 'b') or (initial_value = 'p') or
        (initial_value = 'm') or (initial_value = 'f') or
        (initial_value = 'w')) and (Length(final_value) > 1) and
        (final_value[1] = 'u') then
    begin
        Exit(False);
    end;

    if not nc_is_pinyin_spelling_helper_compatible(initial_value,
        final_value) then
    begin
        Exit(False);
    end;

    if (initial_value = 'j') or (initial_value = 'q') or
        (initial_value = 'x') then
    begin
        if (final_value = 'ua') or (final_value = 'uai') or
            (final_value = 'uang') or (final_value = 'ui') or
            (final_value = 'uo') then
        begin
            Exit(False);
        end;
    end;

    if (initial_value = 'zh') or (initial_value = 'ch') or
        (initial_value = 'sh') or (initial_value = 'r') or
        (initial_value = 'z') or (initial_value = 'c') or
        (initial_value = 's') then
    begin
        if (final_value = 'ia') or (final_value = 'in') or
            (final_value = 'ing') or (final_value = 'iu') or
            (final_value = 'ie') or (final_value = 'ian') or
            (final_value = 'iang') or (final_value = 'iao') or
            (final_value = 'iong') or (final_value = 'ue') or
            (final_value = 've') or (final_value = 'van') or
            (final_value = 'vn') then
        begin
            Exit(False);
        end;
    end;

    if ((initial_value = 'b') or (initial_value = 'p') or
        (initial_value = 'm') or (initial_value = 'f') or
        (initial_value = 'd') or (initial_value = 't') or
        (initial_value = 'g') or (initial_value = 'k') or
        (initial_value = 'h')) and
        ((final_value = 'iang') or (final_value = 'iong')) then
    begin
        Exit(False);
    end;

    Result := True;
end;

function nc_is_canonical_pinyin_syllable(const value: string): Boolean;
var
    normalized: string;
    initial_idx: Integer;
    final_idx: Integer;
    initial_value: string;
    final_value: string;
begin
    normalized := LowerCase(Trim(value));
    if normalized = '' then
    begin
        Exit(False);
    end;

    for final_idx := Low(c_finals_no_initial) to
        High(c_finals_no_initial) do
    begin
        if normalized = c_finals_no_initial[final_idx] then
        begin
            Exit(True);
        end;
    end;

    for initial_idx := Low(c_initials) to High(c_initials) do
    begin
        initial_value := c_initials[initial_idx];
        if Copy(normalized, 1, Length(initial_value)) <> initial_value then
        begin
            Continue;
        end;
        final_value := Copy(normalized, Length(initial_value) + 1, MaxInt);
        for final_idx := Low(c_finals) to High(c_finals) do
        begin
            if (final_value = c_finals[final_idx]) and
                is_initial_final_compatible_common(initial_value,
                final_value) then
            begin
                Exit(True);
            end;
        end;
    end;

    Result := False;
end;

function TncPinyinParser.parse(const input_text: string): TncPinyinParseResult;
var
    lower_text: string;
    cursor: Integer;
    text_length: Integer;
    result_list: TncPinyinParseResult;
    memo_score: TncIntegerArray;
    memo_next: TncIntegerArray;
    memo_text: TncStringArray;
    memo_len: TncIntegerArray;
    memo_done: TncBooleanArray;

    function has_prefix(const source: string; const start_index: Integer; const value: string): Boolean;
    begin
        if value = '' then
        begin
            Exit(False);
        end;

        if start_index + Length(value) > Length(source) then
        begin
            Exit(False);
        end;

        Result := Copy(source, start_index + 1, Length(value)) = value;
    end;

    function is_initial_final_compatible(const initial_value: string; const final_value: string): Boolean;
    begin
        // "er" is a zero-initial syllable. Accepting synthetic initial+er
        // syllables (ner/ger/...) makes compact streams such as "pingwener"
        // prefer "ping+we+ner" over the intended "ping+wen+er".
        if final_value = 'er' then
        begin
            Exit(False);
        end;

        // b/p/m/f/w can take bare "u" (bu/pu/mu/fu/wu), but not medial-u
        // finals such as ue/uan/uai/uo. Without this, missing-apostrophe input
        // like "bue" is greedily parsed as invalid "bue" instead of "bu"+"e".
        if ((initial_value = 'b') or (initial_value = 'p') or
            (initial_value = 'm') or (initial_value = 'f') or
            (initial_value = 'w')) and
            (Length(final_value) > 1) and (final_value[1] = 'u') then
        begin
            Exit(False);
        end;

        // y/w are spelling helpers in pinyin, so their legal combinations are
        // much narrower than ordinary initials. Use allowlists here: accepting
        // synthetic spellings such as yian, yuai, or wuan steals compact-input
        // boundaries (for example, yu+ai becomes the invalid single unit yuai).
        if not nc_is_pinyin_spelling_helper_compatible(initial_value,
            final_value) then
        begin
            Exit(False);
        end;

        // j/q/x use u as the written form of ü only for u/ue/uan/un.
        // Other u-medial finals are invalid and otherwise steal boundaries,
        // e.g. "quangao" becomes invalid "quang"+"ao" instead of "quan"+"gao".
        if (initial_value = 'j') or (initial_value = 'q') or
            (initial_value = 'x') then
        begin
            if (final_value = 'ua') or (final_value = 'uai') or
                (final_value = 'uang') or (final_value = 'ui') or
                (final_value = 'uo') then
            begin
                Exit(False);
            end;
        end;

        // Restrict obviously invalid retroflex/alveolar combinations to avoid
        // greedy wrong splits like "zhineng" -> "zhin + eng" (expected "zhi + neng").
        if (initial_value = 'zh') or (initial_value = 'ch') or (initial_value = 'sh') or
            (initial_value = 'r') or (initial_value = 'z') or (initial_value = 'c') or
            (initial_value = 's') then
        begin
            if (final_value = 'ia') or (final_value = 'in') or (final_value = 'ing') or (final_value = 'iu') or
                (final_value = 'ie') or (final_value = 'ian') or (final_value = 'iang') or
                (final_value = 'iao') or (final_value = 'iong') or
                (final_value = 'ue') or (final_value = 've') or (final_value = 'van') or
                (final_value = 'vn') then
            begin
                Exit(False);
            end;
        end;

        // These initials do not form standard iang/iong syllables. Allowing
        // synthetic forms like "diang" makes compact streams such as
        // "dian+geng" tie with the wrong "diang+eng" parse.
        if ((initial_value = 'b') or (initial_value = 'p') or
            (initial_value = 'm') or (initial_value = 'f') or
            (initial_value = 'd') or (initial_value = 't') or
            (initial_value = 'g') or (initial_value = 'k') or
            (initial_value = 'h')) and
            ((final_value = 'iang') or (final_value = 'iong')) then
        begin
            Exit(False);
        end;

        Result := True;
    end;

    procedure append_syllable(const text: string; const start_index: Integer; const len: Integer);
    var
        idx: Integer;
    begin
        idx := Length(result_list);
        SetLength(result_list, idx + 1);
        result_list[idx].text := text;
        result_list[idx].start_index := start_index;
        result_list[idx].length := len;
    end;

    function solve(const start_index: Integer): Integer;
    var
        best_score: Integer;
        best_next: Integer;
        best_text: string;
        best_len: Integer;
        score_value: Integer;
        next_index: Integer;
        initial_idx: Integer;
        final_idx: Integer;
        initial_value: string;
        final_value: string;
        token_text: string;
        token_len: Integer;

        function get_no_initial_penalty(const final_token: string; const token_start: Integer): Integer;
        begin
            // In the middle of a raw pinyin stream, no-initial syllables are often
            // artifacts of greedy over-merge (e.g. "sange" -> "sang"+"e").
            // Keep them possible, but score them lower so regular initial+final
            // paths win unless no better parse exists.
            if token_start <= 0 then
            begin
                Exit(0);
            end;
            if (token_start > 0) and (lower_text[token_start] = '''') then
            begin
                Exit(0);
            end;

            if (final_token = 'a') or (final_token = 'e') or (final_token = 'o') then
            begin
                Exit(160);
            end;
            if final_token = 'er' then
            begin
                Exit(100);
            end;
            if final_token = 'r' then
            begin
                // Compact erhua input such as "nar" and "yihuir" leaves a
                // trailing r after the base syllable. Treat it as a costly but
                // valid boundary marker instead of an unknown character.
                // Do not let it steal canonical er in inputs like "dierge" or
                // "eryan", where greedy "die+r"/"due+r" breaks normal words.
                if (token_start > 0) and (lower_text[token_start] = 'e') then
                begin
                    Exit(1200);
                end;
                Exit(80);
            end;

            // Multi-letter zero-initial finals (ao/an/ou/...) often occur after
            // n/ng without an apostrophe in real input, e.g. beijing+aoyun.
            // Keep the heavy penalty only for bare a/e/o; otherwise the parser
            // prefers jin+gao over jing+ao and poisons long-sentence paths.
            Result := 20;
        end;
    begin
        if start_index >= text_length then
        begin
            Result := 0;
            Exit;
        end;

        if memo_done[start_index] then
        begin
            Result := memo_score[start_index];
            Exit;
        end;

        // Apostrophe is an explicit boundary marker and should be skipped.
        if lower_text[start_index + 1] = '''' then
        begin
            memo_done[start_index] := True;
            memo_text[start_index] := '';
            memo_len[start_index] := 0;
            memo_next[start_index] := start_index + 1;
            memo_score[start_index] := solve(start_index + 1);
            Result := memo_score[start_index];
            Exit;
        end;

        best_score := Low(Integer) div 2;
        best_next := start_index + 1;
        best_text := Copy(lower_text, start_index + 1, 1);
        best_len := 1;

        // Try all "initial + final" syllables.
        for initial_idx := Low(c_initials) to High(c_initials) do
        begin
            initial_value := c_initials[initial_idx];
            if not has_prefix(lower_text, start_index, initial_value) then
            begin
                Continue;
            end;

            for final_idx := Low(c_finals) to High(c_finals) do
            begin
                final_value := c_finals[final_idx];
                if not is_initial_final_compatible(initial_value, final_value) then
                begin
                    Continue;
                end;
                if not has_prefix(lower_text, start_index + Length(initial_value), final_value) then
                begin
                    Continue;
                end;

                token_text := initial_value + final_value;
                token_len := Length(token_text);
                next_index := start_index + token_len;
                score_value := solve(next_index) + (token_len * token_len * 10);
                if score_value > best_score then
                begin
                    best_score := score_value;
                    best_next := next_index;
                    best_text := token_text;
                    best_len := token_len;
                end;
            end;
        end;

        // Try no-initial finals.
        for final_idx := Low(c_finals_no_initial) to High(c_finals_no_initial) do
        begin
            final_value := c_finals_no_initial[final_idx];
            if not has_prefix(lower_text, start_index, final_value) then
            begin
                Continue;
            end;

            token_text := final_value;
            token_len := Length(token_text);
            next_index := start_index + token_len;
            score_value := solve(next_index) + (token_len * token_len * 10) -
                get_no_initial_penalty(final_value, start_index);
            if score_value > best_score then
            begin
                best_score := score_value;
                best_next := next_index;
                best_text := token_text;
                best_len := token_len;
            end;
        end;

        // Fallback: consume one character as an unknown token.
        score_value := solve(start_index + 1) - 1000;
        if score_value > best_score then
        begin
            best_score := score_value;
            best_next := start_index + 1;
            best_text := Copy(lower_text, start_index + 1, 1);
            best_len := 1;
        end;

        memo_done[start_index] := True;
        memo_score[start_index] := best_score;
        memo_next[start_index] := best_next;
        memo_text[start_index] := best_text;
        memo_len[start_index] := best_len;
        Result := best_score;
    end;
begin
    memo_score := nil;
    memo_next := nil;
    memo_text := nil;
    memo_len := nil;
    memo_done := nil;
    SetLength(result_list, 0);
    if input_text = '' then
    begin
        Result := result_list;
        Exit;
    end;

    lower_text := LowerCase(input_text);
    cursor := 0;
    text_length := Length(lower_text);

    SetLength(memo_score, text_length + 1);
    SetLength(memo_next, text_length + 1);
    SetLength(memo_text, text_length + 1);
    SetLength(memo_len, text_length + 1);
    SetLength(memo_done, text_length + 1);
    solve(0);

    while cursor < text_length do
    begin
        if lower_text[cursor + 1] = '''' then
        begin
            Inc(cursor);
            Continue;
        end;

        if (not memo_done[cursor]) or (memo_next[cursor] <= cursor) or (memo_len[cursor] <= 0) or
            (memo_text[cursor] = '') then
        begin
            append_syllable(Copy(lower_text, cursor + 1, 1), cursor, 1);
            Inc(cursor);
            Continue;
        end
        else
        begin
            append_syllable(memo_text[cursor], cursor, memo_len[cursor]);
            cursor := memo_next[cursor];
        end;
    end;

    Result := result_list;
end;

end.
