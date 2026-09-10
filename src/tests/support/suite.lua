local Reporter = require("tests.support.reporter")

local Suite = {}

---@param name string
---@return TestSuite
function Suite.new(name)
    local self = {}

    self.name = name
    self.names = {}
    self.results = {}
    self.order = {}
    self.pending = 0
    self.total = 0

    ---@param testName string
    function self:registerTest(testName)
        if self.names[testName] then
            error(string.format("[%s] duplicate test name: %q", self.name, testName))
        end
        self.names[testName] = true
        self.total = self.total + 1
        self.pending = self.pending + 1
        self.order[#self.order + 1] = testName
    end

    ---@param testName string
    ---@param ok boolean
    ---@param err? string
    function self:record(testName, ok, err)
        self.results[testName] = { ok = ok, err = err }
        self.pending = self.pending - 1
        if self.pending == 0 then
            self:flush()
        end
    end

    function self:flush()
        Reporter.flushSuite(self)
    end

    return self --[[@as TestSuite]]
end

---@cast Suite SuiteModule
return Suite
