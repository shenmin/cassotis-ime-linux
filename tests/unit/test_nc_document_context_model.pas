unit test_nc_document_context_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit,
    testregistry;

type
    TncDocumentContextModelTests = class(TTestCase)
    published
        procedure EmptyContextHasNoEffect;
        procedure RepeatedDocumentTermsReceiveMoreSupport;
        procedure TwoCharacterTermsGainMonotonicSupport;
        procedure PathTransitionsUseDocumentEvidence;
        procedure SwitchingDocumentsDiscardsOldTerms;
        procedure OverlappingSnapshotsPreserveOlderDocumentTerms;
        procedure RepeatedSnapshotRefreshIsIdempotent;
        procedure EmptyProtectedSnapshotClearsCachedTerms;
        procedure SlidingSnapshotsTrimStaleTerms;
        procedure DocumentCompletionReturnsOnlySeenContinuations;
        procedure DocumentCompletionDoesNotReadFutureText;
        procedure DocumentCompletionFeedbackIsDocumentScoped;
    end;

implementation

uses
    nc_document_context_model;

procedure TncDocumentContextModelTests.EmptyContextHasNoEffect;
var
    model: TncDocumentContextModel;
begin
    model := TncDocumentContextModel.Create;
    try
        AssertEquals(0, model.score_text('modeldesign'));
        AssertEquals(0, model.score_path('model'#3'design', #3));
    finally
        model.Free;
    end;
end;

procedure TncDocumentContextModelTests.RepeatedDocumentTermsReceiveMoreSupport;
var
    model: TncDocumentContextModel;
begin
    model := TncDocumentContextModel.Create;
    try
        model.set_snapshot('doc-a',
            'candidate ranking needs modeldesign and modeldesign validation');
        AssertTrue(model.score_text('modeldesign') >
            model.score_text('medicalterm'));
    finally
        model.Free;
    end;
end;

procedure TncDocumentContextModelTests.TwoCharacterTermsGainMonotonicSupport;
var
    model: TncDocumentContextModel;
    term_a: string;
    term_b: string;
    first_score: Integer;
begin
    model := TncDocumentContextModel.Create;
    try
        term_a := #$7532#$4E59;
        term_b := #$4E19#$4E01;
        model.set_snapshot('doc-a', term_a + ' ' + term_b);
        first_score := model.score_text(term_a);
        AssertTrue(first_score > 0);
        AssertEquals(first_score, model.score_text(term_b));
        model.set_snapshot('doc-a', term_a + ' ' + term_a + ' ' + term_b);
        AssertTrue(model.score_text(term_a) > first_score);
        AssertTrue(model.score_text(term_a) > model.score_text(term_b));
    finally
        model.Free;
    end;
end;

procedure TncDocumentContextModelTests.PathTransitionsUseDocumentEvidence;
var
    model: TncDocumentContextModel;
begin
    model := TncDocumentContextModel.Create;
    try
        model.set_snapshot('doc-a',
            'the engine repeatedly discusses modeldesign choices');
        AssertTrue(model.score_path('model'#3'design', #3) >
            model.score_path('model'#3'clinic', #3));
    finally
        model.Free;
    end;
end;

procedure TncDocumentContextModelTests.SwitchingDocumentsDiscardsOldTerms;
var
    model: TncDocumentContextModel;
begin
    model := TncDocumentContextModel.Create;
    try
        model.set_snapshot('doc-a', 'uniquealphauniquealpha');
        AssertTrue(model.score_text('uniquealpha') > 0);
        model.set_snapshot('doc-b', 'betadocumentonly');
        AssertEquals(0, model.score_text('uniquealpha'));
    finally
        model.Free;
    end;
end;

procedure TncDocumentContextModelTests.OverlappingSnapshotsPreserveOlderDocumentTerms;
var
    model: TncDocumentContextModel;
begin
    model := TncDocumentContextModel.Create;
    try
        model.set_snapshot('doc-a', 'projectalpha discusses renderingcache');
        model.set_snapshot('doc-a', 'discusses renderingcache and inputlatency');
        AssertTrue(model.score_text('projectalpha') > 0);
        AssertTrue(model.score_text('inputlatency') > 0);
    finally
        model.Free;
    end;
end;

procedure TncDocumentContextModelTests.RepeatedSnapshotRefreshIsIdempotent;
var
    model: TncDocumentContextModel;
    before_score: Integer;
begin
    model := TncDocumentContextModel.Create;
    try
        model.set_snapshot('doc-a', 'stableterminology appears once');
        before_score := model.score_text('stableterminology');
        model.set_snapshot('doc-a', 'stableterminology appears once');
        AssertEquals(before_score, model.score_text('stableterminology'));
    finally
        model.Free;
    end;
end;

procedure TncDocumentContextModelTests.EmptyProtectedSnapshotClearsCachedTerms;
var
    model: TncDocumentContextModel;
begin
    model := TncDocumentContextModel.Create;
    try
        model.set_snapshot('doc-a', 'stableterminology appears here');
        AssertTrue(model.score_text('stableterminology') > 0);
        model.set_snapshot('doc-a', '');
        AssertFalse(model.has_context);
        AssertEquals(0, model.score_text('stableterminology'));
    finally
        model.Free;
    end;
end;

procedure TncDocumentContextModelTests.SlidingSnapshotsTrimStaleTerms;
var
    model: TncDocumentContextModel;
    document_text: string;
    offset: Integer;
    idx: Integer;
begin
    model := TncDocumentContextModel.Create;
    try
        document_text := 'uniquealpha';
        for idx := 1 to 7000 do
            document_text := document_text + WideChar($4E00 + idx);
        model.set_snapshot('doc-a', Copy(document_text, 1, 1024));
        AssertTrue(model.score_text('uniquealpha') > 0);
        offset := 257;
        while offset + 1023 <= Length(document_text) do
        begin
            model.set_snapshot('doc-a', Copy(document_text, offset, 1024));
            Inc(offset, 256);
        end;
        AssertEquals(0, model.score_text('uniquealpha'));
    finally
        model.Free;
    end;
end;

procedure TncDocumentContextModelTests.DocumentCompletionReturnsOnlySeenContinuations;
var
    model: TncDocumentContextModel;
    results: TncDocumentContinuationList;
    idx: Integer;
    found: Boolean;
begin
    model := TncDocumentContextModel.Create;
    try
        model.set_snapshot('doc-a',
            'earlier sharedanchortargetphrase later');
        AssertTrue(model.lookup_continuations('sharedanchor', 16, results));
        found := False;
        for idx := 0 to High(results) do
            if results[idx].suffix_text = 'targetphrase' then
            begin
                found := True;
                AssertTrue(results[idx].context_width >= 4);
                Break;
            end;
        AssertTrue(found);
    finally
        model.Free;
    end;
end;

procedure TncDocumentContextModelTests.DocumentCompletionDoesNotReadFutureText;
var
    model: TncDocumentContextModel;
    results: TncDocumentContinuationList;
begin
    model := TncDocumentContextModel.Create;
    try
        model.set_snapshot('doc-a', 'sharedanchor');
        AssertFalse(model.lookup_continuations('sharedanchor', 16, results));
        AssertEquals(0, Length(results));
    finally
        model.Free;
    end;
end;

procedure TncDocumentContextModelTests.DocumentCompletionFeedbackIsDocumentScoped;
var
    model: TncDocumentContextModel;
    accepted_score: Integer;
begin
    model := TncDocumentContextModel.Create;
    try
        model.set_snapshot('doc-a', 'sharedanchortargetphrase');
        model.record_completion_feedback('sharedanchor', 'targetphrase', True);
        accepted_score := model.completion_feedback_score(
            'sharedanchor', 'targetphrase');
        AssertTrue(accepted_score > 0);
        model.set_snapshot('doc-a', 'sharedanchortargetphrase');
        AssertEquals(accepted_score, model.completion_feedback_score(
            'sharedanchor', 'targetphrase'));
        model.record_completion_feedback('sharedanchor', 'targetphrase', False);
        AssertTrue(model.completion_feedback_score(
            'sharedanchor', 'targetphrase') < accepted_score);

        model.set_snapshot('doc-b', 'otherdocumentcontent');
        AssertEquals(0, model.completion_feedback_score(
            'sharedanchor', 'targetphrase'));
    finally
        model.Free;
    end;
end;

initialization
    RegisterTest(TncDocumentContextModelTests);

end.
