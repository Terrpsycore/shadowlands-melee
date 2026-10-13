# Legacy war3map hot-reload patches (removed)

Hot reload **больше не** патчит корневой `war3map.lua`. Скрипты и snippets из этой папки **удалены** из репозитория; восстановить можно через git history (коммиты до cleanup PR).

## Что было

- `patch_war3map.py` / `patch_war3map_loader.py` — вставка в embed loader: `__HOT_RELOAD__`, overlay `__HOT_RELOAD_FILES__`, `compilefile` hook, `package.setFileSource` / invalidate, poller tail в war3map.
- Snippets `war3map_*.lua`, `war3map_tail.lua` — исходники для ручного/полуавтоматического патча.

## Почему отказались

- **`wc3 pack` после правки `.build/war3map.lua`** давал `.w3x` ~6.95 MB → WC3 откатывал в меню; нормальный размер ~7.05+ MB после одного `wc3 build`.
- Хуки только в embed `main-debug.lua` не выполнялись корневым loader → in-game poller «hooks missing».
- Подход через `debug.getupvalue` для bootstrap — в WC3 нет `debug` → краш при старте.

## Текущий reload

Без правок war3map:

- OS: `tools/hot_reload_watch.py` → `CustomMapData/shadowlands-melee-reload/inbox/N.pld`
- Карта: `src/lib/reload/client.lua` (FileIO + poller) → `registry.lua` (`load(..., _ENV)` + слот в `scenario.abilities`) → `engine.teardown` → `Bootstrap.reregister`

Документация: [docs/hot-reload.md](../../docs/hot-reload.md). Сборка: `python build/wc3.py build .`
