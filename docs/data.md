# Data-слой

Декларации игровых объектов: units, abilities, buffs, items, upgrades. Код — `src/data/`. Bake генерирует ID и meta, OE-шаг пишет object data в карту. Из scenario **не** подключать таблицы rows (`require("data.abilities")` и т.п.) — пресеты тянут `tools/oe`, которого в карте нет. В runtime: `data.ids`, `data.buffTypes`, поля объекта через нативы и `lib.units` / `lib.items` — см. [data-in-scenario.md](data-in-scenario.md).

Пайплайн целиком — [architecture.md](architecture.md). Здесь — что и как объявлять.

## Общая форма

Каждый домен — таблица `slug → row`. Slug — доменное имя в camelCase (`defenceProtocolToggle`), не vanilla-имя и не FourCC. Row — plain Lua-таблица; обязательное поле одно — `parent` (vanilla FourCC-строка из `vendor/assets/*Ids.lua`).

```lua
-- data/units/kyrian/units.lua
praetor = {
    parent = UnitIds.grunt,
    name = "Praetor",
    abilities = { "defenceProtocol", "defenceProtocolToggle" },
    classification = "Mechanical",
    mana = { max = 200, initial = 100 },
    cost = { lumber = 50 },
    art = { icon = Icons.armorGolem },
},
```

Row проходит через обработчик домена `tools/oe/kinds/<domain>.lua`: каждый ключ — именованный setter (`name → setName`, `cost.lumber → setLumberCost`). Всё, что не покрыто ключами, — через `apply`.

### Каталоги и порядок загрузки

`data/<domain>/init.lua` собирает домен из файлов по списку `data/<domain>/_sources.lua`:

```lua
{ faction = "kyrian", class = "unit", path = "data.units.kyrian.units" },
```

`_merge.merge` кладёт rows в общую таблицу и проставляет `row.class` / `row.faction` из записи источника, если в row их нет. Дубликат slug между файлами — ошибка `duplicate <domain> slug '<slug>' in <path>`.

| Домен | Источники | Что проставляется из `_sources` |
|-------|-----------|--------------------------------|
| units | `common` (dummy) + `<faction>/{heroes,units,buildings}` | `class` (`dummy`/`hero`/`unit`/`building`), `faction` |
| abilities | `common` + `<faction>/{buildings,common,heroes,units,items}` | `class` (`unit`/`hero`/`item`). `faction` — только для tooling, в row не пишется |
| buffs | `factions/<faction>` | `faction` |
| items | `manual` + автоген `corpses` + `grabbed` | — |
| upgrades | `template` + `factions/<faction>` | `faction` |

Новый файл данных без записи в `_sources.lua` не подхватится.

### Общие правила для всех доменов

