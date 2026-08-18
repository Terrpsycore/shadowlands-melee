local UnitIds = require("lib.community.types.assets.UnitIds")

local db = {
    dummy = {
        parent = UnitIds.footman,
        apply = function(u)
            u:setNormalAbilities("")
        end,
    },
    dummyHero = {
        parent = UnitIds.paladin,
        apply = function(u)
            u:setName("Name")
        end,
    },
    aspirant = {
        parent = UnitIds.footman,
        abilities = { "soulbind" },
        apply = function(u)
            u:setName("Aspirant")
        end,
    },
}

return db
