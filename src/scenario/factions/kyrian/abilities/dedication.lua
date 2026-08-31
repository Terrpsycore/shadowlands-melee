-- TODO
-- - test dispell removes both buffs
local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local Storage = require("scenario.storage.dedication")

local CONFIG = {
    abilityId = FourCC(Ids.abilities.dedication),

    adBuffAbilityId = FourCC(Ids.abilities.dedicationDamageBuff),
    adBuffId = FourCC(Ids.buffs.dedication),

    asAbilityId = FourCC(Ids.abilities.dedicationAttackSpeedBuff),
}

local function removeDedicationEffect(unit)
    -- print("removeDedicationEffect")
    UnitRemoveBuffBJ(CONFIG.adBuffId, unit)
    UnitRemoveAbility(unit, CONFIG.asAbilityId)
    Storage:clear(unit)
end

local function onDedicationCast()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()

    Dummy.applyDummyOrder(GetOwningPlayer(caster), target, CONFIG.adBuffAbilityId, "innerfire")
end

local function onDummyCast()
    local unit = GetSpellTargetUnit()

    UnitAddAbility(unit, CONFIG.asAbilityId)

    Storage:set(unit, "target", nil)
end

local function onAttack()
    local unit = GetAttacker()
    local target = GetTriggerUnit()

    -- dump("Dedication onAttack", Storage:get(unit, "target"), target)

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
        if not UnitHasBuffBJ(unit, CONFIG.adBuffId) then
            removeDedicationEffect(unit)
        end
    end)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.abilityId,
            action = onDedicationCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.adBuffAbilityId,
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
