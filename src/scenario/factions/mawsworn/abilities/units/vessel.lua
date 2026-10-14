--[[
TODO:
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local DispellMeter = require("scenario.common.mechanics.dispellMeter")
local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.vessel,
            dummy = Ids.abilities.vesselDispell,
        },
        buffs = {},
        units = {
            vessel = Ids.units.vessel,
        },
    },
    balance = {
        radius = 200,
        timerDelta = 0.25,
        pulseDelta = 1,
    },
})

--- @type table<unit, {owner: player, charges: integer, untilPulse: number}>
local memory = {} -- TODO: save/load

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local x = GetSpellTargetX()
    local y = GetSpellTargetY()

    DispellMeter.api.count(
        owner,
        { ability = CONFIG.refs.abilities.dummyDispell, target = { x = x, y = y } },
        { unit = { mp = 1 } },
        --- @param result dispellMeterResult
        function(result)
            dump("dispellMeterResult", result)
            if result.unit and result.unit > 0 then
                ---@diagnostic disable-next-line: param-type-mismatch
                local vessel = CreateUnit(owner, CONFIG.refs.units.vessel, x, y, 270)
                Unit.applyTimedLife(vessel, 10)
                memory[vessel] = {
                    owner = owner,
                    charges = math.min(10, result.unit),
                    untilPulse = CONFIG.balance.pulseDelta,
                }
            end
        end
    )
end

local function onTimer()
    local flushQueue = {}
    for vessel, data in pairs(memory) do
        data.untilPulse = math.max(0, data.untilPulse - CONFIG.balance.timerDelta)
        if data.untilPulse <= 0 then
            data.untilPulse = CONFIG.balance.pulseDelta
            for _, target in
                ipairs(Unit.getUnitsInRadius(vessel, CONFIG.balance.radius, function(t)
                    return not IsUnitAlly(t, data.owner) -- TODO and not structure, and not mechanical
                end))
            do
                data.charges = data.charges - 1
                WS.api.applyWeakenedSoulStack(target, 1, data.owner)
                if data.charges == 0 then
                    KillUnit(vessel)
                end
            end
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
            delta = CONFIG.balance.timerDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
