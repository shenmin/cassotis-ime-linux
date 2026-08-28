program cassotis_engine;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

uses
{$IFDEF UNIX}
    cthreads,
    cwstring,
{$ENDIF}
    SysUtils,
    nc_version,
    nc_types,
    nc_config,
    nc_engine_service,
    nc_pinyin_parser,
    nc_shuangpin_decoder,
    nc_fuzzy_pinyin,
    nc_dictionary_reader
{$IFDEF UNIX}
    , nc_unix_socket_server
{$ENDIF}
    ;

function default_socket_path: string;
var
    runtime_directory: string;
begin
    runtime_directory := GetEnvironmentVariable('XDG_RUNTIME_DIR');
    if runtime_directory = '' then
        Exit('');
    Result := IncludeTrailingPathDelimiter(runtime_directory) +
        'cassotis-ime' + PathDelim + 'engine.sock';
end;

procedure run_server(const dictionary_path: string;
    const traditional_dictionary_path: string;
    const user_dictionary_path: string; const socket_path: string);
{$IFDEF UNIX}
var
    service: TncEngineService;
    server: TncUnixSocketServer;
begin
    if dictionary_path = '' then
    begin
        WriteLn(StdErr, 'dictionary path is not configured');
        Halt(2);
    end;
    if socket_path = '' then
    begin
        WriteLn(StdErr, 'XDG_RUNTIME_DIR is unavailable and --socket was not set');
        Halt(2);
    end;
    service := TncEngineService.Create(dictionary_path,
        traditional_dictionary_path, user_dictionary_path);
    try
        if not service.DictionaryReady then
        begin
            WriteLn(StdErr, 'dictionary open failed: ', service.DictionaryError);
            Halt(1);
        end;
        server := TncUnixSocketServer.Create(socket_path, service);
        try
            server.Run;
        finally
            server.Free;
        end;
    finally
        service.Free;
    end;
end;
{$ELSE}
begin
    WriteLn(StdErr, '--serve is only available on Unix platforms');
    Halt(2);
end;
{$ENDIF}

function run_self_test: Boolean;
var
    service: TncEngineService;
begin
    service := TncEngineService.Create;
    try
        Result := service.CreateContext(1) and
            (service.ContextCount = 1) and
            service.SetActive(1, True, 1) and
            service.SetSurrounding(1, 'test', 4, 2) and
            service.ResetContext(1, 3) and
            service.DestroyContext(1) and
            (service.ContextCount = 0);
    finally
        service.Free;
    end;
end;

procedure run_parse(const input_text: string);
var
    parser: TncPinyinParser;
    result_data: TncPinyinParseResult;
    index: Integer;
begin
    parser := TncPinyinParser.Create;
    try
        result_data := parser.Parse(input_text);
        for index := 0 to High(result_data) do
            WriteLn(result_data[index].start_index, ':',
                result_data[index].length, ':', result_data[index].text);
    finally
        parser.Free;
    end;
end;

function try_parse_shuangpin_scheme(const value: string;
    out scheme: TncPinyinInputScheme): Boolean;
var
    normalized: string;
begin
    normalized := LowerCase(Trim(value));
    Result := True;
    if normalized = 'microsoft' then
        scheme := pis_microsoft_shuangpin
    else if normalized = 'xiaohe' then
        scheme := pis_xiaohe_shuangpin
    else if normalized = 'ziranma' then
        scheme := pis_ziranma_shuangpin
    else if normalized = 'sogou' then
        scheme := pis_sogou_shuangpin
    else if normalized = 'ziguang' then
        scheme := pis_ziguang_shuangpin
    else if normalized = 'pinyinjiajia' then
        scheme := pis_pinyinjiajia_shuangpin
    else
        Result := False;
end;

procedure run_decode_shuangpin(const scheme_name: string;
    const input_text: string);
var
    scheme: TncPinyinInputScheme;
    decoded: TncShuangpinDecodeResult;
    index: Integer;
