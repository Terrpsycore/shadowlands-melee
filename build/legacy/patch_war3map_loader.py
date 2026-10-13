"""Insert hot-reload compilefile hook, preload reader, and package.invalidate into war3map.lua."""

from __future__ import annotations

import re
import sys
from pathlib import Path

PRESENCE_MARKER = "__HOT_RELOAD__"
MAP_PRELOAD_MARKER = "__MAP_PRELOAD_SOURCE__"
INSERT_BEFORE = "    -- hook for errorhandler"
ROOT_BOUNDARY = "\nP['"


def _war3map_root(text: str) -> str:
    pos = text.find(ROOT_BOUNDARY)
    if pos < 0:
        print(f"patch_war3map_loader: {ROOT_BOUNDARY!r} not found (cannot locate root loader)", file=sys.stderr)
        sys.exit(1)
    return text[:pos]


COMPILEFILE_OLD = re.compile(
    r"    local function compilefile\(filename, mode, env, level\)\r?\n"
    r"        local code = _FILES\[filename\]\r?\n"
    r"        if not code then\r?\n"
    r"            error\(string\.format\('cannot open %s: No such file or directory', filename\), \(level or 1\) \+ 1\)\r?\n"
    r"        end\r?\n"
    r"        return preload\(code, '@' \.\. filename, mode, env or _G\)\r?\n"
    r"    end\r?\n",
    re.MULTILINE,
)


def _read_snippet(project_root: Path, name: str) -> str:
    path = project_root / "build" / name
    if not path.is_file():
        print(f"patch_war3map_loader: missing {path}", file=sys.stderr)
        sys.exit(1)
    text = path.read_text(encoding="utf-8")
    if not text.endswith("\n"):
        text += "\n"
    return text


def patch_war3map_loader(project_root: Path) -> None:
    war3map = project_root / ".build" / "war3map.lua"
    if not war3map.is_file():
        print(f"patch_war3map_loader: missing {war3map} (run wc3 build first)", file=sys.stderr)
        sys.exit(1)

    text = war3map.read_text(encoding="utf-8")
    root = _war3map_root(text)
    changed = False

    if "__HOT_RELOAD_FILES__" not in root:
        hook = _read_snippet(project_root, "war3map_compilefile_hook_snippet.lua")
        match = COMPILEFILE_OLD.search(text)
        if not match:
            print("patch_war3map_loader: legacy compilefile block not found", file=sys.stderr)
            sys.exit(1)
        text = text[: match.start()] + hook + text[match.end() :]
        changed = True
        print("patch_war3map_loader: applied compilefile hook")
    else:
        print("patch_war3map_loader: compilefile hook already present (skip)")

    if MAP_PRELOAD_MARKER not in root:
        loader = _read_snippet(project_root, "war3map_loader_snippet.lua")
        pos = text.find(INSERT_BEFORE)
        if pos < 0:
            print(f"patch_war3map_loader: {INSERT_BEFORE!r} not found in {war3map}", file=sys.stderr)
            sys.exit(1)
        text = text[:pos] + loader + text[pos:]
        changed = True
        print("patch_war3map_loader: applied preload reader snippet")
    else:
        print("patch_war3map_loader: preload reader already present (skip)")

    if PRESENCE_MARKER not in root:
        api = _read_snippet(project_root, "war3map_hot_reload_api_snippet.lua")
        anchor = "    function geterrorhandler()"
        pos = text.find(anchor)
        if pos < 0:
            print("patch_war3map_loader: geterrorhandler anchor not found", file=sys.stderr)
            sys.exit(1)
        end_fn = text.find("\n    end\n", pos)
        if end_fn < 0:
            print("patch_war3map_loader: geterrorhandler end not found", file=sys.stderr)
            sys.exit(1)
        insert_at = end_fn + len("\n    end\n")
        text = text[:insert_at] + api + text[insert_at:]
        changed = True
        print("patch_war3map_loader: applied hot reload API snippet")

    root = _war3map_root(text)
    if "__HOT_RELOAD_API__" not in root and PRESENCE_MARKER in root:
        api_export = _read_snippet(project_root, "war3map_hot_reload_api_export_snippet.lua")
        anchor = "    _G.__MAP_PRELOAD_SOURCE__ = mapPreloadSource"
        pos = text.find(anchor)
        if pos >= 0:
            text = text[:pos] + api_export + text[pos:]
            changed = True
            print("patch_war3map_loader: applied hot reload API export (existing map)")
        else:
            print("patch_war3map_loader: warning: could not insert __HOT_RELOAD_API__ export", file=sys.stderr)

    if changed:
        war3map.write_text(text, encoding="utf-8", newline="\n")

    final = war3map.read_text(encoding="utf-8")
    final_root = _war3map_root(final)
    if "_G.__HOT_RELOAD__ = true" not in final_root:
        print("patch_war3map_loader: __HOT_RELOAD__ missing in root loader after patch", file=sys.stderr)
        sys.exit(1)
    if "__HOT_RELOAD_API__" not in final_root:
        print("patch_war3map_loader: __HOT_RELOAD_API__ missing in root loader after patch", file=sys.stderr)
        sys.exit(1)


def main() -> None:
    if len(sys.argv) != 2:
        print("usage: patch_war3map_loader.py <project_root>", file=sys.stderr)
        sys.exit(1)
    patch_war3map_loader(Path(sys.argv[1]).resolve())


if __name__ == "__main__":
    main()
