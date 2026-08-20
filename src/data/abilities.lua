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
    },
}

return db
