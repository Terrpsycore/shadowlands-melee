import argparse
import json
import os
import shutil
import subprocess
import sys
from enum import StrEnum
from pathlib import Path


class Mode(StrEnum):
    ASSETS = "assets"
    BUILD = "build"
    UPDATE = "update"
    RUN = "run"
    GO = "go"
    WATCH = "watch"
    DESIGN = "design"


parser = argparse.ArgumentParser(description="...")
parser.add_argument("mode", choices=list(Mode), type=Mode)
parser.add_argument("path", type=str)
parser.add_argument(
    "--imports",
    action="store_true",
    help="sync referenced custom icons into imports/ (build and go only)",
)
parser.add_argument(
    "--hot-reload",
    action="store_true",
    help="with go: start hot_reload_watch.py in background",
)
args = parser.parse_args()

USER_DIR = "C:/Users/nornil"
BUILDER_EXE = Path(
    f"{USER_DIR}/.vscode/extensions/dencer.warcraft-vscode-0.3.8-win32-x64/bin/wc3.exe"
)
MAPS_DIR = Path(f"{USER_DIR}/Documents/Warcraft III/Maps/Test")
# Repack after hand-edited .build/war3map.lua yields ~6.95 MB and WC3 rejects the map (~7.05+ MB OK).
MIN_W3X_BYTES = 7_050_000
GAME_EXE = Path("C:/Games/Warcraft III/_retail_/x86_64/Warcraft III.exe")
EDITOR_EXE = Path("C:/Games/Warcraft III/_retail_/x86_64/World Editor.exe")
LUA = Path("C:/Programs/Lua/lua55.exe")  # или полный путь к lua.exe

ERROR = "\033[31m"
RESET = "\033[0m"


def enable_ansi_colors() -> None:
    if os.name != "nt":
        return
    try:
        import ctypes

        kernel32 = ctypes.windll.kernel32  # type: ignore[attr-defined]
        mode = ctypes.c_ulong()
        for handle_id in (-11, -12):
            handle = kernel32.GetStdHandle(handle_id)
            if kernel32.GetConsoleMode(handle, ctypes.byref(mode)):
                kernel32.SetConsoleMode(handle, mode.value | 0x0004)
    except (AttributeError, OSError):
        return


def print_error(message: str) -> None:
    print(f"{ERROR}{message}{RESET}", file=sys.stderr)


enable_ansi_colors()


def main(
    mode: Mode,
    _project_path: str,
    *,
    sync_imports: bool = False,
    hot_reload: bool = False,
):
    project_path = Path(_project_path).resolve()

    match mode:
        case Mode.ASSETS:
            bake_assets(project_path)
        case Mode.BUILD:
            build(project_path, sync_imports=sync_imports)
        case Mode.UPDATE:
            build(project_path)
            copy(project_path)
        case Mode.RUN:
            run(project_path)
        case Mode.GO:
            go(
                project_path,
                sync_imports=sync_imports,
                hot_reload=hot_reload,
            )
        case Mode.WATCH:
            watch_hot_reload(project_path)
        case Mode.DESIGN:
            design(project_path)


def go(
    project_path: Path,
    *,
    sync_imports: bool = False,
    hot_reload: bool = False,
):
    build(project_path, sync_imports=sync_imports)
    if hot_reload:
        spawn_hot_reload_watcher(project_path)
    run(project_path)


def trim_stack_trace(text: str) -> str:
    if "stack traceback:" in text:
        return text.split("stack traceback:")[0].rstrip()
    return text.rstrip()


def print_wc3_output(stdout: str) -> None:
    for line in stdout.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            print(line)
            continue

        match event.get("event"):
            case "progress":
                continue
            case "error":
                msg = trim_stack_trace(event.get("message", line))
                print_error(msg)
                if event.get("file") and event.get("line"):
                    print_error(f"  → {event['file']}:{event['line']}")
            case _:
                print(line)


