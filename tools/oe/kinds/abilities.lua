-- Declarative row fields: tools/oe/ability_row_fields.lua (type hints via tools/gen/ability_kinds.lua)
local AbilityIds = require("vendor.assets.AbilityIds")
local Ids = require("data.generated.ids")
local generated = require("data.generated.ability_classes")
local shared = dofile("tools/oe/kinds/_shared.lua")

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

---@param value number|number[]
local function applyPerLevel(a, data, setter, value)
    if type(value) == "number" then
        for level in eachLevel(data) do
            setter(a, level, value)
        end
        return
    end
    for level, v in ipairs(value) do
        setter(a, level, v)
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
    button = function(a, value)
        if value[1] == nil or value[2] == nil then
            error("button requires { x, y }")
        end
        a:setButtonPositionNormalX(value[1])
        a:setButtonPositionNormalY(value[2])
    end,
    hotkey = function(a, value)
        a:setHotkeyNormal(value)
    end,
    levels = function(a, value)
        a:setLevels(value)
    end,
    requirements = function(a, value)
        a:setRequirements(value)
    end,
    manaCost = function(a, value, data)
        applyPerLevel(a, data, function(ability, level, v)
            ability:setManaCost(level, v)
        end, value)
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
    art = function(a, value)
        shared.applySubfields(a, value, {
            icon = function(a, v)
                a:setIconNormal(shared.normalizePath(v))
            end,
            iconOff = function(a, v)
                a:setIconTurnOff(shared.normalizePath(v))
            end,
            iconResearch = function(a, v)
                a:setIconResearch(shared.normalizePath(v))
            end,
        }, "art")
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
            a:setCanDropItems(1, true)
            a:setCanGetItems(1, true)
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
                    -- Subclass ctor calls createDefinition; super must not receive parent.
                    ---@diagnostic disable-next-line: missing-parameter
                    return cls:new(id)
                end,
            }
        end
        return fallback
    end,
    defaults = function(a, data)
        a:setHeroAbility(data.class == "hero")
        if data.requirements == nil then
            a:setRequirements("")
        end
    end,
    applyFields = applyFields,
}
