---@class AbilityDefinitionSacrificePit: AbilityDefinition
AbilityDefinitionSacrificePit = class("AbilityDefinitionSacrificePit", AbilityDefinition)

function AbilityDefinitionSacrificePit:constructor(id)
    self.def = createDefinition(DefinitionType.Ability, id, "Asac")
end
