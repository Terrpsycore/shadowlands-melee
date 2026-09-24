"""Serve icon preview UI and cached assets."""

from __future__ import annotations

import argparse
import http.server
import os
import socketserver
import subprocess
import sys
import threading
import time
from pathlib import Path

from env import apply_dotenv

ROOT = Path(__file__).resolve().parent
REPO_ROOT = ROOT.parents[1]
CACHE_DIR = ROOT / ".cache"
STATIC_DIR = ROOT / "static"
DEFAULT_PORT = 8000

DATA_WATCH_ROOT = REPO_ROOT / "src" / "data"
ICONS_WATCH_FILES = (
    REPO_ROOT / "src" / "vendor" / "assets" / "generated" / "Icons.lua",
    REPO_ROOT / "src" / "vendor" / "assets" / "generated" / "custom_icon_index.lua",
)

WATCH_DEBOUNCE_SEC = 0.5
WATCH_POLL_SEC = 1.0
ICONS_STABLE_SEC = 0.5

NO_CACHE_PATHS = frozenset({"/icons.json", "/units.json", "/icons.stamp", "/units.stamp"})


class PreviewHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def translate_path(self, path: str) -> str:
        clean = path.split("?", 1)[0]
        if clean in ("", "/"):
            return str(STATIC_DIR / "index.html")
        if clean.startswith("/static/"):
            return str(STATIC_DIR / clean.removeprefix("/static/"))
        if clean.startswith("/.cache/"):
            return str(CACHE_DIR / clean.removeprefix("/.cache/"))
        if clean == "/icons.json":
            return str(CACHE_DIR / "icons.json")
        if clean == "/units.json":
            return str(CACHE_DIR / "units.json")
        if clean == "/icons.stamp":
            return str(CACHE_DIR / "icons.stamp")
        if clean == "/units.stamp":
            return str(CACHE_DIR / "units.stamp")
        resolved = (ROOT / clean.lstrip("/")).resolve()
        if ROOT.resolve() not in resolved.parents and resolved != ROOT.resolve():
            return str(STATIC_DIR / "index.html")
        return str(resolved)

    def end_headers(self) -> None:
        if self.path.split("?", 1)[0] in NO_CACHE_PATHS:
            self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, format: str, *args) -> None:
        print(f"[icon-preview] {self.address_string()} - {format % args}")


class ReusableTCPServer(socketserver.TCPServer):
    allow_reuse_address = True


def snapshot_data_mtimes() -> dict[str, float]:
    seen: dict[str, float] = {}
    if not DATA_WATCH_ROOT.is_dir():
        return seen
    for path in DATA_WATCH_ROOT.rglob("*"):
        if path.is_file():
            seen[str(path)] = path.stat().st_mtime
    return seen


def snapshot_icons_mtimes() -> dict[str, float]:
    seen: dict[str, float] = {}
    for path in ICONS_WATCH_FILES:
        if path.is_file():
            seen[str(path)] = path.stat().st_mtime
    return seen


def resolve_lua() -> str:
    return os.environ.get("LUA", "C:/Programs/Lua/lua55.exe")


def icons_catalog_stable() -> bool:
    first = snapshot_icons_mtimes()
    time.sleep(ICONS_STABLE_SEC)
    second = snapshot_icons_mtimes()
    return first == second


def run_units_pipeline() -> None:
    lua = resolve_lua()
    print("[icon-preview] rebuilding units.json…")
    subprocess.run(
        [lua, "tools/icon_preview/export.lua", "--units"],
        cwd=REPO_ROOT,
        check=True,
    )
    print("[icon-preview] units rebuild done")


def run_icons_pipeline() -> bool:
    if not icons_catalog_stable():
        print("[icon-preview] icon catalog still changing, deferring…")
        return False

    lua = resolve_lua()
    print("[icon-preview] rebuilding icons.json + thumbs…")
    subprocess.run(
        [lua, "tools/icon_preview/export.lua", "--icons"],
        cwd=REPO_ROOT,
        check=True,
    )
    subprocess.run(
        [sys.executable, "tools/icon_preview/build_cache.py"],
        cwd=REPO_ROOT,
        check=True,
    )
    print("[icon-preview] icons rebuild done")
    return True


def watch_loop(stop_event: threading.Event) -> None:
    last_data = snapshot_data_mtimes()
    last_icons = snapshot_icons_mtimes()
    data_pending = False
    icons_pending = False
    data_changed_at = 0.0
    icons_changed_at = 0.0

    while not stop_event.is_set():
        current_data = snapshot_data_mtimes()
        if current_data != last_data:
            last_data = current_data
            data_pending = True
            data_changed_at = time.monotonic()

        current_icons = snapshot_icons_mtimes()
        if current_icons != last_icons:
            last_icons = current_icons
            icons_pending = True
            icons_changed_at = time.monotonic()

        now = time.monotonic()

        if data_pending and (now - data_changed_at) >= WATCH_DEBOUNCE_SEC:
            data_pending = False
            try:
                run_units_pipeline()
            except subprocess.CalledProcessError as err:
                print(f"[icon-preview] units rebuild failed: {err}", file=sys.stderr)

        if icons_pending and (now - icons_changed_at) >= WATCH_DEBOUNCE_SEC:
            try:
                if run_icons_pipeline():
                    icons_pending = False
                else:
                    icons_changed_at = time.monotonic()
            except subprocess.CalledProcessError as err:
                icons_pending = False
                print(f"[icon-preview] icons rebuild failed: {err}", file=sys.stderr)

        stop_event.wait(WATCH_POLL_SEC)


def main() -> None:
    apply_dotenv()
    parser = argparse.ArgumentParser(description="Serve icon preview")
    parser.add_argument(
        "--port",
        type=int,
        default=int(os.environ.get("ICON_PREVIEW_PORT", DEFAULT_PORT)),
    )
    parser.add_argument(
        "--watch",
        action="store_true",
        help="re-export icons.json / units.json when data or icon catalog changes",
    )
    args = parser.parse_args()

    missing = [
        name
        for name, path in (
            ("icons.json", CACHE_DIR / "icons.json"),
            ("units.json", CACHE_DIR / "units.json"),
        )
        if not path.is_file()
    ]
    if missing:
        raise SystemExit(
            f"missing .cache/{', '.join(missing)} — run: lua tools/icon_preview/export.lua"
        )

    stop_event = threading.Event()
    if args.watch:
        watcher = threading.Thread(target=watch_loop, args=(stop_event,), daemon=True)
        watcher.start()
        print("[icon-preview] watching src/data and icon catalog (Icons.lua, custom_icon_index.lua)")

    try:
        with ReusableTCPServer(("127.0.0.1", args.port), PreviewHandler) as httpd:
            url = f"http://127.0.0.1:{args.port}/"
            print(f"icon preview: {url}")
            print("press Ctrl+C to stop")
            httpd.serve_forever()
    except OSError as err:
        raise SystemExit(
            f"port {args.port} busy ({err}). "
            f"Stop the other process or set ICON_PREVIEW_PORT in tools/icon_preview/.env"
        ) from err
    finally:
        stop_event.set()


if __name__ == "__main__":
    main()
