local A = require("data.abilityPresets")

return {
    weakenedSoulEffect = A.slowAura({
        name = "Weakened Soul",
        levels = 10,
        buffs = { "weakenedSoulAura" },
    }),
    weakenedSoulDebuff = A.dispellableTargetDebuff({
        name = "Weakened Soul",
        levels = 10, -- UI
        buffs = { "weakenedSoulDebuff" },
    }),
    exhaustionDebuff = A.nonDispellableTargetDebuff({
        name = "Exhaustion",
        buffs = { "exhaustion" },
    }),
    grab = A.channelTarget({
        name = "Grab",
    }),
}
