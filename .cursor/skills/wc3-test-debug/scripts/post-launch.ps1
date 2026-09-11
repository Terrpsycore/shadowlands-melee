# After `python build/wc3.py go .`: dismiss splash, wait for tests, print log.
# Exit codes match read-test-log.ps1.

param(
    [string]$LogPath = "C:/Users/nornil/Documents/Warcraft III/CustomMapData/shadowlands-melee.txt",
    [int]$DismissWaitSec = 18,
    [int]$TestWaitSec = 30
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

& "$scriptDir/dismiss-press-any-key.ps1" -WaitSec $DismissWaitSec
if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) { exit $LASTEXITCODE }

& "$scriptDir/read-test-log.ps1" -LogPath $LogPath -WaitSec $TestWaitSec
exit $LASTEXITCODE
