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
            a:setRequirements("")
            a:setManaCost(1, 0)
            a:setNormalFormUnit(1, Ids.units.aspirant)
            a:setAlternateFormUnit(1, Ids.units.aspirantMelee)
        end),
    }),
    ascendAspirant = A.stormCrowForm({
        name = "Ascend",
        apply = A.stormCrowForm.apply(function(a)
            a:setRequirements("")
            a:setMorphingFlags(1, 29) -- uninterruptable,immediate take off, permanent, requires payment
            a:setManaCost(1, 0)
            a:setAlternateFormUnit(1, Ids.units.ascendedWarriorFlying)
        end),
    }),
    ascendedWarriorFly = A.stormCrowForm({
        name = "Ascend/Descend",
        apply = A.stormCrowForm.apply(function(a)
            a:setRequirements("")
            a:setMorphingFlags(1, 1) -- uninterruptable
            a:setManaCost(1, 0)
            a:setNormalFormUnit(1, Ids.units.ascendedWarriorFlying)
            a:setAlternateFormUnit(1, Ids.units.ascendedWarrior)
        end),
    }),
    soulbind = A.channel({
        name = "Soulbind",
        options = 1,
        buttonNormalX = 0,
        buttonNormalY = 2,
        apply = A.channel.apply(function(a)
            a:setTargetType(1, 1)
            a:setDisableOtherAbilities(1, false)
        end),
    }),
    soulbindBuff = A.innerFire({
        name = "",
        autocastRange = 0,
        buffs = { "soulbind" },
        levels = 3,
        apply = A.innerFire.apply(function(a)
            a:setRequirements("")
            a:setDefenseIncrease(1, 2)
            a:setDamageIncrease(1, 0.1)
            a:setDefenseIncrease(2, 3)
            a:setDamageIncrease(2, 0.2)
            a:setDefenseIncrease(3, 5)
            a:setDamageIncrease(3, 0.3)
        end),
    }),
    defenceProtocol = A.exhume({
        apply = A.exhume.apply(function(a)
            a:setRequirements("")
            a:setMaximumNumberofCorpses(1, 0)
            a:setCooldown(1, 0)
        end),
    }),
    defenceProtocolBuff = A.bloodlust({
        buffs = { "defenceProtocol" },
        apply = A.bloodlust.apply(function(a)
            a:setRequirements("")
            a:setTargetsAllowed(1, "allied,ground,mechanical,nonhero,player")
        end),
    }),
    defenceProtocolToggle = A.immolation({
        name = "Defence Protocol",
        apply = A.immolation.apply(function(a)
            a:setRequirements("")
            a:setManaCost(1, 20)
            a:setDamageperInterval(1, 0)
            a:setManaDrainedperSecond(1, 0)
            a:setBufferManaRequired(1, 0)
        end),
    }),
    pride = A.evasion({
        apply = A.evasion.apply(function(a)
            a:setRequirements("")
            a:setChancetoEvade(1, 0)
        end),
    }),
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
    formation = A.evasion({
        apply = A.evasion.apply(function(a)
            a:setRequirements("")
            a:setChancetoEvade(1, 0)
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
    cannibalizeSearch = A.channel({
        name = "Cannibalize",
        options = 1,
        buttonNormalX = 0,
        buttonNormalY = 2,
        apply = A.channel.apply(function(a)
            a:setTargetType(1, 2)
            a:setDisableOtherAbilities(1, false)
        end),
    }),
    huntedAnimal = A.evasion({
        apply = A.evasion.apply(function(a)
            a:setRequirements("")
            a:setChancetoEvade(1, 0)
        end),
    }),
    huntedAnimalBuff = A.bloodlust({
        buffs = { "huntedAnimal" },
        apply = A.bloodlust.apply(function(a)
            a:setRequirements("")
        end),
    }),
    cannibalize = A.cannibalize({
        name = "",
        apply = A.cannibalize.apply(function(a)
            a:setRequirements("")
        end),
    }),
    vesperBell = A.dispelMagic({
        name = "Vesper Bell",
        apply = A.dispelMagic.apply(function(a)
            a:setRequirements("")
            -- TODO: block necromancy
        end),
    }),
    humility = A.cripple({
        name = "Vesper Bell",
        apply = A.cripple.apply(function(a)
            a:setRequirements("")
            a:setManaCost(1, 75)
            a:setDamageReduction(1, 0.6)
            a:setAttackSpeedReduction(1, 0)
            a:setMovementSpeedReduction(1, 0)
        end),
    }),
    dedication = A.channel({
        name = "Dedication",
        options = 1,
        buttonNormalX = 0,
        buttonNormalY = 2,
        apply = A.channel.apply(function(a)
            a:setTargetType(1, 1)
            a:setDisableOtherAbilities(1, false)
        end),
    }),
    dedicationDamageBuff = A.innerFire({
        name = "Dedication",
        buffs = { "dedication" },
        apply = A.innerFire.apply(function(a)
            a:setRequirements("")
            a:setDefenseIncrease(1, 0)
            a:setDamageIncrease(1, 0.25)
        end),
    }),
    dedicationAttackSpeedBuff = A.attackSpeedIncrease({
        name = "Dedication",
        apply = A.attackSpeedIncrease.apply(function(a)
            a:setRequirements("")
            a:setAttackSpeedIncrease(1, 0.25)
        end),
    }),
    spiritLink = A.spiritLink({
        name = "Spirit Link",
        buffs = { "spiritLink" },
        apply = A.spiritLink.apply(function(a)
            a:setRequirements("")
            a:setMaximumNumberofTargets(1, 2)
            a:setDistributedDamageFactor(1, 0.5)
        end),
    }),
    deepMeditation = A.channel({
        name = "Deep Meditation",
        options = 1,
        buttonNormalX = 1,
        buttonNormalY = 2,
        apply = A.channel.apply(function(a)
            a:setRequirements("")
            a:setTargetType(1, 1)
            a:setDisableOtherAbilities(1, false)
            a:setTargetsAllowed(1, "allied,ground,organic,nonhero,player")
            a:setFollowThroughTime(1, 0)
            a:setArtDuration(1, 0)
        end),
    }),
    deepMeditationStunDummy = A.stormBolt({
        name = "Deep Meditation",
        buffs = { "deepMeditationStun" },
        apply = A.stormBolt.apply(function(a)
            a:setRequirements("")
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
            a:setRequirements("")
            a:setManaPointsGained(1, 300)
            a:setNoTargetRequired(1, false)
            a:setHitPointsGained(1, 0)
            a:setAllowWhenFull(1, 0)
            a:setDurationNormal(1, 8)
            -- a:setDurationHero(1, 8)
            a:setTargetsAllowed(1, "allied,ground,organic,nonhero,player")
        end),
    }),
}
