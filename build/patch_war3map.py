"""Replace root war3map.lua tail after wc3.exe compile (workaround for wc3 wrapper vs P[] embed)."""

from __future__ import annotations

import sys
from pathlib import Path

MARKER = "dofile('origwar3map.lua')"


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
    idx = text.rfind(MARKER)
    if idx == -1:
        print(f"patch_war3map: {MARKER!r} not found in {war3map}", file=sys.stderr)
        sys.exit(1)

    orig_marker = text.rfind("P['origwar3map.lua']")
    if orig_marker != -1 and idx < orig_marker:
        print(
            "patch_war3map: root tail marker appears before P['origwar3map.lua'] — unexpected layout",
            file=sys.stderr,
        )
        sys.exit(1)

    new_tail = tail_src.read_text(encoding="utf-8")
    if not new_tail.lstrip().startswith(MARKER):
        print(f"patch_war3map: {tail_src} must start with {MARKER}", file=sys.stderr)
        sys.exit(1)

    war3map.write_text(text[:idx] + new_tail, encoding="utf-8", newline="\n")
    print(f"patch_war3map: applied tail from {tail_src.name}")


def main() -> None:
    if len(sys.argv) != 2:
        print("usage: patch_war3map.py <project_root>", file=sys.stderr)
        sys.exit(2)
    patch_war3map(Path(sys.argv[1]).resolve())


if __name__ == "__main__":
    main()
