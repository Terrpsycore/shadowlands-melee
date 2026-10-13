"""Insert map preload reader and compilefile hook into war3map.lua loader if wc3.exe omitted them."""

from __future__ import annotations

import sys
from pathlib import Path

PRESENCE_MARKER = "__MAP_PRELOAD_SOURCE__"
COMPILEFILE_HOOK_MARKER = "__MAP_COMPILEFILE_HOOK__"
INSERT_BEFORE = "    -- hook for errorhandler"

OLD_COMPILEFILE = """    local function compilefile(filename, mode, env, level)
        local code = _FILES[filename]
        if not code then
            error(string.format('cannot open %s: No such file or directory', filename), (level or 1) + 1)
        end
        return preload(code, '@' .. filename, mode, env or _G)
    end"""


def patch_war3map_loader(project_root: Path) -> None:
    war3map = project_root / ".build" / "war3map.lua"
    snippet_src = project_root / "build" / "war3map_loader_snippet.lua"

    if not war3map.is_file():
        print(f"patch_war3map_loader: missing {war3map} (run wc3 build first)", file=sys.stderr)
        sys.exit(1)
    if not snippet_src.is_file():
        print(f"patch_war3map_loader: missing {snippet_src}", file=sys.stderr)
        sys.exit(1)

    text = war3map.read_text(encoding="utf-8")
    head_end = text.find("\nP['")
    head = text if head_end == -1 else text[:head_end]

    if PRESENCE_MARKER not in head:
        pos = text.find(INSERT_BEFORE)
        if pos == -1:
            print(f"patch_war3map_loader: {INSERT_BEFORE!r} not found in {war3map}", file=sys.stderr)
            sys.exit(1)
        snippet = snippet_src.read_text(encoding="utf-8")
        if not snippet.endswith("\n"):
            snippet += "\n"
        text = text[:pos] + snippet + "\n" + text[pos:]
        print(f"patch_war3map_loader: applied snippet from {snippet_src.name}")
    else:
        print("patch_war3map_loader: loader already has preload reader (skip)")

    if COMPILEFILE_HOOK_MARKER not in text and "compilefileRaw" not in text:
        hook_src = project_root / "build" / "war3map_compilefile_hook_snippet.lua"
        if not hook_src.is_file():
            print(f"patch_war3map_loader: missing {hook_src}", file=sys.stderr)
            sys.exit(1)
        if OLD_COMPILEFILE not in text:
            print("patch_war3map_loader: legacy compilefile block not found (skip hook)", file=sys.stderr)
        else:
            hook_snippet = hook_src.read_text(encoding="utf-8")
            if not hook_snippet.endswith("\n"):
                hook_snippet += "\n"
            text = text.replace(OLD_COMPILEFILE, hook_snippet.rstrip("\n"), 1)
            print(f"patch_war3map_loader: applied compilefile hook from {hook_src.name}")
    else:
        print("patch_war3map_loader: compilefile hook already present (skip)")

    war3map.write_text(text, encoding="utf-8", newline="\n")


def main() -> None:
    if len(sys.argv) != 2:
        print("usage: patch_war3map_loader.py <project_root>", file=sys.stderr)
        sys.exit(2)
    patch_war3map_loader(Path(sys.argv[1]).resolve())


if __name__ == "__main__":
    main()
