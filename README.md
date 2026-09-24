# shadowlands-melee

Custom Altered Melee-карта для Warcraft III в тематике World of Warcraft: Shadowlands

## Стек

- Lua 5.3 — runtime WC3 + standalone для tools/oe
- [warcraft-vscode](https://marketplace.visualstudio.com/items?itemName=dencer.warcraft-vscode) — сборка карты
- Python 3 — `build/wc3.py`
- LuaLS — `.luarc.json`
- Community libs: Influa, DamageEngine, IngameConsole (`src/vendor/ext/`)

## Bake

Папки `*/generated/` в `.gitignore` — после clone нужна codegen.

- **`wc3 assets .`** — scan `WC3_ASSETS` / `WC3_CUSTOM` → `Icons.lua`, Models, `imports/` (редко: новые custom-иконки или обновление dump)
- **`wc3 build .`** — `tools/bake.lua` (IDs, реестры, validate) + сборка карты; требует уже сгенерированный `Icons.lua`
- **`wc3 build . --imports`** / **`wc3 go . --imports`** — то же + sync referenced custom → `imports/` (после назначения custom-иконок в data)

## Тесты

Лог - C:\Users\nornil\Documents\Warcraft III\CustomMapData\shadowlands-melee.txt

In-game автотесты в `src/tests/` (`factions/`, `mechanics/`, `data/`). `tests.init` подключает модули из `tests/generated/registry.lua` и **запускает их автоматически при старте карты**. Отдельного CLI test-runner нет.

Статическая проверка типов (LuaLS):

```powershell
& "C:/Programs/Lua/LuaLS/bin/lua-language-server.exe" --check .
& "C:/Programs/Lua/LuaLS/bin/lua-language-server.exe" --check src/tests
```

Шаблоны objediting runtime (`main-debug.lua`, `main-release.lua`) исключены через `workspace.ignoreDir` в `.luarc.json`.

Trade-off'ы и отложенные баги: [docs/adr/0001-luals-zero-warnings-trade-offs.md](docs/adr/0001-luals-zero-warnings-trade-offs.md), [docs/adr/0002-custom-assets-imports-vs-game-folder-dev.md](docs/adr/0002-custom-assets-imports-vs-game-folder-dev.md), [docs/known-issues.md](docs/known-issues.md).

## Ссылки

- [warcraft-vscode](https://marketplace.visualstudio.com/items?itemName=dencer.warcraft-vscode)
- [Object IDs (wc3edit)](https://forum.wc3edit.net/viewtopic.php?t=2648)
