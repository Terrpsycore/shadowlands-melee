local AbilityIds = require("lib.community.types.assets.AbilityIds")

local fallback = {
    new = function(id, parent)
        return AbilityDefinition:new(id, parent)
    end,
}

local byParent = {
    [AbilityIds.inventory] = {
        new = function(id, parent)
            return AbilityInventory:new(id, parent)
        end,
        apply = function(a)
            a:setCanUseItems(1, false)
        end,
    },
}

return {
    resolve = function(parent)
        return byParent[parent] or fallback
    end,
    defaults = function(a)
        a:setHeroAbility(false)
    end,
}
