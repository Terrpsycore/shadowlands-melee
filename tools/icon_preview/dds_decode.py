"""Minimal DDS (DXT1/DXT3) to PNG converter for WC3 icon previews."""

from __future__ import annotations

import struct
import zlib
from pathlib import Path


def _unpack_rgb565(value: int) -> tuple[int, int, int]:
    r = ((value >> 11) & 0x1F) * 255 // 31
    g = ((value >> 5) & 0x3F) * 255 // 63
    b = (value & 0x1F) * 255 // 31
    return r, g, b


def _decode_dxt1_block(block: bytes) -> list[tuple[int, int, int, int]]:
    c0, c1 = struct.unpack("<HH", block[:4])
    bits = struct.unpack("<I", block[4:8])[0]

    colors = [(*_unpack_rgb565(c0), 255), (*_unpack_rgb565(c1), 255)]
    if c0 > c1:
        colors.extend(
            [
                (
                    (2 * colors[0][0] + colors[1][0]) // 3,
                    (2 * colors[0][1] + colors[1][1]) // 3,
                    (2 * colors[0][2] + colors[1][2]) // 3,
                    255,
                ),
                (
                    (colors[0][0] + 2 * colors[1][0]) // 3,
                    (colors[0][1] + 2 * colors[1][1]) // 3,
                    (colors[0][2] + 2 * colors[1][2]) // 3,
                    255,
                ),
            ]
        )
    else:
        colors.extend(
            [
                (
                    (colors[0][0] + colors[1][0]) // 2,
                    (colors[0][1] + colors[1][1]) // 2,
                    (colors[0][2] + colors[1][2]) // 2,
                    255,
                ),
                (0, 0, 0, 0),
            ]
        )

    out: list[tuple[int, int, int, int]] = []
    for y in range(4):
        for x in range(4):
            idx = (bits >> (2 * (4 * y + x))) & 0x3
            out.append(colors[idx])
    return out


def _decode_dxt5_block(block: bytes) -> list[tuple[int, int, int, int]]:
    alpha0, alpha1 = block[0], block[1]
    alpha_bits = int.from_bytes(block[2:8], "little")

    alphas = [alpha0, alpha1]
    if alpha0 > alpha1:
        for i in range(1, 7):
            alphas.append(((7 - i) * alpha0 + i * alpha1) // 7)
    else:
        for i in range(1, 5):
            alphas.append(((5 - i) * alpha0 + i * alpha1) // 5)
        alphas.extend([0, 255])

    alpha_values: list[int] = []
    for i in range(16):
        idx = (alpha_bits >> (3 * i)) & 0x7
        alpha_values.append(alphas[idx])

    colors = _decode_dxt1_block(block[8:16])
    return [(r, g, b, alpha_values[i]) for i, (r, g, b, _a) in enumerate(colors)]


def _decode_dxt3_block(block: bytes) -> list[tuple[int, int, int, int]]:
    alphas = block[:8]
    alpha_values: list[int] = []
    for i in range(16):
        byte = alphas[i // 2]
        nibble = (byte >> 4) if i % 2 == 0 else (byte & 0x0F)
        alpha_values.append(nibble * 17)

    color_block = block[8:16]
    colors = _decode_dxt1_block(color_block)
    return [(r, g, b, alpha_values[i]) for i, (r, g, b, _a) in enumerate(colors)]


def _decode_dxt(data: bytes, width: int, height: int, block_size: int, decoder) -> bytes:
    rgba = bytearray(width * height * 4)
    blocks_x = max(1, (width + 3) // 4)
    blocks_y = max(1, (height + 3) // 4)
    offset = 0

    for by in range(blocks_y):
        for bx in range(blocks_x):
            block = data[offset : offset + block_size]
            offset += block_size
            pixels = decoder(block)
            for py in range(4):
                for px in range(4):
                    x = bx * 4 + px
                    y = by * 4 + py
                    if x >= width or y >= height:
                        continue
                    idx = (y * width + x) * 4
                    r, g, b, a = pixels[py * 4 + px]
                    rgba[idx : idx + 4] = bytes((r, g, b, a))

    return bytes(rgba)


def write_png(path: Path, width: int, height: int, rgba: bytes) -> None:
    raw = b"".join(b"\x00" + rgba[y * width * 4 : (y + 1) * width * 4] for y in range(height))

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
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)


def convert_dds_to_png(source: Path, dest: Path) -> bool:
    data = source.read_bytes()
    if len(data) < 128 or data[:4] != b"DDS ":
        return False

    height, width = struct.unpack_from("<II", data, 12)
    fourcc = data[84:88]

    if fourcc == b"DXT1":
        rgba = _decode_dxt(data[128:], width, height, 8, _decode_dxt1_block)
    elif fourcc == b"DXT3":
        rgba = _decode_dxt(data[128:], width, height, 16, _decode_dxt3_block)
    elif fourcc == b"DXT5":
        rgba = _decode_dxt(data[128:], width, height, 16, _decode_dxt5_block)
    else:
        return False

    write_png(dest, width, height, rgba)
    return dest.is_file()
