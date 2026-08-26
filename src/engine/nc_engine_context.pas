unit nc_engine_context;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    Contnrs,
    nc_types;

type
    TncEngineContext = class
    private
        FId: QWord;
        FGeneration: QWord;
        FActive: Boolean;
        FSurroundingText: string;
        FCursorOffset: Integer;
        FComposition: string;
        FCandidates: TncCandidateList;
        FSelectedIndex: Integer;
        FCompletionText: string;
        FCompletionPinyin: string;
        FModifierShortcutPending: Boolean;
        FModifierShortcutCanceled: Boolean;
        FModifierShortcutAction: TncShortcutAction;
        FModifierShortcutKeyCode: Word;
    public
        constructor Create(const context_id: QWord);
        function AdvanceGeneration(const generation_id: QWord): Boolean;
        procedure Reset;
        procedure ClearComposition;
        procedure SetComposition(const value: string);
        procedure AppendComposition(const value: string);
        function DeleteLastCompositionCharacter: Boolean;
        procedure SetCandidates(const value: TncCandidateList);
        procedure SetCompletion(const full_pinyin: string;
            const text: string);
        procedure BeginModifierShortcut(const action: TncShortcutAction;
            const key_code: Word);
        procedure CancelModifierShortcut;
        procedure ClearModifierShortcut;
        function FinishModifierShortcut(const key_code: Word;
            out action: TncShortcutAction; out should_execute: Boolean): Boolean;
        procedure MoveSelection(const delta: Integer);
        procedure SelectCandidate(const candidate_index: Integer);
        procedure SetSurrounding(const text: string; const cursor_offset: Integer);
        property Id: QWord read FId;
        property Generation: QWord read FGeneration;
        property Active: Boolean read FActive write FActive;
        property SurroundingText: string read FSurroundingText;
        property CursorOffset: Integer read FCursorOffset;
        property Composition: string read FComposition;
        property Candidates: TncCandidateList read FCandidates;
        property SelectedIndex: Integer read FSelectedIndex;
        property CompletionText: string read FCompletionText;
        property CompletionPinyin: string read FCompletionPinyin;
        property ModifierShortcutPending: Boolean
            read FModifierShortcutPending;
        property ModifierShortcutKeyCode: Word
            read FModifierShortcutKeyCode;
    end;

    TncEngineContextRegistry = class
    private
        FItems: TObjectList;
        function FindIndex(const context_id: QWord): Integer;
    public
        constructor Create;
        destructor Destroy; override;
        function Add(const context_id: QWord): Boolean;
        function Remove(const context_id: QWord): Boolean;
        function Find(const context_id: QWord): TncEngineContext;
        procedure Clear;
        procedure ClearCompositions;
        function Count: Integer;
    end;

implementation

constructor TncEngineContext.Create(const context_id: QWord);
begin
    inherited Create;
    FId := context_id;
    FGeneration := 0;
    Reset;
end;

function TncEngineContext.AdvanceGeneration(const generation_id: QWord): Boolean;
begin
    Result := generation_id >= FGeneration;
    if Result then
        FGeneration := generation_id;
end;

procedure TncEngineContext.Reset;
begin
    FActive := False;
    FSurroundingText := '';
    FCursorOffset := 0;
    ClearModifierShortcut;
    ClearComposition;
end;

procedure TncEngineContext.ClearComposition;
begin
    FComposition := '';
    SetLength(FCandidates, 0);
    FSelectedIndex := -1;
    FCompletionText := '';
    FCompletionPinyin := '';
end;

procedure TncEngineContext.SetComposition(const value: string);
begin
    FComposition := value;
end;

procedure TncEngineContext.AppendComposition(const value: string);
begin
    FComposition := FComposition + value;
end;

function TncEngineContext.DeleteLastCompositionCharacter: Boolean;
begin
    Result := Length(FComposition) > 0;
    if Result then
        Delete(FComposition, Length(FComposition), 1);
end;

procedure TncEngineContext.SetCandidates(const value: TncCandidateList);
begin
    FCandidates := Copy(value, 0, Length(value));
    if Length(FCandidates) = 0 then
        FSelectedIndex := -1
    else if (FSelectedIndex < 0) or (FSelectedIndex >= Length(FCandidates)) then
        FSelectedIndex := 0;
