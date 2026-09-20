local AbilityIds = require("vendor.assets.AbilityIds")

---@type AbilityFactories
local F = require("data.generated.ability_factories")

local shared = dofile("tools/oe/kinds/_shared.lua")

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
    local levels = data.levels or 1
    local presetApply = preset.apply
    local userApply = data and data.apply
    if presetApply or userApply then
        local ctx = { levels = levels }
        row.apply = function(a)
            if presetApply then
                shared.runApplyPerLevel(presetApply, a, ctx)
            end
            if userApply then
                shared.runApplyPerLevel(userApply, a, ctx)
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
        apply = function(a, level)
            a:setDisableOtherAbilities(level, false)
            a:setFollowThroughTime(level, 0)
            a:setArtDuration(level, 0)
        end,
    }),

    channelTarget = presetFactory(F.channel, {
        options = 1,
        apply = function(a, level)
            a:setTargetType(level, 1)
            a:setDisableOtherAbilities(level, false)
            a:setFollowThroughTime(level, 0)
            a:setArtDuration(level, 0)
        end,
    }),

    channelPoint = presetFactory(F.channel, {
        options = 1,
        apply = function(a, level)
            a:setTargetType(level, 2)
            a:setDisableOtherAbilities(level, false)
            a:setFollowThroughTime(level, 0)
            a:setArtDuration(level, 0)
        end,
    }),

    channelArea = presetFactory(F.channel, {
        options = 3, -- fix missing area circle
        apply = function(a, level)
            a:setAreaofEffect(level, 300)
            a:setCastRange(level, 300)
            a:setTargetType(level, 2)
            a:setDisableOtherAbilities(level, false)
            a:setFollowThroughTime(level, 0)
            a:setArtDuration(level, 0)
        end,
    }),

    immolationToggle = presetFactory(F.immolation, {
        apply = function(a, level)
            a:setDamageperInterval(level, 0)
            a:setManaDrainedperSecond(level, 0)
            a:setBufferManaRequired(level, 0)
        end,
    }),

    exhumeBased = presetFactory(F.exhume, {
        apply = function(a, level)
            a:setMaximumNumberofCorpses(level, 0)
            a:setCooldown(level, 0)
        end,
    }),

    --- Hidden evasion with 0% — passive marker for script triggers, no gameplay effect.
    passiveGeneric = presetFactory(F.evasion, {
        apply = function(a, level)
            a:setChancetoEvade(level, 0)
        end,
    }),
    passiveAura = presetFactory(F.slowAura, {
        apply = function(a, level)
            a:setMovementSpeedFactor(level, 0)
            a:setAttackSpeedFactor(level, 0)
            a:setAreaofEffect(level, 1)
            a:setTargetsAllowed(level, "self")
        end,
    }),
    nonDispellableSelfBuffTimed = presetFactory(F.berserkerRage1, {
        apply = function(a, level)
            a:setAttackSpeedIncrease(level, 0)
            a:setMovementSpeedIncrease(level, 0)
            a:setDamageTakenIncrease(level, 0)
        end,
    }),
    nonDispellableTargetDebuff = presetFactory(F.acidBomb, {
        apply = function(a, level)
            a:setDamageInterval(level, 1)
            a:setPrimaryDamage(level, 0)
            a:setMovementSpeedReduction(level, 0)
            a:setArmorPenalty(level, 0)
            a:setSecondaryDamage(level, 0)
            a:setAttackSpeedReduction(level, 0)
            a:setAreaofEffect(level, 0)
        end,
    }),
}, { __index = F })
