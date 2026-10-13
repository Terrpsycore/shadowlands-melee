"""Replace root war3map.lua tail after wc3.exe compile (workaround for wc3 wrapper vs P[] embed)."""

from __future__ import annotations

import sys
from pathlib import Path

MARKER = "dofile('origwar3map.lua')"
ORIG_PRELOAD_KEY = "P['origwar3map.lua']"


def patch_war3map(project_root: Path) -> None:
    war3map = project_root / ".build" / "war3map.lua"
    tail_src = project_root / "build" / "war3map_tail.lua"
    if not war3map.is_file():
        print(f"patch_war3map: missing {war3map} (run wc3 build first)", file=sys.stderr)
        sys.exit(1)
    if not tail_src.is_file():
        print(f"patch_war3map: missing {tail_src}", file=sys.stderr)
        sys.exit(1)

    text = war3map.read_text(encoding="utf-8")
    tail = tail_src.read_text(encoding="utf-8")
    if not tail.endswith("\n"):
        tail += "\n"

    # Idempotent: tail already applied (no stray main() call at EOF).
    if text.rstrip("\n").endswith(tail.rstrip("\n")):
        print("patch_war3map: tail already applied (skip)")
        return

    orig_pos = text.rfind(ORIG_PRELOAD_KEY)
    if orig_pos < 0:
        print(f"patch_war3map: {ORIG_PRELOAD_KEY!r} not found in {war3map}", file=sys.stderr)
        sys.exit(1)

    idx = text.find(MARKER, orig_pos)
    if idx < 0:
        print(
            f"patch_war3map: {MARKER!r} not found after {ORIG_PRELOAD_KEY} in {war3map}",
            file=sys.stderr,
        )
        sys.exit(1)

    if not tail.lstrip().startswith(MARKER):
        print(f"patch_war3map: {tail_src} must start with {MARKER}", file=sys.stderr)
        sys.exit(1)

    war3map.write_text(text[:idx] + tail, encoding="utf-8", newline="\n")
    print(f"patch_war3map: applied tail from {tail_src.name}")


def main() -> None:
    if len(sys.argv) != 2:
        print("usage: patch_war3map.py <project_root>", file=sys.stderr)
        sys.exit(1)
    patch_war3map(Path(sys.argv[1]).resolve())


if __name__ == "__main__":
    main()
