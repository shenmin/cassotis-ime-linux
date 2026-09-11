unit nc_dictionary_reload_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit, testregistry, nc_port_test_support,
    nc_engine_intf,
    nc_dictionary_sqlite;

type
    TncDictionaryReloadTests = class(TTestCase)
    private
        m_root, m_base, m_user: string;
        m_engine: TncEngine;
        m_dictionary: TncSqliteDictionary;
        m_destructions: Integer;
        procedure create_engine(const deferred: Boolean = False);
        procedure write_database(const path, sql: string);
        procedure checkpoint_change(const path, sql: string);
    public
        procedure setup; override;
        procedure teardown; override;
    published
        procedure user_checkpoint_preserves_models_and_composition;
        procedure user_delete_invalidates_cached_candidates;
        procedure deferred_user_creation_does_not_load_base_models;
        procedure base_update_reloads_the_same_snapshot;
        procedure user_reload_does_not_abort_learning_transaction;
        procedure wal_user_changes_refresh_without_reopening_base;
    end;

implementation

uses
    SysUtils,
    nc_io_compat,
    nc_platform_compat,
    nc_config,
    nc_sqlite,
    nc_types,
    nc_dictionary_intf;

type
    TTrackedDictionary = class(TncSqliteDictionary)
    public
        destruction_count: PInteger;
        destructor Destroy; override;
    end;

destructor TTrackedDictionary.Destroy;
begin
    if destruction_count <> nil then
        Inc(destruction_count^);
    inherited;
end;

function nihao: string;
begin
    Result := Char($4F60) + string(Char($597D));
end;

function user_text: string;
begin
    Result := Char($62DF) + string(Char($597D));
end;

function lm_path: string;
begin
    Result := Char($4F60) + string(Char(3)) + Char($597D);
end;

function user_insert_sql: string;
begin
    Result := 'INSERT INTO dict_user(pinyin,text,weight) VALUES ' +
        '(''nihao'',' + QuotedStr(user_text) + ',1000);';
end;

procedure TncDictionaryReloadTests.write_database(const path, sql: string);
var
    connection: TncSqliteConnection;
begin
    connection := TncSqliteConnection.Create(path);
    try
        Assert.IsTrue(connection.open(SQLITE_OPEN_READWRITE));
        Assert.IsTrue(connection.exec(sql), 'Fixture SQL failed: ' + sql);
        Assert.IsTrue(connection.exec('PRAGMA wal_checkpoint(TRUNCATE);'));
    finally
        connection.Free;
    end;
end;

procedure TncDictionaryReloadTests.checkpoint_change(const path, sql: string);
var
    old_time: TDateTime;
begin
    old_time := TFile.GetLastWriteTime(path);
    // Exercise a real SQLite checkpoint, after the engine's poll interval.
    Sleep(2200);
    write_database(path, sql);
    Assert.IsTrue(TFile.GetLastWriteTime(path) <> old_time,
        'Fixture did not change the database timestamp');
end;

procedure TncDictionaryReloadTests.setup;
var
    guid: TGUID;
    seed: TncSqliteDictionary;
begin
    m_engine := nil;
    m_dictionary := nil;
    m_destructions := 0;
    CreateGUID(guid);
    m_root := TPath.Combine(TPath.GetTempPath,
        'cassotis_dictionary_reload_' + GUIDToString(guid));
    ForceDirectories(m_root);
    m_base := TPath.Combine(m_root, 'base.db');
    m_user := TPath.Combine(m_root, 'user.db');
    seed := TncSqliteDictionary.Create('', m_base, False);
    try
        Assert.IsTrue(seed.open);
    finally
        seed.Free;
    end;
    write_database(m_base,
        'INSERT INTO dict_base(pinyin,text,weight) VALUES ' +
        '(''nihao'',' + QuotedStr(nihao) + ',1000);' +
        'INSERT INTO dict_base_lm_transition(query_pinyin,path_text,weight) ' +
        'VALUES (''nihao'',' + QuotedStr(lm_path) + ',420);');
end;

procedure TncDictionaryReloadTests.teardown;
begin
    FreeAndNil(m_engine);
    m_dictionary := nil;
    if TDirectory.Exists(m_root) then
        TDirectory.Delete(m_root, True);
end;

procedure TncDictionaryReloadTests.create_engine(const deferred: Boolean);
var
    tracked: TTrackedDictionary;
begin
    tracked := TTrackedDictionary.Create(m_base, m_user, False);
    tracked.destruction_count := @m_destructions;
    m_dictionary := tracked;
    if deferred then
        Assert.IsTrue(tracked.open_deferred)
    else
        Assert.IsTrue(tracked.open);
    m_engine := TncEngine.create(nc_default_engine_config, deferred,
        False, False, tracked);
end;

procedure TncDictionaryReloadTests.user_checkpoint_preserves_models_and_composition;
var
    state: TncKeyState;
    bonus: Integer;
