# Helpers

Куда смотреть перед своим перебором юнитов, dummy-кастом или новым storage. Полные сигнатуры — `src/utils/unit.lua`, `src/utils/dummy.lua`. Контракт storage — [storage.md](storage.md); объявления — `src/scenario/storage/`.

## Сначала это

| Задача | Бери |
|---|---|
| Юниты в радиусе | `Unit.getUnitsInRadius` |
| Союзники в радиусе | `Unit.getAllyUnitsInRadius` |
| Союзники нужного типа | `Unit.getAllyUnitsOfTypeInRadius` |
| Трупы в радиусе | `Unit.getCorpsesInRadius` |
| Дистанция, жив ли | `Unit.distance`, `Unit.isAlive` |
| Кулдаун готов | `Unit.isOffCooldown` |
| Мана | `Unit.getCurrentMana`, `Unit.substractMana`, `Unit.restoreMana` |
| Dummy-каст в цель | `Dummy.applyDummyOrder` |
| Dummy-каст в точку | `Dummy.applyDummyPointOrder` |
| Dummy мгновенный приказ | `Dummy.applyDummyImmediateOrder` |
| Toggle вкл/выкл | `scenario.storage.mech` |
| Трупы под воскрешение | `scenario.storage.corpses` |
| Данные смерти | `scenario.storage.death` |

## utils.unit

`local Unit = require("utils.unit")`

| Вызов | Проблема |
|---|---|
| `Unit.getClosestUnit` | `return` внутри callback не выходит из функции — результат всегда `nil`. Бери `getUnitsInRadius`. |
| `Unit.getNearestUnit` | Не ищет ближайшего: последний в радиусе, прошедший filter (без filter — любой, в т.ч. мёртвый). |
| `Unit.hasSpaceInInventory` | `findFreeSlot` возвращает `0` и когда слота нет — не nil. Бери `countFreeSlots`. |

## utils.dummy

`local Dummy = require("utils.dummy")`

Dummy живёт 10 секунд (`BTLF`), invulnerable, без pathing. Типовые касты — в таблице выше (`applyDummy*`).

## Storage

Новое хранилище — схема в `src/scenario/storage/<slug>.lua`, логика в способности. Kind (`unitSet` / `unitFields` / `record`), save/load и примеры — [storage.md](storage.md). `Storage.initAll()` только из `main.lua`, не из способности.
