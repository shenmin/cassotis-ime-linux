unit nc_config;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_types;

function get_default_dictionary_path_simplified: string;
function get_default_dictionary_path_traditional: string;
function get_default_user_dictionary_path: string;
function nc_default_engine_config: TncEngineConfig;
function nc_normalize_punctuation_ascii_symbols(const value: string): string;

implementation

uses
    SysUtils,
    {$ifdef unix}BaseUnix,{$endif}
    nc_shortcut;

function nc_normalize_punctuation_ascii_symbols(const value: string): string;
var symbol: Char;
begin
    Result := '';
    for symbol in value do
        if CharInSet(symbol, ['!'..'/', ':'..'@', '['..'`', '{'..'~']) and
            (Pos(symbol, Result) = 0) then
            Result := Result + symbol;
end;

function get_user_data_path(const file_name: string): string;
var
    data_home: string;
    home_directory: string;
begin
    data_home := GetEnvironmentVariable('XDG_DATA_HOME');
    if data_home = '' then
    begin
        home_directory := GetEnvironmentVariable('HOME');
        if home_directory <> '' then
            data_home := IncludeTrailingPathDelimiter(home_directory) +
                '.local' + PathDelim + 'share';
    end;
    if data_home = '' then
        Exit('');
    Result := IncludeTrailingPathDelimiter(data_home) + 'cassotis-ime' +
        PathDelim + file_name;
end;

function get_install_data_path(const file_name: string): string;
var
    executable_directory: string;
    candidate_path: string;
    home_directory: string;
    user_runtime_directory: string;
    is_user_install: Boolean;
    {$ifdef unix}
    executable_info, user_runtime_info: Stat;
    {$endif}
begin
    Result := '';
    candidate_path := '';
    {$ifdef linux}
    candidate_path := UTF8Decode(fpReadLink('/proc/self/exe'));
    {$endif}
    if candidate_path = '' then
        candidate_path := ExpandFileName(ParamStr(0));
    executable_directory := ExtractFileDir(candidate_path);
    if executable_directory = '' then
        Exit;

    // User installs keep their data in XDG_DATA_HOME, which may be elsewhere.
    is_user_install := False;
    home_directory := GetEnvironmentVariable('HOME');
    if home_directory <> '' then
    begin
        user_runtime_directory := ExpandFileName(IncludeTrailingPathDelimiter(
            home_directory) + '.local/libexec/cassotis-ime');
        is_user_install := executable_directory = user_runtime_directory;
        {$ifdef unix}
        if not is_user_install then
            if (fpStat(UTF8Encode(executable_directory), executable_info) = 0) and
                (fpStat(UTF8Encode(user_runtime_directory), user_runtime_info) = 0) then
                is_user_install := (executable_info.st_dev = user_runtime_info.st_dev) and
                    (executable_info.st_ino = user_runtime_info.st_ino);
        {$endif}
    end;
    if is_user_install then
    begin
        candidate_path := get_user_data_path(file_name);
        if (candidate_path <> '') and FileExists(candidate_path) then
            Result := candidate_path;
        Exit;
    end;

    candidate_path := ExpandFileName(IncludeTrailingPathDelimiter(
        executable_directory) + '..' + PathDelim + '..' + PathDelim +
        'share' + PathDelim + 'cassotis-ime' + PathDelim + file_name);
    if FileExists(candidate_path) then
        Result := candidate_path;
end;

function get_base_dictionary_path(const environment_name: string;
    const file_name: string): string;
var
    user_path: string;
    install_path: string;
begin
    Result := GetEnvironmentVariable(environment_name);
    if Result <> '' then
        Exit;
    // A package upgrade must not be shadowed by an old user-directory copy.
    install_path := get_install_data_path(file_name);
    if install_path <> '' then
        Exit(install_path);
    user_path := get_user_data_path(file_name);
    if (user_path <> '') and FileExists(user_path) then
        Exit(user_path);
    Result := '/usr/share/cassotis-ime/' + file_name;
end;

function get_default_dictionary_path_simplified: string;
begin
    Result := get_base_dictionary_path('CASSOTIS_DICTIONARY', 'dict_sc.db');
end;

function get_default_dictionary_path_traditional: string;
begin
    Result := get_base_dictionary_path('CASSOTIS_DICTIONARY_TC', 'dict_tc.db');
end;

function get_default_user_dictionary_path: string;
begin
    Result := GetEnvironmentVariable('CASSOTIS_USER_DICTIONARY');
    if Result = '' then
        Result := get_user_data_path('user_dict.db');
end;

function nc_default_engine_config: TncEngineConfig;
begin
    Result := Default(TncEngineConfig);
    Result.input_mode := im_chinese;
    Result.pinyin_input_scheme := pis_full_pinyin;
    Result.max_candidates := 100;
    Result.enable_ctrl_space_toggle := True;
    Result.enable_shift_space_full_width_toggle := True;
    Result.enable_ctrl_period_punct_toggle := True;
    Result.punctuation_full_width := True;
    Result.decimal_period_after_digit := True;
    Result.punctuation_ascii_symbols := c_markdown_punctuation_ascii_symbols;
    Result.auto_english := True;
    Result.enable_segment_candidates := True;
    Result.segment_head_only_multi_syllable := True;
    Result.candidate_font_name := c_default_candidate_font_name;
    Result.candidate_font_size := c_default_candidate_font_size;
    Result.candidate_page_size := c_default_candidate_page_size;
    Result.candidate_expand_on_paging := False;
    Result.candidate_page_key_scheme := cpks_minus_plus;
    Result.one_key_completion_key := ock_tab;
    Result.candidate_color_scheme := c_default_candidate_color_scheme;
    Result.dictionary_variant := dv_simplified;
    Result.shortcuts := nc_default_shortcut_config;
end;

end.
