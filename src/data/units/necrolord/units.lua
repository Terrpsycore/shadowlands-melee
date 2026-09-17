local UnitIds = require("vendor.assets.UnitIds")
local UnitArt = require("vendor.assets.generated.UnitArt")

return {
    animate = {
        parent = UnitIds.peon,
        name = "Animate",
        abilities = { "surviveWish" },
        art = {
            model = UnitArt[UnitIds.skeletonwarrior].model,
            scale = 0.9,
        },
    },
    animateWarrior = {
        parent = UnitIds.skeletonwarrior,
        name = "Animate Warrior",
        abilities = { "surviveWish", "combatExpertise" },
    },
    aranakkSpy = {
        parent = UnitIds.nerubianwarrior,
        name = "Aranakk Spy",
        abilities = { "vanish" },
    },
    gladiator = {
        parent = UnitIds.grunt,
        name = "Gladiator",
        abilities = { "warBanner" },
    },
    scavenger = {
        parent = UnitIds.ghoul,
        abilities = { "inventory", "collectCorpses", "dropCorpses", "exhume" },
    },
    construct = {
        parent = UnitIds.abomination,
    },
    necromancer = {
        parent = UnitIds.necromancer,
        abilities = { "animateDead", "maldraciteNullify" },
    },
    mixologist = {
        parent = UnitIds.necromancer,
        art = {
            model = UnitArt[UnitIds.acolyte].model,
            scale = 1,
        },
        abilities = { "healingSlime", "corrosivePlague" },
    },
    physician = {
        parent = UnitIds.necromancer,
        art = {
            model = UnitArt[UnitIds.acolyte].model,
            scale = 1,
        },
        abilities = { "applyLimb", "scissorSoul", "betterBody" },
    },
    necroray = {
        parent = UnitIds.nagacoutl,
        abilities = { "sporeCloud" },
    },
    --
    warBanner = {
        parent = UnitIds.sentryward,
        abilities = { "warBannerAura" },
    },
    sigilOfBinding = {
        parent = UnitIds.stasistraptotem,
        abilities = { "sigilOfBindingActivation" },
    },
}
