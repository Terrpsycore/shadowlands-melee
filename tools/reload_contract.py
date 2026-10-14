"""Hot reload OS ↔ map contract. Keep in sync with src/lib/reload/contract.lua."""

from __future__ import annotations

import json
import os
import re
from pathlib import Path

# --- paths (CustomMapData, FileIO on Windows uses backslashes in map code) ---

RELOAD_DIR_NAME = "shadowlands-melee-reload"
INBOX_SUBDIR = "inbox"
ACK_BASENAME = "ack.json"
PING_BASENAME = "_ping.pld"
INBOX_EXTENSION = ".pld"

# --- inbox payload (Lua chunk executed with load(..., "t", {})) ---
#
# return {
#   seq = <int>,          -- monotonic; map ignores seq <= lastSeq
#   patches = {
#     { file = "<key>", source = "<lua source>" },
#     ...
#   },
# }
#
# file: path under src/ with forward slashes, e.g. scenario/factions/foo/bar.lua
# One reload flush → one inbox/{seq}.pld; filename seq MUST match payload seq.


def custom_map_data_dir(user_home: Path | None = None) -> Path:
    if user_home is None:
        user_home = Path(os.environ.get("USERPROFILE") or os.path.expanduser("~"))
    return user_home / "Documents" / "Warcraft III" / "CustomMapData"


def reload_root(custom_map_data: Path | None = None) -> Path:
    base = custom_map_data if custom_map_data is not None else custom_map_data_dir()
    return base / RELOAD_DIR_NAME


def inbox_pld_path(reload_root_dir: Path, seq: int) -> Path:
    return reload_root_dir / INBOX_SUBDIR / f"{seq}{INBOX_EXTENSION}"


def ack_path(reload_root_dir: Path) -> Path:
    return reload_root_dir / ACK_BASENAME


def lua_long_string(s: str) -> str:
    delim = ""
    while f"]{delim}]" in s:
        delim = delim + "="
    return f"[{delim}[{s}]{delim}]"


def build_inbox_lua(seq: int, patches: list[tuple[str, str]]) -> str:
    lines = ["return {", f"  seq = {seq},"]
    lines.append("  patches = {")
    for file_key, source in patches:
        lines.append(f"    {{ file = {lua_long_string(file_key)}, source = {lua_long_string(source)} }},")
    lines.append("  },")
    lines.append("}")
    return "\n".join(lines) + "\n"


def read_ack_seq(reload_root_dir: Path) -> int:
    path = ack_path(reload_root_dir)
    if not path.is_file():
        return 0
    try:
        raw = path.read_text(encoding="utf-8")
    except OSError:
        return 0
    try:
        data = json.loads(raw)
        seq = data.get("seq")
        if isinstance(seq, int) and seq >= 0:
            return seq
    except json.JSONDecodeError:
        pass
    match = re.search(r'"seq"\s*:\s*(\d+)', raw)
    if match:
        return int(match.group(1))
    return 0


def write_ack_json(reload_root_dir: Path, seq: int) -> None:
    """Test/helper mirror of in-game FileIO.Save(ack, ...)."""
    path = ack_path(reload_root_dir)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps({"seq": seq, "ok": True}), encoding="utf-8")


def clear_reload_dir_at(reload_root_dir: Path) -> None:
    """Remove ack/ping at reload root and all inbox/*.pld. No-op if root missing."""
    root = reload_root_dir
    if not root.is_dir():
        return
    for name in (ACK_BASENAME, PING_BASENAME):
        path = root / name
        if path.is_file():
            path.unlink()
    inbox = root / INBOX_SUBDIR
    if inbox.is_dir():
        for path in inbox.iterdir():
            if path.is_file():
                path.unlink()


def clear_reload_dir(custom_map_data: Path | None = None) -> None:
    clear_reload_dir_at(reload_root(custom_map_data))


if __name__ == "__main__":
    payload = build_inbox_lua(2, [("scenario/a.lua", "return {}")])
    assert "seq = 2" in payload
    assert "scenario/a.lua" in payload
    tmp = Path(os.environ.get("TEMP", ".")) / "_reload_contract_ack_test"
    tmp.mkdir(parents=True, exist_ok=True)
    root = tmp / RELOAD_DIR_NAME
    write_ack_json(root, 7)
    assert read_ack_seq(root) == 7
    inbox = root / INBOX_SUBDIR
    inbox.mkdir(parents=True, exist_ok=True)
    (inbox / f"1{INBOX_EXTENSION}").write_text("x", encoding="utf-8")
    (root / PING_BASENAME).write_text("ping", encoding="utf-8")
    clear_reload_dir(tmp)
    assert read_ack_seq(root) == 0
    assert not (inbox / f"1{INBOX_EXTENSION}").exists()
    assert not (root / PING_BASENAME).exists()
    print("reload_contract: ok")
