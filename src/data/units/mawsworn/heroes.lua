local UnitIds = require("vendor.assets.UnitIds")

return {
    forswornHero = {
        parent = UnitIds.jaina,
        name = "Forsworn Hero",
        abilities = {
            "forswornHeroFly",
            "forswornHeroFlyInstant",
        },
        heroAbilities = { "harpoon", "promoteLeutinant", "superiourCause", "abduct" },
    },
    forswornHeroFlying = {
        parent = UnitIds.jaina,
        name = "Forsworn Hero",
        abilities = {
            "forswornHeroFly",
            "forswornHeroFlyInstant",
        },
        heroAbilities = { "harpoon", "promoteLeutinant", "superiourCause", "abduct" },
        apply = function(u)
            u:setMovementType(MovementType.Fly)
            u:setMovementHeight(240)
        end,
    },
    mawcasterHero = {
        parent = UnitIds.lich,
        name = "Mawcaster Hero",
        heroAbilities = { "twistedPain", "opressiveChains", "eatSoul", "gorgoa" },
    },
    mournebladeHero = {
        parent = UnitIds.arthaswithfrostmourne,
        name = "Mourneblade Hero",
        heroAbilities = { "deadlyBlow", "wraithWalk", "soulRend", "dominateWill" },
    },
}
