--[[
TODO:
-- - BUG: multiple heroes apply chains on same unit - memory rewrites, effect bugs
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.opressiveChains,
            slow = Ids.abilities.opressiveChainsSlow,
        },
        buffs = {
            main = Ids.buffs.opressiveChains,
        },
        units = {
            chain = { Ids.units.opressiveChain1, Ids.units.opressiveChain2, Ids.units.opressiveChain3 },
        },
    },
    balance = {
        radius = 300,
        breakDamage = { 100, 200, 300 },
        duration = 8,
        timerDelta = 0.5,
    },
})

--- @type table<unit, {chain: unit, level: integer}>
local memory = {} -- TODO: save/load /+/ cleaning

--- @param unit unit
--- @param level integer
--- @return unit
local function applyEffect(owner, unit, level)
    local dummy = CreateUnit(owner, CONFIG.refs.units.chain[level], GetUnitX(unit), GetUnitY(unit), 270)
    UnitAddType(dummy, UNIT_TYPE_SUMMONED)
    Unit.applyTimedLife(dummy, CONFIG.balance.duration)
    Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.slow, "shadowstrike", level)

    memory[unit] = { level = level, chain = dummy }
    return dummy
end

local function onSpell()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    applyEffect(GetOwningPlayer(caster), target, level)
end

local function onTimer()
    for unit, data in pairs(memory) do
        if Unit.isAlive(data.chain) then
            local d = Unit.distance(unit, data.chain)
            if d > CONFIG.balance.radius then
                Damage.apply(data.chain, unit, CONFIG.balance.breakDamage[data.level], false, false, ATTACK_TYPE_CHAOS)
                memory[unit] = nil
            end
        else
            UnitRemoveBuffBJ(CONFIG.refs.buffs.main, unit)
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
            delta = CONFIG.balance.timerDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
