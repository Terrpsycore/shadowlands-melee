---
name: wc3-read-log
description: >-
  Reads and parses shadowlands-melee in-game test log from CustomMapData, waits
  for async tests if needed, and stops Warcraft III. Does NOT launch the game.
  Use when the user asks to read test logs, check test results, parse wc3 log,
  or stop the game after tests — without running wc3 go.
---

# WC3 read test log (shadowlands-melee)

Log reading only. To build and launch the map, use skill **wc3-run**.

## Allowed commands (this skill)

- `powershell -File .cursor/skills/wc3/scripts/read-test-log.ps1`
- `powershell -File .cursor/skills/wc3/scripts/stop-wc3.ps1`
- `Get-Content` on the log file path below

## Forbidden (use wc3-run instead)

- `python build/wc3.py go .`
- `python build/wc3.py run .`
- `dismiss-press-any-key.ps1`
- Any command that starts Warcraft III

## Log file

```
C:/Users/nornil/Documents/Warcraft III/CustomMapData/shadowlands-melee.txt
```

Written by `src/tests/support/reporter.lua` via `utils.logger`.

## Workflow

```
- [ ] Step 1: Wait for tests (if game still running)
- [ ] Step 2: Read and parse log
- [ ] Step 3: Stop Warcraft III (default)
- [ ] Step 4: Report OK / FAILED suites
```

### Step 1 — Wait

If tests may still be running (game was started earlier):

```powershell
powershell -File .cursor/skills/wc3/scripts/read-test-log.ps1 -WaitSec 30
```

If log should already exist (tests finished):

```powershell
powershell -File .cursor/skills/wc3/scripts/read-test-log.ps1 -WaitSec 0
```

Fixed delay until a completion marker exists (not implemented yet).

### Step 2 — Read log

Script prints file contents and sets exit code. Or read directly:

```powershell
Get-Content "C:/Users/nornil/Documents/Warcraft III/CustomMapData/shadowlands-melee.txt" -ErrorAction Stop
```

If file missing: game not run, splash not dismissed, Allow Local Files off, or wait too short.

### Step 3 — Stop game

`read-test-log.ps1` stops WC3 by default after reading.

Keep game open: `-KeepGameRunning`

Read only, no stop: `-NoStop` (or `-KeepGameRunning` — both skip stop)

Manual stop:

```powershell
powershell -File .cursor/skills/wc3/scripts/stop-wc3.ps1
```

### Step 4 — Parse results

| Pattern | Meaning |
|---------|---------|
| `[suiteName] N/N OK` | Suite passed |
| `[suiteName] FAILED k/n` | Suite failed |
| `  x testName: message` | Failure detail |
| `--- [suiteName] ---` | Suite section marker |

Report:

1. Failed suites with `x` lines
2. Count of OK suites
3. If log empty — suggest more wait or check wc3-run was used first

## Exit codes (`read-test-log.ps1`)

| Code | Meaning |
|------|---------|
| 0 | No FAILED lines in log |
| 1 | Failures found |
| 2 | Log file missing |

## Reporter modes (`src/tests/init.lua`)

- `summary` (default): OK one-liner per suite; failures with details
- `errors`: only failed suites in log
- `verbose`: per-test lines via `Reporter.immediate`

## Allowlist hint (permissions.json)

```jsonc
"terminalAllowlist": [
  "powershell -File .cursor/skills/wc3/scripts/read-test-log.ps1",
  "powershell -File .cursor/skills/wc3/scripts/stop-wc3.ps1",
  "Get-Content"
]
```

Do **not** add `python build/wc3.py go` here if launch should require separate approval.

## Do not

- Launch or build the map under this skill
- Edit generated files by hand
