---@class AbilityInventory: AbilityDefinition
---@field def Definition
AbilityInventory = class("AbilityInventory", AbilityDefinition)

function AbilityInventory:setCanDropItems(level, value)
    checktype(level, "integer", "setCanDropItems", 1)
    checktype(value, "boolean", "setCanDropItems", 2)
    self.def:setLvlDataBoolean("inv5", level, 5, value)
end

function AbilityInventory:setCanUseItems(level, value)
    checktype(level, "integer", "setCanUseItems", 1)
    checktype(value, "boolean", "setCanUseItems", 2)
    self.def:setLvlDataBoolean("inv3", level, 3, value)
end

function AbilityInventory:setDropItemsOnDeath(level, value)
    checktype(level, "integer", "setDropItemsOnDeath", 1)
    checktype(value, "boolean", "setDropItemsOnDeath", 2)
    self.def:setLvlDataBoolean("inv2", level, 2, value)
end

function AbilityInventory:setCanGetItems(level, value)
    checktype(level, "integer", "setCanGetItems", 1)
    checktype(value, "boolean", "setCanGetItems", 2)
    self.def:setLvlDataBoolean("inv4", level, 4, value)
end

function AbilityInventory:setItemCapacity(level, value)
    checktype(level, "integer", "setItemCapacity", 1)
    checktype(value, "integer", "setItemCapacity", 2)
    self.def:setLvlDataInt("inv1", level, 1, value)
end
