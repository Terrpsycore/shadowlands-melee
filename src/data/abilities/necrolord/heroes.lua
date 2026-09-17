local Ids = require("data.ids")

local A = require("data.abilityPresets")

return {
    moldWeakness = A.nonDispellableTargetDebuff({
        name = "Mold Weakness",
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        buffs = { "moldWeakness" },
        hotkey = "Q",
    }),
    serratedSpaulders = A.innerFire({
        name = "Serrated Spaulders",
        levels = 3,
        manaCost = 50,
        hotkey = "W",
    }),
    ammunitionControl = A.passiveGeneric({
        name = "Ammunition Control",
        levels = 3,
        hotkey = "E",
    }),
    forgeboneReveries = A.channelTarget({ -- triggered onLethalDamage
        name = "Forgebone Reveries",
        levels = 1,
        manaCost = 50,
        buffs = { "forgeboneReveries" },
        hotkey = "R",
    }),
    --
    weaponTest = A.innerFire({
        name = "Serrated Spaulders",
        levels = 3,
        manaCost = 50,
        apply = A.innerFire.apply(function(a)
            -- a:setTargetType() -- enemy
        end),
        hotkey = "Q",
    }),
    opressiveBanner = A.sentryWard({
        name = "Opressive Banner",
        levels = 3,
        manaCost = 100,
        apply = A.sentryWard.apply(function(a)
            -- a:setUnitType()
        end),
        hotkey = "W",
    }),
    brutalCombo = A.passiveGeneric({
        name = "Brutal Combo",
        levels = 3,
        hotkey = "E",
    }),
    allOnOne = A.channelNoTarget({
        name = "All on One",
        levels = 1,
        hotkey = "R",
    }),
    --
    necroticEruption = A.channelArea({
        name = "Necrotic Eruption",
        levels = 3,
        hotkey = "Q",
    }),
    bindDeathwalker = A.feralSpirit({
        name = "Bind Deathwalker",
        levels = 3,
        hotkey = "W",
    }),
    droughtSigil = A.itemPlaceGoblinLandMine({
        name = "Drought Sigil",
        levels = 3,
        apply = A.itemPlaceGoblinLandMine.apply(function(a)
            for level = 1, 3 do
                a:setCastRange(1, 500)
                a:setUnitType(1, Ids.units.sigilOfBinding)
            end
        end),
        hotkey = "E",
    }),
    explodeCorpses = A.channelArea({
        name = "Explode Corpses",
        levels = 1,
        hotkey = "R",
    }),
}
