# Архитектура

Идея одна: **данные декларируются slug-ами в `src/data/`, bake превращает их в ID и реестры, runtime читает только сгенерированное**. Руками `generated/` не правится.

## Слои

- **Data** (`src/data/`) — units, abilities, items, buffs, upgrades. Ключ — slug (`combatExpertise`), не FourCC. Пресеты способностей — `abilityPresets.lua`. Форма rows, ID, ошибки bake — [data.md](data.md).
- **Bake** (`tools/bake.lua` → `tools/gen/*`) — из Data делает `data/generated/` (ids, slug-алиасы, meta), реестры модулей для scenario и tests, валидирует ссылки. `tools/oe/` — пишет object data в карту при build.
- **Lib** (`src/lib/`) — инфраструктура: `triggers` (события + filter), `storage` (hashtable), `ability/config` (compile refs/balance), `objediting` (свои base-классы для OE).
- **Scenario** (`src/scenario/`) — runtime способностей: `factions/*/abilities/`, `common/mechanics/`. Состояние — `scenario/storage/*`. Каркасы для копирования — `common/templates/` (в реестр не попадают).
- **Tests** (`src/tests/`) — in-game автотесты, включаются `RUN.tests` в `main.lua`.
- **Vendor** (`src/vendor/`) — community libs, vanilla ID, objediting-стабы. Не трогать.
- **Map** (`map.w3x/`) — terrain, imports, object data. Правится через WE или OE bake.

## Сборка: `wc3 go .` = bake → build → run

1. `lua tools/bake.lua` — standalone Lua, без WC3-натив:
   - `gen/ids` — slug → `A100`, `B101`… Старые ID сохраняются (читаются из текущего `ids.lua`), новые получают следующий номер, удалённые slug-и вычищаются.
   - `gen/registries` — список модулей `scenario/**` и `tests/**` по каталогам.
   - `gen/validate_scenario` — каждый `Ids.<domain>.<slug>` и `trigger = "..."` в scenario существует; `units.*.abilities` и `abilities.*.buffs` ссылаются на известные slug.
   - `gen/status` — [`docs/generated/status.md`](generated/status.md): матрица по фракциям (data row → scenario-модуль → тест → TODO). Единственный `generated/`, который в git.
2. warcraft-vscode `build` — вызывает `objediting/main.lua` → `tools/oe/main.lua` (object data в карту), компилирует Lua в `.build/*.w3x`.
3. `run` — копия в `Maps/Test`, запуск игры.

## Runtime

```text
main.lua
  lib.init                 vendor/ext, seterrorhandler
    lib.triggers.init
      scenario.abilities   require всех модулей из abilities_registry
      registerCallback     каждый элемент ability.triggers
      registerEvents       один WC3-триггер на тип события, диспетчер — Filter
  tests.init               если RUN.tests
  spawn.run                dev-спаун
  Storage.initAll()
```

Модуль способности возвращает `{ triggers, config, debug }`. Формат — `.cursor/rules/abilities.mdc`, все события с примерами — `scenario/common/templates/_reference.lua`.

## Границы

- **Data ни от кого не зависит**, кроме `vendor/assets` и других `data/*`. Она исполняется и в bake, и в игре.
- **Scenario и Tests из Data берут только `data.ids`** (и `data.buffTypes`). Row-атрибуты — через `lib.units` / `lib.items`.
- **Lib не знает о Scenario.** Единственное исключение — `lib/triggers/init.lua` (composition root).
- **Никаких FourCC-литералов в Scenario** — только `Ids.<domain>.<slug>`, иначе validate не поймает опечатку.
- **`generated/` — только через bake.** Расхождение чинится в Data или генераторе.
