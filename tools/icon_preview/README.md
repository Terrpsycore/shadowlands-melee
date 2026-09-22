# Icon Preview

Локальный picker иконок + preview command card для способностей.

Кеш и manifest — только в `tools/icon_preview/.cache/` (не трогает `.build/`).

## Требования

- `tools/icon_preview/.env` — путь к dump ассетов (см. `.env.example`)
- `lua tools/bake.lua` — generated IDs и `Icons.lua`
- Reforged `.dds` (DXT5) и WC3 `.blp` (palette/JPEG) — встроенные декодеры в `dds_decode.py` / `blp_decode.py`
- `texconv` опционален для прочих форматов; **не читает WC3 `.blp` напрямую** (только fallback после BLP-декодера для JPEG mip)

## Настройка

```powershell
copy tools\icon_preview\.env.example tools\icon_preview\.env
# отредактировать WC3_ASSETS
```

`.env`:
```
WC3_ASSETS=D:/Workspace/game/wc3/wc3-assets
ICON_PREVIEW_PORT=8000
```

Приоритет: переменная окружения → `.env` → fallback `../wc3-assets`.

Порт **8000** по умолчанию (раньше был 8765 — произвольный dev-порт, чтобы не пересекаться с 8080; можно менять в `.env`).

## Запуск

**cmd** (из корня репозитория):

```cmd
tools\icon_preview\run.cmd
```

**PowerShell**:

```powershell
.\tools\icon_preview\run.ps1
```

Или по шагам (cmd/PowerShell):

```powershell
lua tools/icon_preview/export.lua
python tools/icon_preview/build_cache.py
python tools/icon_preview/serve.py
```

Открыть http://127.0.0.1:8000/

Если порт занят (WinError 10048) — смените `ICON_PREVIEW_PORT` или остановите предыдущий процесс.

## Workflow

1. **Picker** — поиск иконки, copy `Icons.xxx` (ключ из каталога, не угадывается с диска)
2. **Units** — выбор faction → сетки Heroes / Units / Buildings с портретами
3. Клик юнита → sidebar: portrait + command card 4×3
4. **Pick icon…** / **Pick portrait…** → picker с контекстом назначения
5. **Auto-reload** — `run.ps1` запускает `--watch`; UI polling `generatedAt` каждые 1.5s

Picker по умолчанию скрывает иконки без ассета в dump (`available: false` в manifest после `build_cache.py`). Чекбокс «Показать недоступные» — для отладки. Фильтр folder: **CommandButtons** / **PassiveButtons** / **AutocastButtons** (On/Off-состояния).

Dummy/common юниты без `faction` скрыты.

URL state (minimal): `?u=slug&a=ability&i=iconKey&p=unit/ability` — сохраняется через `history.replaceState`, восстанавливается после F5.

## Файлы

| Файл | Назначение |
|------|------------|
| `.env` | `WC3_ASSETS`, `ICON_PREVIEW_PORT` (local, gitignored) |
| `export.lua` | data → `.cache/manifest.json` |
| `build_cache.py` | DDS/BLP → `.cache/thumbs/*.png` |
| `blp_decode.py` | WC3 BLP1 palette/JPEG → PNG |
| `serve.py` | static server (`allow_reuse_address` для Win10) |
| `static/` | UI |
