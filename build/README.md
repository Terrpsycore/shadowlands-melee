# Сборка war3map.lua

После `wc3.exe build` два патча правят `.build/war3map.lua`:

| Файл | Что меняет |
|------|------------|
| `patch_war3map_loader.py` + `war3map_loader_snippet.lua` | `package.source` / WSCode jump по preload |
| `patch_war3map.py` + `war3map_tail.lua` | Старт карты: WSCode, `main.lua`, порядок загрузки |

**Куда править вручную**

- Старт карты → только `war3map_tail.lua`
- Preload reader для jump → только `war3map_loader_snippet.lua`
- `src/vendor/assets/main-debug.lua` — шаблон для wc3 (loader + `%CODE%`); хвост после `%CODE%` в игру не попадает (его заменяет patch tail)

Проверка после `python build/wc3.py build .`: в начале `.build/war3map.lua` есть `__MAP_PRELOAD_SOURCE__`, в конце — как в `war3map_tail.lua`.

**Scenario debug (вариант B):** `lib.bootstrap_config` → `ENABLE_WSCODE_SCENARIO_DEBUG` (нужен `ENABLE_WSCODE`). Хук `compilefile` transpile’ит `scenario/**` (кроме `scenario/generated/`). Первый старт карты может быть дольше.
