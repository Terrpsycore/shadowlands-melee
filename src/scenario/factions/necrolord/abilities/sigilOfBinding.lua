--[[
TODO:
- adjust buff duration (should be always same for every stack)
- root shouldn't forbid attacking (write triggered because native roots are not dispellable)
- epicenter mech -> replace with dispell-empowered version
- provoke anti-air dmg+stun event
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.sigilOfBinding,
            empowered = Ids.abilities.sigilOfBindingGreater,
            slow = Ids.abilities.sigilOfBindingSlow,
            stun = Ids.abilities.sigilOfBindingStun,
        },
        buffs = {
            debuff = Ids.buffs.sigilOfBinding,
        },
        units = {
            sigil = Ids.units.sigilOfBinding,
        },
    },
    balance = {
        radius = 150,
        duration = 60,
    },
})

local memory = {}
local queue = {} -- list
local queued = {} -- map

local spawnQueue = {}

local function onSpell()
    -- note: can be rewritten to "onSpawn" trigger
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)

    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)
    spawnQueue[owner] = { level = level, caster = caster }
end

local function onSpawn()
    -- note: can be rewritten to "onSpawn" trigger
    local sigil = GetEnteringUnit()
    local owner = GetOwningPlayer(sigil)

    local data = spawnQueue[owner]
    spawnQueue[owner] = nil

    Unit.applyTimedLife(sigil, CONFIG.balance.duration)
    -- SetUnitAbilityLevel(sigil, CONFIG.refs.abilities.activation, data.level)
end

local function onDeath(info)
    local sigil = GetDyingUnit()
    local owner = GetOwningPlayer(sigil)

    local epicenterTargets = Unit.getUnitsInRadius(sigil, CONFIG.balance.radius / 2, function(u)
        return IsUnitAliveBJ(u) and IsUnitEnemy(u, owner)
    end)
    local targets = Unit.getUnitsInRadius(sigil, CONFIG.balance.radius, function(u)
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
            memory[target] = { stacks = stacks, debuffApplied = false, propWindow = GetUnitPropWindow(target) }
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

local function onTimerSigil()
    for i = #queue, 1, -1 do
        local target = queue[i]
        local data = memory[target]
        if data then
            local r, g, b = 0, 255, 0
            local text = CreateTextTagUnitBJ(string.format("%.0f!", data.stacks), target, 0, 10, r, g, b, 0)
            SetTextTagVelocityBJ(text, 64, 90)
            SetTextTagPermanent(text, false)
            SetTextTagLifespan(text, 2.0)
            SetTextTagFadepoint(text, 1.5)

            Dummy.applyDummyOrder(queued[target], target, CONFIG.refs.abilities.slow, "slow")
            if data.stacks == 2 then
                SetUnitPropWindow(target, 0)
            end
            if data.stacks == 3 then
                Dummy.applyDummyOrder(queued[target], target, CONFIG.refs.abilities.stun, "thunderbolt")
            end
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
        SetUnitPropWindow(unit, memory[unit].propWindow)
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
            trigger = "CREATE",
            filter = { target = CONFIG.refs.units.sigil },
            action = onSpawn,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = { CONFIG.refs.abilities.slow, CONFIG.refs.abilities.root, CONFIG.refs.abilities.stun },
            action = onDummyDisable,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.sigil },
            action = onDeath,
        },
        {
            trigger = "TIMER",
            delta = 0.15,
            action = onTimerSigil,
        },
        {
            trigger = "TIMER",
            delta = 0.15,
            action = onTimerFlush,
        },
    },
    config = CONFIG,
}
