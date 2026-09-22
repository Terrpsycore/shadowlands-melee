"""Build PNG thumbnails for icon preview manifest."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

from blp_decode import convert_blp_to_png
from dds_decode import convert_dds_to_png
from env import apply_dotenv

ROOT = Path(__file__).resolve().parents[2]
CACHE_DIR = ROOT / "tools" / "icon_preview" / ".cache"
MANIFEST_PATH = CACHE_DIR / "manifest.json"
THUMBS_DIR = CACHE_DIR / "thumbs"
PLACEHOLDER_NAME = "_missing.png"


def resolve_assets_root(raw: str | None) -> Path:
    apply_dotenv()
    value = raw or os.environ.get("WC3_ASSETS") or "../wc3-assets"
    return Path(value).resolve()


def normalize_path(path: str) -> str:
    return path.replace("/", "\\")


def editor_path_variants(editor_path: str) -> list[Path]:
    """Map editor .blp path to likely on-disk filenames."""
    rel = normalize_path(editor_path)
    parts = [part for part in rel.split("\\") if part]
    if len(parts) < 2:
        return []

    folder = parts[-2]
    filename = parts[-1]
    stem = filename[:-4] if filename.lower().endswith(".blp") else filename
    variants = [
        f"{stem}.dds",
        f"{stem}.blp",
        f"{stem.lower()}.dds",
        f"{stem.lower()}.blp",
        f"{filename}",
        f"{filename.lower()}",
    ]

    unique: list[Path] = []
    seen: set[str] = set()
    for name in variants:
        candidate = f"ReplaceableTextures\\{folder}\\{name}"
        key = candidate.lower()
        if key in seen:
            continue
        seen.add(key)
        unique.append(Path(candidate))
    return unique


def find_source_file(assets_root: Path, editor_path: str) -> Path | None:
    for rel in editor_path_variants(editor_path):
        candidate = assets_root / rel
        if candidate.is_file():
            return candidate
    return None


def find_texconv() -> str | None:
    env = os.environ.get("TEXCONV")
    if env and Path(env).is_file():
        return env

    found = shutil.which("texconv")
    if found:
        return found

    for candidate in (
        Path("C:/Program Files/Microsoft DirectXTex/texconv.exe"),
        Path("C:/Tools/texconv/texconv.exe"),
    ):
        if candidate.is_file():
            return str(candidate)
    return None


def write_placeholder(path: Path) -> None:
    # 64x64 neutral placeholder PNG
    import struct
    import zlib

    width, height = 64, 64
    rgba = bytes([48, 48, 56, 255]) * (width * height)
    raw = b"".join(b"\x00" + rgba[i : i + width * 4] for i in range(0, len(rgba), width * 4))

    def chunk(tag: bytes, data: bytes) -> bytes:
        return (
            struct.pack(">I", len(data))
            + tag
            + data
            + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
        )

    png = b"".join(
        [
            b"\x89PNG\r\n\x1a\n",
            chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)),
            chunk(b"IDAT", zlib.compress(raw, 9)),
            chunk(b"IEND", b""),
        ]
    )
    path.write_bytes(png)


def convert_with_texconv(texconv: str, source: Path, dest: Path) -> bool:
    dest.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        texconv,
        "-nologo",
        "-y",
        "-ft",
        "png",
        "-f",
        "R8G8B8A8_UNORM",
        "-o",
        str(dest.parent),
        str(source),
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        return False

    produced = dest.parent / f"{source.stem}.png"
    if produced.is_file() and produced != dest:
        produced.replace(dest)
    return dest.is_file()


def convert_source(source: Path, dest: Path, texconv: str | None) -> bool:
    suffix = source.suffix.lower()
    if suffix == ".dds" and convert_dds_to_png(source, dest):
        return True
    if suffix == ".blp" and convert_blp_to_png(source, dest, texconv):
        return True
    if texconv:
        return convert_with_texconv(texconv, source, dest)
    return False


def mark_icon_available(icon: dict) -> None:
    icon["available"] = True
    icon.pop("missingReason", None)


def mark_icon_unavailable(icon: dict, reason: str) -> None:
    icon["available"] = False
    icon["missingReason"] = reason


def main() -> int:
    if not MANIFEST_PATH.is_file():
        print(f"missing manifest: {MANIFEST_PATH}\nrun: lua tools/icon_preview/export.lua", file=sys.stderr)
        return 1

    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    assets_root = resolve_assets_root(manifest.get("assetsRoot"))
    if not assets_root.is_dir():
        print(f"WC3_ASSETS not found: {assets_root}", file=sys.stderr)
        return 1

    THUMBS_DIR.mkdir(parents=True, exist_ok=True)
    texconv = find_texconv()
    if texconv:
        print(f"texconv: {texconv}")
    else:
        print(
            "texconv not found; using built-in decoders for .dds/.blp sources",
            file=sys.stderr,
        )

    placeholder = THUMBS_DIR / PLACEHOLDER_NAME
    if not placeholder.is_file():
        write_placeholder(placeholder)

    converted = 0
    reused = 0
    missing = 0

    for icon in manifest.get("icons", []):
        key = icon["key"]
        editor_path = icon["path"]
        thumb = THUMBS_DIR / f"{key}.png"
        icon["thumb"] = f"thumbs/{key}.png"

        source = find_source_file(assets_root, editor_path)
        if not source:
            shutil.copy2(placeholder, thumb)
            (THUMBS_DIR / f"{key}.missing").write_text("source", encoding="utf-8")
            mark_icon_unavailable(icon, "source")
            missing += 1
            continue

        missing_marker = THUMBS_DIR / f"{key}.missing"
        if (
            thumb.is_file()
            and not missing_marker.is_file()
            and thumb.stat().st_mtime >= source.stat().st_mtime
        ):
            mark_icon_available(icon)
            reused += 1
            continue

        if convert_source(source, thumb, texconv):
            missing_marker.unlink(missing_ok=True)
            mark_icon_available(icon)
            converted += 1
            continue

        shutil.copy2(placeholder, thumb)
        missing_marker.write_text("convert", encoding="utf-8")
        mark_icon_unavailable(icon, "convert")
        missing += 1

    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print(f"icon preview cache: {THUMBS_DIR}")
    print(f"  converted: {converted}")
    print(f"  reused: {reused}")
    print(f"  missing/placeholder: {missing}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
