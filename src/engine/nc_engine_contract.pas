unit nc_engine_contract;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_types;

type
    TncEngineCore = class abstract
    public
        function CreateContext(const context_id: QWord): Boolean; virtual; abstract;
        function DestroyContext(const context_id: QWord): Boolean; virtual; abstract;
        function ResetContext(const context_id: QWord;
            const generation_id: QWord): Boolean; virtual; abstract;
        function SetActive(const context_id: QWord; const active: Boolean;
            const generation_id: QWord): Boolean; virtual; abstract;
        function SetSurrounding(const context_id: QWord; const text: string;
            const cursor_offset: Integer; const generation_id: QWord): Boolean;
            virtual; abstract;
        function GetState(out state: TncEngineState): Boolean;
            virtual; abstract;
        function SetState(const state: TncEngineState): Boolean;
            virtual; abstract;
        function ClearUserDictionary: Boolean; virtual; abstract;
        function ProcessKey(const context_id: QWord; const generation_id: QWord;
            const key_event: TncKeyEvent): TncEngineResult; virtual; abstract;
        function PollResult(const context_id: QWord;
            const generation_id: QWord): TncEngineResult; virtual;
    end;

implementation

function TncEngineCore.PollResult(const context_id: QWord;
    const generation_id: QWord): TncEngineResult;
begin
    nc_initialize_engine_result(Result);
end;

end.
