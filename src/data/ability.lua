local AbilityIds = require("lib.community.types.assets.AbilityIds")

---@class AbilityRowInput
---@field name? string
---@field levels? integer
---@field buffs? string[]
---@field autocastRange? number
---@field options? integer
---@field button? integer[]
---@field hotkey? string
---@field requirements? string
---@field manaCost? number|number[]
---@field art? { icon?: string, iconOff?: string, iconResearch?: string }
---@field apply? fun(a: AbilityDefinition)

---@class AbilityFactory
---@field parent string
---@field apply fun(fn: fun(a: AbilityDefinition)): fun(a: AbilityDefinition)
---@overload fun(data?: AbilityRowInput): AbilityRowInput

---@alias AbilityDefinitionChannel AbilityDefinitionIllidanChannel
---@alias AbilityDefinitionImmolation AbilityDefinitionImmolationcreep

local A = require("data.generated.ability_factories")

local function mergeDefaults(preset, data)
    local row = {}
    for k, v in pairs(preset) do
        if k ~= "apply" then
            row[k] = v
        end
    end
    for k, v in pairs(data or {}) do
        if k ~= "apply" then
            row[k] = v
        end
    end
    local presetApply = preset.apply
    local userApply = data and data.apply
    if presetApply or userApply then
        row.apply = function(a)
            if presetApply then
                presetApply(a)
            end
            if userApply then
                userApply(a)
            end
        end
    end
    return row
end

---@generic T: AbilityFactory
---@param base T
---@param presetDefaults AbilityRowInput
---@return T
local function presetFactory(base, presetDefaults)
    ---@type AbilityFactory
    local factoryBase = base
    return setmetatable({
        parent = factoryBase.parent,
        apply = factoryBase.apply,
    }, {
        __call = function(_, data)
            return base(mergeDefaults(presetDefaults, data))
        end,
    })
end

---@class AbilityFactoryInventory : AbilityFactory
---@field apply fun(fn: fun(a: AbilityInventory)): fun(a: AbilityInventory)

---@type AbilityFactoryInventory
A.inventory = setmetatable({
    parent = AbilityIds.inventory,
    apply = function(fn)
        return fn
    end,
}, getmetatable(A.innerFire))

---@param a AbilityDefinitionChannel
local function applyChannelNoTargetDefaults(a)
    a:setDisableOtherAbilities(1, false)
end

---@param a AbilityDefinitionChannel
local function applyChannelTargetDefaults(a)
    a:setTargetType(1, 1)
    a:setDisableOtherAbilities(1, false)
end

---@param a AbilityDefinitionChannel
local function applyChannelPointDefaults(a)
    a:setTargetType(1, 2)
    a:setDisableOtherAbilities(1, false)
end

---@param a AbilityDefinitionChannel
local function applyChannelAreaDefaults(a)
    a:setTargetType(1, 2)
    a:setDisableOtherAbilities(1, false)
    a:setFollowThroughTime(1, 0)
    a:setArtDuration(1, 0)
end

---@param a AbilityDefinitionImmolation
local function applyImmolationToggleDefaults(a)
    a:setDamageperInterval(1, 0)
    a:setManaDrainedperSecond(1, 0)
    a:setBufferManaRequired(1, 0)
end

---@param a AbilityDefinitionExhume
local function applyExhumeBasedDefaults(a)
    a:setMaximumNumberofCorpses(1, 0)
    a:setCooldown(1, 0)
end

---@param a AbilityDefinitionEvasion
local function applyPassiveGenericDefaults(a)
    a:setChancetoEvade(1, 0)
end

A.channelNoTarget = presetFactory(A.channel, {
    options = 1,
    apply = applyChannelNoTargetDefaults,
})

A.channelTarget = presetFactory(A.channel, {
    options = 1,
    apply = applyChannelTargetDefaults,
})

A.channelPoint = presetFactory(A.channel, {
    options = 1,
    apply = applyChannelPointDefaults,
})

A.channelArea = presetFactory(A.channel, {
    options = 3,
    apply = applyChannelAreaDefaults,
})

A.immolationToggle = presetFactory(A.immolation, {
    apply = applyImmolationToggleDefaults,
})

A.exhumeBased = presetFactory(A.exhume, {
    apply = applyExhumeBasedDefaults,
})

--- Hidden evasion with 0% — passive marker for script triggers, no gameplay effect.
A.passiveGeneric = presetFactory(A.evasion, {
    apply = applyPassiveGenericDefaults,
})

return A
