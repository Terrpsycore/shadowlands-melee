--[[
TODO:
-- check reapply after attack / spell cast
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.wraithWalk,
            phase = Ids.abilities.wraithWalkPhase,
            aura = Ids.abilities.wraithWalkSlow,
        },
        buffs = {
            main = Ids.buffs.wraithWalk,
        },
        units = {
            carrier = Ids.units.mournebladeHero,
        },
    },
    balance = {
        duration = { 4, 6, 8 },
        timerDelta = 0.5,
    },
})

--- @type table<unit, {expiresAt: number, level: integer}>
local memory = {} -- TODO: save/load

local function applyEffect(unit, level)
    -- apply/reapply phase
    UnitAddAbility(unit, CONFIG.refs.abilities.phase)
    SetUnitAbilityLevel(unit, CONFIG.refs.abilities.phase, level)
    IssueImmediateOrder(unit, "windwalk")
    UnitRemoveAbility(unit, CONFIG.refs.abilities.phase)

    if not memory[unit] then
        UnitAddAbility(unit, CONFIG.refs.abilities.aura)
        SetUnitAbilityLevel(unit, CONFIG.refs.abilities.aura, level)
        memory[unit] = { expiresAt = GetElapsedGameTime() + CONFIG.balance.duration[level], level = level }
    end
end

local function removeEffect(unit, level)
    UnitRemoveBuffBJ(CONFIG.refs.buffs.main, unit)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.aura)
    memory[unit] = nil
end

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    applyEffect(caster, level)
end

local function onTimer()
    for unit, data in pairs(memory) do
        if GetElapsedGameTime() > data.expiresAt then
            removeEffect(unit)
        elseif not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            applyEffect(unit, data.level)
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
