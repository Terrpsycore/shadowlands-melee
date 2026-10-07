---
name: wc3-ability
description: >-
  Workflow для scenario-способностей shadowlands-melee: archetype из templates,
  CONFIG/triggers, data rows, bake, опционально in-game тест. Следует
  abilities.mdc. Use when the user adds or changes an ability, scenario script
  under factions/*/abilities, ability data rows, or asks for wc3-ability skill.
disable-model-invocation: true
---

# WC3 ability (shadowlands-melee)

**Red-контур.** Перед правками прочитай и соблюдай `.cursor/rules/abilities.mdc`.

Не подключать файлы из `src/scenario/common/templates/` в реестр — только **копировать** archetype в `scenario/factions/<faction>/abilities/<slug>.lua`.

Стартовая точка в репо: `src/scenario/common/_template.lua`.

## Эталоны сложности (копировать стиль, не размер)

| Tier | Когда | Примеры |
|------|--------|---------|
| **A** (по умолчанию) | archetype покрывает задачу | `defenceProtocol.lua`, `pulseback.lua`, `huntedAnimal.lua`, шаблон в `templates/` |
| **B** | только если пользователь указал | `soulbind`, `scan`, `cannibalize`, `oneMoreChance`, `lastStand` |
| **C** (не образец для агента) | legacy / refactor | `stitching.lua` и другие большие файлы с TODO |

## Workflow (чеклист)

```
- [ ] Step 0: Уточнить faction, slug, carrier; если нет spec — спросить (триггер, mana/cd, edge cases)
- [ ] Step 1: Выбрать archetype (или _reference.lua для custom mix)
- [ ] Step 2: Скопировать template → factions/<faction>/abilities/<slug>.lua
- [ ] Step 3: Заменить placeholders в refs / balance; AbilityConfig.compile напрямую в CONFIG
- [ ] Step 4: Уникальная логика — только в effect / tryActivate / onTick / … (early return, как tier A)
- [ ] Step 5: Data rows (abilities, buffs, units) — пресет из таблицы в abilities.mdc; carrier.abilities → lua tools/bake.lua
- [ ] Step 6: Bake подхватит scenario (gen_ability_registry.lua)
- [ ] Step 7 (optional): tests/factions/<faction>/<slug>.lua по образцу defenceProtocol / pulseback
```

### Step 1 — Archetypes

| Файл template | Назначение | Reference в коде |
|---------------|------------|------------------|
| `on-cast-target.lua` | SPELL_CAST on target | Reusables |
| `on-cast-effect.lua` | SPELL_EFFECT, area/point | Bastion Spear |
| `toggle-passive-on-damage.lua` | immolation toggle + DAMAGE proc | Defence Protocol, Pulseback |
| `toggle-passive-on-attack.lua` | immolation toggle + ATTACKED proc | Anima Barrage |
| `proximity-tick.lua` | TRAIN + DEATH + TIMER proximity buff | Formation |
| `disable-triggered.lua` | STUN/ROOT reactive buff | Hunted Animal |
| `buff-chain-storage.lua` | cast → dummy chain + storage + TIMER | Dedication, Deep Meditation |
| `pre-damage-modifier.lua` | PRE_DAMAGE hook | Spirit Link |

**Слишком кастомно для archetype** — собирать триггеры из `templates/_reference.lua` (все trigger-типы): soulbind, scan, cannibalize, oneMoreChance, lastStand.

**Все trigger-типы:** `src/scenario/common/templates/_reference.lua`.

### Step 4 — Ограничения (anti–over-engineering)

- Не добавлять новые `require` и storage-модули без явного запроса пользователя.
- Не создавать обёртки и «фреймворки» внутри файла способности.
- Triggers — только array-формат; filter через `CONFIG.refs.*` после compile.
- Визуалы/dummy — `utils/dummy.lua`; toggle — паттерн immolation + `MechStorage` из tier-A reference.
- Перед новым storage или перебором юнитов — `docs/helpers.md` и `docs/storage.md`; не дублировать уже объявленное в `src/scenario/storage/`.

### Step 5–6 — Bake

Из корня репозитория:

```powershell
lua tools/bake.lua
```

- Не править вручную `src/data/generated/*`, `src/scenario/generated/*`, `src/tests/generated/*`.
- **Не запускать** in-game тесты и не напоминать пользователю их запускать (правило проекта).

### Step 7 — Тесты (optional)

- Файл: `src/tests/factions/<faction>/<slug>.lua`
- Паттерн: `tests.support.runner`, `case:createUnit`, `case:delay`, assert на buff/cooldown/mana
- Образцы: `src/tests/factions/kyrian/defenceProtocol.lua`, `pulseback.lua`

## Двухфазная работа (если задача большая)

1. **Фаза 1:** data + CONFIG + triggers + пустые handlers (или TODO в одной функции).
2. **Фаза 2:** только уникальная логика после ревью пользователя.

## Связанные skills

- **wc3-run** — только если пользователь явно просит собрать/запустить карту.
- **wc3-read-log** — только если пользователь просит разобрать лог тестов.

## Do not

- `require` templates из `scenario/abilities.lua`
- Новые поля ability row без `tools/oe/ability_row_fields.lua` + `tools/oe/kinds/abilities.lua` + bake
- `A.channel(` напрямую в `data/abilities` (только пресеты из `abilityPresets.lua`)
- Копировать структуру tier **C** как образец новой способности
