# Icon Preview

Локальный picker иконок + preview command card для способностей.

Кеш и manifest — только в `tools/icon_preview/.cache/` (не трогает `.build/`).

## Требования

- `tools/icon_preview/.env` — пути к dump и custom-ассетам (см. `.env.example`)
- **`wc3 assets .`** — `Icons.lua` + `custom_icon_index.lua` (scan `WC3_ASSETS` / `WC3_CUSTOM`); см. [Bake](../../README.md#bake) в корневом README
- **`wc3 build .`** — IDs/slugs и реестры (`src/data/generated/`, `src/scenario/generated/`); нужен для вкладки Units (data.units)
- Reforged `.dds` (DXT5) и WC3 `.blp` (palette/JPEG) — встроенные декодеры в `dds_decode.py` / `blp_decode.py`
- `texconv` опционален для прочих форматов; **не читает WC3 `.blp` напрямую** (только fallback после BLP-декодера для JPEG mip)

`run.ps1` при отсутствии `Icons.lua` вызывает `asset_catalogs.lua` сам — для полного workflow лучше явно `wc3 assets .`.

## Настройка

```powershell
copy tools\icon_preview\.env.example tools\icon_preview\.env
# отредактировать WC3_ASSETS и WC3_CUSTOM
```

`.env`:
```
WC3_ASSETS=D:/Workspace/game/wc3/wc3-assets
WC3_CUSTOM=D:/Workspace/game/wc3/wc3-custom
ICON_PREVIEW_PORT=8000
```

Приоритет: переменная окружения → `.env` → fallback (`../wc3-assets`, `../wc3-custom`).

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
wc3 assets .
wc3 build .
lua tools/icon_preview/export.lua
python tools/icon_preview/build_cache.py
python tools/icon_preview/serve.py
```

Открыть http://127.0.0.1:8000/

Если порт занят (WinError 10048) — смените `ICON_PREVIEW_PORT` или остановите предычущий процесс.

## Manifest (icons.json + units.json)

Каталог разделён на два артефакта с разными триггерами rebuild:

| Файл | Содержимое | Когда пересобирать |
|------|------------|-------------------|
| `.cache/icons.json` | `icons[]`, `assetsRoot`, `customRoot`, `generatedAt` | `Icons.lua`, `custom_icon_index.lua`, wc3 assets; после — `build_cache.py` |
| `.cache/units.json` | `units[]`, `warnings[]`, `generatedAt` | изменения в `src/data/` (units, abilities, items) |
| `.cache/icons.stamp` / `.cache/units.stamp` | одна строка `generatedAt` | пишутся вместе с JSON; UI polling по stamp (без parse больших файлов) |

Export:

```powershell
lua tools/icon_preview/export.lua           # оба файла
lua tools/icon_preview/export.lua --icons   # только icons.json
lua tools/icon_preview/export.lua --units   # только units.json
```

UI загружает оба JSON. Picker → `icons.json`; вкладка Units / assign → `units.json` + `icons.json` для резолва иконок.

## Watch (`serve.py --watch`)

`run.ps1` запускает сервер с `--watch`. Debounce/coalesce ≥ 0.5s сохранён.

| Изменение | Rebuild |
|-----------|---------|
| `src/data/**` | `export.lua --units` (без `build_cache`; lookup из `icons.json` или `Icons.lua` без disk scan) |
| `Icons.lua` или `custom_icon_index.lua` | `export.lua --icons` + `build_cache.py` |

Перед icons-rebuild проверяется стабильность mtime каталога (race при записи `Icons.lua` во время `wc3 assets`).

UI polling `/icons.stamp` + `/units.stamp` каждые 1.5s; полный JSON — только при изменении stamp. Частичный rerender: units-only не трогает icon grid.

## Workflow

1. **Picker** — поиск иконки, copy `Icons.xxx` (ключ из каталога, не угадывается с диска)
2. **Units** — выбор faction → сетки Heroes / Units / Buildings с портретами
3. Клик юнита → sidebar: portrait + command card 4×3
4. **Pick icon…** / **Pick portrait…** → picker с контекстом назначения
5. **Auto-reload** — `run.ps1` запускает `--watch`; UI polling `generatedAt` каждые 1.5s

Picker по умолчанию скрывает иконки без ассета в dump (`available: false` в icons.json после `build_cache.py`). Чекбокс «Показать недоступные» — для отладки. Фильтр folder: **CommandButtons** / **PassiveButtons** / **AutocastButtons** / **Custom**. Custom passive/autocast попадают в соответствующие фильтры; в сетке — `displayKey` без префиксов `pas`/`autocast`. Префиксные disabled-варианты (`DIS…`, `ATCdisbtn…`) скрыты в picker, но импортируются companions вместе с основной иконкой при sync imports.

## Custom icons

1. Положить `.blp`/`.dds` в `WC3_CUSTOM/ReplaceableTextures/` — WC3-layout:
   - `CommandButtons/BTNFoo` — активные способности
   - `PassiveButtons/PASBTNFoo` — пассивы
   - `CommandButtonsDisabled/DISBTNFoo` — disabled companion к primary
   - `AutocastButtons/ATCbtnFoo` — autocast (опционально)
2. **`wc3 assets .`** — scan → key из папки + имени (`CommandButtons/BTNFoo` → `Icons.foo`, `AutocastButtons/ATCbtnFoo` → `Icons.autocastFoo`, `PassiveButtons/PASBTNFoo` → `Icons.pasFoo`), editor path = mirror layout. Дубликаты vanilla key — skip + warning.
3. Назначить `Icons.xxx` в `src/data/` → **`wc3 build . --imports`** или **`wc3 go . --imports`** (sync referenced → `imports/ReplaceableTextures/...`).
4. Picker: custom иконки в фильтрах по category (**CommandButtons** / **PassiveButtons** / …), copy `Icons.xxx`.

Dummy/common юниты без `faction` скрыты.

URL state (minimal): `?u=slug&a=ability&i=iconKey&p=unit/ability` — сохраняется через `history.replaceState`, восстанавливается после F5.

## Файлы

| Файл | Назначение |
|------|------------|
| `.env` | `WC3_ASSETS`, `WC3_CUSTOM`, `ICON_PREVIEW_PORT` (local, gitignored) |
| `export.lua` | data/assets → `.cache/icons.json` + `.cache/units.json` |
| `export_common.lua` | JSON/helpers для export |
| `build_cache.py` | DDS/BLP → `.cache/thumbs/*.png`, обновляет `icons.json` |
| `blp_decode.py` | WC3 BLP1 palette/JPEG → PNG |
| `serve.py` | static server + `--watch` (split rebuild) |
| `static/` | UI |
