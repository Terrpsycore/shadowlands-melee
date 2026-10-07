# Инструкции для агента

Отвечай на **русском языке**. Следуй `.cursor/rules/global-standards.mdc`.

## Контуры автономии (Green / Yellow / Red)

| Контур | Пути (типично) | Как работать |
|--------|----------------|--------------|
| **Green** | `tools/icon_preview/**`, узкие правки `src/spawn.lua`, data-row без scenario | Можно делать end-to-end; минимальное ревью |
| **Yellow** | `src/lib/**`, `tools/oe/**`, `tools/gen/**`, `src/lib/objediting/**` | План + маленький diff; расширять существующее API; новый модуль/слой — только по явному запросу пользователя |
| **Red** | `src/scenario/**/abilities/**`, `src/data/abilities/**`, `src/data/buffs/**`, тесты способностей | Skill **wc3-ability** + rule **abilities.mdc**; копировать tier-A эталоны, не «архитектурить» |

Если пользователь не указал контур — определи по таблице. Спорное → Yellow или спроси.

## Правила

| Файл | Когда |
|------|--------|
| `global-standards.mdc` | всегда |
| `abilities.mdc` | **Red**: любая работа со способностями (scenario, data abilities/units для способности, templates, tests) |
| `objediting-classes.mdc` | **Yellow**: `tools/oe/` и `src/lib/objediting/` |
| `project-profile.mdc` | контекст репозитория (структура, bake, «не трогать») |
| `project-profile-bootstrap.mdc` | создать `project-profile.mdc`, если его нет |

## Skills (проект)

| Skill | Когда |
|-------|--------|
| **wc3-ability** | новая или существенная правка scenario-способности |
| **wc3-run** | сборка и запуск карты (`build/wc3.py go`) |
| **wc3-read-log** | чтение in-game лога тестов, остановка WC3 |
