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
WATCH_PATHS = (
    REPO_ROOT / "src" / "data",
    REPO_ROOT / "src" / "vendor" / "assets" / "generated",
)
WATCH_DEBOUNCE_SEC = 0.5
WATCH_POLL_SEC = 1.0


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
        if clean == "/manifest.json":
            return str(CACHE_DIR / "manifest.json")
        resolved = (ROOT / clean.lstrip("/")).resolve()
        if ROOT.resolve() not in resolved.parents and resolved != ROOT.resolve():
            return str(STATIC_DIR / "index.html")
        return str(resolved)

    def end_headers(self) -> None:
        if self.path.split("?", 1)[0] in ("/manifest.json",):
            self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, format: str, *args) -> None:
        print(f"[icon-preview] {self.address_string()} - {format % args}")


class ReusableTCPServer(socketserver.TCPServer):
    allow_reuse_address = True


def snapshot_mtimes() -> dict[str, float]:
    seen: dict[str, float] = {}
    for root in WATCH_PATHS:
        if not root.is_dir():
            continue
        for path in root.rglob("*"):
            if path.is_file():
                seen[str(path)] = path.stat().st_mtime
    return seen


def resolve_lua() -> str:
    return os.environ.get("LUA", "C:/Programs/Lua/lua55.exe")


def run_pipeline() -> None:
    lua = resolve_lua()
    print("[icon-preview] rebuilding manifest…")
    subprocess.run([lua, "tools/icon_preview/export.lua"], cwd=REPO_ROOT, check=True)
    subprocess.run([sys.executable, "tools/icon_preview/build_cache.py"], cwd=REPO_ROOT, check=True)
    print("[icon-preview] rebuild done")


def watch_loop(stop_event: threading.Event) -> None:
    last_snapshot = snapshot_mtimes()
    pending = False
    changed_at = 0.0

    while not stop_event.is_set():
        current = snapshot_mtimes()
        if current != last_snapshot:
            last_snapshot = current
            pending = True
            changed_at = time.monotonic()

        if pending and (time.monotonic() - changed_at) >= WATCH_DEBOUNCE_SEC:
            pending = False
            try:
                run_pipeline()
            except subprocess.CalledProcessError as err:
                print(f"[icon-preview] rebuild failed: {err}", file=sys.stderr)

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
        help="re-export manifest when src/data or generated assets change",
    )
    args = parser.parse_args()

    if not (CACHE_DIR / "manifest.json").is_file():
        raise SystemExit("missing .cache/manifest.json — run export.lua first")

    stop_event = threading.Event()
    if args.watch:
        watcher = threading.Thread(target=watch_loop, args=(stop_event,), daemon=True)
        watcher.start()
        print("[icon-preview] watching src/data and src/vendor/assets/generated")

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
