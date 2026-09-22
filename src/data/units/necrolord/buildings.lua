local UnitIds = require("vendor.assets.UnitIds")

-- missing: shop, forge

return {
    -- Basic --
    necrolordMain = {
        parent = UnitIds.necropolis,
        name = "Necropoli",
        unitsTrained = { "animate", "aranakkSpy" },
        abilities = {}, -- TODO: manaregen, manashield, ...
    },
    necrolordAltar = {
        parent = UnitIds.altarofdarkness,
        name = "Altar",
        unitsTrained = { "gladiatorHero", "lich", "bonesmith" },
        revivesDeadHeros = true,
    },
    -- Resources --
    transportConductor = {
        parent = UnitIds.graveyard,
        name = "Transport Conductor",
        abilities = {}, -- ? TODO: necropoli regen
    },
    maldraciteBattery = {
        parent = UnitIds.farm,
        name = "Maldracite Battery",
    },
    -- Barracks --
    chosenBarracks = {
        parent = UnitIds.crypt,
        name = "Common",
        unitsTrained = { "animateWarrior", "ballista", "gladiator", "frayedwing" },
    },
    constructBarracks = {
        parent = UnitIds.slaughterhouse,
        name = "Body Banks",
        unitsTrained = { "scavenger", "physician", "construct" },
        abilities = {}, -- TODO: sacrifice
    },
    ritualBarracks = {
        parent = UnitIds.templeofthedamned,
        name = "Rituals",
        unitsTrained = { "necromancer", "bonestorm" },
    },
    plagueBarracks = {
        parent = UnitIds.sacrificialpit,
        name = "Orangery",
        unitsTrained = { "mixologist", "necroray" },
    },
    -- Misc --
    necrolordTower = {
        parent = UnitIds.sentryTower,
        name = "Tower",
    },
    necrolordShop = {
        parent = UnitIds.arcanesanctum,
        name = "Shop",
    },
}
