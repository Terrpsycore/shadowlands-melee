local UnitIds = require("vendor.assets.UnitIds")
-- missing: farm, forge

return {
    -- Basic --
    venthyrMain = {
        parent = UnitIds.townhall,
        name = "Main",
        unitsTrained = {},
    },
    venthyrAltar = {
        parent = UnitIds.altarofstorms,
        name = "Altar",
        unitsTrained = { "stonebornHero", "fencer", "highInquisitor" },
        revivesDeadHeros = true,
    },
    -- Resources --
    muckPool = {
        parent = UnitIds.sacrificialpit,
        name = "Muck Pool",
        unitsTrained = { "duelist", "hopebreaker" },
        abilities = {}, -- TODO
    },
    -- Barracks --
    venthyrBarracks = {
        parent = UnitIds.humanbarracks,
        name = "PLACEHOLDER",
        unitsTrained = { "duelist", "hopebreaker" },
    },
    masonry = {
        parent = UnitIds.humanbarracks,
        name = "Masonry",
        unitsTrained = { "stoneborn", "gargoyle", "gargon", "courier" },
    },
    venthyrMageBarracks = {
        parent = UnitIds.humanbarracks,
        name = "PLACEHOLDER",
        unitsTrained = { "infuser", "tormentor", "inquisitor" },
    },
    sinstone = {
        parent = UnitIds.humanbarracks,
        name = "PLACEHOLDER",
        unitsTrained = { "sinstoneGolem" },
    },
    -- Misc --
    venthyrTower = {
        parent = UnitIds.sentryTower,
        name = "Focusing Mirror",
        abilities = {}, -- TODO
    },
    venthyrShop = {
        parent = UnitIds.arcanesanctum,
        name = "Shop",
    },
}
