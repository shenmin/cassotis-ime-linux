param(
    [Parameter(Mandatory = $true)]
    [string]$Dictionary,
    [string]$Cases
)

$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$runner = Join-Path $root 'build\bin\cassotis-candidate-regression.exe'
if ([string]::IsNullOrWhiteSpace($Cases)) {
    $Cases = Join-Path $root 'tests\cases\candidate_quality.tsv'
}
if (-not (Test-Path -LiteralPath $runner)) {
    throw "Regression runner was not built: $runner"
}
if (-not (Test-Path -LiteralPath $Dictionary)) {
    throw "Dictionary does not exist: $Dictionary"
}
if (-not (Test-Path -LiteralPath $Cases)) {
    throw "Case file does not exist: $Cases"
}

& $runner ([System.IO.Path]::GetFullPath($Dictionary)) `
    ([System.IO.Path]::GetFullPath($Cases))
if ($LASTEXITCODE -ne 0) {
    throw "Candidate regression failed with exit code $LASTEXITCODE"
}
