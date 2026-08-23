local Case = require("tests.support.case")

local T = {}

function T.new()
    local self = {}
    local world = GetWorldBounds()
    local minX, minY, maxX, maxY = world[1], world[2], world[3], world[4]

    local cursorX = minX
    local cursorY = minY
    local rowHeight = 0

    local cellSize = 700
    local grid = {}

    local function alloc(cellSize)
        if cursorX + cellSize > maxX then
            cursorX = minX
            cursorY = cursorY + rowHeight
            rowHeight = 0
        end
        if cursorY + cellSize > maxY then
            error("no free test cells on the map")
        end
        local x, y = cursorX, cursorY
        cursorX = cursorX + cellSize
        if cellSize > rowHeight then
            rowHeight = cellSize
        end
        return x, y
    end

    function self:create_case(name, testFunc)
        local x, y = alloc(cellSize)
        return Case.new(name, testFunc, x, y)
    end

    function self:test(name, testFunc)
        return self:create_case(name, testFunc):run()
    end

    return self
end

return T:new()
