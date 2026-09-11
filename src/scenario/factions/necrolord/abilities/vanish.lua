local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.vanish,
            dummy = Ids.abilities.vanishDummy,
        },
    },
})

local function onCast()
    local caster = GetTriggerUnit()
    Dummy.applyDummyOrder(GetOwningPlayer(caster), caster, CONFIG.refs.abilities.dummy, "invisibility") -- check order name
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_CAST",
            spellId = CONFIG.refs.abilities.main,
            action = onCast,
        },
    },
    config = CONFIG,
}
