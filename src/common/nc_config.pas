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

implementation

uses
    SysUtils,
    nc_shortcut;

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
begin
    Result := '';
    executable_directory := ExtractFileDir(ExpandFileName(ParamStr(0)));
    if executable_directory = '' then
        Exit;
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
    user_path := get_user_data_path(file_name);
    if (user_path <> '') and FileExists(user_path) then
        Exit(user_path);
    install_path := get_install_data_path(file_name);
    if install_path <> '' then
        Exit(install_path);
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
    Result.enable_segment_candidates := True;
    Result.segment_head_only_multi_syllable := True;
    Result.candidate_font_name := c_default_candidate_font_name;
    Result.candidate_font_size := c_default_candidate_font_size;
    Result.candidate_page_size := c_default_candidate_page_size;
    Result.candidate_page_key_scheme := cpks_minus_plus;
    Result.one_key_completion_key := ock_tab;
    Result.candidate_color_scheme := c_default_candidate_color_scheme;
    Result.dictionary_variant := dv_simplified;
    Result.shortcuts := nc_default_shortcut_config;
end;

end.
