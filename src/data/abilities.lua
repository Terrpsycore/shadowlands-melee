local AbilityIds = require("lib.community.types.assets.AbilityIds")

local db = {

    inventory = {
        parent = AbilityIds.inventory,
    },

    soulbind = {
        parent = AbilityIds.channel,
        name = "Soulbind",
        options = 1,
        buttonNormalX = 0,
        buttonNormalY = 2,
        apply = function(a)
            a:setTargetType(1, 1)
            a:setDisableOtherAbilities(1, false)
        end,
    },
    soulbindBuff = {
        parent = AbilityIds.innerFire,
        name = "",
        autocastRange = 0,
        buffs = { "soulbind" },
        levels = 3,
        ---@param a AbilityDefinitionInnerFire
        apply = function(a)
            a:setRequirements("")
            a:setDefenseIncrease(1, 2)
            a:setDamageIncrease(1, 0.1)
            a:setDefenseIncrease(2, 3)
            a:setDamageIncrease(2, 0.2)
            a:setDefenseIncrease(3, 5)
            a:setDamageIncrease(3, 0.3)
        end,
    },
    defenceProtocol = {
        parent = AbilityIds.exhume,
        ---@param a AbilityDefinitionExhume
        apply = function(a)
            a:setRequirements("")
            a:setMaximumNumberofCorpses(1, 0)
            a:setCooldown(1, 0)
        end,
    },
    defenceProtocolBuff = {
        parent = AbilityIds.bloodlust,
        buffs = { "defenceProtocol" },
        ---@param a AbilityDefinitionBloodlust
        apply = function(a)
            a:setRequirements("")
        end,
    },
    pride = {
        parent = AbilityIds.evasion,
        ---@param a AbilityDefinitionEvasion
        apply = function(a)
            a:setRequirements("")
            a:setChancetoEvade(1, 0)
        end,
    },
    prideDamage = {
        parent = AbilityIds.itemDamageBonus,
        name = "",
        levels = 5,
        ---@param a AbilityDefinitionAttackBonus
        apply = function(a)
            a:setItemAbility(true)
            for level = 1, 5 do
                a:setAttackBonus(level, 4 * level)
            end
        end,
    },
}

return db
