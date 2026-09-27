local Ids = require("data.ids")

local A = require("data.abilityPresets")

return {
    -- == UI == --
    -- Worker
    stygianShield = A.nonDispellableTargetDebuff({
        name = "Stygian Shield",
        buffs = { "stygianShieldCooldown" },
    }),
    -- Mawguards
    disarm = A.nonDispellableTargetDebuff({
        name = "Disarm",
        buffs = { "disarm" },
    }),
    shackle = A.channelTarget({
        name = "Shackle",
    }),
    malignantBolt = A.poisonArrows({
        name = "Malignant Bolt",
    }),
    accursedStrength = A.channelNoTarget({
        name = "Accursed Strength",
    }),
    -- Myrmidon
    fallenArmaments = A.passiveGeneric({
        name = "Fallen Armaments",
    }),
    myrmidonFly = A.stormCrowForm({
        name = "Ascend/Descend",
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
    }),
    weaknessHunger = A.passiveGeneric({ -- onDamage
        name = "Weakness Hunger",
    }),
    foulBite = A.slowPoison({ -- 0 OE effects, triggered onDamage
        name = "Foul Bite",
        buffs = { "foulBite" },
        -- apply non stacking
    }),
    soulEaterFly = A.stormCrowForm({
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
    }),
    sneakPeek = A.channelPoint({
        name = "Sneak Peek",
    }),
    -- Fire caster
    blazingPurge = A.channelTarget({
        name = "Blazing Purge",
    }),
    infusion = A.channelTarget({
        name = "Infusion",
    }),
    burnResidue = A.channelArea({
        name = "Burn Residue",
    }),
    -- Frost caster
    freezeBlood = A.dispellableTargetDebuff({ -- ? use negative FP aura? (nah it will block all healing, not only regen)
        name = "Freeze Blood",
    }),
    vessel = A.channelArea({
        name = "Vessel",
    }),
    calcify = A.channelTarget({
        name = "Calcify",
    }),
    -- Dom caster
    fallenMorale = A.channelTarget({
        name = "Fallen Morale",
    }),
    forcedRestitution = A.replenishLife({
        name = "Forced Restitution",
        buffs = { "forcedRestitution" },
        -- apply duration
    }),
    betrayalSeed = A.channelTarget({
        name = "Betrayal Seed",
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
    }),
    -- == Dummy & Effects & etc. == --
    stygianShieldBuff = A.nonDispellableTargetDebuff({
        name = "stygianShield",
        buffs = { "stygianShield" },
    }),
    shackleSlow = A.slow({
        name = "Shackle",
        buffs = { "shackle" },
    }),
    accursedStrengthDamage = A.auraCommandCreep({
        name = "Accursed Strength",
        buffs = {},
    }),
    accursedStrengthSplash = A.pitLordCleavingAttack({
        name = "Accursed Strength",
    }),
    fallenArmamentsEffect = A.enduranceAura({
        name = "Fallen Armaments",
        levels = 5,
        buffs = { "fallenArmaments" },
    }),
    soulFeastEat = A.channelNoTarget({ -- ? cannibalize + dummy corpse instead
        name = "Soul Feast",
    }),
    blazingPurgeMorph = A.bearForm({ -- tmp morph to unit with different attack type (instant + effect)
        name = "Blazing Purge",
    }),
    blazingPurgeDispell = A.devourMagic({ -- tmp morph to unit with different attack type (instant + effect)
        name = "Blazing Purge",
    }),
    infusionBuff = A.innerFire({ -- ? change to itemDamageBonus/aura mb
        name = "Infusion",
        buffs = { "infusion" },
        levels = 5,
    }),
    burnResidueDummy = A.pitLordHowlofTerror({ -- ? beware if not stacking with related abilities
        name = "Burn Residue",
        buffs = { "burnResidue" },
        -- apply DoT, track buff
    }),
    burnResidueArmorDebuff = A.devotionAura({ -- ? replace with itemArmor
        name = "Burn Residue",
        buffs = {}, -- possible to not have another buff?
        -- apply minus armor
    }),
    vesselDispell = A.devourMagic({
        name = "Vessel",
    }),
    calcifySlow = A.slow({
        name = "Calcify",
        buffs = { "calcifySlow" },
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
    }),
}
