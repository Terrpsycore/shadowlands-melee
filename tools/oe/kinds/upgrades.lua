local shared = dofile("tools/oe/kinds/_shared.lua")

local reserved = {
    parent = true,
    apply = true,
    faction = true,
}

local fields = {
    name = function(u, value, data)
        local levels = data.levels or 1
        for level = 1, levels do
            u:setName(level, value)
            u:setTooltip(level, value)
        end
    end,
    class = function(u, value)
        u:setClass(value)
    end,
    race = function(u, value)
        u:setRace(value)
    end,
    levels = function(u, value)
        u:setLevels(value)
    end,
    cost = function(u, value)
        shared.applySubfields(u, value, {
            gold = function(u, v)
                u:setGoldCostBase(v)
            end,
            goldIncrement = function(u, v)
                u:setGoldCostIncrement(v)
            end,
            lumber = function(u, v)
                u:setLumberCostBase(v)
            end,
            lumberIncrement = function(u, v)
                u:setLumberCostIncrement(v)
            end,
            time = function(u, v)
                u:setTimeBase(v)
            end,
            timeIncrement = function(u, v)
                u:setTimeIncrement(v)
            end,
        }, "cost")
    end,
    button = function(u, value)
        u:setButtonPositionX(value[1])
        u:setButtonPositionY(value[2])
    end,
    icon = function(u, value, data)
        local levels = data.levels or 1
        local path = shared.normalizePath(value)
        for level = 1, levels do
            u:setIcon(level, path)
        end
    end,
    hotkey = function(u, value, data)
        local levels = data.levels or 1
        for level = 1, levels do
            u:setHotkey(level, value)
        end
    end,
    tooltipExtended = function(u, value, data)
        local levels = data.levels or 1
        for level = 1, levels do
            u:setTooltipExtended(level, value)
        end
    end,
    requirements = function(u, slugs, data)
        local levels = data.levels or 1
        local ids = {}
        for _, slug in ipairs(slugs) do
            ids[#ids + 1] = shared.resolveUpgradeId(slug)
        end
        local value = table.concat(ids, ",")
        for level = 1, levels do
            u:setRequirements(level, value)
        end
    end,
    requirementsLevels = function(u, value, data)
        local levels = data.levels or 1
        for level = 1, levels do
            u:setRequirementsLevels(level, value)
        end
    end,
    transferWithUnitOwnership = function(u, value)
        u:setTransferWithUnitOwnership(value)
    end,
    effects = function(u, list)
        for index, fx in ipairs(list) do
            u:setEffectType(index, fx.type)
            if fx.base ~= nil then
                u:setEffectBase(index, fx.base)
            end
            if fx.increment ~= nil then
                u:setEffectIncrement(index, fx.increment)
            end
            if fx.code ~= nil then
                u:setEffectCode(index, fx.code)
            end
        end
    end,
}

local function applyFields(u, data, slug)
    for key, value in pairs(data) do
        if not reserved[key] then
            local handler = fields[key]
            if not handler then
                error("unknown upgrade field '" .. key .. "' on " .. slug)
            end
            handler(u, value, data)
        end
    end
end

return {
    resolve = function()
        return {
            new = function(id, parent)
                return UpgradeDefinition:new(id, parent)
            end,
        }
    end,
    defaults = function() end,
    applyFields = applyFields,
}
