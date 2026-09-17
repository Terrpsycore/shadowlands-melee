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
            place = Ids.abilities.sigilOfBindingPlaceDummy,
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

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()

    Dummy.applyDummyPointOrder(owner, { x = targetX, y = targetY }, CONFIG.refs.abilities.place, "channel")
end

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

    for target, stacks in ipairs(processed) do
        if memory[target] then
            memory[target] = math.min(memory[target] + stacks, 3)
        else
            memory[target] = stacks
        end
        if not queued[target] then
            table.insert(queue, target)
        end
        queued[target] = owner
    end
end

local function onDummyDisable()
    local target = GetSpellTargetUnit()
    memory[target].debuffApplied = true
end

local function onTimerTrap()
    local spellData = {
        [1] = CONFIG.refs.abilities.slow,
        [2] = CONFIG.refs.abilities.root,
        [3] = CONFIG.refs.abilities.stun,
    }
    local flush = {} -- targets
    for i, target in ipairs(queue) do
        Dummy.applyDummyOrder(queued[target], target, spellData[memory[target]], "channel")
        table.insert(flush, { index = i, target = target })
    end
    for _, targetData in ipairs(flush) do
        local index = targetData.index
        local target = targetData.target
        queued[target] = nil
        table.remove(queue, index)
    end
end

local function onTimerFlush()
    local flush = {}
    for unit, data in pairs(memory) do
        if data.debuffApplied and not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
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
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
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
