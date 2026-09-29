local UnitIds = require("vendor.assets.UnitIds")

return {
    -- Basic --
    kyrianMain = {
        parent = UnitIds.townhall,
        name = "Main",
        unitsTrained = { "steward" },
        abilities = { "emergencyGuard1" },
    },
    herosRest = {
        parent = UnitIds.altarofkings,
        name = "Hero's Rest",
        unitsTrained = { "forgelite", "watcher", "bearer" },
        revivesDeadHeros = true,
    },
    -- Resources --
    animaExtractor = {
        parent = UnitIds.goldmine,
        name = "Anima Extractor",
    },
    animaStorage = {
        parent = UnitIds.moonwell,
        name = "Anima Storage",
        abilities = { "animaReplenish" },
    },
    -- Barracks --
    trainingGrounds = {
        parent = UnitIds.humanbarracks,
        name = "Training Grounds",
        unitsTrained = { "aspirant", "praetor", "larion" },
    },
    templeOfVirtue = {
        parent = UnitIds.arcanesanctum,
        name = "Temple of Virtue",
        unitsTrained = { "purity", "wisdom", "loyalty" },
    },
    workshop = {
        parent = UnitIds.workshop,
        name = "Workshop",
        unitsTrained = { "phalynx", "goliath", "colossus" },
    },
    -- Tech --
    crestOfAscension = {
        parent = UnitIds.arcaneobservatory,
        name = "Crest of Ascension",
    },
    -- Misc --
    templeWard = {
        parent = UnitIds.scouttower,
        name = "Temple Ward",
        abilities = { "magicBarrierOn" },
    },
    kyrianShop = {
        parent = UnitIds.marketplace,
        name = "Shop",
    },
}
