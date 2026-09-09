--- Declarative AbilityRow input fields — type hints for gen_ability_kinds.lua.
--- Runtime handlers: objediting/kinds/abilities.lua (keep in sync).
--- `parent` is injected by A.* factory pack(), not passed in data literals.
return {
    { "name", "string", optional = true },
    { "levels", "integer", optional = true },
    { "buffs", "string[]", optional = true },
    { "autocastRange", "number", optional = true },
    { "options", "integer", optional = true },
    { "button", "integer[]", optional = true },
    { "hotkey", "string", optional = true },
    { "requirements", "string", optional = true },
    { "manaCost", "number|number[]", optional = true },
    { "apply", "fun(a: AbilityDefinition)", optional = true },
}