- **Неизвестный ключ — ошибка bake** (`unknown unit field 'foo' on <slug>`). То же для вложенных таблиц (`unknown art field 'foo'`). Список допустимых ключей — таблица `fields` в `tools/oe/kinds/<domain>.lua`.
- **`apply = function(obj, level?)`** — произвольные setter'ы Definition-класса. Если функция объявлена с двумя параметрами, bake вызывает её для каждого уровня `1..levels`; с одним — один раз (`tools/oe/kinds/_apply.lua`). `apply` выполняется **после** именованных полей и может их перезаписать.
- **Пути в `art`** (`icon`, `model`) — WC3-формат; `/` нормализуются в `\` при bake. Иконки — через каталог `Icons.*` (`vendor/assets/generated/Icons.lua`), не строковые литералы.
- **Ссылки между доменами — slug'ами**: `units.abilities = { "soulbind" }`, `abilities.buffs = { "soulbind" }`. Bake резолвит их в ID; неизвестный slug — ошибка.
- Enum'ы (`WeaponType`, `WeaponSound`, `AttackType`, `MovementType`, `Race`, …) — глобальные из `vendor/assets/objediting/core/enum.lua`; подключаются в `data/units/init.lua`.

## ID

Генератор — `tools/gen/ids.lua`. Выход — `src/data/generated/ids.lua` (`domain → slug → FourCC`).

| Домен | Префикс | Пример |
|-------|---------|--------|
| units | первая буква `parent` (`h`/`H`/`o`/`u`/`n`…) | `UnitIds.grunt` (`ogru`) → `o100` |
| abilities | `A` | `A100` |
| buffs | `B` | `B100` |
| items | `I` | `I100` |
| upgrades | `R` | `R100` |

Алгоритм: прочитать текущий `ids.lua`, сохранить уже выданные ID, новым slug'ам выдать следующий свободный номер (счётчик от 100), удалить orphans (slug исчез из данных), проверить дубликаты внутри домена и коллизии между доменами.

Следствия:

- **Переименование slug = новый ID.** Старый вычищается. Ссылки в WE / сохранениях на старый ID ломаются.
- **Стабильность локальная.** `generated/` в `.gitignore`, порядок выдачи новым slug'ам зависит от `pairs`. На свежем clone ID раздадутся заново — не закладывайся на конкретные значения, только на slug.
- Vanilla-объекты не получают ID: `data.ids` отдаёт их через fallback.

### Доступ к ID

```lua
local Ids = require("data.ids")
Ids.units.praetor        -- "o100"  (проектный)
Ids.abilities.windWalk   -- "AOwk"  (vanilla, через __index → vendor.assets.AbilityIds)
```

`data.ids` = generated поверх `vendor/assets/*Ids` с fallback. Если `generated/ids.lua` ещё нет (первый bake), работают только vanilla.

Ограничение: `tools/gen/validate_scenario.lua` проверяет каждое `Ids.<domain>.<slug>` в scenario-модулях **только по generated**. Vanilla-ссылка в scenario (`Ids.abilities.locust`) упадёт на bake как `unknown slug` — там бери `vendor.assets.AbilityIds.locust` напрямую. В `data/` (например `buffTypes.lua`) fallback допустим.

Сопутствующие артефакты:

| Файл | Что | Кто читает |
|------|-----|------------|
| `generated/id_slugs.lua` | LuaLS-алиасы `UnitSlug`, `AbilitySlug`, … (union всех slug'ов) | аннотации типов |
| `generated/id_reverse.lua` | `FourCC → slug` | `lib/slugs.lua` (`Slugs.unit(typeId)` → slug в runtime) |
| `generated/unit_meta.lua` | `id → { slug, faction, corpse, revive }` | `lib/units.lua` |
| `generated/item_meta.lua` | `id → { slug, hero, unique, corpseOf }` | `lib/items.lua` |

## Abilities

### Фабрики

Row способности создаётся не литералом, а вызовом фабрики — она подставляет `parent`:

```lua
local A = require("data.abilityPresets")

soulbind = A.channelTarget({ name = "Soulbind", button = { 0, 2 } }),
spiritLink = A.spiritLink({
    name = "Spirit Link",
    buffs = { "spiritLink" },
    apply = A.spiritLink.apply(function(a)
        a:setMaximumNumberofTargets(1, 2)
    end),
}),
```

- `A.<key>` для каждого vanilla-ключа из `vendor/assets/AbilityIds.lua` и `data/abilityBaseIds.lua`, у которого есть Definition-класс (`tools/gen/ability_kinds.lua` парсит конструкторы в `AbilityObjEditing.lua` и `lib/objediting/bases/`). Если `A.foo` — `nil`, для этого parent нет класса: добавить base-класс в `lib/objediting/bases/` (см. `.cursor/rules/objediting-classes.mdc`) и, если ключа нет в vendor, — в `abilityBaseIds.lua`.
- `A.<key>.apply(fn)` — identity-обёртка, нужна только для типизации `a` под конкретный класс (`AbilityDefinitionSpiritLink`). Без неё `a` — базовый `AbilityDefinition`.
- Пресеты (`A.channelTarget`, `A.immolationToggle`, …) — те же фабрики с предустановленными полями и собственным `apply`. При вызове: поля пресета ← поля вызова (перезапись), затем `apply` пресета, затем `apply` вызова. `A.channel(` напрямую в данных не использовать — только пресеты.

### Пресеты (`data/abilityPresets.lua`)

Таблица «хочу → пресет» — в `.cursor/rules/abilities.mdc`.

Новый пресет — `name = presetFactory(F.base, { ... })` в `abilityPresets.lua` (`inventory` — через `setmetatable`, не `presetFactory`). `tools/gen/ability_kinds.lua` по этому шаблону пишет поле `A.name` в `data/ability.meta.lua`. После добавления — `lua tools/bake.lua`.

### Поля row

Полный список — `tools/oe/ability_row_fields.lua` (типы для LuaLS) + обработчики в `tools/oe/kinds/abilities.lua`. Новое поле добавляется в **оба** файла, затем bake.

| Поле | Тип | Что делает |
|------|-----|-----------|
| `name` | string | `setName`; tooltip на каждый уровень (для `class = "hero"` — с суффиксом ` [N]`); tooltip learn. `""` — пустое имя для скрытых dummy-способностей |
| `levels` | integer | `setLevels`; задаёт диапазон для per-level полей и `apply(a, level)` |
| `buffs` | slug[] | `setBuffs` на каждом уровне; slug'и из `data/buffs`, иначе `unknown buff` |
| `manaCost` | number \| number[] | число — на все уровни; массив — по уровням |
| `button` | `{ x, y }` | позиция normal и turn-off; research — `{ x, y - 2 }`. По умолчанию `{ 0, 2 }`, research у героев `{ 0, 0 }` |
| `hotkey` | string | `setHotkeyNormal` |
| `requirements` | string | по умолчанию `""` (сброс унаследованных) |
| `options` | integer | `setOptions` на каждом уровне (битовые флаги WC3) |
| `autocastRange` | number | уровень 1 |
| `order` | string | base order ID на каждом уровне + order strings turn-on / activate. Нужен, когда несколько custom-способностей на одном юните наследуют один order (`"shadowstrike"`, `"innerfire"`) |
| `art` | `{ icon, iconOff, iconResearch }` | `icon` → normal **и** research; `iconOff` → turn-off; `iconResearch` переопределяет research. `""` сбрасывает унаследованную иконку |
| `apply` | function | см. общие правила |

Класс способности (`unit` / `hero` / `item`) берётся из `_sources` и задаёт `setHeroAbility` / `setItemAbility`.

## Units

Обработчик — `tools/oe/kinds/units.lua`. Definition-класс по `class`: `hero → HeroDefinition`, `building → BuildingDefinition`, иначе `UnitDefinition`.

| Поле | Тип | Что делает |
|------|-----|-----------|
| `name` | string | `setName` |
| `abilities` | slug[] | normal abilities. Slug — проектный **или** vanilla-ключ `AbilityIds` (`"locust"`, `"windWalk"`) |
| `heroAbilities` | slug[] | hero abilities (learnable), те же правила |
| `unitsTrained` / `structuresBuilt` | slug[] | только проектные slug'и units |
| `revivesDeadHeros` | boolean | алтарь |
| `classification` | string | `"Mechanical"`, `"Suicidal"`, … — влияет на смерть (ниже) |
| `mana` | `{ max, initial }` | |
| `cost` | `{ gold, lumber, food }` | |
| `attack1` | `{ type, weapon, range, cooldown, damageBase, weaponSound, targetsAllowed }` | `type`/`weapon`/`weaponSound` — enum'ы (`AttackType.Chaos`, `WeaponType.Normal`, `WeaponSound.MetalMediumChop`) |
| `art` | `{ model, icon, scale }` | `model = ""` — невидимый юнит |
| `button` | `{ x, y }` | |
| `corpse`, `revive`, `deathType` | теги | не setter'ы напрямую, см. ниже |

### Смерть: `corpse` / `revive`

Правила в `data/units/death.lua`, применяются в `finalize` и попадают в `unit_meta`:

- Герой или `classification = "Mechanical"` → `corpse = false`, `revive = false` всегда.
- Иначе — значение тега, по умолчанию `true`.
- `leavesCorpse` → Death Type = `deathType` или `decayFlesh (3)`; иначе — `noCorpseBone (0)` + decay time 0.

Runtime читает это через `lib.units.leavesCorpse(typeId)` / `canRevive(typeId)`, а механика трупов (`items/corpses.lua`) генерирует предмет-труп только для `class = "unit"` с `leavesCorpse`.

### Dummy-юниты

`data/units/common.lua`, `class = "dummy"`: `dummy` (кастер), `dummyVision`, `dummyAttack`, `dummyDispellMeter`, `dummyTank`, `dummyHero`, … Все — `corpse = false, revive = false`, обычно `classification = "Suicidal"`, `setCollisionSize(0)`. Новый dummy под конкретную механику — сюда же.

## Buffs

Обработчик — `tools/oe/kinds/buffs.lua`. Поля: `parent` (`BuffIds.*`), `name` (имя + tooltip), `apply`. Больше ничего — иконка/эффекты берутся от parent или через `apply`.

```lua
defenceProtocol = { parent = BuffIds.bloodlust, name = "Defence Protocol" },
```

Buff-slug указывается в `abilities.*.buffs`. Регистрация бафов как stun/root/invisibility для custom-событий (`STUN`, `ROOT`) — `data/buffTypes.lua`.

## Items

Три источника (`data/items/init.lua`):

| Источник | Slug | Когда появляется |
|----------|------|------------------|
| `manual.lua` | свой | ручные предметы: зелья Necrolord, Soul / Soulkeeper / Soulforged Mawsworn, `dummyUnitItem`, `dummyHeroItem` |
| `corpses.lua` (автоген) | `<unitSlug>Corpse` | каждый `class = "unit"` с `leavesCorpse` |
| `grabbed.lua` (автоген) | `<unitSlug>Grabbed` | каждый `class = "unit"` или `"dummy"` |

Автогенерируемые предметы берут `parent = ringProtection1`, имя `"<Name> Corpse"` / `"<Name> (Grabbed)"`, иконку — из `art.icon` юнита или из `vendor/assets/generated/UnitArt` по parent (нет иконки → ошибка bake).

Поля row (`tools/oe/kinds/items.lua`): `name`, `art.icon`, `abilities` (slug[]; проектные или vanilla), `apply`.

Теги (не setter'ы, уходят в `item_meta`, проверяются `tools/gen/item_meta.lua`):

| Тег | Смысл | Runtime |
|-----|-------|---------|
| `unit = true` | предмет для юнитов (не героя); в meta `hero = false` | `lib.items.isHero(id)` |
| `unique = true` | единственный экземпляр | `lib.items.isUnique(id)` |
| `corpseOf = "<unitSlug>"` | предмет-труп; включает defaults «0 стоимость, не perishable, droppable, без abilities» | `lib.items.getCorpseOf(id)`, `getCorpseItemId(unitTypeId)` |

## Upgrades

Обработчик — `tools/oe/kinds/upgrades.lua`. Сейчас фракционные файлы пустые; есть только `template.lua` как образец.

| Поле | Что делает |
|------|-----------|
| `name` | имя + tooltip на каждый уровень |
| `levels` | `setLevels` |
| `class`, `race` | `UpgradeClass.*`, `Race.*` |
| `cost` | `{ gold, goldIncrement, lumber, lumberIncrement, time, timeIncrement }` |
| `button`, `icon`, `hotkey`, `tooltipExtended` | UI (per level где применимо) |
| `requirements` | slug[] апгрейдов (проектные или `UpgradeIds`) |
| `requirementsLevels`, `transferWithUnitOwnership` | прямые setter'ы |
| `effects` | `{ { type = UpgradeEffectType.*, base, increment, code }, … }` по индексу |

## Что генерирует bake из данных

Порядок — `tools/bake.lua`:

1. `gen/objediting_meta` — стабы `lib/objediting/.meta.lua` для custom base-классов
2. `gen/ability_kinds` — `generated/ability_classes.lua` (parent → класс), `generated/ability_factories.lua` (`A.*` + типы), `data/ability.meta.lua` (типы пресетов; лежит не в `generated/`, но тоже автоген)
3. `gen/ids` — `ids.lua`, `id_slugs.lua`, `id_reverse.lua`, `item_meta.lua`, `unit_meta.lua`
4. `gen/registries` — реестры scenario/tests
5. `gen/validate_scenario` — валидация (ниже)
6. `gen/status` — [`docs/generated/status.md`](generated/status.md): матрица slug → data / scenario / test / TODO по фракциям

Затем `wc3 build` запускает `tools/oe/main.lua`: для каждого домена `create(db, kinds/<domain>, Ids.<domain>)` → Definition-объекты → object data карты. Порядок доменов: buffs → abilities → units → items → upgrades.

## Ошибки bake и что они значат

| Сообщение | Причина | Исправление |
|-----------|---------|-------------|
| `duplicate <domain> slug 'x' in <path>` | один slug в двух файлах домена | переименовать или убрать дубликат |
| `unknown <domain> field 'x' on <slug>` | ключа нет в `fields` обработчика | опечатка, либо перенести в `apply`, либо добавить поле в обработчик (для abilities — и в `ability_row_fields.lua`) |
| `unknown <art\|cost\|mana\|attack1> field 'x'` | то же для вложенной таблицы | — |
| `unknown ability 'x'` / `unknown unit 'x'` / `unknown buff 'x'` | slug-ссылка на несуществующую запись | проверить slug; для vanilla-способности — ключ `AbilityIds` |
| `units.<slug>.abilities: unknown ability "x"` | то же, из `validate_scenario` | — |
| `<module>: Ids.<domain>.<slug> unknown slug` | scenario ссылается на slug без generated ID (в т.ч. vanilla через `Ids`) | добавить row в data или использовать `vendor.assets.*Ids` |
| `no icon for unit parent 'X' in UnitArt` | автоген corpse/grabbed не нашёл иконку | задать `art.icon` юниту или `corpse = false` |
| `unit tag 'corpse' on <slug> must be boolean` | тег не boolean | — |
| `button requires { x, y }` | неполная позиция | — |
| `failed to create <slug> (<id>): …` | конструктор Definition упал (чаще — нет класса для parent) | проверить `A.<key>` / base-класс |
| `abilityBaseIds key overlaps vendor AbilityIds` | дублирование ключа | убрать из `abilityBaseIds.lua` |
| `missing generated id for <slug>` | рассинхрон `ids.lua` и данных | повторить `lua tools/bake.lua` |

## Чеклисты

**Новая способность**

1. Row в `data/abilities/<faction>/<file>.lua` через `A.<preset|key>({ … })`; имя — доменный slug.
2. Бафф (если есть) — row в `data/buffs/factions/<faction>.lua`, ссылка в `buffs = { "<slug>" }`.
3. Добавить slug в `abilities` / `heroAbilities` носителя в `data/units/…`.
4. `lua tools/bake.lua` → появится `Ids.abilities.<slug>`.
5. Runtime — `scenario/factions/<faction>/abilities/<slug>.lua` (`.cursor/rules/abilities.mdc`, skill `wc3-ability`).

**Новый юнит**

1. Row в `data/units/<faction>/{heroes,units,buildings}.lua` (файл определяет `class`).
2. Если здание — `unitsTrained`; если рабочий — `structuresBuilt`; производящее здание — добавить slug юнита в его `unitsTrained`.
3. Решить про `classification` / `corpse` / `revive` — от этого зависят автоген-предметы `<slug>Corpse` / `<slug>Grabbed`.
4. Иконка через `Icons.*`; custom-иконки — `wc3 build . --imports` ([getting-started](getting-started.md)).
5. `lua tools/bake.lua`.

**Новое поле ability row** — `tools/oe/ability_row_fields.lua` (тип) + `fields.<name>` в `tools/oe/kinds/abilities.lua` (setter) → bake. Для других доменов — только `fields` в `kinds/<domain>.lua`.

**Новый пресет** — `name = presetFactory(F.base, { … })` в `abilityPresets.lua` → bake. Таблица — `.cursor/rules/abilities.mdc`.

**Новый vanilla-parent без фабрики** — класс в `src/lib/objediting/bases/` с LuaLS-аннотациями (`.cursor/rules/objediting-classes.mdc`); если ключа нет в `vendor/assets/AbilityIds.lua` — добавить в `data/abilityBaseIds.lua` → bake → `A.<key>` доступен.

## Связанное

- [architecture.md](architecture.md) — слои, границы, пайплайн
- [storage.md](storage.md) — runtime-состояние способностей
- [generated/status.md](generated/status.md) — матрица покрытия по фракциям
- [helpers.md](helpers.md) — развилка хелперов и ловушки `utils.unit`
- `.cursor/rules/abilities.mdc` — формат scenario-модуля, triggers, filter
- `.cursor/rules/objediting-classes.mdc` — custom Definition-классы
- [Icon Preview](../tools/icon_preview/README.md) — подбор иконок и command card
