local ReporterMode = require("tests.support.reporter_mode")

local logger = require("utils.logger")

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

---@param hex string
---@param plain string
local function printColored(hex, plain)
    Debug.original.print(color(hex, plain))

    logger.log(plain)
end

---@param testName string
---@param ok boolean
---@param err? string
function Reporter.immediate(testName, ok, err)
    if Reporter.mode ~= ReporterMode.verbose then
        return
    end

    local plain

    if ok then
        plain = "OK: [" .. testName .. "]"
    else
        plain = "ERROR: [" .. testName .. "] -> " .. (err or "?")
    end
    DisplayTextToPlayer(GetLocalPlayer(), 0, 0, color(ok and COLOR_OK or COLOR_FAIL, plain))
    logger.log(plain)
end

---@param suite TestSuite
---@param failed { name: string, err?: string }[]
local function printFailures(suite, failed)
    printColored(COLOR_FAIL, string.format("[%s] FAILED %d/%d", suite.name, #failed, suite.total))

    for _, f in ipairs(failed) do
        printColored(COLOR_FAIL, string.format("  x %s: %s", f.name, f.err or "?"))
    end
end

---@param suite TestSuite
function Reporter.flushSuite(suite)
    logger.log(string.format("--- [%s] ---", suite.name))

    if Reporter.mode ~= ReporterMode.verbose then
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
            if #failed > 0 then
                printFailures(suite, failed)
            end
        elseif #failed == 0 then
            printColored(COLOR_OK, string.format("[%s] %d/%d OK", suite.name, passed, suite.total))
        else
            printFailures(suite, failed)
        end
    end

    logger.flush()
end

---@cast Reporter TestReporter
return Reporter
