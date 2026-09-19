--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.forgeboneReveries,
        },
        buffs = {
            main = Ids.buffs.forgeboneReveries,
        },
    },
    balance = {
        flushDelta = 0.2,
    },
})

local memory = {} -- dies after buff fades or not; TODO: save/load

local function onSpell()
    local target = GetSpellTargetUnit()

    memory[target] = true
end

local function onDamage(info)
    if not UnitHasBuffBJ(info.target, CONFIG.refs.buffs.main) then
        return
    end
    local life = GetUnitState(info.target, UNIT_STATE_LIFE)
    if life - info.damage < 1 then
        info.damage = math.max(0, life - 1)
    end
end

local function onLethalDamage(info)
    if memory[info.source] then
        memory[info.source] = false
    end
end

local function onTimer(info)
    local flushQueue = {}
    for i, unit in pairs(memory) do
        if not UnitHasBuffBJ(unit, CONFIG.buffs.main) then
            if memory[info.source] == true then
                Damage.apply(unit, unit, 99999, false, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_ENHANCED)
            end
            table.insert(flushQueue, unit)
        end
    end
    for _, unit in ipairs(flushQueue) do
        memory[unit] = nil
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
            trigger = "DAMAGE",
            action = onDamage,
        },
        {
            trigger = "LETHAL_DAMAGE",
            action = onLethalDamage,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.flushDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