begin
    create_engine;
    bonus := m_dictionary.get_lm_transition_bonus('nihao', lm_path);
    Assert.IsTrue(bonus > 0);
    state := Default(TncKeyState);
    m_engine.process_key(Ord('N'), state);
    m_engine.process_key(Ord('I'), state);
    checkpoint_change(m_user, user_insert_sql);
    m_engine.reload_dictionary_if_needed;
    Assert.AreEqual(0, m_destructions,
        'User checkpoint discarded the prewarmed base provider');
    Assert.AreEqual('ni', m_engine.get_composition_text);
    Assert.IsTrue(m_dictionary.is_user_entry('nihao', user_text));
    Assert.AreEqual(bonus,
        m_dictionary.get_lm_transition_bonus('nihao', lm_path));
end;

procedure TncDictionaryReloadTests.user_delete_invalidates_cached_candidates;
var
    candidates: TncCandidateList;
    candidate: TncCandidate;
begin
    create_engine;
    write_database(m_user, user_insert_sql);
    Assert.IsTrue(m_dictionary.reload_user_dictionary);
    Assert.IsTrue(m_dictionary.is_user_entry('nihao', user_text));
    Assert.IsTrue(m_dictionary.lookup_exact_full_pinyin('nihao', candidates));
    checkpoint_change(m_user, 'DELETE FROM dict_user;');
    m_engine.reload_dictionary_if_needed;
    Assert.AreEqual(0, m_destructions);
    Assert.IsFalse(m_dictionary.is_user_entry('nihao', user_text));
    Assert.IsTrue(m_dictionary.lookup_exact_full_pinyin('nihao', candidates));
    for candidate in candidates do
        Assert.AreNotEqual(user_text, candidate.text);
end;

procedure TncDictionaryReloadTests.deferred_user_creation_does_not_load_base_models;
var
    writer: TncSqliteDictionary;
begin
    create_engine(True);
    Assert.IsFalse(TFile.Exists(m_user));
    writer := TncSqliteDictionary.Create('', m_user, False);
    try
        Assert.IsTrue(writer.open);
    finally
        writer.Free;
    end;
    write_database(m_user, user_insert_sql);
    m_engine.reload_dictionary_if_needed;
    Assert.AreEqual(0, m_destructions);
    Assert.IsTrue(m_engine.dictionary_models_deferred);
    Assert.IsTrue(m_dictionary.is_user_entry('nihao', user_text));
    Assert.AreEqual(0,
        m_dictionary.get_lm_transition_bonus('nihao', lm_path));
end;

procedure TncDictionaryReloadTests.base_update_reloads_the_same_snapshot;
var
    provider: TncDictionaryProvider;
    candidates: TncCandidateList;
begin
    create_engine;
    checkpoint_change(m_base, 'UPDATE dict_base SET weight=1200;');
    m_engine.reload_dictionary_if_needed;
    Assert.AreEqual(1, m_destructions,
        'A real base dictionary update must still reload the provider');
    provider := m_engine.detach_dictionary_provider;
    try
        Assert.IsTrue(provider is TncSqliteDictionary);
        Assert.AreEqual(m_base, TncSqliteDictionary(provider).db_path);
        Assert.AreEqual(m_user, TncSqliteDictionary(provider).user_db_path);
        Assert.IsTrue(provider.lookup_exact_full_pinyin('nihao', candidates));
        Assert.AreEqual(nihao, candidates[0].text);
        Assert.AreEqual(1200, candidates[0].dict_weight);
    finally
        provider.Free;
    end;
end;

procedure TncDictionaryReloadTests.user_reload_does_not_abort_learning_transaction;
begin
    create_engine;
    m_dictionary.begin_learning_batch;
    Assert.IsFalse(m_dictionary.reload_user_dictionary,
        'Reload must not close a connection with pending learning');
    m_dictionary.rollback_learning_batch;
    Assert.IsTrue(m_dictionary.reload_user_dictionary);
    Assert.IsTrue(m_dictionary.is_base_entry('nihao', nihao));
end;

procedure TncDictionaryReloadTests.wal_user_changes_refresh_without_reopening_base;
var
    writer: TncSqliteConnection;
begin
    create_engine;
    Assert.IsFalse(m_dictionary.is_user_entry('nihao', user_text));
    writer := TncSqliteConnection.Create(m_user);
    try
        Assert.IsTrue(writer.open(SQLITE_OPEN_READWRITE));
        Assert.IsTrue(writer.exec(user_insert_sql), 'User INSERT failed');
        Sleep(220);
        Assert.IsTrue(m_dictionary.is_user_entry('nihao', user_text),
            'Uncheckpointed changes must still invalidate user lookup caches');
        Assert.AreEqual(0, m_destructions);
    finally
        writer.Free;
    end;
end;

initialization
    RegisterTest(TncDictionaryReloadTests);

end.
