# ADR 0001: LuaLS `--check .` без предупреждений

**Статус:** Accepted  
**Дата:** 2026-09-10

## Контекст

`lua-language-server --check .` на корне репозитория давал ~1380 предупреждений. Основной шум — type-stubs community/objediting (~97%). `--check src/tests` уже был чистым.

Цель: довести `--check .` до 0 без cast-маскировки расхождений типов и логики (явное решение: при сомнении — спрашивать, не прятать cast'ом).

## Решение

1. Исправить корневую типизацию objediting: `@field def ObjectDefinition` (runtime — экземпляр `ObjectDefinition`, не таблица `Definition`).
2. Настроить [`.luarc.json`](../../.luarc.json): `workspace.library`, `diagnostics.globals`, `workspace.ignoreDir` для шаблонов `main-debug.lua` / `main-release.lua`.
3. Точечные аннотации в community runtime (`DamageEngine`, `LinkedList`, `Timed`, `GlobalRemap`) и прикладном коде.
4. Не использовать `@cast` / cast для подавления реальных расхождений.

Команда проверки:

```powershell
& "C:/Programs/Lua/LuaLS/bin/lua-language-server.exe" --check .
```

## Trade-off'ы

### Прикладной код (`src/`)

| Область | Что сделано | Цена |
|---------|-------------|------|
| [`abilityPresets.lua`](../../src/data/abilityPresets.lua) | `apply`-логика вынесена в именованные функции с `---@param a ...`; generic `presetFactory`; дубли stub-классов `AbilityFactory` / `AbilityRowInput` | **Хуже читаемость**: пресет и apply разнесены; дублирование контракта с `ability_factories.lua`. Кандидат на рефакторинг (локальный `channelApply(setup)`, types в отдельном файле). |
| [`filter.lua`](../../src/lib/triggers/filter.lua) | `trigger?` для `registerCallback` без обязательного `trigger` | При filter без `trigger` текст ошибок FourCC использует fallback `"callback"`. |
| [`unitFields.lua`](../../src/lib/storage/unitFields.lua) | `---@diagnostic disable-next-line: duplicate-set-field` на `store:have` | Конфlict `Storage.instance:have(parent, field)` vs `store:have(unit)` **не решён**, только заглушен (см. TODO в файле). |
| [`soulbind.lua`](../../src/tests/soulbind.lua) | `assert(Store:get(id), ...)` | Скорее улучшение: явный контракт после `bond`. |
| [`order.lua`](../../src/scenario/common/order.lua) | `dump("order", OrderId2String(...))` | Улучшение и типов, и смысла. |

### Community / objediting

| Область | Что сделано | Цена |
|---------|-------------|------|
| Objediting core (`object.lua`, `application.lua`, `objectwriter`, …) | File-level `---@diagnostic disable` (полный или частичный) | **Слепые зоны**: реальные ошибки в tooling-stubs не видны в `--check .`. |
| [`AbilityObjEditing.lua`](../../src/vendor/assets/objediting/object/AbilityObjEditing.lua) | `disable: duplicate-set-field` на файл | Скрыт [баг дубликата `setBackstabDamage`](../known-issues.md#windwalk-duplicate-setbackstabdamage) — не исправлен в runtime. |
| `main-debug.lua` / `main-release.lua` | `workspace.ignoreDir` | Шаблоны с `%PLACEHOLDER%` не проверяются; поломка шаблона не ловится LuaLS. |
| [`DamageEngine.lua`](../../src/vendor/ext/DamageEngine.lua) | Часть полей `damageInfo` сделана optional | Слабее контроль полноты инициализации при доработках. |
| [`GlobalRemap.lua`](../../src/vendor/ext/GlobalRemap.lua) | Getter `fun(): any` | Return type getter'ов не проверяется. |
| `createDefinition(defType: string)` | Вместо `DefinitionType` | Опечатка в строке типа определения не ловится. |
| Весь `src/vendor/` | Правки аннотаций | Сложнее merge с upstream; по project-profile — «не трогать без согласования» (согласовано выбором fix_all). |

### Конфигурация

| Область | Что сделано | Цена |
|---------|-------------|------|
| `.luarc.json` → `diagnostics.globals` | `Hook`, `UnitEvent`, `args`, `sourcecode`, `seterrorhandler`, … | Опечатки / использование до инициализации не warn, если имя в списке. |
| README | Целевая команда — `--check .` | Полный прогон длиннее; для day-to-day можно по-прежнему `--check src/tests`. |

## Сознательно отложено

- Cast / `@cast` для маскировки типов.
- Refactor `unitFields.have` / единая модель storage typing.
- Исправление дубликата методов в generated objediting stubs (см. known-issues).

## Последствия

- **Плюс:** один зелёный критерий для CI/merge: `--check .` = 0.
- **Минус:** часть строгости и читаемости перенесена в disable/ignore/globals; прикладной `abilityPresets.lua` — главный регресс по UX кода.
- **Рекомендация:** при работе над abilities — держать types отдельно или вернуть inline apply через typed helper (`channelApply`); периодически пересматривать disable в community при обновлении stubs.

## Связанные документы

- [Известные баги](../known-issues.md)
- [README — LuaLS](../../README.md)