def run_wc3(args: list[str | Path], *, cwd: Path | None = None) -> None:
    if cwd is None and len(args) >= 2:
        maybe = Path(str(args[-1]))
        if maybe.is_dir() and (maybe / "warcraft.json").is_file():
            cwd = maybe.resolve()
    result = subprocess.run(
        [str(arg) for arg in args],
        cwd=str(cwd) if cwd else None,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.stdout:
        print_wc3_output(result.stdout)
    if result.stderr:
        print_error(result.stderr.rstrip("\n"))
    if result.returncode != 0:
        sys.exit(result.returncode)


def clean_stale_wc3_build(project_path: Path) -> None:
    """Drop pack inputs that may still carry legacy war3map loader/tail patches."""
    build_dir = project_path / ".build"
    for name in (
        "war3map.lua",
        "_warcraft_vscode_test.w3x",
        "w3x-patched.bin",
        "w3x-plain.bin",
    ):
        path = build_dir / name
        if path.is_file():
            path.unlink()
            print(f"clean: removed {path.name}")


def verify_w3x_pack(project_path: Path) -> None:
    w3x = project_path / ".build" / "_warcraft_vscode_test.w3x"
    if not w3x.is_file():
        print_error(f"missing {w3x} after wc3 build")
        sys.exit(1)
    size = w3x.stat().st_size
    if size < MIN_W3X_BYTES:
        print_error(
            f".w3x too small ({size} bytes) — likely repacked after patch_war3map*.py. "
            f"Run: python build/wc3.py build . (do not run wc3 pack on patched war3map.lua)"
        )
        sys.exit(1)
    war3map = project_path / ".build" / "war3map.lua"
    if war3map.is_file():
        text = war3map.read_text(encoding="utf-8")
        boundary = "\nP['"
        root = text[: text.find(boundary)] if boundary in text else text[:5000]
        if "_G.__HOT_RELOAD__ = true" in root:
            print_error(
                "war3map root loader still has legacy hot-reload patch — "
                "delete .build/war3map.lua and rebuild (reload no longer uses war3map hooks)"
            )
            sys.exit(1)
    print(f"map pack OK ({size // 1024} KiB)")


def run_python(args: list[str | Path]) -> None:
    result = subprocess.run(
        [str(arg) for arg in args],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.stdout:
        print(result.stdout.rstrip())
    if result.stderr:
        print_error(result.stderr.rstrip())
    if result.returncode != 0:
        sys.exit(result.returncode)


def build(project_path: Path, *, sync_imports: bool = False):
    bake(project_path)
    if sync_imports:
        run_lua_script(project_path, "tools/bake_imports.lua")
    project_path = project_path.resolve()
    clean_stale_wc3_build(project_path)
    run_wc3([BUILDER_EXE, "build", project_path], cwd=project_path)
    verify_w3x_pack(project_path)


def run_lua_script(project_path: Path, script: str) -> None:
    result = subprocess.run(
        [str(LUA), script],
        cwd=project_path,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode == 0:
        if result.stdout:
            end = "" if result.stdout.endswith("\n") else "\n"
            print(result.stdout, end=end)
        return

    output = trim_stack_trace(result.stdout or "")
    if result.stderr:
        stderr = trim_stack_trace(result.stderr)
        if stderr:
            output = f"{output}\n{stderr}" if output else stderr

    lua_prefix = f"{LUA}: "
    for line in output.splitlines():
        line = line.rstrip()
        if not line:
            continue
        line = line.removeprefix(lua_prefix)
        if line.startswith("Generated "):
            print(line)
        else:
            print_error(line)

    sys.exit(result.returncode)


def bake(project_path: Path) -> None:
    run_lua_script(project_path, "tools/bake.lua")


def bake_assets(project_path: Path) -> None:
    run_lua_script(project_path, "tools/bake_assets.lua")


def run(project_path: Path):
    map_path = copy(project_path)
    run_map(map_path)


def copy(project_path: Path) -> Path:
    map_path = project_path / ".build/_warcraft_vscode_test.w3x"
    verify_w3x_pack(project_path)
    map_fn = os.path.split(map_path)[-1]
    destination_path = MAPS_DIR / map_fn
    shutil.copy2(map_path, destination_path)
    print(f"copied map -> {destination_path} ({destination_path.stat().st_size // 1024} KiB)")
    return destination_path


def design(project_path: Path):
    if not os.path.isfile(project_path / "warcraft.json"):
        raise ValueError("Not warcraft map folder")
    src = Path("D:/Workspace/mine/obsidian-core/glagol/game/wc3/factions")
    dst = Path(project_path / "docs/design/factions")
    if dst.exists():
        shutil.rmtree(dst)
    shutil.copytree(src, dst)


def watch_hot_reload(project_path: Path) -> None:
    script = project_path / "tools" / "hot_reload_watch.py"
    if not script.is_file():
        print_error(f"missing {script}")
        sys.exit(1)
    os.execv(sys.executable, [sys.executable, str(script), str(project_path)])


def spawn_hot_reload_watcher(project_path: Path) -> None:
    script = project_path / "tools" / "hot_reload_watch.py"
    if not script.is_file():
        print_error(f"missing {script}")
        sys.exit(1)
    subprocess.Popen(
        [sys.executable, str(script), str(project_path)],
        cwd=project_path,
        start_new_session=True,
    )
    print("hot reload watcher started (background)")


def run_map(map_path: Path):
    GAME_ARGS = [
        "-launch",
        "-mapdiff",
        "1",
        "-testmapprofile",
        "WorldEdit",
        "-allowLocalFiles",
        "-fixedseed",
        "1",
    ]
    args = [str(GAME_EXE), *GAME_ARGS, "-loadfile", str(map_path)]
    print(" ".join(args))
    subprocess.Popen(
        args,
        start_new_session=True,
    )


main(
    args.mode,
    args.path,
    sync_imports=args.imports,
    hot_reload=args.hot_reload,
)
