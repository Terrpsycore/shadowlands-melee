local A = require("data.abilityPresets")

return {
    -- == Buildings
    witherAura = A.permanentImmolation({
        name = "Wither",
    }),
    -- == Units
    -- Sylvar
    spareAnimacone = A.rejuvenation({
        name = "Spare Animacone",
        buffs = { "spareAnimacone" },
        levels = 3,
        button = { 0, 2 },
    }),
    -- == Upgrades
    -- Hunter's Training
    huntersTraining = A.nonDispellableSelfBuffTimed({
        name = "Blink",
        buffs = { "huntersTraining" },
        levels = 3,
        button = { 0, 2 },
    }),
}
