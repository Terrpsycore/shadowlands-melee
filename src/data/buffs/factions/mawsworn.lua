local BuffIds = require("vendor.assets.BuffIds")

return {
    weakenedSoulAura = {
        parent = BuffIds.tornadoSlowAura,
        name = "Weakened Soul (aura)",
    },
    weakenedSoulDebuff = {
        parent = BuffIds.curse,
        name = "Weakened Soul (debuff)",
    },
    exhaustion = {
        parent = BuffIds.acidBomb,
        name = "Exhaustion",
    },
    harpoon = {
        parent = BuffIds.stunned,
        name = "Harpoon",
    },
    twistedPain = {
        parent = BuffIds.acidBomb,
        name = "Twisted Pain",
    },
    promoteLeutinant = {
        parent = BuffIds.trueshotAura,
        name = "Promote Leutinant",
    },
    opressiveChains = {
        parent = BuffIds.immolation,
        name = "Opressive Chains",
    },
    stygianShieldCooldown = {
        parent = BuffIds.acidBomb,
        name = "Stygian Shield (cooldown)",
    },
    stygianShield = {
        parent = BuffIds.acidBomb,
        name = "Stygian Shield",
    },
    disarm = {
        parent = BuffIds.acidBomb,
        name = "Disarm",
    },
    forcedRestitution = {
        parent = BuffIds.replenish,
        name = "Forced Restitution",
    },
    forcedRestitutionDecay = {
        parent = BuffIds.acidBomb,
        name = "Forced Restitution (decay)",
    },
    threateningRoar = {
        parent = BuffIds.howlofTerror,
        name = "Threatening Roar",
    },
    shackle = {
        parent = BuffIds.slow,
        name = "Shackle",
    },
    fallenArmaments = {
        parent = BuffIds.enduranceAura,
        name = "Fallen Armaments",
    },
    infusion = {
        parent = BuffIds.innerFire,
        name = "Infusion",
    },
    burnResidue = {
        parent = BuffIds.howlofTerror,
        name = "Burn Residue",
    },
    calcifySlow = {
        parent = BuffIds.slow,
        name = "Calcify (slow)",
    },
    calcifyStun = {
        parent = BuffIds.stunned,
        name = "Calcify (stun)",
    },
    foulBite = {
        parent = BuffIds.slowPoisonNonStacking,
        name = "Foul Bite",
    },
}
