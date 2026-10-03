local A = require("data.abilityPresets")

return {
    --- Active
    soulkeeper = A.channelNoTarget({
        name = "Soulkeeper",
    }),
    soulforgedCloak = A.channelTarget({
        name = "soulforgedCloak",
        -- cooldown = 5,
        apply = A.channelTarget.apply(function(a, level)
            a:setTargetsAllowed(level, "ground,air,organic,nonhero,player")
        end),
    }),
    soulforgedSpikedArmor = A.cryptLordSpikedCarapace({
        name = "soulforgedSpikedArmor",
        apply = A.cryptLordSpikedCarapace.apply(function(a, level)
            a:setReturnedDamageFactor(level, 0.35)
        end),
    }),
    --- Dummy
    soulforgedCloakInvis = A.invisibility({
        name = "soulforgedCloak",
    }),
    soulforgedGauntletsFrenzy = A.nonDispellableSelfBuffTimed({
        name = "soulforgedGauntlets",
        apply = A.nonDispellableSelfBuffTimed.apply(function(a, level)
            a:setAttackSpeedIncrease(level, 0.4)
        end),
    }),
    soulforgedSpikedArmorNegativeRegen = A.permanentImmolation({
        name = "soulforgedSpikedArmor",
        apply = A.permanentImmolation.apply(function(a, level)
            a:setDamageperInterval(level, 5)
            a:setTargetsAllowed(level, "self")
        end),
    }),
}
