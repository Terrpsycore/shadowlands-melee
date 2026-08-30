local AbilityIds = require("lib.community.types.assets.AbilityIds")

local A = require("data.generated.ability_factories")

---@class AbilityFactoryInventory
---@overload fun(data: AbilityRow<AbilityInventory>?): AbilityRow<AbilityInventory>
---@field apply fun(fn: fun(a: AbilityInventory)): fun(a: AbilityInventory)

---@type AbilityFactoryInventory
A.inventory = setmetatable({
    parent = AbilityIds.inventory,
    apply = function(fn)
        return fn
    end,
}, getmetatable(A.innerFire))

return A
