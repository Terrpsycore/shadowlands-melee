local A = require("data.abilityPresets")

return {
    -- Main
    suppressingAura = A.slowAura({
        name = "Suppressing Aura",
        levels = 3,
        buffs = { "suppressingAura" },
    }),
    -- Maw Chain
    relink = A.channelTarget({
        name = "Re-link",
    }),
}
