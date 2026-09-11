-- TODO:
-- - check dispell

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local GetElapsedGameTime = require("scenario.common.timer")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local Storage = require("scenario.storage.oneMoreChance")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.oneMoreChance,
            buffDummy = Ids.abilities.oneMoreChanceBuffDummy,
            cross = Ids.abilities.oneMoreChanceCross,
            reincarnationCheck = Ids.abilities.reincarnationCheck,
            healDummy = Ids.abilities.oneMoreChanceHealDummy,
        },
        buffs = {
            main = Ids.buffs.oneMoreChance,
        },
    },
    balance = {
        duration = 5, -- real duration + delta
    },
})

local function removeEffect(unit)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.cross)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.reincarnationCheck)
    UnitRemoveBuffBJ(CONFIG.refs.buffs.main, unit)
end

local function onSpell()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    Dummy.applyDummyOrder(
        GetOwningPlayer(caster),
        target,
        CONFIG.refs.abilities.buffDummy,
        "innerfire",
        GetUnitAbilityLevel(caster, CONFIG.refs.abilities.buffDummy)
    )
end

local function onDummyBuff()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    Storage:set(target, "abilityLevel", GetUnitAbilityLevel(caster, CONFIG.refs.abilities.buffDummy))
    Storage:set(target, "buffedAt", GetElapsedGameTime())
    UnitAddAbility(target, CONFIG.refs.abilities.cross)
    UnitAddAbility(target, CONFIG.refs.abilities.reincarnationCheck)
end

local function onDummyHeal()
    local target = GetSpellTargetUnit()
    Storage:drop(target)
end

local function onReincarnate()
    local unit = GetOrderedUnit()
    if not GetUnitAbilityLevel(unit, CONFIG.refs.abilities.cross) then
        return
    end
    if GetUnitState(unit, UNIT_STATE_LIFE) >= 0.01 then
        return
    end
    if Storage:has(unit) then
        removeEffect(unit)
        Storage:drop(unit)
    end
end

local function onTimer()
    Storage:each(function(unit)
        if Storage:get(unit, "expired") then
            return
        end
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            removeEffect(unit)
            Storage:drop(unit)
            return
        end
        local expireTime = Storage:get(unit, "buffedAt") + (CONFIG.balance.duration - 0.1)
        if expireTime <= GetElapsedGameTime() then
            removeEffect(unit)
            Dummy.applyDummyOrder(
                GetOwningPlayer(unit),
                unit,
                CONFIG.refs.abilities.healDummy,
                "holybolt",
                Storage:get(unit, "abilityLevel")
            )
            Storage:set(unit, "expired", true)
        end
    end)
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
            spellId = CONFIG.refs.abilities.buffDummy,
            action = onDummyBuff,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.healDummy,
            action = onDummyHeal,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "undefend", -- https://www.hiveworkshop.com/threads/reincarnation-summon.370049/
            action = onReincarnate,
        },
        {
            trigger = "TIMER",
            delta = 0.03,
            action = onTimer,
        },
    },
    config = CONFIG,
}
