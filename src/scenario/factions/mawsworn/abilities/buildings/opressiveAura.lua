--[[
TODO:
- on building upgrade -> ..
- carrier -> T2, T3
- TMP hardcoded T1
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        units = {
            carrier = { Ids.units.mawswornMain, Ids.units.mawswornMain, Ids.units.mawswornMain },
        },
    },
    balance = {
        radius = 800,
        timerRate = 0.25,
        tickRate = { 1.5, 1.25, 1 },
    },
})

--- @type table<unit, {owner: player, tech: integer, pulseRate: number, beforePulse: number}>
local memory = {}

local function onTimer()
    dump("opressiveAura onTimer")
    for unit, data in pairs(memory) do
        local owner = data.owner
        data.beforePulse = data.beforePulse - CONFIG.balance.timerRate
        dump("opressiveAura onTimer", unit, data.beforePulse)
        if data.beforePulse <= 0 then
            data.beforePulse = data.pulseRate
            for _, u in
                ipairs(Unit.getUnitsInRadius(unit, CONFIG.balance.radius, function(x)
                    return not IsUnitAlly(x, owner) -- TODO and not structure, and not mechanical
                end))
            do
                WS.api.applyWeakenedSoulStack(u, 1, owner)
            end
        end
    end
end

local function onCreate()
    local building = GetConstructedStructure()
    local buildingTypeId = GetUnitTypeId(building)

    local tech = Generic.index(CONFIG.balance.tickRate, buildingTypeId)

    memory[building] = {
        owner = GetOwningPlayer(building),
        tech = tech,
        pulseRate = CONFIG.balance.tickRate[tech],
        beforePulse = CONFIG.balance.tickRate[tech],
    }
end

local function onDeath()
    memory[GetDyingUnit()] = nil
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_CONSTRUCT_FINISH",
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
            delta = CONFIG.balance.timerRate,
            action = onTimer,
        },
    },
    config = CONFIG,
}
