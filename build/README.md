# Сборка карты

`python build/wc3.py build` / `go`: один **`wc3 build`** (objediting + compile + pack). Hot reload **не** патчит `war3map.lua`.

`wc3.exe` — cwd = корень проекта (задаёт `wc3.py`).

Перед `wc3 build`:

- удаляются `.build/war3map.lua` и старый `.w3x` (чтобы не тащить legacy-патч);
- после сборки проверка: `.w3x` ≥ ~7050 KiB;
- в **корне** сгенерированного war3map нет `_G.__HOT_RELOAD__ = true`.

Если verify падает — не запускать `wc3 pack` на ручной `.build/war3map.lua` (~6.95 MB → откат в меню).

In-game reload (dev): [docs/hot-reload.md](../docs/hot-reload.md).

Старый подход (patch loader): [legacy/README.md](legacy/README.md) — **не использовать**.
