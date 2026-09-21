local Ids = require("data.ids")

local A = require("data.abilityPresets")
local Icons = require("vendor.assets.generated.Icons")

return {
    --- BONESMITH ---
    moldWeakness = A.nonDispellableTargetDebuff({
        name = "Mold Weakness",
        buffs = { "moldWeaknessAim" },
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        art = { icon = Icons.malachiteShortsword },
        hotkey = "Q",
    }),
    moldWeaknessDebuff = A.nonDispellableTargetDebuff({
        name = "Mold Weakness",
        buffs = { "moldWeakness" },
        levels = 3,
        apply = A.nonDispellableTargetDebuff.apply(function(a, level) end),
    }),
    serratedSpaulders = A.innerFire({
        name = "Serrated Spaulders",
        levels = 3,
        buffs = { "serratedSpaulders" },
        manaCost = 50,
        art = { icon = Icons.theBlackArrowOnOff },
        hotkey = "W",
    }),
    serratedSpauldersThorns = A.nonDispellableTargetDebuff({
        name = "Forgebone Reveries",
        levels = 3,
        buffs = { "serratedSpauldersThorns" },
        apply = A.nonDispellableSelfBuffTimed.apply(function(a, level)
            a:setPrimaryDamage(level, 3 * level)
            a:setSecondaryDamage(level, 5 * level)
        end),
    }),
    ammunitionControl = A.passiveGeneric({ -- onTrain/onRevive dummy
        name = "Ammunition Control",
        levels = 3,
        art = { icon = Icons.pasPillage },
        hotkey = "E",
    }),
    ammunitionControlBuff = A.nonDispellableSelfBuffTimed({
        name = "Ammunition Control",
        levels = 3,
        buffs = { "ammunitionControl" },
        apply = A.nonDispellableSelfBuffTimed.apply(function(a, level)
            a:setDurationNormal(level, 120 + 60 * level)
        end),
    }),
    ammunitionControlBonusDamage = A.auraCommandCreep({
        name = "Ammunition Control",
        levels = 3,
        buffs = {}, -- TODO: check if works
        apply = A.auraCommandCreep.apply(function(a, level)
            a:setAttackDamageIncrease(level, 0.1 * level)
        end),
    }),
    ammunitionControlBonusArmor = A.itemArmorBonus({
        name = "Ammunition Control",
        levels = 3,
        apply = A.itemArmorBonus.apply(function(a, level)
            a:setDefenseBonus(level, 1 * level)
        end),
    }),
    forgeboneReveries = A.nonDispellableTargetDebuff({ -- triggered onLethalDamage
        name = "Forgebone Reveries",
        levels = 1,
        manaCost = 50,
        buffs = { "forgeboneReveries" },
        art = { icon = Icons.plaguebearercuirass },
        hotkey = "R",
        apply = A.nonDispellableSelfBuffTimed.apply(function(a, level)
            a:setDurationNormal(level, 10)
            a:setDurationHero(level, 10)
            a:setTargetsAllowed(level, "allied,organic,player")
        end),
    }),
    -- GLADIATOR ---
    weaponTest = A.channelTarget({ -- dummy mirror to hero, repeat on kill
        name = "Weapon Test",
        levels = 3,
        manaCost = 50,
        art = { icon = Icons.orcMeleeUpThree },
        apply = A.channelTarget.apply(function(a)
            -- a:setTargetType() -- enemy
        end),
        hotkey = "Q",
    }),
    weaponTestDummy = A.nonDispellableTargetDebuff({ -- dummy mirror to hero, repeat on kill
        name = "Weapon Test",
        levels = 3,
        manaCost = 50,
        buffs = { "weaponTest" },
        apply = A.nonDispellableTargetDebuff.apply(function(a)
            -- a:setTargetType() -- enemy
        end),
        hotkey = "Q",
    }),
    weaponTestSelfBuff = A.nonDispellableSelfBuffTimed({
        name = "Weapon Test",
        levels = 3,
        buffs = { "weaponTest" },
        apply = A.nonDispellableSelfBuffTimed.apply(function(a, level)
            a:setDurationNormal(level, 10)
            a:setDurationHero(level, 10)
        end),
    }),
    weaponTestEffect = A.itemDamageBonus({
        name = "Weapon Test",
        levels = 3,
        apply = A.itemDamageBonus.apply(function(a, level)
            a:setAttackBonus(level, 10 * level)
        end),
    }),
    opressiveBanner = A.channelPoint({ -- ? add invul; timed remove invul
        name = "Opressive Banner",
        levels = 3,
        manaCost = 100,
        apply = A.channelPoint.apply(function(a, level) end),
        art = { icon = Icons.orcCaptureFlag },
        hotkey = "W",
    }),
    opressiveBannerAura = A.enduranceAura({ -- negative
        name = "Opressive Banner",
        levels = 3,
        buffs = { "opressiveBanner" },
        apply = A.enduranceAura.apply(function(a, level)
            a:setMovementSpeedIncrease(level, level * -0.10)
            a:setAttackSpeedIncrease(level, level * -0.10)
            a:setAreaofEffect(level, 600)
            a:setTargetsAllowed(level, "enemy,ground,air,organic,mechanical")
        end),
    }),
    opressiveBannerShield = A.nonDispellableSelfBuffTimed({ -- negative
        name = "Opressive Banner",
        levels = 3,
        buffs = { "opressiveBannerShield" },
        apply = A.nonDispellableSelfBuffTimed.apply(function(a, level) end),
    }),
    brutalCombo = A.passiveGeneric({ -- onDamage
        name = "Brutal Combo",
        levels = 3,
        art = { icon = Icons.pasGnollCommandAura },
        hotkey = "E",
    }),
    allOnOne = A.nonDispellableSelfBuffTimed({ -- triggered taunt + onDamage DAMAGE_TYPE_ENHANCED
        name = "All on One",
        levels = 1,
        buffs = { "allOnOne" },
        art = { icon = Icons.warcry },
        hotkey = "R",
    }),
    allOnOneSplash = A.pitLordCleavingAttack({
        name = "All on One",
    }),
    --- LICH ---
    necroticEruption = A.channelArea({ -- timed dummy nova + dummy stomp
        name = "Necrotic Eruption",
        levels = 3,
        art = { icon = Icons.orbofdeath },
        hotkey = "Q",
        apply = A.channelArea.apply(function(a, level)
            a:setBaseOrderID(level, "shadowstrike")
            a:setOrderStringUseTurnOn("shadowstrike")
            a:setOrderStringActivate("shadowstrike")
        end),
    }),
    necroticEruptionDummySlow = A.thunderClap({
        name = "Necrotic Eruption",
        levels = 3,
        buffs = { "necroticEruptionSlow" },
        apply = A.thunderClap.apply(function(a, level)
            a:setAreaofEffect(level, 300)
            a:setAttackSpeedReduction(level, 0)
        end),
    }),
    necroticEruptionDummyStun = A.warStomp({
        name = "Necrotic Eruption",
        levels = 3,
        buffs = { "necroticEruptionStun" },
        apply = A.warStomp.apply(function(a, level)
            a:setAreaofEffect(level, 150)
        end),
    }),
    bindDeathwalker = A.feralSpirit2({
        name = "Bind Deathwalker",
        levels = 3,
        art = { icon = Icons.shade },
        hotkey = "W",
        apply = A.feralSpirit2.apply(function(a)
            a:setSummonedUnit(1, Ids.units.deathwalker1)
            a:setSummonedUnit(2, Ids.units.deathwalker2)
            a:setSummonedUnit(3, Ids.units.deathwalker3)
            a:setNumberofSummonedUnits(1, 3)
            a:setNumberofSummonedUnits(2, 2)
            a:setNumberofSummonedUnits(3, 1)
        end),
    }),
    droughtSigil = A.itemPlaceGoblinLandMine({
        name = "Drought Sigil",
        levels = 3,
        manaCost = 100,
        apply = A.itemPlaceGoblinLandMine.apply(function(a, level)
            a:setCastRange(level, 500)
            a:setUnitType(level, Ids.units.sigilOfDrought)
        end),
        art = { icon = Icons.glyph },
        hotkey = "E",
    }),
    sigilOfDroughtActivation = A.mineexploding({
        name = "Sigil of Drought",
        levels = 3,
        apply = A.mineexploding.apply(function(a, level)
            a:setActivationDelay(level, 1)
        end),
    }),
    sigilOfDroughtDrainMana = A.siphonMana({
        name = "Sigil of Drought",
        levels = 3,
        apply = A.siphonMana.apply(function(a, level)
            a:setManaCost(level, 0)
            a:setDurationNormal(level, 1.1)
            a:setDurationHero(level, 1.1)
            a:setManaPointsDrained(level, 200 * level)
            a:setOrderStringActivate("channel")
            a:setOrderStringUseTurnOn("channel")
            a:setCastRange(level, 9999)
        end),
    }),
    sigilOfDroughtTransferMana = A.siphonMana({
        name = "Sigil of Drought",
        levels = 3,
        apply = A.siphonMana.apply(function(a, level)
            a:setManaCost(level, 0)
            a:setDurationNormal(level, 1)
            a:setDurationHero(level, 1.1)
            a:setManaTransferredPerSecond(level, 100 * level)
            a:setOrderStringActivate("channel")
            a:setOrderStringUseTurnOn("channel")
            a:setCastRange(level, 9999)
        end),
    }),
    sigilOfDroughtDrawback = A.rejuvenation1({
        name = "Sigil of Drought",
        levels = 10, -- using based on burned mana
        buffs = { "sigilOfDroughtDrawback" },
        apply = A.rejuvenation1.apply(function(a, level)
            a:setHitPointsGained(level, 50 * level)
            a:setDurationHero(level, 10)
            a:setDurationNormal(level, 10)
            a:setCastRange(level, 9999)
            a:setTargetsAllowed(level, "allied,enemy,ground,air,organic,player")
        end),
    }),
    explodeCorpses = A.channelArea({ -- for corpse - dummy clap - onSpell target delete
        name = "Explode Corpses",
        levels = 1,
        art = { icon = Icons.corpseExplode },
        hotkey = "R",
    }),
    explodeCorpsesDummy = A.thunderClap({
        name = "Explode Corpses",
        buffs = {},
        apply = A.thunderClap.apply(function(a, level)
            a:setAttackSpeedReduction(level, 0)
            a:setMovementSpeedReduction(level, 0)
            -- a:setTargetType() -- dead
        end),
    }),
}
