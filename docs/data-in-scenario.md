# Данные `data/` в способностях и механиках

Число, которое уже объявлено в `data/`, в scenario не дублируется. Но `require("data.abilities")` из scenario не работает: строки собираются через `A.*`-пресеты, а те делают `dofile("tools/oe/...")` — этот код есть только на bake, в карте его нет. Поэтому до runtime данные доходят тремя каналами.

Напрямую из `data/` в scenario можно только `data.ids` (`Ids.<domain>.<slug>` → `refs`) и `data.buffTypes` — это плоские таблицы без OE-зависимостей. Строки units/abilities/items — нет.

## 1. Поле уже записано в объект — читать из игры

Всё, что лежит в строке способности (`manaCost`, `levels`, `a:setCooldown(...)` в `apply`, duration и т.д.), после OE bake находится в объекте карты. В runtime его отдаёт сам юнит-носитель:

```lua
-- было: balance = { toggleManacost = 20 }  — копия pulsebackToggle.manaCost
-- стало:
local function toggleManaCost(unit)
    local id = CONFIG.refs.abilities.toggle
    return BlzGetUnitAbilityManaCost(unit, id, GetUnitAbilityLevel(unit, id) - 1)
end
```

Натики:

- `BlzGetUnitAbilityManaCost(unit, id, level)`, `BlzGetUnitAbilityCooldown(unit, id, level)` — мана и кулдаун
- любое другое поле — `BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, id), ABILITY_RLF_DURATION_NORMAL, level)` (и `Integer`/`Boolean`/`String`-варианты)
- `level` везде 0-based: `GetUnitAbilityLevel(unit, id) - 1`
- константы полей — `ABILITY_RLF_*` / `ABILITY_ILF_*` в `src/vendor/blizzard/common.lua`; искать по rawcode из OE: `adur` → `ABILITY_RLF_DURATION_NORMAL`, `aare` → `ABILITY_RLF_AREA_OF_EFFECT`, `amcs` → `ABILITY_ILF_MANA_COST`

Когда: значение зависит от уровня/апгрейдов или юнит уже в руках (обработчик триггера, `GetTriggerUnit()`, `info.target`). Не подходит для модульного уровня — при `AbilityConfig.compile` юнита ещё нет.

## 2. Значение нужно без юнита — meta через bake

Bake вытаскивает выбранные поля строк в `data/generated/unit_meta.lua` / `item_meta.lua`, а `lib/units.lua` / `lib/items.lua` оборачивают их FourCC-ключами и аксессорами:

```lua
local Units = require("lib.units")
Units.factionOf(unit)        -- "kyrian" | ... из data.units.<slug>.faction
Units.canRevive(typeId)      -- data.units.<slug>.revive с учётом defaults (data/units/death.lua)

local Items = require("lib.items")
Items.getCorpseOf(typeId)    -- data.items.<slug>.corpseOf
```

Новое поле:

1. `tools/gen/<domain>_meta.lua` — взять из строки, записать в `rows` и в writer
2. `lib/<domain>.lua` — аксессор
3. `lua tools/bake.lua`

Для способностей meta пока нет. Нужно — `tools/gen/ability_meta.lua` + `lib/abilities.lua` по образцу item_meta и вызов рядом с `genItemMeta` в `tools/gen/ids.lua` → `generateIds()`.

Когда: логика по типу юнита без инстанса (фильтры, проверка фракции), значение для CONFIG на этапе загрузки, флаги, у которых нет OE-поля (`corpse`, `revive`, `unique`).

## 3. `balance` — только то, чего нет в `data/`

Шанс прока, радиус скриптового урона, таймеры механики — для них нет OE-поля, значит это не дубликат, а единственное место хранения. Если же число есть в строке `data/` — канал 1 или 2, в `balance` не копировать.

## Коротко

| Нужно | Канал |
|---|---|
| ID сущности | `Ids.<domain>.<slug>` → `CONFIG.refs` |
| поле способности, юнит известен | натики `BlzGet*` (1) |
| поле строки без инстанса / флаг без OE-поля | `lib.units` / `lib.items`, при необходимости расширить gen (2) |
| число, которого в `data/` нет | `CONFIG.balance` (3) |
