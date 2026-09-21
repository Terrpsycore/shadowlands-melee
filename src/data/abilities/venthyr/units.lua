local Ids = require("data.ids")

local A = require("data.abilityPresets")

return {
    motivation = A.nonDispellableSelfBuffTimed({
        name = "Motivation",
    }),
    duel = A.passiveGeneric({
        name = "Duel",
    }),
    -- riposte
    dreadTrack = A.passiveGeneric({
        name = "Dread Track",
    }),
    hopebreakerThrill = A.passiveGeneric({
        name = "Hopebreaker Thrill",
    }),
    breakTheRanks = A.passiveGeneric({ -- TODO: has to be set up in upgrade (OE unit attack types)
        name = "Break the Ranks",
    }),
    screech = A.shockwave({
        name = "Screech",
    }),
    fearsomePresence = A.slowPoison({
        name = "Fearsome Presence",
        apply = A.slowPoison.apply(function(a)
            a:setStackingType(1, 0)
            a:setDamagePerSecond(1, 0)
        end),
    }),
    provoke = A.channelTarget({
        name = "Provoke",
    }),
    stampede = A.windWalk({
        name = "Stampede",
        apply = A.windWalk.apply(function(a)
            a:setManaCost(1, 0)
            a:setTransitionTime(1, -1)
            a:setBackstabDamage(1, 0)
        end),
    }),
    infuseWeapon = A.bloodlust1({
        name = "Infuse Weapon",
    }),
    harvestAcceleration = A.bloodlust1({
        name = "Harvest Acceleration",
    }),
    feast = A.channelTarget({
        name = "Feast",
    }),
    castigate = A.channelTarget({
        name = "Castigate",
    }),
    sharedSuffering = A.spiritLink({
        name = "Shared Suffering",
    }),
    secondBreath = A.channelTarget({
        name = "Second Breath",
    }),
    condemnWrath = A.dispellableTargetDebuff({
        name = "Condemn Wrath",
    }),
    devourSins = A.devourMagic({ -- TBD
        name = "Devour Sins",
    }),
    contain = A.aerialShackles({
        name = "Contain",
    }),
    --
    harvestAccelerationSlow = A.shadowStrike({
        name = "Harvest Acceleration",
        buffs = { "harvestAccelerationSlow" },
        apply = A.shadowStrike.apply(function(a)
            a:setMovementSpeedFactor(1, 1)
            a:setInitialDamage(1, 0)
            a:setDecayPower(1, 3)
            a:setDecayingDamage(1, 0)
            a:setAttackSpeedFactor(1, 0)
            a:setDurationHero(1, 3)
            a:setDurationNormal(1, 5)
        end),
    }),
}
