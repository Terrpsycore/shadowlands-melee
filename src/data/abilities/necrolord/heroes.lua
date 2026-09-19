local Ids = require("data.ids")

local A = require("data.abilityPresets")

return {
    moldWeakness = A.nonDispellableTargetDebuff({
        name = "Mold Weakness",
        buffs = { "moldWeaknessAim" },
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        hotkey = "Q",
    }),
    moldWeaknessDebuff = A.nonDispellableTargetDebuff({
        name = "Mold Weakness",
        buffs = { "moldWeakness" },
        levels = 3,
        apply = A.nonDispellableTargetDebuff.apply(function(a, level) end),
    }),
    moldWeaknessPassiveDebuff = A.auraCommandCreep({
        name = "Mold Weakness",
        buffs = {},
        levels = 3,
        apply = A.auraCommandCreep.apply(function(a, level)
            a:setAreaofEffect(level, 0)
            a:setAttackDamageIncrease(level, -0.33 * level)
        end),
    }),
    serratedSpaulders = A.innerFire({
        name = "Serrated Spaulders",
        levels = 3,
        buffs = { "serratedSpaulders" },
        manaCost = 50,
        hotkey = "W",
    }),
    serratedSpauldersThorns = A.nonDispellableTargetDebuff({
        name = "Forgebone Reveries",
        levels = 3,
        buffs = { "serratedSpauldersThorns" },
    }),
    ammunitionControl = A.passiveGeneric({ -- onTrain/onRevive dummy
        name = "Ammunition Control",
        levels = 3,
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
    forgeboneReveries = A.channelTarget({ -- triggered onLethalDamage
        name = "Forgebone Reveries",
        levels = 1,
        manaCost = 50,
        buffs = { "forgeboneReveries" },
        hotkey = "R",
    }),
    --
    weaponTest = A.innerFire({ -- dummy mirror to hero, repeat on kill
        name = "Weapon Test",
        levels = 3,
        manaCost = 50,
        buffs = { "weaponTest" },
        apply = A.innerFire.apply(function(a)
            -- a:setTargetType() -- enemy
        end),
        hotkey = "Q",
    }),
    opressiveBanner = A.sentryWard({ -- add invul; timed remove invul
        name = "Opressive Banner",
        levels = 3,
        manaCost = 100,
        apply = A.sentryWard.apply(function(a)
            -- a:setUnitType()
        end),
        hotkey = "W",
    }),
    opressiveBannerAura = A.enduranceAura({ -- negative
        name = "Opressive Banner",
        levels = 3,
        buffs = { "opressiveBanner" },
        apply = A.enduranceAura.apply(function(a)
            -- a:setUnitType()
        end),
    }),
    brutalCombo = A.passiveGeneric({ -- onDamage
        name = "Brutal Combo",
        levels = 3,
        hotkey = "E",
    }),
    allOnOne = A.nonDispellableSelfBuffTimed({ -- triggered taunt + onDamage DAMAGE_TYPE_ENHANCED
        name = "All on One",
        levels = 1,
        hotkey = "R",
    }),
    allOnOneSplash = A.pitLordCleavingAttack({
        name = "All on One",
    }),
    --
    necroticEruption = A.channelArea({ -- timed dummy nova + dummy stomp
        name = "Necrotic Eruption",
        levels = 3,
        hotkey = "Q",
    }),
    necroticEruptionDummySlow = A.frostNova({
        name = "Necrotic Eruption",
        levels = 3,
        buffs = { "necroticEruptionSlow" },
        apply = A.frostNova.apply(function(a) end),
    }),
    necroticEruptionDummyStun = A.warStomp({
        name = "Necrotic Eruption",
        levels = 3,
        buffs = { "necroticEruptionStun" },
        apply = A.warStomp.apply(function(a) end),
    }),
    bindDeathwalker = A.feralSpirit2({
        name = "Bind Deathwalker",
        levels = 3,
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
        apply = A.itemPlaceGoblinLandMine.apply(function(a)
            for level = 1, 3 do
                a:setCastRange(1, 500)
                a:setUnitType(1, Ids.units.sigilOfDrought)
            end
        end),
        hotkey = "E",
    }),
    sigilOfDroughtActivation = A.mineexploding({
        name = "Sigil of Drought",
        apply = A.mineexploding.apply(function(a) end),
    }),
    explodeCorpses = A.channelArea({ -- for corpse - dummy nova - onSpell target delete
        name = "Explode Corpses",
        levels = 1,
        hotkey = "R",
    }),
    explodeCorpsesDummy = A.frostNova({
        name = "Explode Corpses",
        buffs = {},
        apply = A.frostNova.apply(function(a)
            -- a:setTargetType() -- dead
        end),
    }),
}
