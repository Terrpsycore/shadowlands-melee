---@class AbilityDefinitionStandDown: AbilityDefinition
AbilityDefinitionStandDown = class("AbilityDefinitionStandDown", AbilityDefinition)

function AbilityDefinitionStandDown:constructor(id)
    self.def = createDefinition(DefinitionType.Ability, id, "Astd")
end
