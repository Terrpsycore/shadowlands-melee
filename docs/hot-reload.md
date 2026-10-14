# Hot reload (dev)

Dev hot reload: `go` + `watch`, правки в `src/scenario/**` (и частично `src/utils/logger.lua`, `src/utils/generic.lua`); карта подхватывает через numbered `inbox/N.pld`, пересобирает ability-модуль и перевешивает триггеры без rebuild war3map. Сборка карты — [build/README.md](../build/README.md).

## Архитектура

```mermaid
flowchart TB
  Watch[hot_reload_watch.py] --> Inbox["CustomMapData/.../inbox/1.pld, 2.pld"]
  Inbox --> Poller["client.lua poller 10 Hz + FileIO.Load"]
  Poller --> Registry["registry.applyPatches load + _ENV"]
  Registry --> Teardown["engine.teardown"]
  Teardown --> Rereg["Bootstrap.reregister"]
  Poller --> Ack["ack.json"]
```

| Слой | Файлы |
|------|--------|
| Transport | `src/vendor/ext/FileIO.lua`, data-способность `fileioLoad` |
| OS → карта | `tools/hot_reload_watch.py`, `tools/reload_fileio.py`, `tools/reload_contract.py` |
| Карта | `src/lib/reload/client.lua`, `src/lib/reload/contract.lua` |
| Применение | `src/lib/reload/registry.lua` |
| Teardown | `src/lib/reload/engine.lua` |
| Перерегистрация | `src/lib/triggers/bootstrap.lua` |

## Требования

- `RUN.hotReload = true` в [`src/main.lua`](../src/main.lua) (по умолчанию для dev)
- Data-способность `fileioLoad` в [`src/data/abilities/common.lua`](../src/data/abilities/common.lua) (после bake — в object data карты)
- Allow Local Files = 1 (см. [getting-started.md](getting-started.md))

## Workflow

**Терминал 1** — карта:

```powershell
python build/wc3.py go .
```

Watcher сразу: `python build/wc3.py go . --hot-reload`

**Терминал 2** — watcher:

```powershell
python build/wc3.py watch .
```

Сохраняете `.lua` в `src/scenario/**` или `src/utils/**`. В игре: `[reload] ok seq=N patches=M`.

Inbox: `CustomMapData/shadowlands-melee-reload/inbox/1.pld`, `2.pld`, … — **новый файл на каждый reload** (Preloader кэширует один путь).

После `go` через ~1 с: `[reload] FileIO ok` или self-test failed → poller выключен.

Watcher читает `fileioLoad` из `src/data/generated/ids.lua` — перед `watch` нужен bake (`build` / `go`).

### Cold start reload cache

`python build/wc3.py run .` и `go .` очищают reload cache через [`tools/reload_contract.py`](../tools/reload_contract.py) (`USER_DIR` из [`build/wc3.py`](../build/wc3.py) → `CustomMapData/.../shadowlands-melee-reload`). Удаляются `ack.json`, `_ping.pld` и все `inbox/*.pld`. Watcher пишет в тот же каталог (`USERPROFILE`/Documents). После `go --hot-reload` inbox снова с `seq=1`.

Resume по `ack` нужен, если **перезапустили test map в WC3 без `wc3 run/go`** (ack и inbox на диске сохранены).

### Ошибки apply и parse

- **Apply fail** (синтаксис, runtime, `not in abilities_registry`): в логе `[reload] error: …`, `ack` не пишется, тот же `inbox/N.pld` читается снова (~10 Hz) до успешного apply или правки файла.
- **Parse fail** (битый `.pld`): slot **пропускается** (`nextInbound` +1), иначе poller зациклится на одном файле.

## Контракт OS ↔ карта

Единый источник имён: [`tools/reload_contract.py`](../tools/reload_contract.py) (Python) и [`src/lib/reload/contract.lua`](../src/lib/reload/contract.lua) (карта). Менять пути только в паре.

| Поле | Значение |
|------|----------|
| Корень | `CustomMapData/shadowlands-melee-reload/` |
| Inbox | `inbox/{seq}.pld` — `{seq}` совпадает с `seq` в payload |
| Ack | `ack.json` — `{"seq":N,"ok":true}` после успешного apply |
| Ping (self-test) | `_ping.pld` |

Payload внутри каждого `.pld` — Lua-таблица:

```lua
return {
  seq = 3,
  patches = {
    { file = "scenario/.../ability.lua", source = [[...]] },
  },
}
```

