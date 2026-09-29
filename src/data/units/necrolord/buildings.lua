local UnitIds = require("vendor.assets.UnitIds")

-- missing: shop, forge

return {
    -- Basic --
    necrolordMain = {
        parent = UnitIds.necropolis,
        name = "Necropoli",
        unitsTrained = { "animate", "aranakkSpy" },
        abilities = { "necropoliManaShield" }, -- TODO: manaregen triggered
        -- apply target type mechanical ancient
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
        abilities = { "conductorManaRegenAura", "conductorManaRegenAuraAmplify" },
    },
    maldraciteBattery = {
        parent = UnitIds.farm,
        name = "Maldracite Battery",
        abilities = { "chargeTower" },
        -- apply 0 mana regen + control it with trigger (regen each 1 sec until freezed amount reached)
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
        abilities = { "bodyBanksInventory", "scavengerHire" },
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