end;

procedure TncEngineContext.SetCompletion(const full_pinyin: string;
    const text: string);
begin
    FCompletionPinyin := full_pinyin;
    FCompletionText := text;
end;

procedure TncEngineContext.BeginModifierShortcut(
    const action: TncShortcutAction; const key_code: Word);
begin
    FModifierShortcutPending := True;
    FModifierShortcutCanceled := False;
    FModifierShortcutAction := action;
    FModifierShortcutKeyCode := key_code;
end;

procedure TncEngineContext.CancelModifierShortcut;
begin
    if FModifierShortcutPending then
        FModifierShortcutCanceled := True;
end;

procedure TncEngineContext.ClearModifierShortcut;
begin
    FModifierShortcutPending := False;
    FModifierShortcutCanceled := False;
    FModifierShortcutAction := Low(TncShortcutAction);
    FModifierShortcutKeyCode := 0;
end;

function TncEngineContext.FinishModifierShortcut(const key_code: Word;
    out action: TncShortcutAction; out should_execute: Boolean): Boolean;
begin
    Result := FModifierShortcutPending and
        (FModifierShortcutKeyCode = key_code);
    action := FModifierShortcutAction;
    should_execute := Result and (not FModifierShortcutCanceled);
    if Result then
        ClearModifierShortcut;
end;

procedure TncEngineContext.MoveSelection(const delta: Integer);
begin
    if Length(FCandidates) = 0 then
    begin
        FSelectedIndex := -1;
        Exit;
    end;
    FSelectedIndex := (FSelectedIndex + delta) mod Length(FCandidates);
    if FSelectedIndex < 0 then
        Inc(FSelectedIndex, Length(FCandidates));
end;

procedure TncEngineContext.SelectCandidate(const candidate_index: Integer);
begin
    if Length(FCandidates) = 0 then
        FSelectedIndex := -1
    else if candidate_index < 0 then
        FSelectedIndex := 0
    else if candidate_index >= Length(FCandidates) then
        FSelectedIndex := Length(FCandidates) - 1
    else
        FSelectedIndex := candidate_index;
end;

procedure TncEngineContext.SetSurrounding(const text: string;
    const cursor_offset: Integer);
begin
    FSurroundingText := text;
    if cursor_offset < 0 then
        FCursorOffset := 0
    else if cursor_offset > Length(text) then
        FCursorOffset := Length(text)
    else
        FCursorOffset := cursor_offset;
end;

constructor TncEngineContextRegistry.Create;
begin
    inherited Create;
    FItems := TObjectList.Create(True);
end;

destructor TncEngineContextRegistry.Destroy;
begin
    FItems.Free;
    inherited Destroy;
end;

function TncEngineContextRegistry.FindIndex(const context_id: QWord): Integer;
var
    index: Integer;
begin
    for index := 0 to FItems.Count - 1 do
        if TncEngineContext(FItems[index]).Id = context_id then
            Exit(index);
    Result := -1;
end;

function TncEngineContextRegistry.Add(const context_id: QWord): Boolean;
begin
    Result := (context_id <> 0) and (FindIndex(context_id) < 0);
    if Result then
        FItems.Add(TncEngineContext.Create(context_id));
end;

function TncEngineContextRegistry.Remove(const context_id: QWord): Boolean;
var
    index: Integer;
begin
    index := FindIndex(context_id);
    Result := index >= 0;
    if Result then
        FItems.Delete(index);
end;

function TncEngineContextRegistry.Find(
    const context_id: QWord): TncEngineContext;
var
    index: Integer;
begin
    index := FindIndex(context_id);
    if index < 0 then
        Exit(nil);
    Result := TncEngineContext(FItems[index]);
end;

procedure TncEngineContextRegistry.Clear;
begin
    FItems.Clear;
end;

procedure TncEngineContextRegistry.ClearCompositions;
var
    index: Integer;
begin
    for index := 0 to FItems.Count - 1 do
        TncEngineContext(FItems[index]).ClearComposition;
end;

function TncEngineContextRegistry.Count: Integer;
begin
    Result := FItems.Count;
end;

end.
