local A = require("data.abilityPresets")

return {
    -- Main
    emergencyGuard0 = A.exhumeBased({ -- dummy tooltip timer showing stock (different icons)
        name = "Emergency Guard",
        levels = 3,
    }),
    emergencyGuard1 = A.exhumeBased({
        name = "Emergency Guard",
        levels = 3,
    }),
    emergencyGuard2 = A.exhumeBased({
        name = "Emergency Guard",
        levels = 3,
    }),
    emergencyGuard3 = A.exhumeBased({
        name = "Emergency Guard",
        levels = 3,
    }),
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
