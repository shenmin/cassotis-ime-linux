unit test_nc_engine_context;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit,
    testregistry,
    nc_engine_context;

type
    TncEngineContextTests = class(TTestCase)
    published
        procedure RegistryOwnsUniqueContexts;
        procedure RejectsStaleGeneration;
        procedure ResetClearsTransientState;
        procedure SurroundingCursorIsClamped;
    end;

implementation

procedure TncEngineContextTests.RegistryOwnsUniqueContexts;
var
    registry: TncEngineContextRegistry;
begin
    registry := TncEngineContextRegistry.Create;
    try
        AssertFalse(registry.Add(0));
        AssertTrue(registry.Add(42));
        AssertFalse(registry.Add(42));
        AssertEquals(1, registry.Count);
        AssertTrue(Assigned(registry.Find(42)));
        AssertTrue(registry.Remove(42));
        AssertFalse(registry.Remove(42));
        AssertEquals(0, registry.Count);
    finally
        registry.Free;
    end;
end;

procedure TncEngineContextTests.RejectsStaleGeneration;
var
    context: TncEngineContext;
begin
    context := TncEngineContext.Create(1);
    try
        AssertTrue(context.AdvanceGeneration(10));
        AssertTrue(context.AdvanceGeneration(10));
        AssertFalse(context.AdvanceGeneration(9));
        AssertEquals(10, Int64(context.Generation));
    finally
        context.Free;
    end;
end;

procedure TncEngineContextTests.ResetClearsTransientState;
var
    context: TncEngineContext;
begin
    context := TncEngineContext.Create(1);
    try
        context.Active := True;
        context.SetSurrounding('abcdef', 4);
        context.AppendComposition('nihao');
        context.Reset;
        AssertFalse(context.Active);
        AssertEquals('', context.SurroundingText);
        AssertEquals(0, context.CursorOffset);
        AssertEquals('', context.Composition);
    finally
        context.Free;
    end;
end;

procedure TncEngineContextTests.SurroundingCursorIsClamped;
var
    context: TncEngineContext;
begin
    context := TncEngineContext.Create(1);
    try
        context.SetSurrounding('abc', -1);
        AssertEquals(0, context.CursorOffset);
        context.SetSurrounding('abc', 99);
        AssertEquals(3, context.CursorOffset);
    finally
        context.Free;
    end;
end;

initialization
    RegisterTest(TncEngineContextTests);

end.