begin
    if not try_parse_shuangpin_scheme(scheme_name, scheme) then
    begin
        WriteLn(StdErr, 'unknown shuangpin scheme: ', scheme_name);
        Halt(2);
    end;
    decoded := nc_decode_shuangpin(scheme, input_text);
    WriteLn('raw=', decoded.raw_text);
    WriteLn('canonical=', decoded.canonical_text);
    WriteLn('compact=', decoded.compact_pinyin);
    WriteLn('valid=', Ord(decoded.valid));
    WriteLn('pending=', Ord(decoded.has_pending_key));
    for index := 0 to High(decoded.units) do
        WriteLn('unit=', index, ':', decoded.units[index].raw_start, ':',
            decoded.units[index].raw_length, ':',
            decoded.units[index].raw_text, ':', decoded.units[index].pinyin,
            ':', Ord(decoded.units[index].complete), ':',
            Ord(decoded.units[index].force_boundary_before));
end;

function fuzzy_rule_names(const rules: TncFuzzyPinyinRules): string;
var
    rule: TncFuzzyPinyinRule;
begin
    Result := '';
    for rule := Low(TncFuzzyPinyinRule) to High(TncFuzzyPinyinRule) do
    begin
        if not (rule in rules) then
            Continue;
        if Result <> '' then
            Result := Result + ',';
        Result := Result + nc_fuzzy_pinyin_rule_name(rule);
    end;
end;

procedure run_fuzzy(const input_text: string);
var
    variants: TncFuzzyPinyinQueryVariants;
    index: Integer;
begin
    variants := nc_build_fuzzy_query_variants(input_text,
        nc_all_fuzzy_pinyin_rules, 4, 32, 8);
    for index := 0 to High(variants) do
        WriteLn(variants[index].cost, ':', variants[index].text, ':',
            fuzzy_rule_names(variants[index].rules));
end;

procedure run_dictionary_query(const database_path: string;
    const pinyin: string; const maximum_count: Integer);
var
    reader: TncDictionaryReader;
    entries: TncRawDictionaryEntries;
    index: Integer;
