local UnitIds = require("vendor.assets.UnitIds")
local UnitArt = require("vendor.assets.generated.UnitArt")
local Icons = require("vendor.assets.generated.Icons")

return {
    animate = {
        parent = UnitIds.peon,
        name = "Animate",
        abilities = { "inventory", "surviveWish" },
        art = {
            model = UnitArt[UnitIds.skeletonwarrior].model,
            scale = 0.9,
            icon = Icons.skeletonWarrior,
        },
    },
    animateWarrior = {
        parent = UnitIds.skeletonwarrior,
        name = "Animate Warrior",
        abilities = { "inventory", "surviveWish", "combatExpertise" },
        art = { icon = Icons.skeletalOrcGrunt },
    },
    aranakkSpy = {
        parent = UnitIds.nerubianqueen,
        name = "Aranakk Spy",
        abilities = { "inventory", "vanish" },
        art = { icon = Icons.nerubianQueen },
    },
    ballista = {
        parent = UnitIds.glaivethrower,
        name = "Ballista",
        art = { icon = Icons.meatWagon },
        abilities = { "netAmmo" },
    },
    gladiator = {
        parent = UnitIds.grunt,
        name = "Gladiator",
        abilities = { "warBanner", "brutalComboCrit" },
        art = { icon = Icons.felGuard },
        mana = { max = 200, initial = 100 },
    },
    scavenger = {
        parent = UnitIds.ghoul,
        name = "Scavenger",
        abilities = { "inventory", "collectCorpses", "dropCorpses", "exhume" },
    },
    construct = {
        parent = UnitIds.abomination,
        name = "Construct",
        abilities = {},
    },
    necromancer = {
        parent = UnitIds.necromancer,
        name = "Necromancer",
        art = { icon = Icons.acolyte },
        abilities = { "animateDead", "maldraciteNullify", "sigilOfBinding" },
    },
    mixologist = {
        parent = UnitIds.necromancer,
        name = "Mixologist",
        art = {
            model = UnitArt[UnitIds.acolyte].model,
            scale = 1,
            icon = Icons.apothecary,
        },
        abilities = { "healingSlime", "corrosivePlague", "concoctPotion" },
    },
    physician = {
        parent = UnitIds.necromancer,
        name = "Physician",
        art = {
            model = UnitArt[UnitIds.acolyte].model,
            scale = 1,
            icon = Icons.cultzealot,
        },
        abilities = { "applyLimb", "scissorSoul", "betterBody" },
    },
    necroray = {
        parent = UnitIds.nagacoutl,
        name = "Necroray",
        abilities = { "sporeCloud" },
    },
    bonestorm = {
        parent = UnitIds.footman,
        name = "Bonestorm",
        abilities = { "deadlyWhirlwind", "slurp" },
        art = { icon = Icons.tornado },
        apply = function(u)
            u:setHitPointsRegenerationRate(-5)
        end,
    },
    --
    warBanner = {
        parent = UnitIds.sentryward,
        name = "War Banner",
        abilities = { "warBannerAura" },
        art = { icon = Icons.undeadCaptureFlag },
    },
    opressiveBanner = {
        parent = UnitIds.sentryward,
        name = "Opressive Banner",
        art = { icon = Icons.orcCaptureFlag },
        abilities = { "opressiveBannerAura" }, -- 1 lvl on spawn, increases with trigger
    },
    sigilOfBinding = {
        parent = UnitIds.stasistraptotem,
        name = "Sigil of Binding",
        abilities = { "sigilOfBindingActivation" },
    },
    sigilOfDrought = {
        parent = UnitIds.stasistraptotem,
        name = "Sigil of Drought",
        abilities = { "sigilOfDroughtActivation" },
    },
    deathwalker1 = {
        parent = UnitIds.waterelemental1,
        name = "Lesser Deathwalker",
        art = { icon = Icons.shade },
    },
    deathwalker2 = {
        parent = UnitIds.waterelemental2,
        name = "Deathwalker",
        art = { icon = Icons.shade },
    },
    deathwalker3 = {
        parent = UnitIds.waterelemental3,
        name = "Greater Deathwalker",
        art = { icon = Icons.shade },
    },
}
