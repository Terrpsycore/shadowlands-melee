local UnitIds = require("lib.community.types.assets.UnitIds")

return {
    dummy = {
        parent = UnitIds.footman,
        abilities = { "locust" },
        apply = function(u)
            u:setManaMaximum(1000)
            u:setManaInitialAmount(1000)
            u:setAttacksEnabled(0)
            u:setModelFile("")
        end,
    },
    dummyTarget = {
        parent = UnitIds.footman,
        apply = function(u)
            u:setAttacksEnabled(0)
        end,
    },
    dummyHero = {
        parent = UnitIds.paladin,
        name = "Name",
    },
}
