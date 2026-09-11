---
name: wc3-test-debug
description: >-
  Builds and launches shadowlands-melee in WC3 (bake + build + go), dismisses
  the press-any-key splash with a click, waits for tests, reads the game log,
  then stops Warcraft III. Use when the user asks to run wc3 go, launch the
  map, run in-game tests, or debug test failures.
---

# WC3 test debug (shadowlands-melee)

## Prerequisites

- Agent mode with shell access
- Windows, WC3 Allow Local Files enabled
- Paths in `build/wc3.py` match this machine
- Game window must not be blocked by other fullscreen apps (click targets WC3 window)

## Log file

```
C:/Users/nornil/Documents/Warcraft III/CustomMapData/shadowlands-melee.txt
```

Test summary lines are written by `src/tests/support/reporter.lua` via `utils.logger`.

## Workflow

Copy checklist and track progress:

```
- [ ] Step 1: Run go (bake + build + launch)
- [ ] Step 2: Wait ~18s, click game window (dismiss press-any-key)
- [ ] Step 3: Wait 30s for in-game tests
- [ ] Step 4: Read log file
- [ ] Step 5: Report OK / FAILED suites
- [ ] Step 6: Stop Warcraft III
```

### Step 1 — Build and launch

From repo root:

```powershell
python build/wc3.py go .
```

- On non-zero exit: build/bake failed — read stderr (JSON `"event":"error"` lines)
- Game starts detached via `Popen`; do not wait for process exit

### Step 2 — Dismiss press-any-key splash

WC3 test launch hangs on «нажмите любую клавишу» until the user clicks. **Without this step tests never start.**

Wait 15–20 seconds after launch, then click the center of the Warcraft III window:

```powershell
powershell -File .cursor/skills/wc3-test-debug/scripts/dismiss-press-any-key.ps1
```

Default wait before click: **18s** (`-WaitSec 18`). Adjust to 15–20 if splash loads slower.

Script: finds `Warcraft III`, brings it to **foreground** (AttachThreadInput + retries), verifies `GetForegroundWindow` matches, then left-clicks window center. **Does not click** if focus failed (exit 1) — avoids hitting Cursor/another app.

### Step 3 — Wait for tests

Fixed delay until a completion marker exists (not implemented yet):

```powershell
Start-Sleep -Seconds 30
```

**Or** run steps 2–4 in one script (after step 1):

```powershell
powershell -File .cursor/skills/wc3-test-debug/scripts/post-launch.ps1
```

This runs: dismiss (18s + click) → wait 30s → read log → stop game.

### Step 4 — Read log

```powershell
Get-Content "C:/Users/nornil/Documents/Warcraft III/CustomMapData/shadowlands-melee.txt" -ErrorAction Stop
```

Or only read/parse (if dismiss + wait already done):

```powershell
powershell -File .cursor/skills/wc3-test-debug/scripts/read-test-log.ps1
```

If file missing: splash not dismissed, Allow Local Files off, or 30s insufficient.

### Step 5 — Parse results

| Pattern | Meaning |
|---------|---------|
| `[suiteName] N/N OK` | Suite passed |
| `[suiteName] FAILED k/n` | Suite failed |
| `  x testName: message` | Failure detail |
| `--- [suiteName] ---` | Suite section marker |

Report to user:

1. List failed suites with `x` lines
2. Count OK suites (`] N/N OK`)
3. If log empty — check splash was dismissed; async tests may need more than 30s

### Step 6 — Stop game

After log is read, terminate WC3 so it does not stay open:

```powershell
powershell -File .cursor/skills/wc3-test-debug/scripts/stop-wc3.ps1
```

`read-test-log.ps1` and `post-launch.ps1` call this automatically. To keep the game running: `-KeepGameRunning` on `read-test-log.ps1`.

## Scripts

| Script | Purpose |
|--------|---------|
| `dismiss-press-any-key.ps1` | Wait 18s, focus WC3 (verified), click center |
| `read-test-log.ps1` | Wait 30s, print log, stop WC3, exit 0/1/2 |
| `stop-wc3.ps1` | Force-stop `Warcraft III` process |
| `post-launch.ps1` | dismiss + read-test-log + stop game |

## Reporter modes (`src/tests/init.lua`)

- `summary` (default): OK one-liner per suite; failures with details
- `errors`: only failed suites in log (successful suites may show only `--- [name] ---`)
- `verbose`: per-test `OK:` / `ERROR:` lines via `Reporter.immediate`

## Do not

- Edit `src/data/generated/*` or `src/tests/generated/*` by hand — run bake via `wc3.py`
- Commit without explicit user request
