local UnitIds = require("lib.community.types.assets.UnitIds")

local db = {
    dummy = {
        parent = UnitIds.footman,
        abilities = {},
        apply = function(u)
            u:setManaMaximum(1000)
            u:setManaInitialAmount(1000)
            u:setModelFile("")
        end,
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
