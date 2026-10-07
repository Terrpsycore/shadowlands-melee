# shadowlands-melee

Custom Altered Melee-карта для Warcraft III в тематике World of Warcraft: Shadowlands

## Стек

- Lua 5.3 — runtime WC3; Lua 5.5 standalone — `tools/bake.lua` и `tools/oe` (`build/wc3.py`)
- [warcraft-vscode](https://marketplace.visualstudio.com/items?itemName=dencer.warcraft-vscode) — сборка карты
- Python 3 — `build/wc3.py`
- LuaLS — `.luarc.json`
- Community libs: Influa, DamageEngine, IngameConsole (`src/vendor/ext/`)

Окружение, команды, первый запуск: [docs/getting-started.md](docs/getting-started.md).

## Bake

Папки `*/generated/` в `.gitignore` — после clone нужны `assets` и bake. Команды `assets` / `build` / `go` / `--imports` — [docs/getting-started.md](docs/getting-started.md).

## Тесты

Лог - C:\Users\nornil\Documents\Warcraft III\CustomMapData\shadowlands-melee.txt

In-game автотесты в `src/tests/` (`factions/`, `mechanics/`, `data/`). `tests.init` подключает модули из `tests/generated/registry.lua` и **запускает их автоматически при старте карты**. Отдельного CLI test-runner нет.

Статическая проверка типов (LuaLS):

```powershell
& "C:/Programs/Lua/LuaLS/bin/lua-language-server.exe" --check .
& "C:/Programs/Lua/LuaLS/bin/lua-language-server.exe" --check src/tests
```

Шаблоны objediting runtime (`main-debug.lua`, `main-release.lua`) исключены через `workspace.ignoreDir` в `.luarc.json`.

Архитектура (слои, bake, runtime, границы): [docs/architecture.md](docs/architecture.md).

Как значения из `data/` попадают в способности без магических чисел: [docs/data-in-scenario.md](docs/data-in-scenario.md).
Data-слой (rows, ID, пресеты, ошибки bake): [docs/data.md](docs/data.md).

Статус фракций (data → runtime → тесты → TODO, автоген при bake): [docs/generated/status.md](docs/generated/status.md).

Trade-off'ы и отложенные баги: [docs/adr/0001-luals-zero-warnings-trade-offs.md](docs/adr/0001-luals-zero-warnings-trade-offs.md), [docs/adr/0002-custom-assets-imports-vs-game-folder-dev.md](docs/adr/0002-custom-assets-imports-vs-game-folder-dev.md), [docs/known-issues.md](docs/known-issues.md).

## Ссылки

- [warcraft-vscode](https://marketplace.visualstudio.com/items?itemName=dencer.warcraft-vscode)
- [Object IDs (wc3edit)](https://forum.wc3edit.net/viewtopic.php?t=2648)
