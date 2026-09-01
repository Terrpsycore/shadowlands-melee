-- TODO:
-- - check dispell

local Ids = require("data.ids")
local GetElapsedGameTime = require("scenario.common.timer")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local Storage = require("scenario.storage.oneMoreChance")

local CONFIG = {
    -- radius = 600,
    duration = 5, -- real duration + delta
    -- cooldown = 5,

    abilityId = FourCC(Ids.abilities.oneMoreChance),

    dummyBuffAbilityId = FourCC(Ids.abilities.oneMoreChanceBuffDummy),
    buffId = FourCC(Ids.buffs.oneMoreChance),

    crossAbilityId = FourCC(Ids.abilities.oneMoreChanceCross),
    reincarnationCheckAbilityId = FourCC(Ids.abilities.reincarnationCheck),

    dummyHealAbilityId = FourCC(Ids.abilities.oneMoreChanceHealDummy),
    -- requiredUpgradeId = nil,
}

local function removeEffect(unit)
    UnitRemoveAbility(unit, CONFIG.crossAbilityId)
    UnitRemoveAbility(unit, CONFIG.reincarnationCheckAbilityId)
    UnitRemoveBuffBJ(CONFIG.buffId, unit)
end

local function onSpell()
    -- dump("oneMoreChance onSpell")
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    Dummy.applyDummyOrder(
        GetOwningPlayer(caster),
        target,
        CONFIG.dummyBuffAbilityId,
        "innerfire",
        GetUnitAbilityLevel(caster, CONFIG.dummyBuffAbilityId)
    )
end

local function onDummyBuff()
    -- dump("oneMoreChance onDummyBuff")
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    Storage:set(target, "abilityLevel", GetUnitAbilityLevel(caster, CONFIG.dummyBuffAbilityId))
    Storage:set(target, "buffedAt", GetElapsedGameTime())
    UnitAddAbility(target, CONFIG.crossAbilityId)
    UnitAddAbility(target, CONFIG.reincarnationCheckAbilityId)
end

local function onDummyHeal()
    -- dump("oneMoreChance onDummyHeal")
    local target = GetSpellTargetUnit()
    Storage:clear(target)
end

local function onReincarnate()
    -- dump("oneMoreChance onReincarnate", OrderId2String(GetIssuedOrderId()))
    local unit = GetOrderedUnit()
    if not GetUnitAbilityLevel(unit, CONFIG.crossAbilityId) then
        -- dump("oneMoreChance onReincarnate break - no ankh ability")
        return
    end
    if GetUnitState(unit, UNIT_STATE_LIFE) >= 0.01 then
        -- dump("oneMoreChance onReincarnate break - not dead")
        return
    end
    if Storage:have(unit) then
        -- dump("oneMoreChance onReincarnate remove effect")
        removeEffect(unit)
        Storage:clear(unit)
    end
end

local function onTimer()
    Storage:forEach(function(unit)
        if Storage:get(unit, "expired") then
            return
        end
        if not UnitHasBuffBJ(unit, CONFIG.buffId) then
            -- dump("oneMoreChance onTimer not UnitHasBuffBJ")
            removeEffect(unit)
            Storage:clear(unit)
            return
        end
        local expireTime = Storage:get(unit, "buffedAt") + (CONFIG.duration - 0.1)
        if expireTime <= GetElapsedGameTime() then
            -- dump("oneMoreChance onTimer expired:", expireTime, GetElapsedGameTime())
            removeEffect(unit)
            Dummy.applyDummyOrder(
                GetOwningPlayer(unit),
                unit,
                CONFIG.dummyHealAbilityId,
                "holybolt",
                Storage:get(unit, "abilityLevel")
            )
            Storage:set(unit, "expired", true)
        end
    end)
    -- body
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.abilityId,
            action = onSpell,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.dummyBuffAbilityId,
            action = onDummyBuff,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.dummyHealAbilityId,
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
