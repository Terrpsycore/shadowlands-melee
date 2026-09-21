--[[
TODO:
- grey floating text with decreased damage
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.moldWeakness,
            debuff = Ids.abilities.moldWeaknessDebuff,
        },
        buffs = {
            aim = Ids.buffs.moldWeaknessAim,
            debuff = Ids.buffs.moldWeakness,
        },
    },
    balance = {
        damageDecrease = { 0.3, 0.6, 1 },
        flushDelta = 1,
        duration = 8,
    },
})

local memory = {} -- todo: save/load persistence
local debuffed = {} -- todo: save/load persistence

local function onSpell()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    local spell = GetSpellAbilityId()
    local level = GetUnitAbilityLevel(caster, spell)
    memory[target] = level
end

local function onDummySpell()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    local spell = GetSpellAbilityId()
    local level = GetUnitAbilityLevel(caster, spell)
    memory[target] = level

    debuffed[target] = level
end

local function onDamage(info)
    if not info.isAttack then
        return
    end
    if UnitHasBuffBJ(info.target, CONFIG.refs.buffs.aim) then
        local owner = GetOwningPlayer(info.source)
        local level = memory[info.target]
        UnitRemoveBuffBJ(CONFIG.refs.buffs.aim, info.target)

        Dummy.applyDummyOrder(owner, info.target, CONFIG.refs.abilities.debuff, "acidbomb", level)
        memory[info.target] = nil
    end
    if UnitHasBuffBJ(info.source, CONFIG.refs.buffs.debuff) then
        local decrease = CONFIG.balance.damageDecrease[debuffed[info.source]]
        info.damage = info.damage - (info.damage * decrease)
    end
end

local function onTimer()
    local flushQueue = {}
    for unit, _ in pairs(debuffed) do
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.debuff) then
            table.insert(flushQueue, unit)
        end
    end
    for _, unit in ipairs(flushQueue) do
        debuffed[unit] = nil
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
            spellId = CONFIG.refs.abilities.debuff,
            action = onDummySpell,
        },
        {
            trigger = "DAMAGE",
            action = onDamage,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.flushDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
