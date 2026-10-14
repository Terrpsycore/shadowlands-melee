local Ids = require("data.ids")
local Orders = require("data.generated.Orders")

local A = require("data.abilityPresets")

return {
    -- UI
    -- Forsworn hero
    forswornHeroFly = A.channelNoTarget({
        name = "Ascend/Descend",
        order = Orders.devour,
    }),
    forswornHeroFlyInstant = A.stormCrowForm({
        name = "Ascend/Descend",
        hidden = true,
        apply = A.stormCrowForm.apply(function(a)
            a:setCastingTime(1, 0) -- TODO
            a:setAltitudeAdjustmentDuration(1, 0) -- TODO
            a:setLandingDelayTime(1, 0) -- TODO
            a:setDurationHero(1, 0)
            a:setDurationNormal(1, 0)
            --
            a:setMorphingFlags(1, 1) -- uninterruptable
            a:setManaCost(1, 0)
            a:setNormalFormUnit(1, Ids.units.forswornHero)
            a:setAlternateFormUnit(1, Ids.units.forswornHeroFlying)
        end),
    }),
    harpoon = A.stormBolt({ -- root/unroot with trigger
        name = "Harpoon",
        buffs = { "harpoon" },
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        hotkey = "Q",
    }),
    promoteLeutinant = A.channelTarget({
        name = "Promote Leutinant",
        levels = 3,
        manaCost = 100,
        button = { 1, 2 },
        hotkey = "W",
    }),
    superiourCause = A.devotionAura({
        name = "Superiour Cause",
        buffs = { "superiourCause" },
        levels = 3,
        manaCost = 100,
        button = { 2, 2 },
        hotkey = "E",
    }),
    abduct = A.channelTarget({
        name = "Abduct",
        levels = 1,
        manaCost = 100,
        button = { 3, 2 },
        hotkey = "R",
        apply = A.channelTarget.apply(function(a, level)
            a:setFollowThroughTime(level, 5)
        end),
    }),
    -- Mage hero
    twistedPain = A.nonDispellableTargetDebuff({
        name = "Twisted Pain",
        buffs = { "twistedPain" },
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        hotkey = "Q",
    }),
    opressiveChains = A.channelTarget({
        name = "Opressive Chains",
        manaCost = 100,
        levels = 3,
        button = { 1, 2 },
        hotkey = "W",
    }),
    eatSoul = A.channelPoint({
        name = "Eat Soul",
        manaCost = 0,
        levels = 3,
        button = { 2, 2 },
        hotkey = "E",
        order = Orders.shadowstrike,
    }),
    gorgoa = A.channelArea({
        name = "Gorgoa",
        manaCost = 100,
        levels = 1,
        button = { 3, 2 },
        hotkey = "R",
        apply = A.channelArea.apply(function(a, level)
            a:setFollowThroughTime(level, 10)
        end),
    }),
    -- Mourneblade Hero
    deadlyBlow = A.channelNoTarget({
        name = "Deadly Blow",
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        hotkey = "Q",
    }),
    wraithWalk = A.channelNoTarget({
        name = "Wraith Walk",
        manaCost = 100,
        levels = 3,
        button = { 1, 2 },
        hotkey = "W",
    }),
    soulRend = A.immolationToggle({ -- mb add non-dispellable debuff for 2-sec window visuals
        name = "Soul Rend",
        manaCost = 0,
        levels = 3,
        button = { 2, 2 },
        hotkey = "E",
    }),
    dominateWill = A.channelTarget({
        name = "Dominate Will",
        manaCost = 100,
        levels = 1,
        button = { 3, 2 },
        hotkey = "R",
    }),
    -- Dummies, ...
    -- Forsworn hero
    harpoonDummy = A.stormBolt({ -- instant. root/unroot with trigger
        name = "Harpoon",
        buffs = { "harpoon" },
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        hotkey = "Q",
        apply = A.stormBolt.apply(function(a, level)
            a:setDurationNormal(level, 0.3)
            a:setDurationHero(level, 0.3)
        end),
    }),
    harpoonRootUI = A.nonDispellableTargetDebuff({
        name = "Harpoon",
        buffs = { "harpoonRoot" },
    }),
    promoteLeutinantDamageBuff = A.auraCommandCreep({
        name = "Promote Leutinant",
        buffs = { "promoteLeutinant" },
        levels = 3,
    }),
    promoteLeutinantHp = A.itemLifeBonus({
        name = "Promote Leutinant",
        levels = 3,
        apply = A.itemLifeBonus.apply(function(a, level)
            a:setMaxLifeGained(level, 100 * level)
        end),
    }),
    superiourCauseShield = A.nonDispellableTargetDebuff({
        name = "Superiour Cause",
        levels = 3,
        buffs = { "superiourCauseShield" },
    }),
    superiourCauseDummy = A.channelNoTarget({
        name = "Superiour Cause",
        levels = 3,
        apply = A.channelNoTarget.apply(function(a, level)
            a:setDisableOtherAbilities(level, true)
            a:setFollowThroughTime(level, 2 - ((level - 1) * 0.5))
            a:setArtDuration(level, 2 - ((level - 1) * 0.5))
        end),
    }),
    superiourCauseDetonate = A.selfDestructClockwerkGoblins({
        name = "Superiour Cause",
        levels = 3,
    }),
    abductHeight = A.stormCrowForm({
        name = "Abduct Height",
    }),
    -- Mage hero
    eatSoulRegenTimed = A.rejuvenation({
        name = "Eat Soul",
        levels = 3,
        apply = A.rejuvenation.apply(function(a, level)
            a:setAllowWhenFull(level, 3)
            a:setManaPointsGained(level, level * 50)
        end),
    }),
    twistedPainDamage = A.immolation({
        name = "Twisted Pain",
        levels = 3,
    }),
    opressiveChainsSlow = A.shadowStrikeCreep({
        name = "Opressive Chains",
        buffs = { "opressiveChains" },
        levels = 3,
        apply = A.shadowStrikeCreep.apply(function(a, level)
            a:setMovementSpeedFactor(level, 0.3 * level)
            a:setInitialDamage(level, 0)
            a:setDecayPower(level, 3)
            a:setDecayingDamage(level, 0)
            a:setAttackSpeedFactor(level, 0.3 * level)
            a:setDurationHero(level, 8)
            a:setDurationNormal(level, 8)
        end),
    }),
    -- Mourneblade Hero
    deadlyBlowMark = A.nonDispellableTargetDebuff({
        name = "Deadly Blow",
        buffs = { "deadlyBlowMark" },
        levels = 3,
    }),
    deadlyBlowStun = A.stormBolt({
        name = "Deadly Blow",
        levels = 3,
    }),
    wraithWalkPhase = A.phaseWalk({
        name = "Wraith Walk",
        buffs = { "wraithWalk" },
        levels = 3,
        apply = A.phaseWalk.apply(function(a, level)
            a:setMovementSpeedIncrease(level, 0.2 * level)
        end),
    }),
    wraithWalkSlow = A.slowAura({
        name = "Wraith Walk",
        buffs = { "wraithWalkSlow" },
        levels = 3,
        apply = A.slowAura.apply(function(a, level)
            a:setMovementSpeedFactor(level, 0.2 * level)
            a:setAttackSpeedFactor(level, 0)
        end),
    }),
    soulRendDamage = A.itemDamageBonus({
        name = "Soul Rend",
        levels = 15,
    }),
    soulRendHeal = A.healCreepHigh({
        name = "Soul Rend",
        levels = 1, -- ?
    }),
}
