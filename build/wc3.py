import argparse
import os
import shutil
import subprocess
from enum import StrEnum
from pathlib import Path


class Mode(StrEnum):
    BUILD = "build"
    RUN = "run"
    GO = "go"


parser = argparse.ArgumentParser(description="...")
parser.add_argument("mode", choices=list(Mode), type=Mode)
parser.add_argument("path", type=str)
args = parser.parse_args()

USER_DIR = "C:/Users/nornil"
BUILDER_EXE = Path(
    f"{USER_DIR}/.vscode/extensions/dencer.warcraft-vscode-0.3.8-win32-x64/bin/wc3.exe"
)
MAPS_DIR = Path(f"{USER_DIR}/Documents/Warcraft III/Maps/Test")
GAME_EXE = Path("C:/Games/Warcraft III/_retail_/x86_64/Warcraft III.exe")
EDITOR_EXE = Path("C:/Games/Warcraft III/_retail_/x86_64/World Editor.exe")
LUA = Path("C:/Programs/Lua/lua55.exe")  # или полный путь к lua.exe


def main(mode: Mode, _project_path: str):
    project_path = Path(_project_path).resolve()

    match mode:
        case Mode.BUILD:
            build(project_path)
        case Mode.RUN:
            run(project_path)
        case Mode.GO:
            go(project_path)


def edit(project_path: Path):
    build(project_path)
    run(project_path)


def go(project_path: Path):
    build(project_path)
    run(project_path)


def build(project_path: Path):
    bake(project_path)
    subprocess.run([BUILDER_EXE, "build", project_path], check=True)


def bake(project_path: Path):
    try:
        subprocess.run(
            [LUA, "objediting/gen_ids.lua"],
            cwd=project_path,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        print("Error occurred!")
        print("Return code:", e.returncode)
        print("Error output:", e.stderr)
        print("Standard output:", e.stdout)


def run(project_path: Path):
    build_path = project_path / ".build/_warcraft_vscode_test.w3x"
    map_path = copy(build_path)
    run_map(map_path)


def copy(map_path: Path) -> Path:
    map_fn = os.path.split(map_path)[-1]
    destination_path = MAPS_DIR / map_fn
    shutil.copy(map_path, destination_path)
    return destination_path


def run_map(map_path: Path):
    GAME_ARGS = [
        "-launch",
        "-mapdiff",
        "1",
        "-testmapprofile",
        "WorldEdit",
        "-fixedseed",
        "1",
    ]
    args = [str(GAME_EXE), *GAME_ARGS, "-loadfile", str(map_path)]
    print(" ".join(args))
    subprocess.Popen(
        args,
        start_new_session=True,
    )


main(args.mode, args.path)
