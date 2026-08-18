local AbilityIds = require("lib.community.types.assets.AbilityIds")

local db = {
    inventory = {
        parent = AbilityIds.inventory,
    },
    soulbind = {
        parent = AbilityIds.channel,
    },
    soulbindBuff = {
        parent = AbilityIds.innerFire,
        apply = function(a)
            a:setName("")
            a:setAutocastRange()
        end,
    },
}

return db
