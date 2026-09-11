local Case = require("tests.support.case")
local Reporter = require("tests.support.reporter")
local Suite = require("tests.support.suite")

local T = {}

local pendingRunners = {}

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

---@param size number
---@return number x
---@return number y
local function alloc(size)
    if cursorX + size > maxX then
        print("-> НЕ ПОМЕЩАЕТСЯ! Перенос строки.")
        cursorX = minX
        cursorY = cursorY + rowHeight
        rowHeight = 0
    end

    if cursorY + size > maxY then
        error(
            "Превышены границы карты: не осталось свободных тестовых ячеек! Увеличьте размер карты или уменьшите cellSize."
        )
    end

    local x, y = cursorX, cursorY
    cursorX = cursorX + size

    if size > rowHeight then
        rowHeight = size
    end

    return x, y
end

---@param suite TestSuite
---@return TestRunner
local function createRunner(suite)
    local self = {}
    local queued = {}
    local started = false

    ---@param name string
    ---@param testFunc TestFn
    function self:test(name, testFunc)
        if started then
            error(string.format("[%s] test registered after run: %q", suite.name, name))
        end

        suite:registerTest(name)
        queued[#queued + 1] = { name = name, testFunc = testFunc }
    end

    function self:run()
        if started then
            error(string.format("[%s] suite already started", suite.name))
        end
        started = true

        if #queued == 0 then
            return
        end

        for _, entry in ipairs(queued) do
            ---@type TestReporterFn
            local reporter = function(testName, ok, err)
                Reporter.immediate(testName, ok, err)
                suite:record(testName, ok, err)
            end

            local x, y = alloc(cellSize)
            Case.new(entry.name, entry.testFunc, x, y, reporter):run()
        end
    end

    return self --[[@as TestRunner]]
end

---@param name string
---@return TestRunner
function T.suite(name)
    local runner = createRunner(Suite.new(name))
    pendingRunners[#pendingRunners + 1] = runner
    return runner
end

function T.runAll()
    for _, runner in ipairs(pendingRunners) do
        runner:run()
    end
end

---@cast T RunnerModule
return T
