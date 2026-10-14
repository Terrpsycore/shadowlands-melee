--[[
TODO:
-- onUnitRemove - clean memory (add trigger type)
-- some visual effect for voidzone
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.twistedPain,
        },
        buffs = {
            main = Ids.buffs.twistedPain,
        },
        units = {},
    },
    balance = {
        duration = 5,
        hits = {
            [1] = 1,
            [2] = 2,
            [3] = 3,
        },
        damagePerTick = {
            [1] = 20,
            [2] = 40,
            [3] = 60,
        },
        radius = 200,
        ticks = 3,
        tickDelta = 1,
        timerDelta = 0.5,
        flushDelta = 1,
    },
})

--- @type table<unit, {level: integer, owner: player, buffApplied: boolean, hits: integer, expiresAt: number}> target->hits
local memory = {} -- TODO: save/load /+/ cleaning
--- @type table<unit, {level: integer, ticks: integer, tickAt: number}> dummy->ticks
local voidzones = {}

--- @param unit unit
local function removeEffect(unit)
    UnitRemoveBuffBJ(CONFIG.refs.buffs.main, unit)
    memory[unit] = nil
end

--- @param info damageInfo
local function onDamage(info)
    if not memory[info.target] then
        return
    end
    if not UnitHasBuffBJ(info.target, CONFIG.refs.buffs.main) then
        return
    end
    if GetElapsedGameTime() > memory[info.target].expiresAt then
        removeEffect(info.target)
        return
    end
    if memory[info.target].hits == 0 then
        removeEffect(info.target)
        return
    end

    memory[info.target].hits = memory[info.target].hits - 1

    local dummy = Dummy.create(memory[info.target].owner, info.target)
    voidzones[dummy] = {
        level = memory[info.target].level,
        owner = memory[info.target].owner,
        ticks = CONFIG.balance.ticks,
        tickAt = GetElapsedGameTime(),
    }
end

local function onSpell()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    memory[target] = {
        level = level,
        owner = GetOwningPlayer(caster),
        buffApplied = false,
        hits = CONFIG.balance.hits[level],
        expiresAt = GetElapsedGameTime() + CONFIG.balance.duration,
    }
end

local function onTimer()
    --- @type table<unit, {dummies: unit[]}>
    local damage = {}
    local now = GetElapsedGameTime()
    for dummy, data in pairs(voidzones) do
        for _, unit in
            ipairs(Unit.getUnitsInRadius(dummy, CONFIG.balance.radius, function(u)
                return not IsUnitAlly(u, data.owner)
            end))
        do
            damage[unit] = damage[unit] or { dummies = {} }
            table.insert(damage[unit].dummies, dummy)
        end
    end
    --
    local ticked = {}
    for target, data in pairs(damage) do
        local damageSource
        for _, dummy in ipairs(damage[target].dummies) do
            local dummyData = voidzones[dummy]
            if damageSource then
                ticked[dummy] = true
                dummyData.ticks = dummyData.ticks - 1
                dummyData.tickAt = now + CONFIG.balance.tickDelta
            elseif now > dummyData.tickAt then
                ticked[dummy] = true
                dummyData.ticks = dummyData.ticks - 1
                dummyData.tickAt = now + CONFIG.balance.tickDelta
                damageSource = dummy
            end
        end
        if damageSource then
            Damage.apply(
                damageSource,
                target,
                CONFIG.balance.damagePerTick[voidzones[damageSource].level],
                false,
                false,
                ATTACK_TYPE_CHAOS
            )
        end
    end
    --
    for dummy, data in pairs(voidzones) do
        if not ticked[dummy] and now > GetElapsedGameTime() then
            data.ticks = data.ticks - 1
            data.tickAt = now + CONFIG.balance.tickDelta
        end
        if data.ticks <= 0 then
            voidzones[dummy] = nil
        end
    end
end

local function onTimerFlush()
    for unit, data in pairs(memory) do
        local buffFound = UnitHasBuffBJ(unit, CONFIG.refs.buffs.main)
        if buffFound and not data.buffApplied then
            data.buffApplied = true
        elseif data.buffApplied and not buffFound then
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
            trigger = "DAMAGE",
            action = onDamage,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.timerDelta,
            action = onTimer,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.flushDelta,
            action = onTimerFlush,
        },
    },
    config = CONFIG,
}
