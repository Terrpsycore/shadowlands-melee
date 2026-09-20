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
            dummy = Ids.abilities.weaponTestDummy,
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
    dump("weaponTest spell finish")
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.dummy, "acidbomb", level)
    applySelfBuff(caster, level)

    Timed.call(0.2, function()
        UnitAddAbility(caster, CONFIG.refs.abilities.effect)
        UnitAddAbility(target, CONFIG.refs.abilities.effect)
        SetUnitAbilityLevel(caster, CONFIG.refs.abilities.effect, level)
        SetUnitAbilityLevel(target, CONFIG.refs.abilities.effect, level)
        memory[caster] = level
        memory[target] = level
        dump("weaponTest has buff caster", UnitHasBuffBJ(caster, CONFIG.refs.buffs.main))
        dump("weaponTest has buff target", UnitHasBuffBJ(target, CONFIG.refs.buffs.main))
    end)
end

local function onLethalDamage(info)
    if not memory[info.source] or not memory[info.target] then
        return
    end

    applySelfBuff(info.source, memory[info.source])
end

local function onTimer()
    local flushQueue = {}
    for unit, _ in pairs(memory) do
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            UnitRemoveAbility(unit, CONFIG.refs.abilities.effect)
            table.insert(flushQueue, unit)
        end
    end
    for _, unit in ipairs(flushQueue) do
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
