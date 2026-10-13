# Hot reload (dev)

Live-перезагрузка Lua под `src/scenario/` и `src/utils/` без restart test map. Transport: FileIO + polling (CustomMapData).

## Требования

- `RUN.hotReload = true` в [`src/main.lua`](../src/main.lua) (по умолчанию включено для dev)
- Обычный `wc3 build` — патч `war3map.lua` не нужен (reload через `load(..., _ENV)` + реестр способностей). Если карта кидает в меню: проверьте размер `.build/_warcraft_vscode_test.w3x` (нужно **≥ ~7050 KiB**); ~6930 KiB после `patch_war3map*` + pack — битый архив, сделайте `python build/wc3.py go .`
- Data-способность `fileioLoad` в [`data/abilities/common.lua`](../src/data/abilities/common.lua) (после bake попадает в object data карты)

## Workflow

**Терминал 1** — карта:

```powershell
python build/wc3.py go .
```

Опционально watcher сразу: `python build/wc3.py go . --hot-reload`

**Терминал 2** — watcher:

```powershell
python build/wc3.py watch .
```

Сохраняете `.lua` в `src/scenario/**` или `src/utils/**`. В игре в логе: `[reload] ok seq=N`.

Inbox (watcher): `CustomMapData/shadowlands-melee-reload/inbox/1.pld`, `2.pld`, … (новый файл на каждый reload — иначе Preloader кэширует один путь).

После `go` в логе через ~1 с: `[reload] FileIO ok` или `FileIO self-test failed` (нет `fileioLoad` в object data / выключены local files).

Если **`not in abilities_registry`** — файл не в `scenario/generated/abilities_registry.lua` (нужен bake + go). Изменения `src/lib/**` — только `go`.

Если в логе путь `inbox.txt` — карта собрана **до** текущего reload-клиента; снова `go`.

Watcher читает `fileioLoad` из `src/data/generated/ids.lua` — перед `watch` нужен bake (`build`/`go`).

Ack (игра): `shadowlands-melee-reload/ack.json` через FileIO.Save.

## Что перезагружается

| Перезагрузка | Полный rebuild + restart |
|--------------|---------------------------|
| `src/scenario/**`, `src/utils/**` | `src/data/**`, bake / `generated/` |
| | `src/lib/**`, vendor |
| | `scenario/storage/**` (состояние сохраняется) |

На reload: снимаются WC3-триггеры и TIMER-триггеры движка, очищаются Damage listeners, заново `registerEvents`. Отложенные `Timed.call` внутри способностей **не** отменяются.

## Known limitations (v1)

- [`scenario/common/control.lua`](../src/scenario/common/control.lua) — per-unit триггеры не трекаются engine
- Изменения реестра способностей (`tools/bake.lua`) требуют `wc3 go`

## Ручная проверка

1. Cold start: cast + damage — OK
2. Правка ability → save → `[reload] ok`, поведение меняется
3. Два reload подряд — нет двойного урона / двойного cast
4. Правка `utils/logger.lua` / `utils/generic.lua` — обновляет `_G.dump` / `_G.Generic` (модули, уже `require` внутри scenario, сами не перечитываются)
5. Правка `src/data/*` — только `wc3 go`
