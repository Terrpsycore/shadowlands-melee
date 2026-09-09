-- TODO:
-- - use conditions
local Storage = require("lib.storage.storage")
local Filter = require("lib.triggers.filter")

local Disable = Storage.unitFields("disable", {
    rooted = "bool",
    stunned = "bool",
})

local T = {
    callbacks = {},
    buffs = {
        root = {},
        stun = {},
    },
}

T.registerEvents = function(callbacks)
    for event, triggers in pairs(callbacks) do
        T.methods[event](triggers)
    end
end

---@param event string
---@param callbackOptions TriggerDefinition
T.registerCallback = function(event, callbackOptions)
    Filter.compileTrigger(callbackOptions)
    if T.callbacks[event] == nil then
        T.callbacks[event] = {}
    end
    table.insert(T.callbacks[event], callbackOptions)
end

T.registerBuffs = function(tag, buffs)
    T.buffs[tag] = buffs
end

T.fireEvent = function(event, data)
    local callbacks = T.callbacks[event]
    if not callbacks then
        return
    end
    for _, callback in ipairs(callbacks) do
        callback.action(data)
    end
end

T.onStun = function(_triggers)
    Damage.register("After", function(info)
        local unit = info.target

        if not Disable:get(unit, "stunned") then
            for _, v in ipairs(T.buffs.stun) do
                if UnitHasBuffBJ(unit, FourCC(v)) then
                    T.fireEvent("STUN", info)
                    Disable:set(unit, "stunned", true)
                    break
                end
            end
        end

        if not Disable:get(unit, "rooted") and not Disable:get(unit, "stunned") then
            Disable:clear(unit)
        end
    end, 1.0)
end

T.onRoot = function(_triggers)
    Damage.register("After", function(info)
        local unit = info.target

        if not Disable:get(unit, "rooted") then
            for _, v in ipairs(T.buffs.root) do
                if UnitHasBuffBJ(unit, FourCC(v)) then
                    T.fireEvent("ROOT", info)
                    Disable:set(unit, "rooted", true)
                    break
                end
            end
        end

        if not Disable:get(unit, "rooted") and not Disable:get(unit, "stunned") then
            Disable:clear(unit)
        end
    end, 1.0)
end

T.onAttack = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ATTACKED)
    TriggerAddAction(trig, function()
        Filter.runUnitTriggers(triggers, GetAttacker(), "source")
    end)
end

T.onDeath = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_DEATH)
    TriggerAddAction(trig, function()
        Filter.runUnitTriggers(triggers, GetDyingUnit(), "target")
    end)
end

T.onSummon = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SUMMON)
    TriggerAddAction(trig, function()
        Filter.runUnitTriggers(triggers, GetSummonedUnit(), "target")
    end)
end

T.onSpellCast = function(triggers)
    local castTrig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(castTrig, EVENT_PLAYER_UNIT_SPELL_CAST)
    TriggerAddAction(castTrig, function()
        local spellId = GetSpellAbilityId()
        for _, trigger in ipairs(triggers) do
            if spellId == trigger.spellId then
                trigger.action()
            end
        end
    end)
end

T.onSpellEffect = function(triggers)
    local castTrig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(castTrig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddAction(castTrig, function()
        local spellId = GetSpellAbilityId()
        for _, trigger in ipairs(triggers) do
            if spellId == trigger.spellId then
                trigger.action()
            end
        end
    end)
end

T.onSpellEndcast = function(triggers)
    local castTrig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(castTrig, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddAction(castTrig, function()
        local spellId = GetSpellAbilityId()
        for _, trigger in ipairs(triggers) do
            if spellId == trigger.spellId then
                trigger.action()
            end
        end
    end)
end

T.onPreDamage = function(triggers)
    Damage.register("Pre", function(info)
        Filter.runFilteredDamageTriggers(triggers, info)
    end, 1.0)
end

T.onDamage = function(triggers)
    Damage.register("On", function(info)
        Filter.runFilteredDamageTriggers(triggers, info)
    end, 1.0)
end

T.afterDamage = function(triggers)
    Damage.register("After", function(info)
        Filter.runFilteredDamageTriggers(triggers, info)
    end, 1.0)
end

T.onAnyOrder = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_ORDER)
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
    TriggerAddAction(trig, function()
        for _, trigger in ipairs(triggers) do
            trigger.action()
        end
    end)
end

T.onOrder = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_ORDER)
    TriggerAddAction(trig, function()
        for _, trigger in ipairs(triggers) do
            if trigger.order then
                if GetIssuedOrderId() == String2OrderIdBJ(trigger.order) then
                    trigger.action()
                end
            else
                trigger.action()
            end
        end
    end)
end

T.onTargetOrder = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
    TriggerAddAction(trig, function()
        for _, trigger in ipairs(triggers) do
            trigger.action()
        end
    end)
end

T.onPointOrder = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    TriggerAddAction(trig, function()
        for _, trigger in ipairs(triggers) do
            trigger.action()
        end
    end)
end

T.onTrain = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_TRAIN_FINISH)
    TriggerAddAction(trig, function()
        Filter.runUnitTriggers(triggers, GetTrainedUnit(), "target")
    end)
end

T.onSelect = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SELECTED)
    TriggerAddAction(trig, function()
        for _, trigger in ipairs(triggers) do
            trigger.action()
        end
    end)
end

T.onTimer = function(triggers)
    for _, timer in ipairs(triggers) do
        TimerStart(CreateTimer(), timer.delta, true, function()
            timer.action()
        end)
    end
end

T.methods = {
    EVENT_PLAYER_UNIT_SELECTED = T.onSelect,
    EVENT_PLAYER_UNIT_ATTACKED = T.onAttack,
    EVENT_PLAYER_UNIT_SPELL_CAST = T.onSpellCast,
    EVENT_PLAYER_UNIT_SPELL_EFFECT = T.onSpellEffect,
    EVENT_PLAYER_UNIT_SPELL_ENDCAST = T.onSpellEndcast,
    EVENT_PLAYER_UNIT_TRAIN_FINISH = T.onTrain,
    EVENT_PLAYER_UNIT_DEATH = T.onDeath,
    EVENT_PLAYER_UNIT_SUMMON = T.onSummon,
    EVENT_PLAYER_UNIT_ISSUED_ORDER = T.onOrder,
    EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER = T.onPointOrder,
    EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER = T.onTargetOrder,
    PRE_DAMAGE = T.onPreDamage,
    DAMAGE = T.onDamage,
    AFTER_DAMAGE = T.afterDamage,
    TIMER = T.onTimer,
    ORDER = T.onAnyOrder,
    STUN = T.onStun,
    ROOT = T.onRoot,
}

return T
