local A = require("data.abilityPresets")

return {
    weakenedSoulEffect = A.slowAura({
        name = "Weakened Soul",
        levels = 10,
        buffs = { "weakenedSoulAura" },
        apply = A.slowAura.apply(function(a, level)
            a:setAreaofEffect(level, 0)
            a:setMovementSpeedFactor(level, -0.02 * level)
            a:setAttackSpeedFactor(level, -0.02 * level)
        end),
    }),
    weakenedSoulDebuff = A.dispellableTargetDebuff({
        name = "Weakened Soul",
        buffs = { "weakenedSoulDebuff" },
        apply = A.dispellableTargetDebuff.apply(function(a, level)
            a:setDurationNormal(level, 20)
            a:setDurationHero(level, 20)
        end),
    }),
    exhaustionDebuff = A.nonDispellableTargetDebuff({
        name = "Exhaustion",
        buffs = { "exhaustion" },
    }),
    exhaustionEffect = A.slowAura({
        name = "Exhaustion",
        buffs = { "exhaustionEffect" },
        apply = A.slowAura.apply(function(a, level)
            a:setAreaofEffect(level, 0)
            a:setMovementSpeedFactor(level, -0.2)
            a:setAttackSpeedFactor(level, -0.2)
        end),
    }),
    exhaustionNeutralize = A.stormBolt({
        name = "Exhaustion",
        buffs = { "exhaustionNeutralize" },
        apply = A.stormBolt.apply(function(a, level)
            a:setDurationNormal(level, 10)
            a:setDurationHero(level, 2)
            a:setDamage(level, 0)
        end),
    }),
    grabPrisoner = A.channelTarget({
        name = "Grab",
    }),
    dropPrisoner = A.channelTarget({
        name = "Drop",
    }),
}
