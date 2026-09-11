local ReporterMode = require("tests.support.reporter_mode")

local Reporter = {}

---@type ReporterMode
Reporter.mode = nil

Reporter.Mode = ReporterMode

local COLOR_OK = "55ff55"
local COLOR_FAIL = "ff5555"

---@param hex string
---@param text string
---@return string
local function color(hex, text)
    return "|cff" .. hex .. text .. "|r"
end

---@param testName string
---@param ok boolean
---@param err? string
function Reporter.immediate(testName, ok, err)
    if Reporter.mode ~= ReporterMode.verbose then
        return
    end

    local msg
    if ok then
        msg = color(COLOR_OK, "OK: [" .. testName .. "]")
    else
        msg = color(COLOR_FAIL, "ERROR: [" .. testName .. "] -> " .. (err or "?"))
    end
    DisplayTextToPlayer(GetLocalPlayer(), 0, 0, msg)
end

---@param suite TestSuite
---@param failed { name: string, err?: string }[]
local function printFailures(suite, failed)
    Debug.original.print(color(COLOR_FAIL, string.format("[%s] FAILED %d/%d", suite.name, #failed, suite.total)))
    for _, f in ipairs(failed) do
        Debug.original.print(color(COLOR_FAIL, string.format("  x %s: %s", f.name, f.err or "?")))
    end
end

---@param suite TestSuite
function Reporter.flushSuite(suite)
    if Reporter.mode == ReporterMode.verbose then
        return
    end

    local failed = {}
    local passed = 0

    for _, testName in ipairs(suite.order) do
        local result = suite.results[testName]
        if result.ok then
            passed = passed + 1
        else
            failed[#failed + 1] = { name = testName, err = result.err }
        end
    end

    if Reporter.mode == ReporterMode.errors then
        if #failed == 0 then
            return
        end
        printFailures(suite, failed)
        return
    end

    if #failed == 0 then
        Debug.original.print(color(COLOR_OK, string.format("[%s] %d/%d OK", suite.name, passed, suite.total)))
        return
    end

    printFailures(suite, failed)
end

---@cast Reporter TestReporter
return Reporter
