-- TODO
-- - test dispell removes both buffs
local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local Storage = require("scenario.storage.dedication")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.dedication,
            damageBuff = Ids.abilities.dedicationDamageBuff,
            attackSpeed = Ids.abilities.dedicationAttackSpeedBuff,
        },
        buffs = {
            main = Ids.buffs.dedication,
        },
    },
})

local function removeDedicationEffect(unit)
    UnitRemoveBuffBJ(CONFIG.refs.buffs.main, unit)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.attackSpeed)
    Storage:clear(unit)
end

local function onDedicationCast()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()

    Dummy.applyDummyOrder(GetOwningPlayer(caster), target, CONFIG.refs.abilities.damageBuff, "innerfire")
end

local function onDummyCast()
    local unit = GetSpellTargetUnit()

    UnitAddAbility(unit, CONFIG.refs.abilities.attackSpeed)

    Storage:set(unit, "target", nil)
end

local function onAttack()
    local unit = GetAttacker()
    local target = GetTriggerUnit()

    if not Storage:have(unit) then
        return
    elseif Storage:get(unit, "target") == nil then
        Storage:set(unit, "target", target)
    elseif target ~= Storage:get(unit, "target") then
        removeDedicationEffect(unit)
    end
end

local function onFrame()
    Storage:forEach(function(unit)
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            removeDedicationEffect(unit)
        end
    end)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onDedicationCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.damageBuff,
            action = onDummyCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ATTACKED",
            action = onAttack,
        },
        {
            trigger = "TIMER",
            delta = 0.03,
            action = onFrame,
        },
    },
    config = CONFIG,
}
