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
    test_nc_document_context_model,
    test_nc_local_repair,
    nc_local_repair_boundary_tests,
    test_nc_engine_service,
    test_nc_engine_pagination,
    test_nc_pinyin_parser,
    test_nc_shuangpin_decoder,
    test_nc_fuzzy_pinyin,
    test_nc_sqlite,
    test_nc_v118_regressions,
    test_nc_v119_regressions,
    test_nc_v122_regressions,
    nc_umlaut_input_tests,
    nc_ambiguous_prefix_tests,
    nc_nasal_prefix_tests,
    nc_short_prefix_length_tests,
    nc_confirmed_suffix_prefix_tests,
    nc_dictionary_reload_tests,
    nc_candidate_presentation_tests,
    nc_prefix_tier_tests,
    nc_predictive_prefix_tests,
    nc_short_compound_evidence_tests,
    nc_short_compound_context_tests,
    nc_jqx_umlaut_tests,
    nc_cold_paging_tests,
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
