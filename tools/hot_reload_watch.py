#!/usr/bin/env python3
"""Watch src/scenario and src/utils; write hot-reload inbox for in-game poller."""

from __future__ import annotations

import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

try:
    from watchdog.events import FileSystemEvent, FileSystemEventHandler
    from watchdog.observers import Observer

    WATCHDOG = True
except ImportError:
    WATCHDOG = False
    FileSystemEventHandler = object  # type: ignore[misc, assignment]
    FileSystemEvent = object  # type: ignore[misc, assignment]
    Observer = None  # type: ignore[misc, assignment]

from reload_contract import (
    build_inbox_lua,
    read_ack_seq,
    reload_root,
)

WATCH_DIRS = ("scenario", "utils")
DEBOUNCE_MS = 400


def rel_preload_key(project_root: Path, path: Path) -> str | None:
    try:
        rel = path.resolve().relative_to((project_root / "src").resolve())
    except ValueError:
        return None
    parts = rel.parts
    if not parts or parts[0] not in WATCH_DIRS:
        return None
    key = rel.as_posix()
    if key.startswith("scenario/generated/"):
        return None
    return key


@dataclass
class PendingReload:
    seq: int = 0
    files: dict[str, str] = field(default_factory=dict)
    last_emit: float = 0.0

    def queue(self, file_key: str, body: str) -> None:
        self.files[file_key] = body

    def flush_if_ready(self, out_dir: Path, project_root: Path) -> bool:
        now = time.monotonic()
        if not self.files:
            return False
        if (now - self.last_emit) * 1000.0 < DEBOUNCE_MS:
            return False
        self.seq += 1
        patches = sorted(self.files.items())
        payload = build_inbox_lua(self.seq, patches)
        from reload_fileio import write_inbox_for_fileio_load

        target = write_inbox_for_fileio_load(out_dir, payload, project_root, seq=self.seq)
        print(f"[reload] inbox seq={self.seq} files={len(patches)} → {target.name}")
        self.files.clear()
        self.last_emit = now
        return True


class Handler(FileSystemEventHandler):
    def __init__(self, project_root: Path, pending: PendingReload) -> None:
        super().__init__()
        self.project_root = project_root
        self.pending = pending

    def _handle(self, path: Path) -> None:
        if path.suffix.lower() != ".lua":
            return
        key = rel_preload_key(self.project_root, path)
        if not key or not path.is_file():
            return
        try:
            body = path.read_text(encoding="utf-8")
        except OSError as exc:
            print(f"[reload] read error {path}: {exc}")
            return
        self.pending.queue(key, body)

    def on_modified(self, event: FileSystemEvent) -> None:
        if event.is_directory:
            return
        self._handle(Path(event.src_path))

    def on_created(self, event: FileSystemEvent) -> None:
        if event.is_directory:
            return
        self._handle(Path(event.src_path))


def poll_loop(project_root: Path, out_dir: Path, pending: PendingReload) -> None:
    src = project_root / "src"
    mtimes: dict[Path, float] = {}
    baseline = False

    print(f"[reload] polling {src} (no watchdog; pip install watchdog for events)")
    while True:
        if not baseline:
            for sub in WATCH_DIRS:
                root = src / sub
                if not root.is_dir():
                    continue
                for path in root.rglob("*.lua"):
                    try:
                        mtimes[path] = path.stat().st_mtime
                    except OSError:
                        pass
            baseline = True
            print(f"[reload] baseline {len(mtimes)} files (no flush)")
        else:
            for sub in WATCH_DIRS:
                root = src / sub
                if not root.is_dir():
                    continue
                for path in root.rglob("*.lua"):
                    try:
                        mtime = path.stat().st_mtime
                    except OSError:
                        continue
                    if mtimes.get(path) != mtime:
                        mtimes[path] = mtime
                        key = rel_preload_key(project_root, path)
                        if key:
                            try:
                                pending.queue(key, path.read_text(encoding="utf-8"))
                            except OSError:
                                pass
        pending.flush_if_ready(out_dir, project_root)
        time.sleep(DEBOUNCE_MS / 1000.0)


def watch(project_root: Path) -> int:
    out_dir = reload_root()
    out_dir.mkdir(parents=True, exist_ok=True)
    ack_seq = read_ack_seq(out_dir)
    pending = PendingReload(seq=ack_seq)
    print(f"[reload] out → {out_dir}")
    if ack_seq > 0:
        print(f"[reload] resume from ack seq={ack_seq} (next inbox={ack_seq + 1})")

    src = project_root / "src"

    if WATCHDOG and Observer is not None:
        handler = Handler(project_root, pending)
        observer = Observer()
        for sub in WATCH_DIRS:
            root = src / sub
            if root.is_dir():
                observer.schedule(handler, str(root), recursive=True)
        observer.start()
        print(f"[reload] watching {', '.join(WATCH_DIRS)} (watchdog)")
        try:
            while True:
                pending.flush_if_ready(out_dir, project_root)
                time.sleep(0.05)
        except KeyboardInterrupt:
            observer.stop()
            observer.join(timeout=2.0)
        return 0

    try:
        poll_loop(project_root, out_dir, pending)
    except KeyboardInterrupt:
        return 0


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: hot_reload_watch.py <project_root>", file=sys.stderr)
        return 1
    root = Path(sys.argv[1]).resolve()
    if not (root / "src").is_dir():
        print(f"not a project root: {root}", file=sys.stderr)
        return 1
    return watch(root)


if __name__ == "__main__":
    raise SystemExit(main())
