--[[
TODO:
- different heal amount on dummy slurp basing on corpse maxhp
- maybe pulse with AoE effect if ate to more than max hp
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.bonestorm") -- CHANGE storage module

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            slurpCorpse = Ids.abilities.slurpCorpseDummy,
        },
        units = {
            carrier = Ids.units.bonestorm,
        },
    },
    balance = {
        tickSeconds = 0.25,
        radius = 100,
    },
})

local function onTick()
    Storage:each(function(unit)
        local owner = GetOwningPlayer(unit)
        for _, corpse in ipairs(Unit.getCorpsesInRadius(unit, CONFIG.balance.radius)) do
            Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.slurpCorpse, "deathcoil")
            RemoveUnit(corpse)
        end
    end)
end

local function onCreate()
    Storage:add(GetEnteringUnit())
end

local function onDeath()
    Storage:drop(GetDyingUnit())
end

return {
    triggers = {
        {
            trigger = "CREATE",
            filter = { target = CONFIG.refs.units.carrier },
            action = onCreate,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDeath,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.tickSeconds,
            action = onTick,
        },
    },
    config = CONFIG,
}
