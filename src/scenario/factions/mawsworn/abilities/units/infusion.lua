-- - ? AoE dmg on unit detonate
-- - test: multiple infusers on same target
local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.infusion,
            buff = Ids.abilities.infusionBuff,
            uiAura = Ids.abilities.infusionUI,
            effect = Ids.abilities.infusionEffect,
        },
        buffs = {
            main = Ids.buffs.infusion,
            ui = Ids.buffs.infusionEffect,
        },
    },
    balance = {
        maxStacks = 5,
        damageBase = 3.5, -- 3, 12, 42, 150, 525
        tickRate = 0.25,
        stacksDelta = 1,
    },
})

--- @type table<unit, {stacks: integer, untilStack: number}>
local memory = {}
--- @type table<unit, unit>
local channels = {}

local function applyEffect(source, unit)
    local data = memory[unit]
    if data.stacks == 0 then
        UnitAddAbility(unit, CONFIG.refs.abilities.uiAura)
        UnitAddAbility(unit, CONFIG.refs.abilities.effect)
    end
    data.stacks = math.min(CONFIG.balance.maxStacks, data.stacks + 1)
    SetUnitAbilityLevel(unit, CONFIG.refs.abilities.effect, data.stacks)

    Damage.apply(
        source,
        unit,
        CONFIG.balance.damageBase ^ data.stacks,
        false,
        false,
        ATTACK_TYPE_CHAOS,
        DAMAGE_TYPE_FIRE
    )
end

local function removeEffect(unit)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.uiAura)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.effect)
    UnitRemoveBuffBJ(CONFIG.refs.buffs.ui, unit)
end

local function onCast()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    channels[caster] = target
    memory[target] = {
        stacks = 0,
        untilStack = CONFIG.balance.stacksDelta,
    }

    Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.buff, "innerfire")
end

local function onBuff()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    applyEffect(caster, target)
end

local function onEndCast()
    local caster = GetTriggerUnit()
    channels[caster] = nil
end

local function onTimer()
    for caster, target in pairs(channels) do
        local owner = GetOwningPlayer(caster)
        local targetData = memory[target]
        targetData.untilStack = math.max(0, targetData.untilStack - CONFIG.balance.tickRate)
        if targetData.untilStack == 0 then
            targetData.untilStack = CONFIG.balance.stacksDelta
            Dummy.applyPoint(owner, target, CONFIG.refs.abilities.buff, "innerfire")
        end
    end
end

local function onTimerFlush()
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
            action = onCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.buff,
            action = onBuff,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_ENDCAST",
            spellId = CONFIG.refs.abilities.main,
            action = onEndCast,
        },
        { trigger = "TIMER", delta = CONFIG.balance.tickRate, action = onTimer },
    },
    config = CONFIG,
}
