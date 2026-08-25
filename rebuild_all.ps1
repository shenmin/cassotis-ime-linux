param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

& (Join-Path $root 'scripts\build.ps1') -Clean
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

& (Join-Path $root 'scripts\test.ps1') -SkipBuild
exit $LASTEXITCODE
