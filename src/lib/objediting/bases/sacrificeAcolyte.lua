---@class AbilityDefinitionSacrificeAcolyte: AbilityDefinition
AbilityDefinitionSacrificeAcolyte = class("AbilityDefinitionSacrificeAcolyte", AbilityDefinition)

function AbilityDefinitionSacrificeAcolyte:constructor(id)
    self.def = createDefinition(DefinitionType.Ability, id, "Alam")
end
