local A = require("data.abilityPresets")

return {
    -- Main
    extractHeartOfTheForest = A.channelTarget({
        name = "Extract Heart",
    }),
    calmDreamsAura = A.forsakenPaladinAura({
        name = "Healing Aura",
        -- apply heal effectiveness only
    }),
    -- Mushroom Ring
    mushroomRingTravel = A.buildTinyScoutTower({
        name = "Travel",
    }),
    mushroomRingInvisibility = A.permanentInvisibility({
        name = "Invisibility",
    }),
    -- == Dummy
    mushroomRingActivation = A.mineexploding({
        name = "Mushroom Ring",
        -- apply activation time 0-1
    }),
    mushroomRingStun = A.stormBolt({
        name = "Mushroom Ring",
        buffs = { "mushroomRingStun" },
    }),
    mushroomRingDamage = A.rainofFire({
        name = "Mushroom Ring",
        buffs = { "mushroomRingDamage" },
    }),
}
