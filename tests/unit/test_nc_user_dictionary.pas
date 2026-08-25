unit test_nc_user_dictionary;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit,
    testregistry;

type
    TncUserDictionaryTests = class(TTestCase)
    private
        FDatabasePath: string;
        procedure DeleteDatabaseFiles;
    protected
        procedure SetUp; override;
        procedure TearDown; override;
    published
        procedure SeparatesPreferenceSignalsFromUserWords;
        procedure PersistsAndRemovesUserWords;
        procedure PersistsCompleteEngineSettings;
    end;

implementation

uses
    SysUtils,
    nc_types,
    nc_user_dictionary;

procedure TncUserDictionaryTests.DeleteDatabaseFiles;
begin
    if FileExists(FDatabasePath) then
        DeleteFile(FDatabasePath);
    if FileExists(FDatabasePath + '-wal') then
        DeleteFile(FDatabasePath + '-wal');
    if FileExists(FDatabasePath + '-shm') then
        DeleteFile(FDatabasePath + '-shm');
end;

procedure TncUserDictionaryTests.SetUp;
begin
    inherited SetUp;
    FDatabasePath := IncludeTrailingPathDelimiter(
        UTF8Decode(GetTempDir(False))) + 'cassotis-user-' +
        UnicodeString(IntToStr(GetTickCount64)) + '-' +
        UnicodeString(IntToHex(PtrUInt(Self), SizeOf(Pointer) * 2)) + '.db';
    DeleteDatabaseFiles;
end;

procedure TncUserDictionaryTests.TearDown;
begin
    DeleteDatabaseFiles;
    inherited TearDown;
end;

procedure TncUserDictionaryTests.SeparatesPreferenceSignalsFromUserWords;
var
    dictionary: TncUserDictionary;
    entries: TncRawUserEntries;
    preferences: TncUserPreferences;
begin
    dictionary := TncUserDictionary.Create(FDatabasePath);
    try
        AssertTrue(dictionary.Open);
        AssertTrue(dictionary.RecordCommit('nihao',
            UnicodeString(WideChar($4F60)) + WideChar($597D), False));
        AssertTrue(dictionary.QueryUserWords('nihao', 10, entries));
        AssertEquals(0, Length(entries));
        AssertTrue(dictionary.QueryPreferences('nihao', preferences));
        AssertEquals(1, Length(preferences));
        AssertEquals(1, preferences[0].commit_count);
        AssertTrue(preferences[0].latest);
    finally
        dictionary.Free;
    end;
end;

procedure TncUserDictionaryTests.PersistsAndRemovesUserWords;
var
    dictionary: TncUserDictionary;
    entries: TncRawUserEntries;
    preferences: TncUserPreferences;
    learned_text: string;
begin
    learned_text := UnicodeString(WideChar($5F00)) + WideChar($59CB) +
        WideChar($5403) + WideChar($996D);
    dictionary := TncUserDictionary.Create(FDatabasePath);
    try
        AssertTrue(dictionary.Open);
        AssertTrue(dictionary.RecordCommit('kaishichifan', learned_text, True));
    finally
        dictionary.Free;
    end;

    dictionary := TncUserDictionary.Create(FDatabasePath);
    try
        AssertTrue(dictionary.Open);
        AssertTrue(dictionary.QueryUserWords('kaishichifan', 10, entries));
        AssertEquals(1, Length(entries));
        AssertEquals(learned_text, entries[0].text);
        AssertTrue(dictionary.RemoveUserWord('kaishichifan', learned_text));
        AssertTrue(dictionary.QueryUserWords('kaishichifan', 10, entries));
        AssertEquals(0, Length(entries));
        AssertTrue(dictionary.QueryPreferences('kaishichifan', preferences));
        AssertEquals(0, Length(preferences));
    finally
        dictionary.Free;
    end;
end;

procedure TncUserDictionaryTests.PersistsCompleteEngineSettings;
var
    dictionary: TncUserDictionary;
    source: TncEngineState;
    loaded: TncEngineState;
begin
    nc_initialize_engine_state(source);
    source.pinyin_scheme := pis_ziguang_shuangpin;
    source.dictionary_variant := dv_traditional;
    source.fuzzy_pinyin_enabled := True;
    source.fuzzy_pinyin_rules := [fpr_s_sh, fpr_in_ing];
    source.full_width_mode := True;
    source.punctuation_full_width := False;
    source.candidate_page_size := 5;
    source.candidate_page_key_scheme := cpks_shift_tab;
    source.one_key_completion_key := ock_backtick;
    source.debug_mode := True;
    source.shortcuts.input_mode_toggle.key_code := Ord('I');
    source.shortcuts.input_mode_toggle.shift_down := True;
    source.shortcuts.input_mode_toggle.ctrl_down := True;

    dictionary := TncUserDictionary.Create(FDatabasePath);
    try
        AssertTrue(dictionary.Open);
        AssertTrue(dictionary.SaveEngineState(source));
    finally
        dictionary.Free;
    end;

    dictionary := TncUserDictionary.Create(FDatabasePath);
    try
        AssertTrue(dictionary.Open);
        AssertTrue(dictionary.LoadEngineState(loaded));
        AssertTrue(nc_engine_states_equal(source, loaded));
    finally
        dictionary.Free;
    end;
end;

initialization
    RegisterTest(TncUserDictionaryTests);

end.
