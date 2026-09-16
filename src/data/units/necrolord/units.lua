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
    scavenger = {
        parent = UnitIds.ghoul,
        abilities = { "inventory", "collectCorpses", "dropCorpses", "exhume" },
    },
    construct = {
        parent = UnitIds.abomination,
    },
    necromancer = {
        parent = UnitIds.necromancer,
        abilities = { "animateDead" },
    },
    mixologist = {
        parent = UnitIds.necromancer,
        art = {
            model = UnitArt[UnitIds.acolyte].model,
            scale = 1,
        },
        abilities = { "healingSlime" },
    },
    physician = {
        parent = UnitIds.necromancer,
        art = {
            model = UnitArt[UnitIds.acolyte].model,
            scale = 1,
        },
        abilities = { "applyLimb" },
    },
}
