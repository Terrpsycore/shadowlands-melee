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
}

return db
