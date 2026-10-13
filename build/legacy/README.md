# Legacy war3map patches (do not use)

Hot reload больше **не** патчит `war3map.lua`. Эти скрипты оставлены только как архив.

**`wc3 pack` после правки `.build/war3map.lua`** даёт `.w3x` ~6.95 MB → WC3 откатывает в меню. Нормальный размер ~7.05+ MB после одного `wc3 build`.

Текущий reload: `src/lib/reload/registry.lua` + `python build/wc3.py build .`
