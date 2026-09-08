local BuffIds = require("lib.community.types.assets.BuffIds")

return {
    soulbind = {
        parent = BuffIds.innerFire,
        name = "Soulbind",
    },
    defenceProtocol = {
        parent = BuffIds.bloodlust,
        name = "Defence Protocol",
    },
    huntedAnimal = {
        parent = BuffIds.bloodlust,
        name = "Hunted Animal",
    },
    spiritLink = {
        parent = BuffIds.spiritLink,
        name = "Spirit Link",
    },
    dedication = {
        parent = BuffIds.innerFire,
        name = "Dedication",
    },
    judgingGazeEvent = {
        parent = BuffIds.coldArrowsInfo,
        name = "Dedication",
    },
    memoryPeer = {
        parent = BuffIds.slowPoisonNonStacking,
        name = "Memory Peer",
    },
    oneMoreChance = {
        parent = BuffIds.innerFire,
        name = "One More Chance",
    },
    lastStand = {
        parent = BuffIds.devotionAura,
        name = "Last Stand",
    },
    deepMeditation = {
        parent = BuffIds.rejuvenationItem,
        name = "Deep Meditation",
    },
    deepMeditationStun = {
        parent = BuffIds.stunned,
        name = "Deep Meditation",
    },
    overchargeDamage = {
        parent = BuffIds.innerFire,
        name = "Overcharge",
    },
    overchargeSpeed = {
        parent = BuffIds.bloodlust,
        name = "Overcharge",
    },
    scanReveal = {
        parent = BuffIds.faerieFire,
        name = "Scan Reveal",
    },
    scanBuffSpeed = {
        parent = BuffIds.bloodlust,
        name = "Scan",
    },
    scanBuffDamage = {
        parent = BuffIds.innerFire,
        name = "Scan",
    },
    bastionSpearBonusDamage = {
        parent = BuffIds.slow,
        name = "Bastion Spear",
    },
    bastionSpearSlow = {
        parent = BuffIds.shadowStrike,
        name = "Bastion Spear",
    },
    securityLeakRepair = {
        parent = BuffIds.liquidFire,
        name = "Security Leak",
    },
    securityLeakAttack = {
        parent = BuffIds.cloud,
        name = "Security Leak",
    },
    securityLeakProduction = {
        parent = BuffIds.freezingBreath,
        name = "Security Leak",
    },
}
