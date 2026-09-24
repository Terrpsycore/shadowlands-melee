# ADR 0002: Custom assets — `imports/` (prod) и папка игры (dev)

**2026-09-24**

## Проблема

`wc3 go` с `-loadfile` на cold start не показывает custom иконки из MPQ (зелёные), хотя файлы в карте есть. Из меню или после «Начать заново» — OK. Preload / `.pld` не помогли.

## Решение

Два канала, **одни и те же paths** (`ReplaceableTextures\...`):

| | Prod | Dev (`-loadfile`) |
|---|------|-------------------|
| **Где** | `imports/` → MPQ карты | Mirror в `_retail_/ReplaceableTextures/...` |
| **Как** | `wc3 build/go . --imports` | Копия тех же файлов в папку игры (не в git) |
| **Запуск** | Обычный / Custom Game | `-allowLocalFiles` (см. `build/wc3.py`) |

Релизная карта **только** через `imports/`. Папка игры — локальный crutch для dev, не для игроков.

## На практике

После смены custom icons: `wc3 go . --imports` **и** обновить mirror в game folder (пока вручную).

Проверка иконок без local mirror: загрузка карты из меню с отключенным `-allowLocalFiles` в реестре, не только `-loadfile`.
