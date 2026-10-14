"""Write CustomMapData preload files for Luashine FileIO.Load (PreloadGenEnd-compatible .pld)."""

from __future__ import annotations

import re
from pathlib import Path

RAW_PREFIX = "]]i([["
# Luashine chunk close: ]])--[[  (two ] before )
RAW_SUFFIX = "\x5d\x5d)\x2d\x2d[["
RAW_SIZE = 255 - len(RAW_PREFIX) - len(RAW_SUFFIX)

PRELOAD_HEADER = (
    "function PreloadFiles takes nothing returns nothing\n"
    " call PreloadStart()\n"
    ' call Preload( "")\n'
    "endfunction\n"
    "//!beginusercode\n"
    "local p={} local i=function(s) table.insert(p,s) end--[[\n"
)


def _escape_preload_payload(s: str) -> str:
    """Escape only user payload; keep Luashine ]]i([[ / ]])--[[ delimiters intact."""
    return s.replace("\\", "!\\").replace("]", "!]")


def _read_fileio_load_id(project_root: Path) -> int:
    ids_path = project_root / "src" / "data" / "generated" / "ids.lua"
    if not ids_path.is_file():
        raise FileNotFoundError(
            f"missing {ids_path} — run bake (e.g. python build/wc3.py build .) before watch"
        )
    text = ids_path.read_text(encoding="utf-8")
    match = re.search(r'fileioLoad\s*=\s*"([^"]+)"', text)
    if not match:
        raise LookupError("fileioLoad not found in data/generated/ids.lua")
    raw = match.group(1)
    if len(raw) != 4:
        raise ValueError(f"fileioLoad id must be FourCC, got {raw!r}")
    # WC3/Lua FourCC: big-endian char4 (same as in-game FileIO.Save / _ping.pld)
    b = raw.encode("latin1")
    return (b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3]


def _chunk_payload(content: str) -> list[str]:
    chunks: list[str] = []
    i = 0
    while i < len(content):
        end = min(i + RAW_SIZE, len(content))
        while end > i and content[end - 1] == "]":
            end -= 1
        chunks.append(RAW_PREFIX + content[i:end] + RAW_SUFFIX)
        i = end
    return chunks


def write_luashine_preload_file(target: Path, content: str, load_ability_id: int) -> None:
    """On-disk format expected by Preloader + FileIO.Load (external tool write)."""
    target.parent.mkdir(parents=True, exist_ok=True)
    lines = [PRELOAD_HEADER]
    for chunk in _chunk_payload(content):
        inner = chunk[len(RAW_PREFIX) : -len(RAW_SUFFIX)]
        wrapped = RAW_PREFIX + _escape_preload_payload(inner) + RAW_SUFFIX
        lines.append(f' call Preload( "{wrapped}" )\n')
    lines.append("]]\n")
    lines.append(f"BlzSetAbilityTooltip({load_ability_id}, table.concat(p), 0)\n")
    lines.append("//!endusercode\n")
    lines.append("function a takes nothing returns nothing\n")
    lines.append('//" )\n')
    lines.append(" call PreloadEnd( 0.1 )\n")
    lines.append("endfunction\n")
    body = "".join(lines).encode("utf-8")
    part = target.with_suffix(target.suffix + ".part")
    part.write_bytes(body)
    part.replace(target)


def write_inbox_for_fileio_load(
    reload_root_dir: Path, inbox_lua: str, project_root: Path, *, seq: int
) -> Path:
    """Write numbered inbox (Preloader caches by path — do not reuse one inbox.pld)."""
    from reload_contract import inbox_pld_path

    load_id = _read_fileio_load_id(project_root)
    target = inbox_pld_path(reload_root_dir, seq)
    write_luashine_preload_file(target, inbox_lua, load_id)
    return target
