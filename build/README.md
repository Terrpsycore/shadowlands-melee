# Сборка war3map.lua

`python build/wc3.py build` / `go`: один **`wc3 build`** (objediting + compile + pack). Hot reload **не** патчит `war3map.lua`.

In-game reload: [`src/lib/reload/registry.lua`](../src/lib/reload/registry.lua) — `load(..., _ENV)` и замена записи в `scenario.abilities.abilities[]`, затем `Bootstrap.reregister()`.

`wc3.exe` — cwd = корень проекта (`wc3.py`).

Перед `wc3 build` удаляются `.build/war3map.lua` и старый `.w3x` (чтобы не тащить legacy-патч). Проверка: `.w3x` ≥ ~7050 KiB, в **корне** war3map нет `__HOT_RELOAD__`.

Архив старых патчей: [`legacy/`](legacy/) — **не запускать** + `wc3 pack`.
