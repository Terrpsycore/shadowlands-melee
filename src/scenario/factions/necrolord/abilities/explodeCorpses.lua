--[[
TODO:
- prevent dummy corpses
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.explodeCorpses,
            dummy = Ids.abilities.explodeCorpsesDummy,
        },
    },
    balance = {
        radius = 600, -- TODO: connect with data. attributes
    },
})

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()

    local corpses = Unit.getCorpsesInRadius({ x = targetX, y = targetY }, CONFIG.balance.radius)

    for _, corpse in ipairs(corpses) do
        Dummy.applyDummyImmediateOrder(owner, corpse, CONFIG.refs.abilities.dummy, "thunderclap")
        RemoveUnit(corpse)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
    },
    config = CONFIG,
}
