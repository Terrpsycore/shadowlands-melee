---
name: wc3-run
description: >-
  Builds and launches shadowlands-melee in Warcraft III (bake + build + go) and
  dismisses the press-any-key splash. Does NOT read test logs — use wc3-read-log
  for that. Use when the user asks to run wc3 go, launch the map, start the game,
  or build and run the map.
---

# WC3 run (shadowlands-melee)

Launch only. For log parsing and stopping the game after tests, use skill **wc3-read-log**.

## Allowed commands (this skill)

- `python build/wc3.py go .`
- `python build/wc3.py build .` (only if user asked to build without run)
- `powershell -File .cursor/skills/wc3/scripts/dismiss-press-any-key.ps1`

## Forbidden (use wc3-read-log instead)

- Reading `shadowlands-melee.txt`
- `read-test-log.ps1`, `stop-wc3.ps1`
- Interpreting test OK/FAILED results

## Prerequisites

- Agent mode with shell access
- Windows, WC3 Allow Local Files enabled
- Paths in `build/wc3.py` match this machine

## Workflow

```
- [ ] Step 1: Run go (bake + build + launch)
- [ ] Step 2: Dismiss press-any-key splash (~18s wait + click)
```

### Step 1 — Build and launch

From repo root:

```powershell
python build/wc3.py go .
```

- On non-zero exit: build/bake failed — read stderr (JSON `"event":"error"` lines)
- Game starts detached via `Popen`; do not wait for process exit

### Step 2 — Dismiss press-any-key splash

WC3 hangs on «нажмите любую клавишу» until clicked. **Without this step tests never start.**

Run immediately after step 1 (script waits 18s internally):

```powershell
powershell -File .cursor/skills/wc3/scripts/dismiss-press-any-key.ps1
```

Adjust splash delay: `-WaitSec 15` … `-WaitSec 25`.

On exit 1: focus not acquired — report error, do not retry blindly.

### After launch

Tell the user the map is running. If they want test results, invoke **wc3-read-log** (wait for tests, read log, stop game).

## Scripts

| Script | Purpose |
|--------|---------|
| `dismiss-press-any-key.ps1` | Wait, focus WC3, click center |

Shared scripts live under `.cursor/skills/wc3/scripts/`.

## Allowlist hint (permissions.json)

```jsonc
"terminalAllowlist": [
  "python build/wc3.py go",
  "python build/wc3.py build",
  "powershell -File .cursor/skills/wc3/scripts/dismiss-press-any-key.ps1"
]
```

## Do not

- Edit `src/data/generated/*` or `src/tests/generated/*` by hand — run bake via `wc3.py`
- Read test logs under this skill
