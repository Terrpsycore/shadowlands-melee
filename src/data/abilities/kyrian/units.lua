local Ids = require("data.ids")

local A = require("data.ability")

return {
    soakAnima = A.manaSteal({
        name = "Soak Anima",
        apply = A.manaSteal.apply(function(a)
            a:setManaCost(1, 0)
            a:setTargetsAllowed(1, "ground,mechanical,nonhero,player")
        end),
    }),
    fuseAnima = A.siphonManaCreep({
        name = "Fuse Anima",
        apply = A.siphonManaCreep.apply(function(a)
            a:setManaCost(1, 0)
            a:setTargetsAllowed(1, "allied,ground,structure,mechanical,nonhero,player")
            a:setManaTransferredPerSecond(1, 200)
        end),
    }),
    rangeSwitch = A.bearForm({
        name = "Range Switch",
        apply = A.bearForm.apply(function(a)
            a:setManaCost(1, 0)
            a:setNormalFormUnit(1, Ids.units.aspirant)
            a:setAlternateFormUnit(1, Ids.units.aspirantMelee)
        end),
    }),
    ascendAspirant = A.stormCrowForm({
        name = "Ascend",
        apply = A.stormCrowForm.apply(function(a)
            a:setMorphingFlags(1, 29) -- uninterruptable,immediate take off, permanent, requires payment
            a:setManaCost(1, 0)
            a:setAlternateFormUnit(1, Ids.units.ascendedWarriorFlying)
        end),
    }),
    ascendedWarriorFly = A.stormCrowForm({
        name = "Ascend/Descend",
        apply = A.stormCrowForm.apply(function(a)
            a:setMorphingFlags(1, 1) -- uninterruptable
            a:setManaCost(1, 0)
            a:setNormalFormUnit(1, Ids.units.ascendedWarriorFlying)
            a:setAlternateFormUnit(1, Ids.units.ascendedWarrior)
        end),
    }),
    soulbind = A.channelTarget({
        name = "Soulbind",
        button = { 0, 2 },
    }),
    soulbindBuff = A.innerFire({
        name = "",
        autocastRange = 0,
        buffs = { "soulbind" },
        levels = 3,
        apply = A.innerFire.apply(function(a)
            a:setDefenseIncrease(1, 2)
            a:setDamageIncrease(1, 0.1)
            a:setDefenseIncrease(2, 3)
            a:setDamageIncrease(2, 0.2)
            a:setDefenseIncrease(3, 5)
            a:setDamageIncrease(3, 0.3)
        end),
    }),
    defenceProtocol = A.exhumeBased({}),
    defenceProtocolBuff = A.bloodlust({
        buffs = { "defenceProtocol" },
        apply = A.bloodlust.apply(function(a)
            a:setTargetsAllowed(1, "allied,ground,mechanical,nonhero,player")
        end),
    }),
    defenceProtocolToggle = A.immolationToggle({
        name = "Defence Protocol",
        manaCost = 20,
    }),
    pulseback = A.exhumeBased({}),
    pulsebackToggle = A.immolationToggle({
        name = "Pulseback",
        manaCost = 20,
    }),
    pulsebackPulse = A.blizzard1({
        name = "",
        apply = A.blizzard1.apply(function(a)
            a:setNumberofWaves(1, 1)
            a:setNumberofShards(1, 1)
            a:setDamage(1, 0)
            a:setMaximumDamageperWave(1, 0)
            a:setDamagePerSecond(1, 0)
            a:setTargetsAllowed(1, "enemy,ground,air,structure")
        end),
    }),
    pride = A.passiveGeneric({}),
    prideDamage = A.itemDamageBonus({
        name = "",
        levels = 5,
        apply = A.itemDamageBonus.apply(function(a)
            a:setItemAbility(true)
            for level = 1, 5 do
                a:setAttackBonus(level, 4 * level)
            end
        end),
    }),
    scanToggle = A.immolationToggle({
        name = "Scan",
        manaCost = 20,
        apply = function(a)
            a:setManaDrainedperSecond(1, 1)
        end,
    }),
    scanRevealArea = A.farSight({
        name = "Scan",
        apply = A.farSight.apply(function(a)
            a:setAreaofEffect(1, 64)
            a:setCastingTime(1, 0)
            a:setMissileArt("")
            a:setMissileSpeed(99999)
        end),
    }),
    scanReveal = A.faerieFire({
        name = "Scan Reveal",
        buffs = { "scanReveal" },
        apply = A.faerieFire.apply(function(a)
            a:setDefenseReduction(1, 0)
            a:setCastingTime(1, 0)
            a:setMissileArt("")
            a:setMissileSpeed(99999)
        end),
    }),
    scanBuffSpeed = A.bloodlust({
        buffs = { "scanBuffSpeed" },
        apply = A.bloodlust.apply(function(a)
            a:setTargetsAllowed(1, "allied,ground,mechanical,nonhero,player")
            a:setScalingFactor(1, 0)
        end),
    }),
    scanBuffDamage = A.innerFire({
        buffs = { "scanBuffDamage" },
        apply = A.innerFire.apply(function(a)
            a:setDefenseIncrease(1, 0)
            a:setDamageIncrease(1, 0.3)
        end),
    }),
    formationBuffSpeed = A.itemAuraCommand({
        name = "",
        apply = A.itemAuraCommand.apply(function(a)
            a:setItemAbility(true)
            a:setAreaofEffect(1, 0)
            a:setAttackDamageIncrease(1, 0.2)
        end),
    }),
    formationBuffDamage = A.itemAuraEndurance({
        name = "",
        apply = A.itemAuraEndurance.apply(function(a)
            a:setItemAbility(true)
            a:setAreaofEffect(1, 0)
            a:setMovementSpeedIncrease(1, 0.2)
            a:setAttackSpeedIncrease(1, 0.2)
        end),
    }),
    cannibalizeSearch = A.channelPoint({
        name = "Cannibalize",
        button = { 0, 2 },
    }),
    huntedAnimal = A.passiveGeneric({}),
    huntedAnimalBuff = A.bloodlust({
        buffs = { "huntedAnimal" },
        apply = A.bloodlust.apply(function(a) end),
    }),
    cannibalize = A.cannibalize({
        name = "",
    }),
    vesperBell = A.dispelMagic({
        name = "Vesper Bell",
        apply = A.dispelMagic.apply(function(a)
            -- TODO: block necromancy
        end),
    }),
    humility = A.cripple({
        name = "Vesper Bell",
        apply = A.cripple.apply(function(a)
            a:setManaCost(1, 75)
            a:setDamageReduction(1, 0.6)
            a:setAttackSpeedReduction(1, 0)
            a:setMovementSpeedReduction(1, 0)
        end),
    }),
    dedication = A.channelTarget({
        name = "Dedication",
        button = { 0, 2 },
    }),
    dedicationDamageBuff = A.innerFire({
        name = "Dedication",
        buffs = { "dedication" },
        apply = A.innerFire.apply(function(a)
            a:setDefenseIncrease(1, 0)
            a:setDamageIncrease(1, 0.25)
        end),
    }),
    dedicationAttackSpeedBuff = A.attackSpeedIncrease({
        name = "Dedication",
        apply = A.attackSpeedIncrease.apply(function(a)
            a:setAttackSpeedIncrease(1, 0.25)
        end),
    }),
    spiritLink = A.spiritLink({
        name = "Spirit Link",
        buffs = { "spiritLink" },
        apply = A.spiritLink.apply(function(a)
            a:setMaximumNumberofTargets(1, 2)
            a:setDistributedDamageFactor(1, 0.5)
        end),
    }),
    deepMeditation = A.channelTarget({
        name = "Deep Meditation",
        button = { 1, 2 },
        apply = A.channelTarget.apply(function(a)
            a:setTargetsAllowed(1, "allied,ground,organic,nonhero,player")
            a:setFollowThroughTime(1, 0)
            a:setArtDuration(1, 0)
        end),
    }),
    deepMeditationStunDummy = A.stormBolt({
        name = "Deep Meditation",
        buffs = { "deepMeditationStun" },
        apply = A.stormBolt.apply(function(a)
            a:setDamage(1, 0)
            a:setDurationNormal(1, 8)
            a:setDurationHero(1, 8)
            a:setTargetsAllowed(1, "allied,enemy,ground,organic,nonhero,player")
        end),
    }),
    deepMeditationRejuvDummy = A.rejuvenation1({
        name = "Deep Meditation",
        buffs = { "deepMeditation" },
        apply = A.rejuvenation1.apply(function(a)
            a:setManaPointsGained(1, 300)
            a:setNoTargetRequired(1, false)
            a:setHitPointsGained(1, 0)
            a:setAllowWhenFull(1, 0)
            a:setDurationNormal(1, 8)
            -- a:setDurationHero(1, 8)
            a:setTargetsAllowed(1, "allied,ground,organic,nonhero,player")
        end),
    }),
    animaBarrageToggle = A.immolationToggle({
        name = "Anima Barrage",
        manaCost = 5,
        apply = function(a)
            a:setBufferManaRequired(1, 5)
        end,
    }),
    animaBarrage = A.rocketAttack({
        name = "Anima Barrage",
    }),
    bastionSpear = A.channelArea({
        name = "Bastion Spear",
        button = { 1, 2 },
        apply = A.channelArea.apply(function(a)
            a:setAreaofEffect(1, 100)
            a:setTargetsAllowed(1, "allied,ground,organic,nonhero,player")
        end),
    }),
    bastionSpearBonusDamageDebuff = A.slow({
        name = "Bastion Spear",
        buffs = { "bastionSpearBonusDamage" },
        apply = A.slow.apply(function(a)
            a:setDurationHero(1, 5)
            a:setDurationNormal(1, 5)
            a:setMovementSpeedFactor(1, 0)
            a:setAttackSpeedFactor(1, 0)
        end),
    }),
    bastionSpearSlow = A.shadowStrike({
        name = "Bastion Spear",
        buffs = { "bastionSpearSlow" },
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
