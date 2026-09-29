local UnitIds = require("vendor.assets.UnitIds")

return {
    -- Basic --
    faeMain = {
        parent = UnitIds.treeoflife,
        name = "Main",
        abilities = { "extractHeartOfTheForest", "calmDreamsAura" },
    },
    faeAltar = {
        parent = UnitIds.altarofkings,
        name = "PLACEHOLDER",
        unitsTrained = {},
        revivesDeadHeros = true,
    },
    -- Resources --
    dreamTreeRoot = {
        parent = UnitIds.farm,
        name = "Dream Tree Root",
        abilities = { "calmDreamsAura" },
    },
    -- Barracks --
    -- Tech --
    -- Misc --
    mushroomRing = {
        parent = UnitIds.sentryTower,
        name = "Mushroom Ring",
        abilities = { "mushroomRingTravel", "mushroomRingInvisibility" },
    },
}
