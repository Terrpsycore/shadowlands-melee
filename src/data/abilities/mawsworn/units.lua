local Ids = require("data.ids")
local Icons = require("vendor.assets.generated.Icons")

local A = require("data.abilityPresets")

return {
    -- == UI == --
    -- Worker
    stygianShield = A.nonDispellableTargetDebuff({
        name = "Stygian Shield",
        buffs = { "stygianShieldCooldown" },
        art = { icon = Icons.lightningShield },
        apply = A.nonDispellableTargetDebuff.apply(function(a, level)
            a:setTargetsAllowed(level, "structure,player")
        end),
    }),
    -- Mawguards
    disarm = A.seaWitchFrostArrows({
        name = "Disarm",
        buffs = { "disarmInit" },
        apply = A.seaWitchFrostArrows.apply(function(a, level)
            a:setMovementSpeedFactor(level, 0)
            a:setAttackSpeedFactor(level, 0)
        end),
        art = { icon = Icons.autocastAbominationshook },
    }),
    shackle = A.channelTarget({
        name = "Shackle",
        art = { icon = Icons.slow },
        apply = A.channelTarget.apply(function(a, level)
            a:setFollowThroughTime(level, 10) -- max duration
            a:setArtDuration(level, 10)
        end),
        order = "shadowstrike",
    }),
    malignantBolt = A.poisonArrows({
        name = "Malignant Bolt",
        buffs = { "malignantBoltInit" },
        art = { icon = Icons.autocastTheblackarrow },
    }),
    accursedStrength = A.nonDispellableSelfBuffTimed({
        name = "Accursed Strength",
        buffs = { "accursedStrength" },
        art = { icon = Icons.advancedunholystrength },
        apply = A.nonDispellableSelfBuffTimed.apply(function(a, level)
            a:setDurationNormal(level, 2)
            a:setDurationHero(level, 2)
            -- TODO: casttime
        end),
    }),
    -- Myrmidon
    fallenArmaments = A.passiveGeneric({
        name = "Fallen Armaments",
        art = { icon = Icons.pasSwordsmanship },
    }),
    myrmidonFly = A.stormCrowForm({
        name = "Ascend/Descend",
        button = { 1, 2 },
        apply = A.stormCrowForm.apply(function(a)
            a:setMorphingFlags(1, 1) -- uninterruptable
            a:setManaCost(1, 0)
            a:setNormalFormUnit(1, Ids.units.myrmidonFlying)
            a:setAlternateFormUnit(1, Ids.units.myrmidon)
        end),
    }),
    -- Soul Eater
    soulFeast = A.channelPoint({ -- must lock soul from other soul-using abilities
        name = "Soul Feast",
        art = { icon = Icons.cannibalize },
    }),
    weaknessHunger = A.passiveGeneric({ -- onDamage
        name = "Weakness Hunger",
        art = { icon = Icons.pasAuraofdarkness },
    }),
    foulBite = A.slowPoison({ -- 0 OE effects, triggered onDamage
        name = "Foul Bite",
        buffs = { "foulBite" },
        -- apply non stacking
        art = { icon = Icons.pasPoisonsting },
        apply = A.slowPoison.apply(function(a, level)
            a:setDamagePerSecond(level, 0)
            a:setAttackSpeedFactor(level, 0)
            a:setMovementSpeedFactor(level, 0)
            a:setStackingType(level, 0)
            a:setDurationNormal(level, 5)
            a:setDurationHero(level, 3)
        end),
    }),
    soulEaterFly = A.stormCrowForm({
        button = { 1, 2 },
        name = "Ascend/Descend",
        apply = A.stormCrowForm.apply(function(a)
            a:setMorphingFlags(1, 1) -- uninterruptable
            a:setManaCost(1, 0)
            a:setNormalFormUnit(1, Ids.units.soulEaterFlying)
            a:setAlternateFormUnit(1, Ids.units.soulEater)
        end),
    }),
    -- Soulseeker
    glare = A.channelTarget({
        name = "Glare",
        art = { icon = Icons.edricsEye },
        order = "shadowstrike",
        apply = A.channelTarget.apply(function(a, level)
            a:setFollowThroughTime(level, 30) -- max duration
            a:setArtDuration(level, 30)
        end),
    }),
    piercingGaze = A.channelPoint({
        name = "Piercing Gaze",
        art = { icon = Icons.blink },
    }),
    glareGreater = A.channelTarget({
        name = "Glare",
        art = { icon = Icons.edricsEye },
        order = "innerfire",
        apply = A.channelTarget.apply(function(a, level)
            a:setFollowThroughTime(level, 30) -- max duration
            a:setArtDuration(level, 30)
            a:setCastRange(level, 3000)
        end),
    }),
    -- Fire caster
    blazingPurge = A.channelTarget({
        name = "Blazing Purge",
        art = { icon = Icons.purge },
        order = "purge",
    }),
    infusion = A.channelTarget({
        name = "Infusion",
        art = { icon = Icons.markOfFire },
        apply = A.channelTarget.apply(function(a, level)
            a:setFollowThroughTime(level, 5.5)
            a:setArtDuration(level, 5)
            a:setCastRange(level, 5.5)
        end),
        order = "shadowstrike",
    }),
    burnResidue = A.channelArea({
        name = "Burn Residue",
        art = { icon = Icons.wallOfFire },
    }),
    -- Frost caster
    freezeBlood = A.dispellableTargetDebuff({ -- ? use negative FP aura? (nah it will block all healing, not only regen)
        name = "Freeze Blood",
        buffs = { "freezeBlood" },
        art = { icon = Icons.autocastBreathoffrost },
    }),
    vessel = A.channelArea({
        name = "Vessel",
        art = { icon = Icons.doom },
    }),
    calcify = A.dispellableTargetDebuff({
        name = "Calcify",
        buffs = { "calcify" },
        art = { icon = Icons.icecolddiamond },
        order = "shadowstrike",
    }),
    -- Dom caster
    fallenMorale = A.channelTarget({
        name = "Fallen Morale",
        art = { icon = Icons.darkSummoning },
    }),
    forcedRestitution = A.replenishLife({
        name = "Forced Restitution",
        buffs = { "forcedRestitution" },
        apply = A.replenishLife.apply(function(a, level)
            a:setDurationNormal(level, 3)
            a:setDurationHero(level, 3)
            a:setCooldown(level, 0)
        end),
        art = { icon = Icons.autocastSkeletallongevity },
    }),
    betrayalSeed = A.channelTarget({
        name = "Betrayal Seed",
        art = { icon = Icons.thunderlizardegg },
        order = "shadowstrike",
    }),
    -- Charred Behemoth
    threateningRoar = A.pitLordHowlofTerror({ -- check conflicts with same parent abilities
        name = "Threatening Roar",
        buffs = { "threateningRoar" },
        -- apply: zero effect
    }),
    overwhelming = A.pitLordCleavingAttack({ -- turn on/off onAttack
        name = "Overwhelming",
        -- apply
        art = { icon = Icons.pasAvataroflight },
    }),
    -- Maw Chain
    mawChainRelink = A.channelPoint({
        name = "Re-link",
        art = { icon = Icons.autocastAbominationshook },
    }),
    mawChainFallback = A.channelTarget({
        name = "Fallback",
        order = "acidbomb",
    }),
    -- == Dummy & Effects & etc. == --
    stygianShieldBuff = A.nonDispellableTargetDebuff({
        name = "stygianShield",
        buffs = { "stygianShield" },
        apply = A.nonDispellableTargetDebuff.apply(function(a, level)
            a:setTargetsAllowed(level, "player")
        end),
    }),
    disarmDummy = A.nonDispellableTargetDebuff({
        name = "Disarm",
        buffs = { "disarm" },
        art = { icon = Icons.autocastAbominationshook },
    }),
    shackleSlow = A.slow({
        name = "Shackle",
        buffs = { "shackle" },
        apply = A.slow.apply(function(a, level)
            a:setDurationHero(level, 1.5)
            a:setDurationNormal(level, 1.5)
        end),
    }),
    accursedStrengthDamage = A.auraCommandCreep({
        name = "Accursed Strength",
        buffs = { "accursedStrengthDamage" }, -- ?
        apply = A.auraCommandCreep.apply(function(a, level)
            a:setAreaofEffect(level, 0)
        end),
    }),
    accursedStrengthSplash = A.pitLordCleavingAttack({
        name = "Accursed Strength",
    }),
    fallenArmamentsEffect = A.enduranceAura({
        name = "Fallen Armaments",
        levels = 5,
        buffs = { "fallenArmaments" },
        apply = A.enduranceAura.apply(function(a, level)
            a:setAttackSpeedIncrease(level, 0.1 * level)
            a:setMovementSpeedIncrease(level, 0)
            a:setAreaofEffect(level, 1) -- ? recheck
        end),
    }),
    soulFeastEat = A.channelNoTarget({ -- ? cannibalize + dummy corpse instead
        name = "Soul Feast",
        apply = A.channelNoTarget.apply(function(a, level)
            a:setFollowThroughTime(level, 10)
            a:setArtDuration(level, 10)
        end),
    }),
    glareDebuff = A.nonDispellableTargetDebuff({
        name = "Glare",
        buffs = { "glare" },
        apply = A.nonDispellableTargetDebuff.apply(function(a, level)
            a:setDurationHero(level, 30)
            a:setDurationNormal(level, 30)
        end),
    }),
    glareVision = A.dustofAppearance({
        name = "Glare",
        buffs = { "glareReveal" },
        apply = A.nonDispellableTargetDebuff.apply(function(a, level)
            a:setCastRange(level, 1)
            a:setDurationHero(level, 30)
            a:setDurationNormal(level, 30)
        end),
    }),
    piercingGazeDummyVision = A.dustofAppearance({
        name = "piercingGazeDummyVision",
        buffs = { "piercingGazeReveal" },
        apply = A.dustofAppearance.apply(function(a, level)
            a:setCastRange(level, 100)
            a:setDurationHero(level, 3)
            a:setDurationNormal(level, 3)
        end),
    }),
    blazingPurgeMorph = A.bearForm({ -- tmp morph to unit with different attack type (instant + effect)
        name = "Blazing Purge",
        apply = A.bearForm.apply(function(a)
            a:setMorphingFlags(1, 1) -- uninterruptable
            a:setManaCost(1, 0)
            a:setNormalFormUnit(1, Ids.units.mawcasterFire)
            a:setAlternateFormUnit(1, Ids.units.mawcasterFirePurge)
            a:setDurationNormal(1, 0.1)
        end),
    }),
    blazingPurgeDispell = A.devourMagic({ -- tmp morph to unit with different attack type (instant + effect)
        name = "Blazing Purge",
        apply = A.devourMagic.apply(function(a, level)
            a:setManaPerUnit(level, 1)
            a:setManaPerBuff(level, 0)
        end),
    }),
    infusionBuff = A.dispellableTargetBuff({ -- ? change to itemDamageBonus/aura mb
        name = "Infusion",
        buffs = { "infusion" },
    }),
    infusionUI = A.passiveAura({
        name = "Infusion",
        buffs = { "infusionEffect" },
        levels = 5,
    }),
    infusionEffect = A.itemDamageBonus({
        name = "Infusion",
        levels = 5,
        apply = A.itemDamageBonus.apply(function(a, level)
            a:setAttackBonus(level, math.floor(2.5 ^ level))
        end),
    }),
    burnResidueDummy = A.pitLordHowlofTerror({ -- ? beware if not stacking with related abilities
        name = "Burn Residue",
        buffs = { "burnResidue" },
        apply = A.pitLordHowlofTerror.apply(function(a, level)
            a:setDamageIncrease(level, 0)
            a:setDefenseIncrease(level, 2)
            a:setLifeRegenerationRate(level, -10) -- TODO: check if it kills low hp or it becomes denied
            a:setDurationHero(level, 5)
            a:setDurationNormal(level, 10)
        end),
        -- apply DoT, track buff
    }),
    vesselDispell = A.devourMagic({
        name = "Vessel",
        apply = A.devourMagic.apply(function(a, level)
            a:setManaPerUnit(level, 1)
            a:setManaPerBuff(level, 0)
        end),
    }),
    calcifySlow = A.slow({
        name = "Calcify",
        buffs = { "calcifySlow" },
        levels = 2,
        apply = A.slow.apply(function(a, level)
            a:setAttackSpeedFactor(level, level * 0.15)
            a:setMovementSpeedFactor(level, level * 0.33)
        end),
    }),
    calcifyStun = A.stormBolt({
        name = "Calcify",
        buffs = { "calcifyStun" },
    }),
    forcedRestitutionDecay = A.nonDispellableTargetDebuff({
        name = "Forced Restitution",
        buffs = { "forcedRestitutionDecay" },
        --
    }),
    threateningRoarEffect = A.itemLifeBonus({ -- mb in future replace with dummy debuff to show debuff level in UI
        name = "Threatening Roar",
        levels = 3,
        apply = A.itemLifeBonus.apply(function(a, level)
            a:setMaxLifeGained(level, -100)
        end),
    }),
    threateningRoarLevelUI = A.devotionAura({
        name = "Threatening Roar",
        buffs = { "threateningRoarLevel" },
        levels = 3,
        apply = A.devotionAura.apply(function(a, level)
            a:setAreaofEffect(level, 0)
            a:setArmorBonus(level, 0)
        end),
    }),
    -- Maw Chain
    mawChainAttack = A.channelPoint({
        name = "Maw Chain Attack",
        order = "shadowstrike",
        apply = A.channelPoint.apply(function(a, level)
            -- a:set cast time, blocks other spells
        end),
    }),
    mawChainChanneledDamage = A.earthquake({
        name = "Damage",
        buffs = { "mawChainQuake" },
        art = { icon = Icons.autocastAbominationshook },
    }),
}
