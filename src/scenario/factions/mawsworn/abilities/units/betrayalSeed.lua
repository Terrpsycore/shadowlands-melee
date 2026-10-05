--[[
TODO:
- cancel if range has broken during channel
- loyalty trigger
- ? give xp to mawsworn on possess

KNOWN:
- reapplying seed prolongates timer
- different mawsworn player can re-bribe enemy unit if another mawsworn bribed it before
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.betrayalSeed,
        },
        buffs = {},
        units = {},
    },
    balance = {
        delay = 5, -- 60
        timedDelta = 1,
    },
})

--- @type table<unit, {owner: player, possessedAt: number}>
local memory = {}

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    if not WS.api.isExhausted(target) then
        dump("Target is not exhausted")
        return
    end

    memory[target] = {
        owner = owner,
        possessedAt = GetElapsedGameTime() + CONFIG.balance.delay,
    }
end

local function onTimer()
    for unit, data in pairs(memory) do
        if GetElapsedGameTime() > data.possessedAt then
            SetUnitOwner(unit, data.owner, true)
            memory[unit] = nil
        end
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
        {
            trigger = "TIMER",
            delay = CONFIG.balance.timedDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
