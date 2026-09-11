# Stop Warcraft III process launched for map testing.

$procs = Get-Process -Name "Warcraft III" -ErrorAction SilentlyContinue
if (-not $procs) {
    Write-Host "Warcraft III is not running"
    exit 0
}

$procs | Stop-Process -Force
Write-Host "Stopped Warcraft III ($($procs.Count) process(es))"
