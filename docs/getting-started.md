# Getting started

## Нужно на машине

- Warcraft III Reforged, в реестре `Allow Local Files = 1` (иначе нет лога тестов)
- Расширение [warcraft-vscode](https://marketplace.visualstudio.com/items?itemName=dencer.warcraft-vscode) — его `bin/wc3.exe` собирает карту
- Lua standalone (5.5) — для bake, Python 3.11+ — для `build/wc3.py`
- Пути ко всему этому — константы в начале `build/wc3.py`, править под себя
- Рядом с репо: `../wc3-assets` (dump vanilla) и `../wc3-custom` (наши иконки). Иначе — `$env:WC3_ASSETS`, `$env:WC3_CUSTOM`

## Команды

`wc3 <cmd> .` — личный алиас для `python build/wc3.py <cmd> .`.

| | |
|---|---|
| `assets` | каталоги ассетов → `src/vendor/assets/generated/`. После clone, при новых файлах в `wc3-custom` |
| `build` | bake (IDs, реестры) + сборка `.build/*.w3x` |
| `go` | `build` + копия в `Maps/Test` + запуск WC3 |
| `--imports` | к `build`/`go`: скопировать используемые custom-иконки в `imports/`. Нужен после назначения `Icons.xxx` в `src/data/` |
| `run` / `update` | только запуск / только build+копия |

## После clone

```powershell
mkdir "$env:USERPROFILE\Documents\Warcraft III\Maps\Test" -Force
python build/wc3.py assets .
python build/wc3.py go . --imports
```

`generated/` и `imports/` в gitignore — без `assets` bake падает на `missing Icons.lua`.

В игре кликнуть splash «нажмите любую клавишу», тесты стартуют сами. Лог: `Documents/Warcraft III/CustomMapData/shadowlands-melee.txt`.

## Иконки зелёные

По порядку, от дешёвого к дорогому. Контекст — [ADR 0002](adr/0002-custom-assets-imports-vs-game-folder-dev.md).

1. `wc3 assets .` — файл добавлен в `wc3-custom`, но `Icons.lua` устарел
2. Иконка должна быть указана через `Icons.xxx` в `src/data/` — только оттуда попадает в `imports/`
3. Был ли `--imports` — проверить `imports/ReplaceableTextures/`
4. Зелёная только disabled — нет `CommandButtonsDisabled/DISBTNxxx` в `wc3-custom`
5. Всё на месте — это cold-start баг `-loadfile`. «Начать заново» или загрузить из меню покажет правду. Обход для dev: зеркало файлов в `_retail_/ReplaceableTextures/`
