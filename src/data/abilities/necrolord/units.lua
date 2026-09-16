local Ids = require("data.ids")

local A = require("data.abilityPresets")

return {
    surviveWish = A.passiveGeneric({
        name = "Survive Wish",
        buffs = { "surviveWish" },
    }),
    surviveWishActive = A.berserkerRage1({
        name = "Survive Wish",
        apply = A.berserkerRage1.apply(function(a)
            a:setAttackSpeedIncrease(1, 0.2)
            a:setMovementSpeedIncrease(1, 0.2)
            a:setDamageTakenIncrease(1, 0)
        end),
    }),
    combatExpertise = A.passiveGeneric({
        name = "Combat Expertise",
    }),
    combatExpertiseDamage = A.itemDamageBonus({
        levels = 5,
        apply = A.itemDamageBonus.apply(function(a)
            for level = 1, 5 do
                a:setAttackBonus(level, 1 * level)
            end
        end),
    }),
    vanish = A.channelNoTarget({
        name = "Vanish",
    }),
    vanishDummy = A.invisibility({
        apply = A.invisibility.apply(function(a)
            a:setTransitionTimeseconds(1, 2)
        end),
    }),
    animateDead = A.raiseDead({
        name = "Animate Dead",
    }),
    animateDeadResurrection = A.resurrection({
        apply = A.resurrection.apply(function(a)
            a:setNumberofCorpsesRaised(1, 1)
        end),
    }),
    collectCorpsesSearch = A.channelPoint({
        name = "Cannibalize",
        button = { 0, 2 },
    }),
    collectCorpses = A.cannibalize({
        name = "Collect Corpses",
        button = { 0, 2 },
    }),
    collectCorpsesToggle = A.heal({
        name = "Collect Corpses",
        apply = A.heal.apply(function(a)
            a:setManaCost(1, 0)
            a:setTargetsAllowed(1, "")
        end),
    }),
    dropCorpses = A.channelTarget({
        name = "Drop Corpses",
    }),
    applyLimb = A.channelTarget({
        name = "Apply Limb",
    }),
    healingSlime = A.rejuvenation1({
        name = "Healing Slime",
        apply = A.rejuvenation1.apply(function(a)
            a:setHitPointsGained(1, 100)
            a:setDurationHero(1, 10)
            a:setDurationNormal(1, 10)
        end),
    }),
    poisonBite = A.slowPoison({
        name = "Poison Bite",
        apply = A.slowPoison.apply(function(a)
            a:setStackingType(1, 0)
        end),
    }),
}
