local AbilityIds = require("lib.community.types.assets.AbilityIds")

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

local function presetFactory(base, presetDefaults)
    return setmetatable({
        parent = base.parent,
        apply = base.apply,
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

---@type AbilityFactoryChannel
A.channelNoTarget = presetFactory(A.channel, {
    options = 1,
    apply = function(a)
        a:setDisableOtherAbilities(1, false)
    end,
})

---@type AbilityFactoryChannel
A.channelTarget = presetFactory(A.channel, {
    options = 1,
    apply = function(a)
        a:setTargetType(1, 1)
        a:setDisableOtherAbilities(1, false)
    end,
})

---@type AbilityFactoryChannel
A.channelPoint = presetFactory(A.channel, {
    options = 1,
    apply = function(a)
        a:setTargetType(1, 2)
        a:setDisableOtherAbilities(1, false)
    end,
})

---@type AbilityFactoryChannel
A.channelArea = presetFactory(A.channel, {
    options = 3,
    apply = function(a)
        a:setTargetType(1, 2)
        a:setDisableOtherAbilities(1, false)
        a:setFollowThroughTime(1, 0)
        a:setArtDuration(1, 0)
    end,
})

---@type AbilityFactoryImmolation
A.immolationToggle = presetFactory(A.immolation, {
    apply = function(a)
        a:setDamageperInterval(1, 0)
        a:setManaDrainedperSecond(1, 0)
        a:setBufferManaRequired(1, 0)
    end,
})

---@type AbilityFactoryExhume
A.exhumeBased = presetFactory(A.exhume, {
    apply = function(a)
        a:setMaximumNumberofCorpses(1, 0)
        a:setCooldown(1, 0)
    end,
})

return A
