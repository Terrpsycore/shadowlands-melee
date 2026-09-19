--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.weaponTest,
            selfBuff = Ids.abilities.weaponTestSelfBuff,
            effect = Ids.abilities.weaponTestEffect,
        },
        buffs = {
            main = Ids.buffs.weaponTest,
        },
    },
    balance = { flushDelta = 0.2 },
})

local memory = {} -- TODO: save/load

local function applySelfBuff(unit, level)
    UnitAddAbility(unit, CONFIG.refs.abilities.selfBuff)
    SetUnitAbilityLevel(unit, CONFIG.refs.abilities.selfBuff, level)
    IssueImmediateOrder(unit, "berserk")
    UnitRemoveAbility(unit, CONFIG.refs.abilities.selfBuff)
end

local function onSpell()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    applySelfBuff(caster, level)

    UnitAddAbility(caster, CONFIG.refs.abilities.effect)
    UnitAddAbility(target, CONFIG.refs.abilities.effect)
    SetUnitAbilityLevel(caster, CONFIG.refs.abilities.effect, level)
    SetUnitAbilityLevel(target, CONFIG.refs.abilities.effect, level)

    memory[caster] = level
    memory[target] = level
end

local function onLethalDamage(info)
    if not memory[info.source] or not memory[info.target] then
        return
    end

    applySelfBuff(info.source, memory[info.source])
end

local function onTimer()
    local flushQueue = {}
    for i, unit in ipairs(memory) do
        if not UnitHasBuffBJ(unit, CONFIG.buffs.main) then
            UnitRemoveAbility(unit, CONFIG.refs.abilities.effect)
            table.insert(flushQueue, i)
        end
    end
    for _, index in ipairs(flushQueue) do
        table.remove(memory, index)
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
            trigger = "LETHAL_DAMAGE",
            action = onLethalDamage,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.flushDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