begin
    reader := TncDictionaryReader.Create(database_path);
    try
        if not reader.Open then
        begin
            WriteLn(StdErr, 'dictionary open failed: ', reader.ErrorMessage);
            Halt(1);
        end;
        if not reader.QueryExact(pinyin, maximum_count, entries) then
        begin
            WriteLn(StdErr, 'dictionary query failed: ', reader.ErrorMessage);
            Halt(1);
        end;
        WriteLn('schema=', reader.SchemaVersion);
        for index := 0 to High(entries) do
            WriteLn(entries[index].weight, #9, entries[index].text, #9,
                entries[index].pinyin, #9, entries[index].comment);
    finally
        reader.Free;
    end;
end;

procedure run_candidate_query(const database_path: string;
    const input_text: string; const maximum_count: Integer);
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    key_event: TncKeyEvent;
    input_index: Integer;
    candidate_index: Integer;
    output_count: Integer;
begin
    service := TncEngineService.Create(database_path);
    try
        if not service.DictionaryReady then
        begin
            WriteLn(StdErr, 'dictionary open failed: ', service.DictionaryError);
            Halt(1);
        end;
        if not service.CreateContext(1) then
        begin
            WriteLn(StdErr, 'unable to create diagnostic context');
            Halt(1);
        end;
        for input_index := 1 to Length(input_text) do
        begin
            key_event.text := input_text[input_index];
            key_event.special_key := sk_none;
            key_event.modifiers := [];
            key_event.scan_code := 0;
            key_event.is_release := False;
            key_event.is_repeat := False;
            key_event.timestamp_ms := input_index;
            engine_result := service.ProcessKey(1, input_index, key_event);
            if engine_result.error_code <> 0 then
            begin
                WriteLn(StdErr, 'candidate query failed: ',
                    engine_result.error_text);
                Halt(1);
            end;
        end;
        WriteLn('query=', engine_result.query_text);
        output_count := Length(engine_result.candidates);
        if (maximum_count > 0) and (output_count > maximum_count) then
            output_count := maximum_count;
        for candidate_index := 0 to output_count - 1 do
            WriteLn(candidate_index + 1, #9,
                engine_result.candidates[candidate_index].score, #9,
                engine_result.candidates[candidate_index].text, #9,
                engine_result.candidates[candidate_index].comment);
    finally
        service.Free;
    end;
end;

function parse_integer_or_zero(const value: string): Integer;
var
    parse_error: Integer;
begin
    Val(value, Result, parse_error);
    if parse_error <> 0 then
        Result := 0;
end;

procedure print_usage;
begin
    WriteLn(c_product_name, ' ', c_engine_version);
    WriteLn('Usage: cassotis-engine [--version|--self-test|--parse PINYIN]');
    WriteLn('       cassotis-engine --decode-shuangpin SCHEME CODE');
    WriteLn('       cassotis-engine --fuzzy PINYIN');
    WriteLn('       cassotis-engine --dict-query DB PINYIN [LIMIT]');
    WriteLn('       cassotis-engine --candidate-query DB INPUT [LIMIT]');
    WriteLn('       cassotis-engine --serve [--dictionary DB]');
    WriteLn('           [--dictionary-traditional DB]');
    WriteLn('           [--user-dictionary DB] [--socket PATH]');
    WriteLn('SCHEME: microsoft|xiaohe|ziranma|sogou|ziguang|pinyinjiajia');
end;

procedure parse_server_options(out dictionary_path: string;
    out traditional_dictionary_path: string;
    out user_dictionary_path: string; out socket_path: string);
var
    index: Integer;
begin
    dictionary_path := get_default_dictionary_path_simplified;
    traditional_dictionary_path := get_default_dictionary_path_traditional;
    user_dictionary_path := get_default_user_dictionary_path;
    socket_path := default_socket_path;
    index := 2;
    while index <= ParamCount do
    begin
        if (ParamStr(index) = '--dictionary') and (index < ParamCount) then
        begin
            Inc(index);
            dictionary_path := ParamStr(index);
        end
        else if (ParamStr(index) = '--dictionary-traditional') and
            (index < ParamCount) then
        begin
            Inc(index);
            traditional_dictionary_path := ParamStr(index);
        end
        else if (ParamStr(index) = '--socket') and (index < ParamCount) then
        begin
            Inc(index);
            socket_path := ParamStr(index);
        end
        else if (ParamStr(index) = '--user-dictionary') and
            (index < ParamCount) then
        begin
            Inc(index);
            user_dictionary_path := ParamStr(index);
        end
        else
        begin
            WriteLn(StdErr, 'invalid --serve option: ', ParamStr(index));
            Halt(2);
        end;
        Inc(index);
    end;
end;

var
    server_dictionary_path: string;
    server_traditional_dictionary_path: string;
    server_user_dictionary_path: string;
    server_socket_path: string;

begin
    if (ParamCount >= 1) and (ParamStr(1) = '--serve') then
    begin
        parse_server_options(server_dictionary_path,
            server_traditional_dictionary_path,
            server_user_dictionary_path, server_socket_path);
        run_server(server_dictionary_path,
            server_traditional_dictionary_path,
            server_user_dictionary_path, server_socket_path);
        Halt(0);
    end;
    if (ParamCount = 1) and (ParamStr(1) = '--version') then
    begin
        WriteLn(c_engine_version);
        Halt(0);
    end;

    if (ParamCount = 1) and (ParamStr(1) = '--self-test') then
    begin
        if run_self_test then
        begin
            WriteLn('engine self-test: ok');
            Halt(0);
        end;
        WriteLn(StdErr, 'engine self-test: failed');
        Halt(1);
    end;

    if (ParamCount = 2) and (ParamStr(1) = '--parse') then
    begin
        run_parse(ParamStr(2));
        Halt(0);
    end;

    if (ParamCount = 3) and (ParamStr(1) = '--decode-shuangpin') then
    begin
        run_decode_shuangpin(ParamStr(2), ParamStr(3));
        Halt(0);
    end;

    if (ParamCount = 2) and (ParamStr(1) = '--fuzzy') then
    begin
        run_fuzzy(ParamStr(2));
        Halt(0);
    end;

    if ((ParamCount = 3) or (ParamCount = 4)) and
        (ParamStr(1) = '--dict-query') then
    begin
        if ParamCount = 4 then
            run_dictionary_query(ParamStr(2), ParamStr(3),
                parse_integer_or_zero(ParamStr(4)))
        else
            run_dictionary_query(ParamStr(2), ParamStr(3), 16);
        Halt(0);
    end;

    if ((ParamCount = 3) or (ParamCount = 4)) and
        (ParamStr(1) = '--candidate-query') then
    begin
        if ParamCount = 4 then
            run_candidate_query(ParamStr(2), ParamStr(3),
                parse_integer_or_zero(ParamStr(4)))
        else
            run_candidate_query(ParamStr(2), ParamStr(3), 16);
        Halt(0);
    end;

    print_usage;
    Halt(2);
end.
