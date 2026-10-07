# Storage

Состояние механик поверх WC3-hashtable. Код — `src/lib/storage/`, объявления — `src/scenario/storage/<slug>.lua`. Развилка «что уже есть» (toggle → `mech`, трупы → `corpses`) — [helpers.md](helpers.md).

## Зачем

Lua-таблицы не переживают save/load, hashtable — да. Storage пишет данные в hashtable, в Lua держит только кэши и восстанавливает их в `:init()`.

Берём Storage, если состояние должно пережить save/load или нужен обход носителей (`each`). Иначе — обычная локальная таблица.

## Жизненный цикл

```
scenario/storage/<slug>.lua   Storage.unitFields("slug", {...})  → инстанс попадает в реестр
abilities/<slug>.lua          require("scenario.storage.<slug>") → использование
main.lua                      Storage.initAll()                  → каждый инстанс :init() восстанавливает кэши из hashtable
```

`initAll()` — после всех `require`, иначе часть хранилищ не инициализируется. Тесты вызывают его сами.

## Что выбрать

- `unitSet(name)` — юнит есть в списке или нет. `add / has / drop / each`. Пример: `pride`.
- `unitFields(name, schema)` — поля по юниту. `set / get / bind / has / drop / each`. Пример: `dedication`.
- `record(name, schema)` — запись с числовым id, связывает несколько юнитов. `alloc / create / read / bind / find / drop / each`. Пример: `soulbind`.

Схема: `field = "int" | "real" | "bool" | "unit"` или `{ type, default, child }`.
`child` — явный ключ в hashtable (стабильность сохранений при переименовании поля). `default` работает только в `record:create`.

## Примеры

```lua
-- scenario/storage/dedication.lua
return Storage.unitFields("dedication", { target = "unit" })

-- abilities/dedication.lua
Storage:set(unit, "target", nil)      -- регистрирует юнита в each, поле заполнится позже
if Storage:has(unit) and target ~= Storage:get(unit, "target") then ... end
Storage:each(function(unit) ... end)
Storage:drop(unit)
```

```lua
-- scenario/storage/soulbind.lua
return Storage.record("soulbind", {
    existsField = "level",            -- по нему проверяется существование записи
    fields = {
        level  = { type = "int", default = 1, child = 1 },
        unit_a = { type = "unit", child = 4 },
        unit_b = { type = "unit", child = 5 },
    },
    indexes = { byUnit = { "unit_a", "unit_b" } },   -- find(unit) → id; юнит не может быть в двух записях
})

-- abilities/soulbind.lua
Store:create(Store:alloc(), { unit_a = caster, unit_b = target })
if Store:find(caster) then return end       -- уже связан
local bond = Store:bind(id); bond.level = bond.level + 1   -- пишет в hashtable
```

## Соглашения

- Один файл — одно хранилище, имя = slug способности. В файле только схема, логика — в способности.
- Очистку делает способность: Storage не следит за смертью юнита. `drop` в `DEATH` или по условию в таймере.
- Шаблон: `scenario/common/templates/buff-chain-storage.lua`.
