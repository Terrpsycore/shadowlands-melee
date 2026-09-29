local UnitIds = require("vendor.assets.UnitIds")
-- missing: farm, forge

return {
    -- Basic --
    venthyrMain = {
        parent = UnitIds.townhall,
        name = "Main",
        unitsTrained = {},
        abilities = { "castleReserves" },
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
        unitsTrained = { "dredger", "dredgerBrute" }, -- TODO: instant dredgerBrute if 3 dredgers are in cargo
        abilities = { "muckpoolCargo", "muckpoolDissolve" },
    },
    coffin = { -- ? crypt
        parent = UnitIds.farm,
        name = "PLACEHOLDER",
        abilities = { "peacefulRestCargo", "peacefulRest", "peacefulRestEnd" },
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
        abilities = { "focusedLight" },
    },
    venthyrShop = {
        parent = UnitIds.arcanesanctum,
        name = "Shop",
    },
}
