local Case = require("tests.support.case")
local dump = require("utils.logger")

local T = {}

function T.new()
    local self = {}
    local world = GetWorldBounds()
    local margin = 800
    local minX = GetRectMinX(world) + margin
    local minY = GetRectMinY(world) + margin
    local maxX = GetRectMaxX(world) - margin / 2
    local maxY = GetRectMaxY(world) - margin / 2

    local cursorX = minX
    local cursorY = minY
    local rowHeight = 0

    local cellSize = 700
    local grid = {}

    local function alloc(cellSize)
        -- 1. Проверяем, помещаемся ли по горизонтали. Если нет — переносим строку.
        if cursorX + cellSize > maxX then
            print("-> НЕ ПОМЕЩАЕТСЯ! Перенос строки.")
            cursorX = minX
            cursorY = cursorY + rowHeight
            rowHeight = 0
        end

        -- 2. Проверяем, помещаемся ли по вертикали в текущей/новой строке.
        if cursorY + cellSize > maxY then
            error(
                "Превышены границы карты: не осталось свободных тестовых ячеек! Увеличьте размер карты или уменьшите cellSize."
            )
        end

        -- 3. Выделяем координаты
        local x, y = cursorX, cursorY

        -- 4. Сдвигаем курсор для следующего элемента в этой строке
        cursorX = cursorX + cellSize

        -- 5. Запоминаем максимальную высоту элемента в текущей строке
        if cellSize > rowHeight then
            rowHeight = cellSize
        end

        return x, y
    end

    function self:freeCell(i)
        grid[i] = nil
    end

    function self:createCase(name, testFunc)
        local x, y = alloc(cellSize)
        return Case.new(name, testFunc, x, y)
    end

    function self:test(name, testFunc)
        return self:createCase(name, testFunc):run()
    end

    return self
end

return T:new()
