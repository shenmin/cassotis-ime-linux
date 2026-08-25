program cassotis_engine;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

uses
{$IFDEF UNIX}
    cwstring,
{$ENDIF}
    SysUtils,
    nc_version,
    nc_config,
    nc_engine_service
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

procedure print_usage;
begin
    WriteLn(c_product_name, ' ', c_engine_version);
    WriteLn('       cassotis-engine --serve [--dictionary DB]');
    WriteLn('           [--dictionary-traditional DB]');
    WriteLn('           [--user-dictionary DB] [--socket PATH]');
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

    print_usage;
    Halt(2);
end.
