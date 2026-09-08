local AbilityIds = require("lib.community.types.assets.AbilityIds")
local Ids = require("data.generated.ids")
local generated = require("data.generated.ability_classes")

local reserved = {
    class = true,
    parent = true,
    apply = true,
}

local function eachLevel(data)
    local levels = data.levels or 1
    local level = 0
    return function()
        level = level + 1
        if level <= levels then
            return level
        end
    end
end

local fields = {
    --- @param a AbilityDefinition
    name = function(a, value, data)
        a:setName(value)
        for level in eachLevel(data) do
            local isHero = data.class == "hero"
            local suffix
            if isHero then
                suffix = " [" .. level .. "]"
            else
                suffix = ""
            end
            a:setTooltipNormal(level, value .. suffix)
        end
        a:setTooltipLearn(value)
    end,
    autocastRange = function(a, value)
        a:setAutocastRange(1, value)
    end,
    options = function(a, value, data)
        for level in eachLevel(data) do
            a:setOptions(level, value)
        end
    end,
    buttonNormalX = function(a, value)
        a:setButtonPositionNormalX(value)
    end,
    buttonNormalY = function(a, value)
        a:setButtonPositionNormalY(value)
    end,
    levels = function(a, value)
        a:setLevels(value)
    end,
    buffs = function(a, slugs, data)
        local parts = {}
        for _, slug in ipairs(slugs) do
            local id = Ids.buffs[slug]
            if not id then
                error("unknown buff '" .. slug .. "'")
            end
            parts[#parts + 1] = id
        end
        for level in eachLevel(data) do
            a:setBuffs(level, table.concat(parts, ","))
        end
    end,
}

local function applyFields(a, data, slug)
    for key, value in pairs(data) do
        if not reserved[key] then
            local handler = fields[key]
            if not handler then
                error("unknown ability field '" .. key .. "' on " .. slug)
            end
            handler(a, value, data)
        end
    end
end

local fallback = {
    new = function(id, parent)
        return AbilityDefinition:new(id, parent)
    end,
}

local overrides = {
    [AbilityIds.inventory] = {
        new = function(id, parent)
            return AbilityInventory:new(id, parent)
        end,
        apply = function(a)
            a:setCanUseItems(1, false)
        end,
    },
}

return {
    resolve = function(parent)
        local override = overrides[parent]
        if override then
            return override
        end
        local cls = generated[parent]
        if cls then
            return {
                new = function(id)
                    return cls:new(id)
                end,
            }
        end
        return fallback
    end,
    defaults = function(a, data)
        a:setHeroAbility(data.class == "hero")
    end,
    applyFields = applyFields,
}
