param(
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

if (-not $SkipBuild) {
    & (Join-Path $PSScriptRoot 'build.ps1')
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

$engine = Join-Path $root 'build\bin\cassotis-engine.exe'
$tests = Join-Path $root 'build\bin\cassotis-core-tests.exe'

& $engine --self-test
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$parseResult = @(& $engine --parse "xi'an")
if (($LASTEXITCODE -ne 0) -or ($parseResult.Count -ne 2) -or
    ($parseResult[0] -ne '0:2:xi') -or ($parseResult[1] -ne '3:2:an')) {
    throw 'Engine parser CLI smoke test failed'
}

$shuangpinResult = @(& $engine --decode-shuangpin xiaohe nihc)
if (($LASTEXITCODE -ne 0) -or
    (-not ($shuangpinResult -contains 'canonical=nihao')) -or
    (-not ($shuangpinResult -contains 'valid=1'))) {
    throw 'Engine shuangpin CLI smoke test failed'
}

$fuzzyResult = @(& $engine --fuzzy zonghe)
if (($LASTEXITCODE -ne 0) -or
    (-not ($fuzzyResult -match ':zhonghe:.*z-zh'))) {
    throw 'Engine fuzzy-pinyin CLI smoke test failed'
}

$previousSqliteLibrary = $env:CASSOTIS_SQLITE_LIBRARY
$sqliteOverrideSet = $false
if ([string]::IsNullOrWhiteSpace($previousSqliteLibrary)) {
    $siblingSqlite = Join-Path $root '..\cassotis_ime\third_party\sqlite\win64\sqlite3.dll'
    if (Test-Path -LiteralPath $siblingSqlite) {
        $env:CASSOTIS_SQLITE_LIBRARY = [System.IO.Path]::GetFullPath($siblingSqlite)
        $sqliteOverrideSet = $true
    }
}

& $tests --all --format=plain
$testExitCode = $LASTEXITCODE
if ($sqliteOverrideSet) {
    Remove-Item Env:CASSOTIS_SQLITE_LIBRARY
}
exit $testExitCode
