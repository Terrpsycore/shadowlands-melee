if Debug then
    Debug.beginFile("threateningRoar")
end
-- TODO
-- - UI aura buff to show debuff level
-- - adjust radius numbers

-- ? overlapping debuffs have different fade time

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.corrosivePlague")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.threateningRoar,
            effect = Ids.abilities.threateningRoarEffect,
            ui = Ids.abilities.threateningRoarLevelUI,
        },
        buffs = {
            main = Ids.buffs.threateningRoar,
            ui = Ids.buffs.threateningRoarLevel,
        },
    },
    balance = {
        maxStacks = 3,
        radius = 400,
        flushRate = 0.2,
    },
})

--- @type table<unit,{stacks: integer}>
local memory = {}

local function applyEffect(unit)
    if not memory[unit] then
        memory[unit].stacks = 1
        UnitAddAbility(unit, CONFIG.refs.abilities.effect)
        UnitAddAbility(unit, CONFIG.refs.abilities.ui)
    elseif memory[unit].stacks == CONFIG.balance.maxStacks then
        return
    else
        memory[unit].stacks = math.min(CONFIG.balance.maxStacks, memory[unit].stacks + 1)
        SetUnitAbilityLevel(unit, CONFIG.refs.abilities.effect, memory[unit].stacks)
        SetUnitAbilityLevel(unit, CONFIG.refs.abilities.ui, memory[unit].stacks)
    end
end

local function removeEffect(unit)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.effect)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.ui)
    UnitRemoveBuffBJ(CONFIG.refs.buffs.ui, unit)
    memory[unit] = nil
end

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)

    Timed.call(0.05, function() -- ? review for glitches (debuff applied, effect did not)
        for _, unit in
            ipairs(Unit.getUnitsInRadius(caster, CONFIG.balance.radius, function(u)
                return (not IsUnitAlly(u, owner) and UnitHasBuffBJ(u, CONFIG.refs.buffs.main))
            end))
        do
            applyEffect(unit)
        end
    end)
end

local function onTimerCleanse()
    for unit, _ in pairs(memory) do
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            removeEffect(unit)
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
            delta = CONFIG.balance.flushRate,
            action = onTimerCleanse,
        },
    },
    config = CONFIG,
}
