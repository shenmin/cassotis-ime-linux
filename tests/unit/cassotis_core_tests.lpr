program cassotis_core_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

uses
{$IFDEF UNIX}
    cthreads,
    cwstring,
{$ENDIF}
    fpcunit,
    testregistry,
    consoletestrunner,
    test_nc_ipc_protocol,
    test_nc_ipc_payload,
    test_nc_ipc_dispatcher,
    test_nc_engine_context,
    test_nc_engine_service,
    test_nc_engine_pagination,
    test_nc_pinyin_parser,
    test_nc_shuangpin_decoder,
    test_nc_fuzzy_pinyin,
    test_nc_sqlite,
    test_nc_v118_regressions,
    test_nc_dictionary_reader,
    test_nc_user_dictionary;

var
    application: TTestRunner;
begin
    DefaultFormat := fPlain;
    DefaultRunAllTests := True;
    application := TTestRunner.Create(nil);
    application.Initialize;
    application.Title := 'Cassotis IME Linux core tests';
    application.Run;
    application.Free;
end.
