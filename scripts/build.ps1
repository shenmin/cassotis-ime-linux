param(
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$buildDir = Join-Path $root 'build'
$binDir = Join-Path $buildDir 'bin'
$unitDir = Join-Path $buildDir 'units'

if ($Clean -and (Test-Path -LiteralPath $buildDir)) {
    $resolvedBuild = [System.IO.Path]::GetFullPath($buildDir)
    $rootPrefix = $root.TrimEnd('\') + '\'
    if (-not $resolvedBuild.StartsWith($rootPrefix,
            [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove build directory outside repository: $resolvedBuild"
    }
    Remove-Item -LiteralPath $resolvedBuild -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $binDir, $unitDir | Out-Null

$fpc = $env:FPC
if ([string]::IsNullOrWhiteSpace($fpc)) {
    $fpc = 'C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe'
}
if (-not (Test-Path -LiteralPath $fpc)) {
    throw "FPC compiler not found. Set FPC or install it at: $fpc"
}

$commonArgs = @(
    '-B',
    '-Mdelphiunicode',
    '-FcUTF8',
    '-vm2091',
    '-O2',
    '-g',
    '-gl',
    '-Si',
    '-vewnhibq',
    "-FE$binDir",
    "-FU$unitDir",
    "-Fu$(Join-Path $root 'src\common')",
    "-Fu$(Join-Path $root 'src\engine')",
    "-Fu$(Join-Path $root 'src\dictionary')",
    "-Fu$(Join-Path $root 'src\ipc')",
    "-Fu$(Join-Path $root 'src\service')",
    "-Fu$(Join-Path $root 'tests\unit')"
)

function Invoke-FpcBuild {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$OutputName
    )

    & $fpc @commonArgs "-o$OutputName" $Source
    if ($LASTEXITCODE -ne 0) {
        throw "FPC build failed for $Source with exit code $LASTEXITCODE"
    }
}

Invoke-FpcBuild -Source (Join-Path $root 'src\service\cassotis_engine.lpr') `
    -OutputName 'cassotis-engine.exe'
Invoke-FpcBuild -Source (Join-Path $root 'tests\unit\cassotis_core_tests.lpr') `
    -OutputName 'cassotis-core-tests.exe'
Invoke-FpcBuild -Source (Join-Path $root 'tools\benchmark\cassotis_parser_benchmark.lpr') `
    -OutputName 'cassotis-parser-benchmark.exe'
Invoke-FpcBuild -Source (Join-Path $root 'tools\benchmark\cassotis_shuangpin_benchmark.lpr') `
    -OutputName 'cassotis-shuangpin-benchmark.exe'
Invoke-FpcBuild -Source (Join-Path $root 'tools\benchmark\cassotis_dictionary_benchmark.lpr') `
    -OutputName 'cassotis-dictionary-benchmark.exe'
Invoke-FpcBuild -Source (Join-Path $root 'tools\benchmark\cassotis_candidate_benchmark.lpr') `
    -OutputName 'cassotis-candidate-benchmark.exe'
Invoke-FpcBuild -Source (Join-Path $root 'tools\regression\cassotis_candidate_regression.lpr') `
    -OutputName 'cassotis-candidate-regression.exe'

Write-Host "Build completed: $binDir"
