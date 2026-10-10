--[[
TODO:
-- ! passive DMG effect update
-- aura buff or info passive to show current soul count
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Souls = require("scenario.factions.mawsworn.mechanics.souls")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            toggle = Ids.abilities.soulRend,
            damage = Ids.abilities.soulRendDamage,
            heal = Ids.abilities.soulRendHeal,
        },
    },
    balance = {
        duration = 2,
        cooldown = 1,
        maxSouls = { 3, 6, 9 },
        timerDelta = 0.5,
    },
})

--- @type table<unit, {toggle: boolean, nextHealAt: number|nil, lastHitTo: unit|nil, lastHitAt: number|nil}>
local memory = {}
--- @type table<unit, unit>
local targetToMourneblade = {}

local function updateDamageEffect(unit)
    local level = Souls.api.count("unit", unit)
    if level == 0 then
        UnitRemoveAbility(unit, CONFIG.refs.abilities.damage)
    else
        local currentEffectLevel = GetUnitAbilityLevel(unit, CONFIG.refs.abilities.damage)
        if currentEffectLevel == 0 then
            UnitAddAbility(unit, CONFIG.refs.abilities.damage)
        end
        SetUnitAbilityLevel(unit, CONFIG.refs.abilities.damage, level)
    end
end

local function stopEffect(unit)
    IssueImmediateOrder(unit, "unimmolation")
    memory[unit].toggle = false
end

local function applyEffect(unit)
    local now = GetElapsedGameTime()

    memory[unit].toggle = true

    if not Souls.api.count("unit", unit) then
        dump("soulRend toggle error - no souls available")
        stopEffect(unit)
        return
    end

    if now < memory[unit].nextHealAt then
        return
    end

    if not Souls.api.use("unit", unit, 1) then
        stopEffect(unit)
        return
    end

    updateDamageEffect(unit)

    local owner = GetOwningPlayer(unit)
    Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.heal, "heal")

    memory[unit].nextHealAt = now + CONFIG.balance.cooldown
end

local function onTurnOn()
    dump("mawcaster onspell")
    local caster = GetTriggerUnit()

    applyEffect(caster)
end

local function onTurnOff()
    local caster = GetTriggerUnit()
    stopEffect(caster)
end

--- @param info damageInfo
local function onDamage(info)
    local source = info.source
    local target = info.target

    if not memory[source] then
        memory[source] = { toggle = false }
    end
    if memory[source].lastHitTo and memory[source].lastHitTo ~= target then
        targetToMourneblade[memory[source].lastHitTo] = nil
        memory[source].lastHitTo = target
        memory[source].lastHitAt = GetElapsedGameTime()
    end
    targetToMourneblade[target] = source
end

local function onDeath()
    local unit = GetDyingUnit()
    local source = targetToMourneblade[unit]
    if source and GetElapsedGameTime() < (memory[source].lastHitAt + CONFIG.balance.duration) then
        local level = GetUnitAbilityLevel(source, CONFIG.refs.abilities.main)
        if Souls.api.count("unit", source) <= CONFIG.balance.maxSouls[level] then
            Souls.api.store("unit", source)
        end
        updateDamageEffect(source)
    end
end

local function onTimer()
    for mourneblade, data in pairs(memory) do
        dump("onTimer", GetElapsedGameTime(), data)
        if data.nextHealAt and GetElapsedGameTime() > data.nextHealAt then
            applyEffect(mourneblade)
        end
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.toggle,
            action = onTurnOn,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "unimmolation",
            action = onTurnOff,
        },
        {
            trigger = "DAMAGE",
            filter = { source = CONFIG.refs.units.carrier },
            action = onDamage,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            action = onDeath,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.timerDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
