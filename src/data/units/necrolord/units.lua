local UnitIds = require("vendor.assets.UnitIds")
local UnitArt = require("vendor.assets.generated.UnitArt")

return {
    animate = {
        parent = UnitIds.peon,
        name = "Animate",
        abilities = { "inventory", "surviveWish" },
        art = {
            model = UnitArt[UnitIds.skeletonwarrior].model,
            scale = 0.9,
        },
    },
    animateWarrior = {
        parent = UnitIds.skeletonwarrior,
        name = "Animate Warrior",
        abilities = { "inventory", "surviveWish", "combatExpertise" },
    },
    aranakkSpy = {
        parent = UnitIds.nerubianwarrior,
        name = "Aranakk Spy",
        abilities = { "inventory", "vanish" },
    },
    ballista = {
        parent = UnitIds.glaivethrower,
        name = "Ballista",
        abilities = { "netAmmo" },
    },
    gladiator = {
        parent = UnitIds.grunt,
        name = "Gladiator",
        abilities = { "warBanner" },
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
        abilities = { "animateDead", "maldraciteNullify", "sigilOfBinding" },
    },
    mixologist = {
        parent = UnitIds.necromancer,
        name = "Mixologist",
        art = {
            model = UnitArt[UnitIds.acolyte].model,
            scale = 1,
        },
        abilities = { "healingSlime", "corrosivePlague", "concoctPotion" },
    },
    physician = {
        parent = UnitIds.necromancer,
        name = "Physician",
        art = {
            model = UnitArt[UnitIds.acolyte].model,
            scale = 1,
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
        apply = function(u)
            u:setHitPointsRegenerationRate(-5)
        end,
    },
    --
    warBanner = {
        parent = UnitIds.sentryward,
        name = "War Banner",
        abilities = { "warBannerAura" },
    },
    sigilOfBinding = {
        parent = UnitIds.stasistraptotem,
        name = "Sigil of Binding",
        abilities = { "sigilOfBindingActivation" },
    },
}
