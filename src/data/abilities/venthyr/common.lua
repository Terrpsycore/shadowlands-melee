local A = require("data.abilityPresets")

return {
    harvest = A.passiveGeneric({
        name = "Harvest",
    }),
    -- == Items
    muckpoolCreate = A.buildTinyScoutTower({
        name = "Create Muckpool",
    }),
}
