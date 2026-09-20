--[[

]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.sigilOfBinding,
            slow = Ids.abilities.sigilOfBindingSlow,
            root = Ids.abilities.sigilOfBindingRoot,
            stun = Ids.abilities.sigilOfBindingStun,
        },
        buffs = {
            debuff = Ids.buffs.sigilOfBinding,
        },
        units = {
            trap = Ids.units.sigilOfBinding,
        },
    },
    balance = {
        radius = 150,
    },
})

local memory = {}
local queue = {} -- list
local queued = {} -- map

local function onDeath(info)
    local trap = GetDyingUnit()
    local owner = GetOwningPlayer(trap)

    local epicenterTargets = Unit.getUnitsInRadius(trap, CONFIG.balance.radius / 2, function(u)
        return IsUnitAliveBJ(u) and IsUnitEnemy(u, owner)
    end)
    local targets = Unit.getUnitsInRadius(trap, CONFIG.balance.radius, function(u)
        return IsUnitAliveBJ(u) and IsUnitEnemy(u, owner)
    end)

    local processed = {}
    for _, target in ipairs(epicenterTargets) do
        processed[target] = 2
        -- Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.debuff, "shadowstrike")
    end
    for _, target in ipairs(targets) do
        if not processed[target] then
            processed[target] = 1
            -- Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.debuff, "shadowstrike")
        end
    end

    for target, stacks in pairs(processed) do
        if memory[target] then
            memory[target].stacks = math.min(memory[target].stacks + stacks, 3)
        else
            memory[target] = { stacks = stacks, debuffApplied = false }
        end
        if not queued[target] then
            table.insert(queue, target)
        end
        queued[target] = owner
    end
end

local function onDummyDisable()
    local target = GetSpellTargetUnit()
    local data = memory[target]
    if data then
        data.debuffApplied = true
    end
end

local function onTimerTrap()
    local spellData = {
        [1] = CONFIG.refs.abilities.slow,
        [2] = CONFIG.refs.abilities.root,
        [3] = CONFIG.refs.abilities.stun,
    }
    for i = #queue, 1, -1 do
        local target = queue[i]
        local data = memory[target]
        if data then
            Dummy.applyDummyOrder(queued[target], target, spellData[data.stacks], "channel")
        end
        queued[target] = nil
        table.remove(queue, i)
    end
end

local function onTimerFlush()
    local flush = {}
    for unit, data in pairs(memory) do
        if data.debuffApplied and not UnitHasBuffBJ(unit, CONFIG.refs.buffs.debuff) then
            table.insert(flush, unit)
        end
    end
    for _, unit in ipairs(flush) do
        memory[unit] = nil
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = { CONFIG.refs.abilities.slow, CONFIG.refs.abilities.root, CONFIG.refs.abilities.stun },
            action = onDummyDisable,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.trap },
            action = onDeath,
        },
        {
            trigger = "TIMER",
            delta = 0.15,
            action = onTimerTrap,
        },
        {
            trigger = "TIMER",
            delta = 0.15,
            action = onTimerFlush,
        },
    },
    config = CONFIG,
}
