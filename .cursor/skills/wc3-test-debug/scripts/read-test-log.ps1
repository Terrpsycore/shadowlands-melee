# Wait for in-game tests, print log, stop WC3, return exit code.
# Usage: after dismiss-press-any-key.ps1 (or post-launch.ps1).
# Exit 0 = no failures found, 1 = failures, 2 = log missing.

param(
    [string]$LogPath = "C:/Users/nornil/Documents/Warcraft III/CustomMapData/shadowlands-melee.txt",
    [int]$WaitSec = 30,
    [switch]$KeepGameRunning
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Waiting ${WaitSec}s for in-game tests..."
Start-Sleep -Seconds $WaitSec

$exitCode = 0

if (-not (Test-Path -LiteralPath $LogPath)) {
    Write-Error "Log not found: $LogPath"
    $exitCode = 2
} else {
    Write-Host "--- $LogPath ---"
    Get-Content -LiteralPath $LogPath

    $failed = Select-String -LiteralPath $LogPath -Pattern '\] FAILED|  x ' -SimpleMatch:$false
    if ($failed) {
        Write-Host ""
        Write-Host "FAIL: $($failed.Count) failure line(s) in log"
        $exitCode = 1
    } else {
        $ok = Select-String -LiteralPath $LogPath -Pattern '\] \d+/\d+ OK'
        Write-Host ""
        Write-Host "OK: $($ok.Count) suite(s) passed (no FAILED lines)"
    }
}

if (-not $KeepGameRunning) {
    & "$scriptDir/stop-wc3.ps1"
}

exit $exitCode
