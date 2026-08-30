local Ids = require("data.ids")

ENUM_WAIT = "WAIT"

local Case = {}

---@param testFunc TestFn
---@return TestCase
function Case.new(testName, testFunc, x, y)
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
