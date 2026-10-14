# Debug-команды (чат)

In-game чат для локальной отладки. Реализация: [`src/scenario/common/mechanics/debugCommands.lua`](../src/scenario/common/mechanics/debugCommands.lua) (подключается через autogen `abilities_registry`).

Ответ в чате — строка `Debug: …`. Команды с **выделением** требуют выбранного юнита (`selection.lua`).

## Карта / спаун

| Команда | Действие |
|---------|----------|
| `game clean` | Удалить всех юнитов на карте, `Storage.initAll()` |
| `game spawn <pack>` | `Spawn.run({ pack })` — имя пака как в `src/spawn.lua` |

## Выделенный юнит

| Команда | Действие |
|---------|----------|
| `cd` | Сброс кулдаунов всех способностей |
| `level <1–10>` | Уровень героя |
| `hp <n>` / `mp <n>` | Текущие HP / MP |
| `maxHp <n>` / `maxMp <n>` | Максимум HP / MP |
| `root` / `unroot` | Prop window 0 / по умолчанию |
| `remove` | `RemoveUnit` |
| `spawn <unitSlug>` | Создать юнит по slug рядом с выделенным |
| `owner <0–11>` | `SetUnitOwner` |
| `cast <owner> <ability> <order>` | Dummy-каст по цели: owner — индекс игрока; ability — slug из `Ids.abilities` или 4-char rawcode; order — строка приказа |

## Dummy (глобально)

| Команда | Действие |
|---------|----------|
| `dummy 1` | `Dummy.setDefault(FourCC(Ids.units.dummy))` — видимый dummy |
| `dummy 0` | `Dummy.setDefault(FourCC(Ids.units.dummyHidden))` — скрытый (locust, пустая модель) |

Влияет на все последующие вызовы `utils.dummy`, где не передан явный `unitId`. См. также [helpers.md](helpers.md#utilsdummy).

## Добавление команд

Новые команды — запись в таблицу `commands` в том же файле (`exact` или `pattern` + `run`; опционально `needsUnit = true`).

**Паттерны — Lua string patterns, не PCRE.** Alternation `|` в regex здесь не работает: `(0|1)` ищет буквально `0|1`. Для одной цифры 0/1 используй `[01]` или `%d` с проверкой в `run`.
