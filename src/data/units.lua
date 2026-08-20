local UnitIds = require("lib.community.types.assets.UnitIds")

local db = {
    dummy = {
        parent = UnitIds.footman,
        abilities = {},
    },
    dummyHero = {
        parent = UnitIds.paladin,
        name = "Name",
    },
    aspirant = {
        parent = UnitIds.footman,
        name = "Aspirant",
        abilities = { "soulbind" },
    },
    larion = {
        parent = UnitIds.footman,
        name = "Larion",
    },
}

return db
