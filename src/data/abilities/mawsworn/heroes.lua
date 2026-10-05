local Ids = require("data.ids")

local A = require("data.abilityPresets")

return {
    -- UI
    -- Forsworn hero
    forswornHeroFly = A.stormCrowForm({
        name = "Ascend/Descend",
        apply = A.stormCrowForm.apply(function(a)
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
        order = "shadowstrike",
    }),
    gorgoa = A.channelArea({
        name = "Gorgoa",
        manaCost = 100,
        levels = 1,
        button = { 3, 2 },
        hotkey = "R",
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
    promoteLeutinantDamageBuff = A.auraCommandCreep({
        name = "Promote Leutinant",
        buffs = { "promoteLeutinant" },
        levels = 3,
    }),
    superiourCauseDetonate = A.selfDestructClockwerkGoblins({
        name = "Superiour Cause",
        manaCost = 0,
        levels = 3,
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
        manaCost = 0,
        levels = 3,
    }),
    opressiveChainsSlow = A.immolation({
        name = "Opressive Chains",
        buffs = { "opressiveChains" },
        manaCost = 0,
        levels = 3,
    }),
    -- Mourneblade Hero
    deadlyBlowMark = A.nonDispellableTargetDebuff({
        name = "Deadly Blow",
        manaCost = 0,
        levels = 3,
    }),
    deadlyBlowStun = A.stormBolt({
        name = "Deadly Blow",
        manaCost = 0,
        levels = 3,
    }),
    wraithWalkSlow = A.slowAura({
        name = "Wraith Walk",
        levels = 3,
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