- `file` — ключ относительно `src/`, слэши `/` (как в `abilities_registry`).
- Карта: игнорировать `inbox.seq <= lastSeq` (dedup).
- Watcher и карта при старте читают `ack.json`: watcher продолжает нумерацию `seq`, карта — `lastSeq` и `nextInbound = ack.seq + 1` (не перечитывает старые `1.pld`… после рестарта test map без `wc3 run`).
- На карте `Contract.parseAckSeq` — regex по сырому файлу (в runtime WC3 нет JSON); в Python — `json.loads` + fallback regex.

## Watch vs apply

| Где | Что решает |
|-----|------------|
| [`hot_reload_watch.py`](../tools/hot_reload_watch.py) — `WATCH_DIRS`, exclude `scenario/generated/` | какие файлы попадают в payload watcher |
| [`registry.lua`](../src/lib/reload/registry.lua) — `patchHandlers`, `utilsGlobalSetters` | применится ли patch на карте |
| [`abilities_registry.lua`](../src/scenario/generated/abilities_registry.lua) (bake) | scenario-модуль есть в live catalog |

Файл может попасть в inbox, но reload на карте отклонит его (`unsupported path`, `not in abilities_registry`, `utils reload not wired`).

## Что перезагружается

| Hot reload | Только `go` (full rebuild) |
|------------|----------------------------|
| `src/scenario/**` (слот в `abilities_registry`) | `src/data/**`, bake / `generated/` |
| Подключённые `src/utils/*.lua` (см. ниже) | `src/lib/**`, vendor |
| | новый scenario-файл не в реестре |

Маршрутизация patch: [`registry.lua`](../src/lib/reload/registry.lua) — префикс `scenario/` → слот в `scenario.abilities.abilities[i]`; `utils/` → `Registry.utilsGlobalSetters`.

Индекс `moduleName → i` для scenario строится **один раз** при первом reload (кэш по `abilities_registry`), без linear scan на каждый patch.

### Расширение utils reload

Только модули из таблицы `Registry.utilsGlobalSetters` в [`registry.lua`](../src/lib/reload/registry.lua):

| moduleName | Куда попадает return модуля |
|------------|----------------------------|
| `utils.logger` | `_G.dump` |
| `utils.generic` | `_G.Generic` |

Чтобы добавить ещё один utils-файл: запись в `utilsGlobalSetters` (module name + setter на нужный global). Watcher уже следит за всем `src/utils/**`; без setter reload вернёт `utils reload not wired for …`.

Scenario: файл должен быть в [`abilities_registry.lua`](../src/scenario/generated/abilities_registry.lua) (`bake` + `go` для новых путей).

На reload: снимаются WC3-триггеры и TIMER-триггеры движка, очищаются Damage listeners, заново `registerEvents`. Отложенные `Timed.call` внутри способностей **не** отменяются.

## Known limitations (v1)

- [`scenario/common/control.lua`](../src/scenario/common/control.lua) — per-unit триггеры не трекаются engine
- После patch каталог и `require` для **этого** module name синхронизируются (`package.setloaded`); способности с `local X = require(...)` на верхнем уровне всё ещё держат старый `X`, пока их файл не перезагрузят
- module-level state в перезагруженном файле обнуляется при reload
- Изменения реестра способностей (`tools/bake.lua`) — `wc3 go`

## Troubleshooting

| Симптом | Проверить |
|---------|-----------|
| Нет `[reload] ok` после save | Запущен `watch`? Файл в `abilities_registry`? |
| `FileIO self-test failed` / `poller off` | `fileioLoad` в object data, Allow Local Files, `-allowLocalFiles` в `wc3.py go` |
| Save есть, reload нет | Старый `seq` (dedup); в логе путь `inbox.txt` — пересобрать карту (`go`) |
| Повтор `[reload] error` на одном seq | Исправьте Lua в файле; ack не обновится, пока apply не пройдёт |
| `[reload] inbox parse` | Битый `.pld`; slot пропущен — проверьте watcher / перезапустите `watch` |
| Карта кидает в меню | `.w3x` &lt; ~7050 KiB или legacy `__HOT_RELOAD__` в корне war3map — см. [build/README.md](../build/README.md) |
| `not in abilities_registry` | `bake` + `go` |

## Ручная проверка

1. Cold start: cast + damage — OK
2. Правка ability → save → `[reload] ok`, поведение меняется
3. Два reload подряд — нет двойного урона / cast
4. Правка `utils/logger.lua` / `utils/generic.lua` — `_G.dump` / `_G.Generic`
5. Правка `src/data/*` — только `wc3 go`
