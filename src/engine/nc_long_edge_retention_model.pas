unit nc_long_edge_retention_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

const
    c_long_edge_retention_feature_count = 13;
    c_long_edge_retention_pair_threshold = 0.0;

type
    TncLongEdgeRetentionFeatures =
        array[0..c_long_edge_retention_feature_count - 1] of Double;

procedure build_long_edge_retention_features(const exact_rank: Integer;
    const raw_weight: Integer; const top_weight: Integer;
    const effective_score: Integer; const chunk_units: Integer;
    const start_position: Integer; const input_units: Integer;
    const source_user: Boolean; out features: TncLongEdgeRetentionFeatures);
function long_edge_retention_score(const exact_rank: Integer;
    const raw_weight: Integer; const top_weight: Integer;
    const effective_score: Integer; const chunk_units: Integer;
    const start_position: Integer; const input_units: Integer;
    const source_user: Boolean): Int64;
function long_edge_retention_prefers(
    const candidate_features: TncLongEdgeRetentionFeatures;
    const current_features: TncLongEdgeRetentionFeatures): Boolean;
function long_edge_retention_pair_score(
    const candidate_features: TncLongEdgeRetentionFeatures;
    const current_features: TncLongEdgeRetentionFeatures): Double;

implementation

uses
    Math;

procedure build_long_edge_retention_features(const exact_rank: Integer;
    const raw_weight: Integer; const top_weight: Integer;
    const effective_score: Integer; const chunk_units: Integer;
    const start_position: Integer; const input_units: Integer;
    const source_user: Boolean; out features: TncLongEdgeRetentionFeatures);
var
    units: Integer;
    weight_gap: Integer;
begin
    units := Max(1, chunk_units);
    weight_gap := Max(0, top_weight - raw_weight);
    features[0] := Max(0, exact_rank - 1);
    features[1] := Ord(exact_rank = 1);
    features[2] := raw_weight / 1000.0;
    features[3] := top_weight / 1000.0;
    features[4] := weight_gap / 1000.0;
    features[5] := effective_score / 10000.0;
    features[6] := units;
    features[7] := units * units;
    features[8] := Max(0, input_units - start_position - units) / 10.0;
    features[9] := start_position / 10.0;
    features[10] := Ord(source_user);
    features[11] := (raw_weight / units) / 1000.0;
    features[12] := (weight_gap / units) / 1000.0;
end;

function bootstrap_score(
    const features: TncLongEdgeRetentionFeatures): Double;
begin
    { Diagnostic fallback for captured edge ordering. It is not allowed to
      expand the production beam without passing the full benchmark gates. }
    Result := features[2] * 23000.0
        - features[4] * 11000.0
        - features[0] * 1700.0
        + features[5] * 1250.0
        + features[6] * 1900.0
        - features[8] * 70.0
        + features[10] * 24000.0;
end;

function long_edge_retention_score(const exact_rank: Integer;
    const raw_weight: Integer; const top_weight: Integer;
    const effective_score: Integer; const chunk_units: Integer;
    const start_position: Integer; const input_units: Integer;
    const source_user: Boolean): Int64;
var
    features: TncLongEdgeRetentionFeatures;
begin
    build_long_edge_retention_features(exact_rank, raw_weight, top_weight,
        effective_score, chunk_units, start_position, input_units,
        source_user, features);
    Result := Round(bootstrap_score(features));
end;

function long_edge_retention_prefers(
    const candidate_features: TncLongEdgeRetentionFeatures;
    const current_features: TncLongEdgeRetentionFeatures): Boolean;
begin
    Result := long_edge_retention_pair_score(candidate_features,
        current_features) > c_long_edge_retention_pair_threshold;
end;

function long_edge_retention_pair_score(
    const candidate_features: TncLongEdgeRetentionFeatures;
    const current_features: TncLongEdgeRetentionFeatures): Double;
begin
    Result := bootstrap_score(candidate_features) -
        bootstrap_score(current_features);
end;

end.
