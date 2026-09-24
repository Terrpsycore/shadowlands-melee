param(
    [string]$AssetsRoot,
    [int]$Port = 0
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

function Import-IconPreviewEnv {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return }
    Get-Content $Path | ForEach-Object {
        if ($_ -match '^\s*([^#=]+)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim().Trim('"').Trim("'")
            if (-not [Environment]::GetEnvironmentVariable($name, "Process")) {
                Set-Item -Path "env:$name" -Value $value
            }
        }
    }
}

Import-IconPreviewEnv (Join-Path $PSScriptRoot ".env")

if (-not $AssetsRoot) {
    $AssetsRoot = $env:WC3_ASSETS
}
if (-not $AssetsRoot) {
    $AssetsRoot = Join-Path (Split-Path $repoRoot -Parent) "wc3-assets"
}
if ($Port -le 0) {
    $Port = if ($env:ICON_PREVIEW_PORT) { [int]$env:ICON_PREVIEW_PORT } else { 8000 }
}

$LUA = if ($env:LUA) { $env:LUA } else { "C:/Programs/Lua/lua55.exe" }

Set-Location $repoRoot
$env:WC3_ASSETS = $AssetsRoot
if (-not $env:WC3_CUSTOM) {
    $env:WC3_CUSTOM = Join-Path (Split-Path $repoRoot -Parent) "wc3-custom"
}

Write-Host "WC3_ASSETS=$AssetsRoot"
Write-Host "WC3_CUSTOM=$($env:WC3_CUSTOM)"
Write-Host "ICON_PREVIEW_PORT=$Port"

$iconsPath = Join-Path $repoRoot "src/vendor/assets/generated/Icons.lua"
if (-not (Test-Path $iconsPath)) {
    Write-Host "Generating Icons catalog..."
    & $LUA tools/gen/asset_catalogs.lua
}

Write-Host "Exporting icons.json + units.json..."
& $LUA tools/icon_preview/export.lua

Write-Host "Building thumbnails..."
& python tools/icon_preview/build_cache.py
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Starting server on port $Port (watch mode)..."
& python tools/icon_preview/serve.py --port $Port --watch
