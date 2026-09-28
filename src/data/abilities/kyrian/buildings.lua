local A = require("data.abilityPresets")

return {
    -- Anima Storage
    animaReplenish = A.replenishManaandLife({
        name = "Anima Replenish",
        -- trigger stop on castStart, restore mana with trigger ()
        -- apply targets mech+building
    }),
    -- Temple Ward
    magicBarrierOn = A.channelNoTarget({
        name = "Activate Magic Barrier",
        -- trigger replace toggle skill; radius damage on tick +
    }),
    magicBarrierOff = A.channelNoTarget({
        name = "Deactivate Magic Barrier",
    }),
    magicBarrierDebuff = A.dispellableTargetDebuff({
        name = "Magic Barrier",
        levels = 3,
        buffs = { "magicBarrierOverload" },
    }),
    magicBarrierBash = A.stormBolt({
        name = "Magic Barrier",
        -- apply duration 0.1
    }),
}
