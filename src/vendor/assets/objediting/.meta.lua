---@meta

---@class W3UDefinition: object
---@class UnitOrBuildingOrHeroDefinition: W3UDefinition
---@class UnitOrHeroDefinition: UnitOrBuildingOrHeroDefinition
---@class UnitDefinition: UnitOrHeroDefinition
---@class HeroDefinition: UnitOrHeroDefinition
---@class BuildingDefinition: UnitOrBuildingOrHeroDefinition
---@class BuildingAndHeroDefinition: UnitOrBuildingOrHeroDefinition

---@class W3TDefinition: object
---@class ItemDefinition: W3TDefinition

---@class W3BDefinition: object
---@class DestructableDefinition: W3BDefinition

---@class W3QDefinition: object
---@class UpgradeDefinition: W3QDefinition

---@class AbilityDefinition: object
---@class BuffDefinition: object

---@param id string|integer
---@param superId string|integer
---@return UnitDefinition
function UnitDefinition:new(id, superId) end

---@param id string|integer
---@param superId string|integer
---@return HeroDefinition
function HeroDefinition:new(id, superId) end

---@param id string|integer
---@param superId string|integer
---@return BuildingDefinition
function BuildingDefinition:new(id, superId) end

---@param id string|integer
---@param superId string|integer
---@return BuildingAndHeroDefinition
function BuildingAndHeroDefinition:new(id, superId) end

---@param id string|integer
---@param superId string|integer
---@return ItemDefinition
function ItemDefinition:new(id, superId) end

---@param id string|integer
---@param superId string|integer
---@return AbilityDefinition
function AbilityDefinition:new(id, superId) end

---@param id string|integer
---@param superId string|integer
---@return BuffDefinition
function BuffDefinition:new(id, superId) end

---@param id string|integer
---@param superId string|integer
---@return DestructableDefinition
function DestructableDefinition:new(id, superId) end

---@param id string|integer
---@param superId string|integer
---@return UpgradeDefinition
function UpgradeDefinition:new(id, superId) end
