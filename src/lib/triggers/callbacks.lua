-- TODO:
-- - use conditions
-- - accept function instead of handle or {handle} -> pass event if function(handle) is true
-- - onDamage - filter .isSpell
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

---@param event string
---@param callbackOptions TriggerDefinition
T.registerCallback = function(event, callbackOptions)
    Filter.compileTrigger(callbackOptions)
    local original = callbackOptions.action
    callbackOptions.action = function(...)
        Debug.try(original, ...)
    end
    if T.callbacks[event] == nil then
        T.callbacks[event] = {}
    end
    table.insert(T.callbacks[event], callbackOptions)
end

T.registerBuffs = function(tag, buffs)
    T.buffs[tag] = buffs
end

T.fireEvent = function(event, ctx)
    local callbacks = T.callbacks[event]
    if not callbacks then
        return
    end
    Filter.run(callbacks, ctx or {}, true)
end

T.onCustomEvent = function(_triggers) end

local function registerUnitEvent(event, triggers, ctxFn)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, event)
    TriggerAddAction(trig, function()
        Filter.run(triggers, ctxFn())
    end)
end

T.onStun = function(_triggers)
    -- TODO: change to UNIT_TYPE_STUNNED
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
            Disable:drop(unit)
        end
    end, 1.0)
end

T.onRoot = function(_triggers)
    -- TODO: ? change to UNIT_TYPE_SNARED
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
            Disable:drop(unit)
        end
    end, 1.0)
end

T.onAttack = function(triggers)
    registerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, triggers, function()
        return { source = GetAttacker() }
    end)
end

T.onDeath = function(triggers)
    registerUnitEvent(EVENT_PLAYER_UNIT_DEATH, triggers, function()
        return { target = GetDyingUnit() }
    end)
end

T.onSummon = function(triggers)
    registerUnitEvent(EVENT_PLAYER_UNIT_SUMMON, triggers, function()
        return { target = GetSummonedUnit() }
    end)
end

T.onSpellCast = function(triggers)
    registerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CAST, triggers, function()
        return { spellId = GetSpellAbilityId() }
    end)
end

T.onSpellEffect = function(triggers)
    registerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, triggers, function()
        return { spellId = GetSpellAbilityId() }
    end)
end

T.onSpellEndcast = function(triggers)
    registerUnitEvent(EVENT_PLAYER_UNIT_SPELL_ENDCAST, triggers, function()
        return { spellId = GetSpellAbilityId() }
    end)
end

T.onSpellFinish = function(triggers)
    registerUnitEvent(EVENT_PLAYER_UNIT_SPELL_FINISH, triggers, function()
        return { spellId = GetSpellAbilityId() }
    end)
end

T.onPreDamage = function(triggers)
    Damage.register("Pre", function(info)
        Filter.run(triggers, info, true)
    end, 1.0)
end

T.onDamage = function(triggers)
    Damage.register("On", function(info)
        Filter.run(triggers, info, true)
    end, 1.0)
end

T.onLethalDamage = function(triggers)
    Damage.register("Lethal", function(info)
        Filter.run(triggers, info, true)
    end, 1.0)
end

T.afterDamage = function(triggers)
    Damage.register("After", function(info)
        Filter.run(triggers, info, true)
    end, 1.0)
end

T.onAnyOrder = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_ORDER)
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
    TriggerAddAction(trig, function()
        Filter.run(triggers, {})
    end)
end

T.onOrder = function(triggers)
    registerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, triggers, function()
        return { orderId = GetIssuedOrderId() }
    end)
end

T.onTargetOrder = function(triggers)
    registerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, triggers, function()
        return {}
    end)
end

T.onPointOrder = function(triggers)
    registerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, triggers, function()
        return {}
    end)
end

T.onTrain = function(triggers)
    registerUnitEvent(EVENT_PLAYER_UNIT_TRAIN_FINISH, triggers, function()
        return { target = GetTrainedUnit() }
    end)
end

T.onSelect = function(triggers)
    registerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, triggers, function()
        return {}
    end)
end

T.onCreate = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterEnterRectSimple(trig, GetWorldBounds())
    TriggerAddAction(trig, function()
        Filter.run(triggers, { target = GetEnteringUnit() })
    end)
end

T.onTimer = function(triggers)
    for _, timer in ipairs(triggers) do
        TimerStart(CreateTimer(), timer.delta, true, function()
            timer.action()
        end)
    end
end

T.registerEvents = function(callbacks)
    for event, triggers in pairs(callbacks) do
        T.methods[event](triggers)
    end
end

T.methods = {
    EVENT_PLAYER_UNIT_SELECTED = T.onSelect,
    EVENT_PLAYER_UNIT_ATTACKED = T.onAttack,
    EVENT_PLAYER_UNIT_SPELL_CAST = T.onSpellCast,
    EVENT_PLAYER_UNIT_SPELL_EFFECT = T.onSpellEffect,
    EVENT_PLAYER_UNIT_SPELL_ENDCAST = T.onSpellEndcast,
    EVENT_PLAYER_UNIT_SPELL_FINISH = T.onSpellFinish,
    EVENT_PLAYER_UNIT_TRAIN_FINISH = T.onTrain,
    EVENT_PLAYER_UNIT_DEATH = T.onDeath,
    EVENT_PLAYER_UNIT_SUMMON = T.onSummon,
    EVENT_PLAYER_UNIT_ISSUED_ORDER = T.onOrder,
    EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER = T.onPointOrder,
    EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER = T.onTargetOrder,
    PRE_DAMAGE = T.onPreDamage,
    DAMAGE = T.onDamage,
    LETHAL_DAMAGE = T.onLethalDamage,
    AFTER_DAMAGE = T.afterDamage,
    TIMER = T.onTimer,
    ORDER = T.onAnyOrder,
    STUN = T.onStun,
    ROOT = T.onRoot,
    CREATE = T.onCreate,
    REVIVE = T.onCustomEvent,
}

return T
