local AbilityIds = require("vendor.assets.AbilityIds")

---@type AbilityFactories
local F = require("data.generated.ability_factories")

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

---@type PresetFactory
local presetFactory
---@diagnostic disable-next-line
function presetFactory(base, presetDefaults)
    return setmetatable({
        parent = base.parent,
        apply = base.apply,
    }, {
        __call = function(_, data)
            return base(mergeDefaults(presetDefaults, data))
        end,
    })
end

---@return AbilityModule
return setmetatable({
    inventory = setmetatable({
        parent = AbilityIds.inventory,
        apply = function(fn)
            return fn
        end,
    }, getmetatable(F.innerFire)),

    channelNoTarget = presetFactory(F.channel, {
        options = 1,
        apply = function(a)
            a:setDisableOtherAbilities(1, false)
        end,
    }),

    channelTarget = presetFactory(F.channel, {
        options = 1,
        apply = function(a)
            a:setTargetType(1, 1)
            a:setDisableOtherAbilities(1, false)
        end,
    }),

    channelPoint = presetFactory(F.channel, {
        options = 1,
        apply = function(a)
            a:setTargetType(1, 2)
            a:setDisableOtherAbilities(1, false)
        end,
    }),

    channelArea = presetFactory(F.channel, {
        options = 3,
        apply = function(a)
            a:setTargetType(1, 2)
            a:setDisableOtherAbilities(1, false)
            a:setFollowThroughTime(1, 0)
            a:setArtDuration(1, 0)
        end,
    }),

    immolationToggle = presetFactory(F.immolation, {
        apply = function(a)
            a:setDamageperInterval(1, 0)
            a:setManaDrainedperSecond(1, 0)
            a:setBufferManaRequired(1, 0)
        end,
    }),

    exhumeBased = presetFactory(F.exhume, {
        apply = function(a)
            a:setMaximumNumberofCorpses(1, 0)
            a:setCooldown(1, 0)
        end,
    }),

    --- Hidden evasion with 0% — passive marker for script triggers, no gameplay effect.
    passiveGeneric = presetFactory(F.evasion, {
        apply = function(a)
            a:setChancetoEvade(1, 0)
        end,
    }),
    passiveAura = presetFactory(F.slowAura, {
        apply = function(a)
            a:setMovementSpeedFactor(1, 0)
            a:setAttackSpeedFactor(1, 0)
            a:setAreaofEffect(1, 1)
            a:setTargetsAllowed(1, "self")
        end,
    }),
    nonDispellableSelfBuffTimed = presetFactory(F.berserkerRage1, {
        apply = function(a)
            a:setAttackSpeedIncrease(1, 0.2)
            a:setMovementSpeedIncrease(1, 0.2)
            a:setDamageTakenIncrease(1, 0)
        end,
    }),
}, { __index = F })
