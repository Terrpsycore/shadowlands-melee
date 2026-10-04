--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.accursedStrength,
            effectDamage = Ids.abilities.accursedStrengthDamage,
            effectSplash = Ids.abilities.accursedStrengthSplash,
        },
        buffs = {
            main = Ids.buffs.accursedStrength,
        },
        units = {
            carrier = { Ids.units.vanguard },
        },
    },
    balance = {
        timerDelta = 0.5,
    },
})

--- @type table<unit, boolean>
local memory = {} -- TODO: save/load

local function onSpell()
    local caster = GetTriggerUnit()

    UnitAddAbility(caster, CONFIG.refs.abilities.effectDamage)
    UnitAddAbility(caster, CONFIG.refs.abilities.effectSplash)

    table.insert(memory, caster)
end

--- @param info damageInfo
local function onAfterDamage(info)
    if not info.isAttack then
        return
    end
    if GetUnitAbilityLevel(info.source, CONFIG.refs.abilities.effectDamage) > 0 then
        UnitRemoveAbility(info.source, CONFIG.refs.abilities.effectDamage)
        UnitRemoveAbility(info.source, CONFIG.refs.abilities.effectSplash)
    end
end

local function onTimer()
    local flushQueue = {}
    for _, unit in ipairs(memory) do
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            table.insert(flushQueue, unit)
        end
    end
    for _, unit in ipairs(flushQueue) do
        flushQueue[unit] = nil
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell, -- ? cast start
        },
        {
            trigger = "AFTER_DAMAGE",
            filter = { source = CONFIG.refs.units.carrier },
            action = onAfterDamage, -- ? cast start
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.timerDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
