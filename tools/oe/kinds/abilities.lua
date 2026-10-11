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
    hidden = function(a, value, data)
        if value then
            for level in eachLevel(data) do
                a:setButtonPositionNormalX(0)
                a:setButtonPositionNormalY(-11)
                a:setButtonPositionResearchX(0)
                a:setButtonPositionResearchY(-11)
                a:setButtonPositionTurnOffX(0)
                a:setButtonPositionTurnOffY(-11)
            end
        end
    end,
    button = function(a, value)
        if value[1] == nil or value[2] == nil then
            error("button requires { x, y }")
        end
        a:setButtonPositionNormalX(value[1])
        a:setButtonPositionNormalY(value[2])
        a:setButtonPositionResearchX(value[1])
        a:setButtonPositionResearchY(value[2] - 2)
        a:setButtonPositionTurnOffX(value[1])
        a:setButtonPositionTurnOffY(value[2])
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
                a:setIconResearch(shared.normalizePath(v))
            end,
            iconOff = function(a, v)
                a:setIconTurnOff(shared.normalizePath(v))
            end,
            iconResearch = function(a, v)
                a:setIconResearch(shared.normalizePath(v))
            end,
        }, "art")
    end,
    order = function(a, value, data)
        if type(value) == "string" then
            for level in eachLevel(data) do
                a:setBaseOrderID(level, value)
            end
            a:setOrderStringUseTurnOn(value)
            a:setOrderStringActivate(value)
        elseif type(value) == "table" then
            if not value.on or not value.off then
                error("Invalid order data field")
            end
            if a.setBaseOrderID then
                for level in eachLevel(data) do
                    a:setBaseOrderID(level, value.on)
                end
            end
            a:setOrderStringUseTurnOn(value.on)
            a:setOrderStringActivate(value.on)
            a:setOrderStringTurnOff(value.off)
            a:setOrderStringDeactivate(value.off)
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
        local isHero = data.class == "hero"
        local isItem = data.class == "item"
        a:setHeroAbility(isHero)
        a:setItemAbility(isItem)
        a:setButtonPositionNormalX(0)
        a:setButtonPositionNormalY(2)
        a:setButtonPositionTurnOffX(0)
        a:setButtonPositionTurnOffY(2)
        if isHero then
            a:setButtonPositionResearchX(0)
            a:setButtonPositionResearchY(0)
        end
        if data.requirements == nil then
            a:setRequirements("")
        end
    end,
    applyFields = applyFields,
}
