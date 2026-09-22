---@class AbilityDefinitionForsakenPaladinAura: AbilityDefinition
AbilityDefinitionForsakenPaladinAura = class("AbilityDefinitionForsakenPaladinAura", AbilityDefinition)

function AbilityDefinitionForsakenPaladinAura:constructor(id)
    self.def = createDefinition(DefinitionType.Ability, id, "AHpa")
end

-- TODO: add setters from Object Editor raw data (Ctrl+D). Example stub:
function AbilityDefinitionForsakenPaladinAura:setExampleField(level, value)
    checktype(level, "integer", "setExampleField", 1)
    checktype(value, "float", "setExampleField", 2)
    self.def:setLvlDataUnreal("Hpa1", level, 1, value)
end
