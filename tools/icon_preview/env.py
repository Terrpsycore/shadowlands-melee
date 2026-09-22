"""Load tools/icon_preview/.env (KEY=VALUE, # comments)."""

from __future__ import annotations

import os
from pathlib import Path

ENV_PATH = Path(__file__).resolve().parent / ".env"


def load_dotenv(path: Path = ENV_PATH) -> dict[str, str]:
    if not path.is_file():
        return {}

    values: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key:
            values[key] = value
    return values


def apply_dotenv(path: Path = ENV_PATH) -> dict[str, str]:
    values = load_dotenv(path)
    for key, value in values.items():
        os.environ.setdefault(key, value)
    return values
