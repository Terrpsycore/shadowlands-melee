local Ids = require("data.ids")

local A = require("data.abilityPresets")

return {
    -- motivation = A.nonDispellableSelfBuffTimed({
    --     name = "Motivation",
    --     buffs = { "motivation" },
    -- }),
    duel = A.passiveGeneric({
        name = "Duel",
        -- ? buffs for UI
    }),
    -- riposte = A.channelNoTarget({
    --     name = "Riposte",
    --     buffs = { "riposte" },
    -- }),
    dreadTrack = A.passiveGeneric({
        name = "Dread Track",
        -- ? buffs for UI
    }),
    hopebreakerThrill = A.passiveGeneric({
        name = "Hopebreaker Thrill",
        -- ? buffs for UI
    }),
    breakTheRanks = A.passiveGeneric({ -- TODO: has to be set up in upgrade (OE unit attack types)
        name = "Break the Ranks",
    }),
    screech = A.shockwave({
        name = "Screech",
    }),
    fearsomePresence = A.slowPoison({
        name = "Fearsome Presence",
        buffs = { "fearsomePresence" },
        apply = A.slowPoison.apply(function(a)
            a:setStackingType(1, 0)
            a:setDamagePerSecond(1, 0)
        end),
    }),
    provoke = A.channelTarget({
        name = "Provoke",
        buffs = { "provoke" },
    }),
    -- TODO: courier invis
    stampede = A.windWalk({
        name = "Stampede",
        buffs = { "stampede" },
        apply = A.windWalk.apply(function(a)
            a:setManaCost(1, 0)
            a:setTransitionTime(1, -1)
            a:setBackstabDamage(1, 0)
        end),
    }),
    infuseWeapon = A.bloodlust1({
        name = "Infuse Weapon",
        buffs = { "infuseWeapon" },
    }),
    harvestAcceleration = A.channelTarget({
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
        buffs = { "condemnWrath" },
    }),
    devourSins = A.devourMagic({ -- TBD
        name = "Devour Sins",
    }),
    contain = A.aerialShackles({
        name = "Contain",
        buffs = { "contain" },
    }),
    pullSins = A.channelNoTarget({
        name = "Pull Sins",
    }),
    siphonAnima = A.channelNoTarget({
        name = "Siphon Anima",
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
    devourSinsVulnerability = A.forsakenPaladinAura({
        name = "Devour Sins",
        buffs = { "devourSinsVulnerability" },
    }),
    castigateDebuff = A.nonDispellableTargetDebuff({
        name = "Castigate",
        buffs = { "castigate" },
    }),
    secondBreathCry = A.warStomp({
        name = "Second Breath",
        buffs = { "secondBreathCry" },
        apply = A.warStomp.apply(function(a) end),
    }),
}
