--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.corrosivePlague")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.calcify,
            slow = Ids.abilities.calcifySlow,
            stun = Ids.abilities.calcifyStun,
        },
        buffs = {
            main = Ids.buffs.calcify,
            slow = Ids.buffs.calcifySlow,
        },
    },
    balance = {
        spreadRadius = 64,
        pulseRate = 1,
        timerDelta = 0.34,
        maxStacks = 3,
    },
})

--- @type table<unit, {owner: player, charges: integer, untilPulse: number}>
local memory = {} -- actively pulsing
--- @type table<unit, {stacks: integer, debuffApplied: boolean}>
local debuffed = {} -- debuff stacks

local function applyEffect(unit, owner)
    if not debuffed[unit] then
        debuffed[unit] = { stacks = 0, debuffApplied = false }
    end
    debuffed[unit].stacks = math.min(CONFIG.balance.maxStacks, debuffed[unit].stacks + 1)

    local stacks = debuffed[unit].stacks
    Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.slow, "slow", math.min(2, stacks))
    if stacks == 3 then
        Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.stun, "thunderbolt")
    end
end

local function onSlow()
    local target = GetSpellTargetUnit()

    debuffed[target].debuffApplied = true
end

local function onSpell()
    local owner = GetOwningPlayer(GetTriggerUnit())
    local target = GetSpellTargetUnit()

    memory[target] = {
        owner = owner, -- WARNING: multiple players casts will overwrite
        charges = 2,
        untilPulse = CONFIG.balance.pulseRate,
    }
end

local function onTimer()
    for target, data in pairs(memory) do
        if not UnitHasBuffBJ(target, CONFIG.refs.buffs.main) then
            memory[target] = nil
            goto continue
        end

        data.untilPulse = data.untilPulse - CONFIG.balance.timerDelta
        if data.untilPulse <= 0 then
            data.untilPulse = data.untilPulse + CONFIG.balance.pulseRate
            data.charges = data.charges - 1
            if data.charges == 0 then
                memory[target] = nil
            end
        end

        local neighbours = Unit.getUnitsInRadius(target, CONFIG.balance.spreadRadius * 2, function(x)
            return not IsUnitAlly(x, data.owner)
        end)
        for _, u in ipairs(neighbours) do
            applyEffect(u, data.owner)
        end
        if #neighbours == 0 then
            --
        end
        ::continue::
    end
end

local function onTimerFlush()
    for target, data in pairs(debuffed) do
        if not UnitHasBuffBJ(target, CONFIG.refs.buffs.slow) then
            debuffed[target] = nil
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
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.slow,
            action = onSlow,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.timerDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
