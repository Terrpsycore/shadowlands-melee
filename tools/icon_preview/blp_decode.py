"""Minimal WC3 BLP1 (palette/JPEG) to PNG converter for icon previews."""

from __future__ import annotations

import struct
import subprocess
import tempfile
from io import BytesIO
from pathlib import Path

from dds_decode import write_png

BLP1_HEADER_SIZE = 156
PALETTE_OFFSET = 156
PALETTE_SIZE = 256 * 4


def _read_blp1_header(
    data: bytes,
) -> tuple[int, int, int, int, tuple[int, ...], tuple[int, ...]]:
    if len(data) < BLP1_HEADER_SIZE or data[:4] != b"BLP1":
        raise ValueError("not a BLP1 file")

    content = struct.unpack_from("<I", data, 4)[0]
    alpha_bits = struct.unpack_from("<I", data, 8)[0]
    width, height = struct.unpack_from("<II", data, 12)
    offsets = struct.unpack_from("<" + "I" * 16, data, 28)
    sizes = struct.unpack_from("<" + "I" * 16, data, 92)
    return content, alpha_bits, width, height, offsets, sizes


def _palette_alpha(
    data: bytes, alpha_bits: int, offset: int, width: int, height: int, index: int
) -> int:
    pixel_count = width * height
    alpha_offset = offset + pixel_count

    if alpha_bits == 8:
        return data[alpha_offset + index]
    if alpha_bits == 4:
        byte = data[alpha_offset + index // 2]
        nibble = (byte >> 4) if index % 2 == 0 else (byte & 0x0F)
        return nibble * 17
    if alpha_bits == 1:
        byte = data[alpha_offset + index // 8]
        return 255 if (byte >> (7 - index % 8)) & 1 else 0
    return 255


def _decode_blp1_palette(data: bytes) -> tuple[int, int, bytes]:
    _content, alpha_bits, width, height, offsets, _sizes = _read_blp1_header(data)
    if width <= 0 or height <= 0:
        raise ValueError("invalid BLP1 dimensions")

    palette = data[PALETTE_OFFSET : PALETTE_OFFSET + PALETTE_SIZE]
    offset = offsets[0]
    indices = data[offset : offset + width * height]
    if len(indices) != width * height:
        raise ValueError("truncated BLP1 palette mip")

    rgba = bytearray(width * height * 4)
    for index, palette_index in enumerate(indices):
        blue, green, red, _palette_alpha_byte = struct.unpack_from(
            "4B", palette, palette_index * 4
        )
        alpha = _palette_alpha(data, alpha_bits, offset, width, height, index)
        out = index * 4
        rgba[out : out + 4] = bytes((red, green, blue, alpha))

    return width, height, bytes(rgba)


def _extract_blp1_jpeg(data: bytes) -> bytes:
    _content, _alpha_bits, _width, _height, offsets, sizes = _read_blp1_header(data)
    header_size = struct.unpack_from("<I", data, PALETTE_OFFSET)[0]
    if header_size <= 0:
        raise ValueError("invalid BLP1 JPEG header size")

    header_end = PALETTE_OFFSET + 4 + header_size
    if header_end > len(data) or offsets[0] > len(data) or sizes[0] <= 0:
        raise ValueError("truncated BLP1 JPEG payload")

    jpeg_header = data[PALETTE_OFFSET + 4 : header_end]
    jpeg_data = data[offsets[0] : offsets[0] + sizes[0]]
    return jpeg_header + jpeg_data


def _write_png_from_pil_image(dest: Path, image) -> None:
    from PIL import Image

    if image.mode != "RGBA":
        image = image.convert("RGBA")
    # WC3 BLP1 JPEG mips decode as BGR; PNG expects RGB.
    r, g, b, a = image.split()
    image = Image.merge("RGBA", (b, g, r, a))
    write_png(dest, image.width, image.height, image.tobytes())


def _decode_jpeg_blob_with_pil(jpeg_bytes: bytes, dest: Path) -> bool:
    try:
        from PIL import Image
    except ImportError:
        return False

    try:
        image = Image.open(BytesIO(jpeg_bytes))
    except Exception:
        return False

    try:
        _write_png_from_pil_image(dest, image)
    except Exception:
        return False
    return dest.is_file()


def _decode_jpeg_blob_with_texconv(jpeg_bytes: bytes, dest: Path, texconv: str) -> bool:
    dest.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="icon_preview_blp_") as temp_dir:
        temp_root = Path(temp_dir)
        source = temp_root / "payload.jpg"
        source.write_bytes(jpeg_bytes)

        cmd = [
            texconv,
            "-nologo",
            "-y",
            "-ft",
            "png",
            "-f",
            "R8G8B8A8_UNORM",
            "-o",
            str(temp_root),
            str(source),
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, check=False)
        if result.returncode != 0:
            return False

        produced = temp_root / f"{source.stem}.png"
        if not produced.is_file():
            return False
        produced.replace(dest)
    return dest.is_file()


def _decode_blp1_jpeg(data: bytes, dest: Path, texconv: str | None) -> bool:
    jpeg_bytes = _extract_blp1_jpeg(data)
    if _decode_jpeg_blob_with_pil(jpeg_bytes, dest):
        return True
    if texconv:
        return _decode_jpeg_blob_with_texconv(jpeg_bytes, dest, texconv)
    return False


def convert_blp_to_png(source: Path, dest: Path, texconv: str | None = None) -> bool:
    data = source.read_bytes()
    if data[:4] != b"BLP1":
        return False

    content = struct.unpack_from("<I", data, 4)[0]
    try:
        if content == 1:
            width, height, rgba = _decode_blp1_palette(data)
            write_png(dest, width, height, rgba)
            return dest.is_file()
        if content == 0:
            return _decode_blp1_jpeg(data, dest, texconv)
    except (ValueError, struct.error):
        return False
    return False
