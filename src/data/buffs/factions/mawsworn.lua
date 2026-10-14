local BuffIds = require("vendor.assets.BuffIds")

return {
    weakenedSoulAura = {
        parent = BuffIds.tornadoSlowAura,
        name = "Weakened Soul",
    },
    weakenedSoulDebuff = {
        parent = BuffIds.curse,
        name = "Weakened Soul Duration",
    },
    exhaustion = {
        parent = BuffIds.cripple,
        name = "Exhaustion Duration",
    },
    exhaustionEffect = {
        parent = BuffIds.tornadoSlowAura,
        name = "Exhaustion",
    },
    exhaustionNeutralize = {
        parent = BuffIds.stunned,
        name = "Neutralized",
    },
    harpoon = {
        parent = BuffIds.stunned,
        name = "Harpoon",
    },
    harpoonRoot = {
        parent = BuffIds.entanglingRoots,
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
    superiourCause = {
        parent = BuffIds.devotionAura,
        name = "Superiour Cause",
    },
    superiourCauseShield = {
        parent = BuffIds.acidBomb,
        name = "Superiour Cause",
    },
    opressiveChains = {
        parent = BuffIds.immolation,
        name = "Opressive Chains",
    },
    deadlyBlowMark = {
        parent = BuffIds.acidBomb,
        name = "Deadly Blow Mark",
    },
    wraithWalk = {
        parent = BuffIds.windWalk,
        name = "Wraith Walk",
    },
    wraithWalkSlow = {
        parent = BuffIds.tornadoSlowAura,
        name = "Wraith Walk",
    },
    stygianShieldCooldown = {
        parent = BuffIds.acidBomb,
        name = "Stygian Shield (cooldown)",
    },
    stygianShield = {
        parent = BuffIds.acidBomb,
        name = "Stygian Shield",
    },
    disarmInit = {
        parent = BuffIds.coldArrowsInfo,
        name = "Disarm",
    },
    disarm = {
        parent = BuffIds.acidBomb,
        name = "Disarm",
    },
    malignantBoltInit = {
        parent = BuffIds.poisonInfo,
        name = "Malignant Bolt",
    },
    malignantBolt = {
        parent = BuffIds.acidBomb,
        name = "Malignant Bolt",
    },
    accursedStrength = {
        parent = BuffIds.berserk,
        name = "Accursed Strength",
    },
    accursedStrengthDamage = {
        parent = BuffIds.commandAura,
        name = "Accursed Strength",
    },
    glare = {
        parent = BuffIds.faerieFire,
        name = "Glare",
    },
    glareReveal = {
        parent = BuffIds.dustofAppearance,
        name = "Piercing Gaze",
    },
    piercingGazeReveal = {
        parent = BuffIds.dustofAppearance,
        name = "Piercing Gaze",
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
    threateningRoarLevel = {
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
    infusionEffect = {
        parent = BuffIds.commandAura,
        name = "Infusion",
    },
    burnResidue = {
        parent = BuffIds.howlofTerror,
        name = "Burn Residue",
    },
    freezeBlood = {
        parent = BuffIds.coldArrowsInfo,
        name = "Freeze Blood",
    },
    calcify = {
        parent = BuffIds.curse,
        name = "Calcify (disease)",
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
    suppressingAura = { parent = BuffIds.tornadoSlowAura, name = "Suppressing Aura" },
    mawChainQuake = { parent = BuffIds.earthquake, name = "Maw Chain" },
}
