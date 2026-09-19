--[[
TODO:
- visuals on cast (before eruption)
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.necroticEruption,
            slow = Ids.abilities.necroticEruptionDummySlow,
            stun = Ids.abilities.necroticEruptionDummyStun,
        },
    },
    balance = {},
})

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()

    Timed.delay(1.5, function()
        Dummy.applyDummyImmediateOrder(owner, { x = targetX, y = targetY }, CONFIG.refs.abilities.stun, "stomp")
        Dummy.applyDummyImmediateOrder(owner, { x = targetX, y = targetY }, CONFIG.refs.abilities.slow, "thunderclap")
    end)
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
