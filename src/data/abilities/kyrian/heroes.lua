-- TODO: fly-ground abilities
local Ids = require("data.ids")

local A = require("data.ability")

return {
    overcharge = A.channel({
        name = "Overcharge",
        levels = 3,
        options = 1,
        buttonNormalX = 0,
        buttonNormalY = 2,
        apply = A.channel.apply(function(a)
            a:setRequirements("")
            for level = 1, 3 do
                a:setDisableOtherAbilities(level, false)
                a:setFollowThroughTime(level, 0)
            end
        end),
    }),
    judgingGaze = A.seaWitchFrostArrows({
        name = "Judging Gaze",
        levels = 3,
        buffs = { "judgingGazeEvent" },
        apply = A.seaWitchFrostArrows.apply(function(a)
            a:setExtraDamage(1, 0)
            a:setAttackSpeedFactor(1, 0)
            a:setMovementSpeedFactor(1, 0)
        end),
    }),
    judgingGazeMissDebuff = A.curse({
        name = "",
        apply = A.curse.apply(function(a)
            --
        end),
    }),
    judgingGazeArmorDebuff = A.acidBomb({
        name = "",
        apply = A.acidBomb.apply(function(a)
            a:setDamageInterval(1, 1)
            a:setPrimaryDamage(1, 0)
            a:setMovementSpeedReduction(1, 0)
            a:setArmorPenalty(1, 2)
            a:setSecondaryDamage(1, 0)
            a:setAttackSpeedReduction(1, 0)
        end),
    }),
    -- judgingGazeDummy
    memoryPeer = A.channel({
        name = "Memory Peer",
        levels = 3,
        options = 1,
        buttonNormalX = 0,
        buttonNormalY = 2,
        apply = A.channel.apply(function(a)
            a:setRequirements("")
            for level = 1, 3 do
                a:setTargetType(level, 1)
                a:setDisableOtherAbilities(level, false)
            end
        end),
    }),
    memoryPeerSummon = A.feralSpirit({
        name = "",
        levels = 3,
        apply = A.feralSpirit.apply(function(a)
            a:setRequirements("")
            for level = 1, 3 do
                a:setSummonedUnit(level, Ids.units.memorySpirit)
                a:setNumberofSummonedUnits(level, level)
                a:setManaCost(level, 0)
                a:setCooldown(level, 0)
                a:setDurationNormal(level, 60)
                a:setDurationHero(level, 20)
            end
        end),
    }),
    -- Slow Poison Non-stacking: physical, single-target, not dispelled
    memoryPeerSlow = A.slowPoison({
        name = "",
        levels = 3,
        buffs = { "memoryPeer" },
        apply = A.slowPoison.apply(function(a)
            a:setRequirements("")
            for level = 1, 3 do
                a:setDamagePerSecond(level, 0)
                a:setMovementSpeedFactor(level, 0.6)
                a:setAttackSpeedFactor(level, 0.25)
                a:setStackingType(level, StackingType.Damage)
                a:setDurationNormal(level, 60)
                a:setDurationHero(level, 20)
            end
        end),
    }),
    oneMoreChance = A.channel({
        name = "One More Chance",
        levels = 3,
        options = 1,
        buttonNormalX = 0,
        buttonNormalY = 2,
        buffs = { "oneMoreChance" },
        apply = A.channel.apply(function(a)
            a:setHotkeyNormal("E")
            a:setBaseOrderID(1, "innerfire")
            a:setBaseOrderID(2, "innerfire")
            a:setBaseOrderID(3, "innerfire")
            a:setOrderStringUseTurnOn("innerfire")
            a:setRequirements("")
            a:setTargetType(1, 1)
            a:setDisableOtherAbilities(1, false)
            a:setHeroAbility(true)
        end),
    }),
    oneMoreChanceBuffDummy = A.innerFire({
        name = "One More Chance",
        levels = 3,
        buttonNormalX = 0,
        buttonNormalY = 2,
        buffs = { "oneMoreChance" },
        apply = A.innerFire.apply(function(a)
            a:setRequirements("")
            a:setHeroAbility(true)
            a:setDefenseIncrease(1, 0)
            a:setDamageIncrease(1, 0)
            a:setDurationNormal(1, 5)
            a:setDurationHero(1, 5)
        end),
    }),
    oneMoreChanceCross = A.reincarnation({
        name = "One More Chance",
        levels = 3,
        apply = A.reincarnation.apply(function(a)
            a:setReincarnationDelay(1, 3)
            a:setReincarnationDelay(2, 3)
            a:setReincarnationDelay(3, 3)
        end),
    }),
    oneMoreChanceHealDummy = A.holyLight({
        name = "One More Chance",
        levels = 3,
        buffs = { "oneMoreChance" },
        apply = A.holyLight.apply(function(a) end),
    }),
    lastStand = A.channel({
        name = "Last Stand",
        options = 1,
        buttonNormalX = 0,
        buttonNormalY = 2,
        apply = A.channel.apply(function(a)
            a:setRequirements("")
            a:setFollowThroughTime(1, 5)
            a:setHotkeyNormal("R")
            a:setOrderStringUseTurnOn("bloodlust")
            a:setDisableOtherAbilities(1, false)
            a:setHeroAbility(true)
        end),
    }),
    lastStandAura = A.slowAura({
        name = "Last Stand",
        buffs = { "lastStand" },
        apply = A.slowAura.apply(function(a)
            a:setRequirements("")
            a:setMovementSpeedFactor(1, 0)
            a:setAttackSpeedFactor(1, 0)
            a:setAreaofEffect(1, 600)
            a:setTargetsAllowed(1, "allied,ground,organic,nonhero,player")
        end),
    }),
    lastStandHealDummy = A.itemAreaHealing({
        name = "Last Stand",
        apply = A.itemAreaHealing.apply(function(a)
            a:setRequirements("")
            a:setHitPointsGained(1, 200)
            a:setAreaofEffect(1, 600)
        end),
    }),
}
