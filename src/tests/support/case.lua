local Case = {}

function Case.new(testName, testFunc, x, y)
    local self = {}

    local items = {}
    local units = {}

    -- local x = -100
    -- local y = -100

    function self:run()
        local ok, err = pcall(testFunc, self)
        if not ok then
            return self:finish(ok, err)
        end
    end

    function self:delay(delta, callback)
        Timed.call(delta, function()
            local ok, err = pcall(callback)
            self:finish(ok, err)
        end)
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

    function self:createUnit(unitTypeId, player)
        if player == nil then
            player = Player(0)
        end
        local unit = CreateUnit(player, FourCC(unitTypeId), x, y, 270)
        units[#units + 1] = unit
        return unit
    end

    function self:flush()
        for _, v in ipairs(items) do
            RemoveItem(v)
        end
        for _, v in ipairs(units) do
            RemoveUnit(v)
        end
        return true
    end

    return self
end

return Case
