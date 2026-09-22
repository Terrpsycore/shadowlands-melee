local UnitIds = require("vendor.assets.UnitIds")

return {
    highInquisitor = {
        parent = UnitIds.jaina,
        name = "High Inquisitor",
        heroAbilities = { "inquisitorMark", "deepInquiry", "condemnPride", "condemnGreed" },
    },
    fencer = {
        parent = UnitIds.blademaster,
        name = "Fencer",
        heroAbilities = { "freeWalk", "bladeThirst", "carnage", "phaseShift" },
    },
    stonebornHero = {
        parent = UnitIds.mountainking,
        name = "Stoneborn",
        heroAbilities = { "fissure", "stoneBarrier", "soldiersOath", "crushingStone" },
    },
}
