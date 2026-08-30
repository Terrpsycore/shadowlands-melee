local Ids = require("data.ids")

ENUM_WAIT = "WAIT"

---@alias TestWait "WAIT"

---@class TestCase
---@field run fun(self: TestCase)
---@field delay fun(self: TestCase, delta: number, callback: fun()): TestWait
---@field finish fun(self: TestCase, ok: boolean, err: any)
---@field ok fun(self: TestCase)
---@field fail fun(self: TestCase, msg: string)
---@field report fun(self: TestCase, msg: string)
---@field createItem fun(self: TestCase, itemTypeId: string): item
---@field createUnit fun(self: TestCase, unitTypeId: string, player?: player, collision?: boolean): unit
---@field applyDummyOrder fun(self: TestCase, owner: player, target: unit, abilityId: integer, order: string, level?: integer)
---@field flush fun(self: TestCase): boolean
---@field addFlushCallback fun(self: TestCase, callback: fun())

---@alias TestFn fun(case: TestCase): TestWait|nil

---@class CaseModule
local Case = {}

---@param testName string
---@param testFunc TestFn
---@param x number
---@param y number
---@return TestCase
function Case.new(testName, testFunc, x, y)
    ---@type TestCase
    local self = {}

    local items = {}
    local units = {}

    local flushCallbacks = {}

    -- local x = -100
    -- local y = -100

    function self:run()
        local ok, res = pcall(testFunc, self)
        if not ok then
            return self:finish(ok, res)
        end
        if res ~= ENUM_WAIT then
            self:finish(ok, res)
        end
    end

    function self:delay(delta, callback)
        Timed.call(delta, function()
            local ok, err = pcall(callback)
            self:finish(ok, err)
        end)
        return ENUM_WAIT
    end

    function self:finish(ok, err)
        self:flush()
        if ok then
            return self:ok()
        else
            return self:fail(err)
        end
    end

    function self:ok()
        return self:report("OK: [" .. testName .. "]")
    end

    function self:fail(msg)
        return self:report("ERROR: [" .. testName .. "] -> " .. msg)
    end

    function self:report(msg)
        return DisplayTextToPlayer(GetLocalPlayer(), 0, 0, msg)
    end

    ---
    ---
    ---

    function self:createItem(itemTypeId)
        local item = CreateItem(FourCC(itemTypeId), x, y)
        items[#items + 1] = item
        return item
    end

    function self:createUnit(unitTypeId, player, collision)
        if player == nil then
            player = Player(0)
        end
        local unit = CreateUnit(player, FourCC(unitTypeId), x, y, 270)
        if collision == nil then
            UnitAddAbility(unit, FourCC(Ids.abilities.phase))
            IssueImmediateOrderBJ(unit, "windwalk")
        end
        units[#units + 1] = unit
        return unit
    end

    function self:applyDummyOrder(owner, target, abilityId, order, level)
        local dummy = self:createUnit(Ids.units.dummy, owner, true)
        UnitApplyTimedLife(dummy, FourCC("BTLF"), 10)
        local abilityAdded = UnitAddAbility(dummy, abilityId)
        if level then
            SetUnitAbilityLevel(dummy, abilityId, level)
        end
        local orderIssued = IssueTargetOrder(dummy, order, target)
        return {
            dummy = dummy,
            abilityAdded = abilityAdded,
            orderIssued = orderIssued,
        }
    end

    function self:flush()
        for _, callback in ipairs(flushCallbacks) do
            callback()
        end
        for _, v in ipairs(items) do
            RemoveItem(v)
        end
        for _, v in ipairs(units) do
            RemoveUnit(v)
        end
        return true
    end

    function self:addFlushCallback(callback)
        table.insert(flushCallbacks, callback)
    end

    return self
end

return Case
