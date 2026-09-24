local Ids = require("data.ids")
local Icons = require("vendor.assets.generated.Icons")

local A = require("data.abilityPresets")

return {
    -- motivation = A.nonDispellableSelfBuffTimed({
    --     name = "Motivation",
    --     buffs = { "motivation" },
    -- }),
    duel = A.passiveGeneric({
        name = "Duel",
        art = { icon = Icons.pasRetaliation },
        -- art = { icon = Icons.pasHoldposition },
        -- ? buffs for UI
    }),
    -- riposte = A.channelNoTarget({
    --     name = "Riposte",
    --     buffs = { "riposte" },
    -- }),
    dreadTrack = A.passiveGeneric({
        name = "Dread Track",
        art = { icon = Icons.pasDeathmark },
        -- ? buffs for UI
    }),
    hopebreakerThrill = A.passiveGeneric({
        name = "Hopebreaker Thrill",
        art = { icon = Icons.pasVampiricAura },
        -- ? buffs for UI
    }),
    breakTheRanks = A.passiveGeneric({ -- TODO: has to be set up in upgrade (OE unit attack types)
        name = "Break the Ranks",
        art = { icon = Icons.pasShockwave },
    }),
    screech = A.shockwave({
        name = "Screech",
        art = { icon = Icons.sentinel },
    }),
    fearsomePresence = A.slowPoison({
        name = "Fearsome Presence",
        buffs = { "fearsomePresence" },
        art = { icon = Icons.pasBearform },
        apply = A.slowPoison.apply(function(a)
            a:setStackingType(1, 0)
            a:setDamagePerSecond(1, 0)
        end),
    }),
    provoke = A.channelTarget({
        name = "Provoke",
        art = { icon = Icons.reincarnation },
        buffs = { "provoke" },
    }),
    -- TODO: courier invis
    stampede = A.windWalk({
        name = "Stampede",
        buffs = { "stampede" },
        art = { icon = Icons.blightweaverboots },
        apply = A.windWalk.apply(function(a)
            a:setManaCost(1, 0)
            a:setTransitionTime(1, -1)
            a:setBackstabDamage(1, 0)
        end),
    }),
    infuseWeapon = A.bloodlust1({
        name = "Infuse Weapon",
        art = { icon = Icons.autocastArcanitemelee },
        buffs = { "infuseWeapon" },
    }),
    harvestAcceleration = A.channelTarget({
        name = "Harvest Acceleration",
        art = { icon = Icons.markOfFire },
    }),
    feast = A.channelTarget({
        name = "Feast",
        art = { icon = Icons.orbofSlowness },
    }),
    castigate = A.channelTarget({
        name = "Castigate",
        art = { icon = Icons.autocastSoulburn },
    }),
    sharedSuffering = A.spiritLink({
        name = "Shared Suffering",
        art = { icon = Icons.spiritLink },
    }),
    secondBreath = A.channelTarget({
        name = "Second Breath",
        art = { icon = Icons.incinerate },
    }),
    condemnWrath = A.dispellableTargetDebuff({
        name = "Condemn Wrath",
        art = { icon = Icons.autocastQuillspray },
        -- art = { icon = Icons.autocastQuillsprayoff },
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
        art = { icon = Icons.scatterrockets },
    }),
    siphonAnima = A.channelNoTarget({
        name = "Siphon Anima",
        art = { icon = Icons.drain },
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
