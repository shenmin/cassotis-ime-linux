unit nc_long_exact_edge_fallback_auditor_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

type
    TncLongExactEdgeFallbackAuditorFeatures =
        array[0..204] of Double;

const
    c_long_exact_edge_fallback_auditor_enabled = False;
    c_long_exact_edge_fallback_auditor_feature_count = 205;
    c_long_exact_edge_fallback_auditor_tree_count = 0;
    c_long_exact_edge_fallback_auditor_threshold: Double = 1.0E300;

function long_exact_edge_fallback_auditor_score(
    const features: TncLongExactEdgeFallbackAuditorFeatures): Double;
function long_exact_edge_fallback_auditor_self_test: Boolean;

implementation

{ Disabled because the independent development/test acceptance gates rejected
  every fallback threshold.
  Training report SHA-256: 4376F79BFD83EC6D9715AEF6F648726CC375B5EEBEC95801901799CCBE8E3FF4
  LightGBM model SHA-256: A0DD8A827D41E92E635B5D1D014982FA86F8A61EBCABDD1971A8DF405BD6DD60 }

function long_exact_edge_fallback_auditor_score(
    const features: TncLongExactEdgeFallbackAuditorFeatures): Double;
begin
    Result := 0.0;
end;

function long_exact_edge_fallback_auditor_self_test: Boolean;
begin
    Result := True;
end;

end.
