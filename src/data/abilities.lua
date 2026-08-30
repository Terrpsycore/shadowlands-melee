local Ids = require("data.generated.ids")

local A = require("data.ability")

local db = {
    inventory = A.inventory({}),
    phase = A.windWalk({
        apply = A.windWalk.apply(function(a)
            a:setRequirements("")
            a:setManaCost(1, 0)
            a:setTransitionTime(1, -1)
            a:setBackstabDamage(1, 0)
        end),
    }),
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
}

return db
