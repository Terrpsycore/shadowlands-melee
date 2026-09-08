local UnitIds = require("lib.community.types.assets.UnitIds")

return {
    main = {
        parent = UnitIds.townhall,
        name = "Main",
        unitsTrained = { "steward" },
    },
    animaExtractor = {
        parent = UnitIds.goldmine,
        name = "Anima Extractor",
    },
    trainingGrounds = {
        parent = UnitIds.humanbarracks,
        name = "Training Grounds",
        unitsTrained = { "aspirant", "praetor", "larion" },
    },
    workshop = {
        parent = UnitIds.workshop,
        name = "Workshop",
        unitsTrained = { "phalynx", "goliath", "colossus" },
    },
    templeOfVirtue = {
        parent = UnitIds.arcanesanctum,
        name = "Temple of Virtue",
        unitsTrained = { "purity", "wisdom", "loyalty" },
    },
    crestOfAscension = {
        parent = UnitIds.arcaneobservatory,
        name = "Crest of Ascension",
    },
    herosRest = {
        parent = UnitIds.altarofkings,
        name = "Hero's Rest",
        unitsTrained = { "forgelite", "watcher", "bearer" },
        revivesDeadHeros = true,
    },
    templeWard = {
        parent = UnitIds.scouttower,
        name = "Temple Ward",
    },
    animaStorage = {
        parent = UnitIds.moonwell,
        name = "Anima Storage",
    },
    shop = {
        parent = UnitIds.marketplace,
        name = "Shop",
    },
}
