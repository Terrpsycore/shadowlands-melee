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
        parent = AbilityIds.evasion,
        apply = function(a)
            a:setRequirements("")
        end,
    },
    defenceProtocolBuff = {
        parent = AbilityIds.bloodlust1,
    },
}

return db
