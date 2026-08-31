-- TODO:
-- - use conditions
local Storage = require("lib.storage.storage")
local dump = require("utils.logger")
local Type = require("utils.type")

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
        -- dump("T.register: try - " .. event)
        T.methods[event](triggers)
    end
end

T.registerCallback = function(event, callbackOptions)
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
    for _, callback in pairs(callbacks) do
        callback.action(data)
    end
end

T.onStun = function(triggers)
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

T.onRoot = function(triggers)
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
        for _, trigger in ipairs(triggers) do
            if trigger.attacker and trigger.attacker.type then
                if GetUnitTypeId(GetAttacker()) == trigger.attacker.type then
                    trigger.action()
                    dump("GetIssuedOrderId", OrderId2String(GetIssuedOrderId()), "trigger.order", trigger.order)
                    dump("trigger.action() 1")
                    goto continue
                end
            else
                trigger.action()
                -- dump("trigger.action() 2")
            end
            ::continue::
        end
    end)
end

T.onDeath = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_DEATH)
    TriggerAddAction(trig, function()
        local unitId = GetUnitTypeId(GetDyingUnit())
        for _, trigger in ipairs(triggers) do
            if unitId == trigger.unitType then
                trigger.action()
            end
        end
    end)
end

T.onSpellCast = function(triggers)
    local castTrig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(castTrig, EVENT_PLAYER_UNIT_SPELL_CAST)
    TriggerAddAction(castTrig, function()
        -- local caster
        -- local target
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
        -- local caster
        -- local target
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
        for _, trigger in ipairs(triggers) do
            trigger.action(info)
        end
    end, 1.0)
end

T.onDamage = function(triggers)
    -- dump("onDamage register")
    Damage.register("On", function(info)
        -- dump("onDamage fired")
        for _, trigger in ipairs(triggers) do
            -- dump("onDamage trigger check ..")
            if trigger.target and trigger.target.type then
                local types = {}
                for _, v in ipairs(trigger.target.type) do
                    types[FourCC(v)] = true
                    -- dump("onDamage trigger check :: ", GetUnitTypeId(info.target), FourCC(v))
                end
                -- dump("types[GetUnitTypeId(info.target)]", types[GetUnitTypeId(info.target)])
                if types[GetUnitTypeId(info.target)] then
                    -- dump("trigger.action(info)")
                    trigger.action(info)
                    goto continue
                end
            else
                trigger.action(info)
            end
            ::continue::
        end
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
                    dump("GetIssuedOrderId", OrderId2String(GetIssuedOrderId()), "trigger.order", trigger.order)
                    dump("trigger.action() 1")
                    goto continue
                end
            else
                trigger.action()
                dump("trigger.action() 2")
            end
            ::continue::
        end
    end)
end

T.onTargetOrder = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    TriggerAddAction(trig, function()
        for _, trigger in ipairs(triggers) do
            trigger.action()
        end
    end)
end

T.onPointOrder = function(triggers)
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
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
        local unitId = GetUnitTypeId(GetTrainedUnit())
        for _, trigger in ipairs(triggers) do
            if unitId == trigger.unitType then
                trigger.action()
            end
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
    EVENT_PLAYER_UNIT_ATTACKED = T.onAttack,
    EVENT_PLAYER_UNIT_SPELL_CAST = T.onSpellCast,
    EVENT_PLAYER_UNIT_SPELL_EFFECT = T.onSpellEffect,
    EVENT_PLAYER_UNIT_TRAIN_FINISH = T.onTrain,
    EVENT_PLAYER_UNIT_DEATH = T.onDeath,
    EVENT_PLAYER_UNIT_ISSUED_ORDER = T.onOrder,
    EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER = T.onPointOrder,
    EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER = T.onTargetOrder,
    PRE_DAMAGE = T.onPreDamage,
    DAMAGE = T.onDamage,
    TIMER = T.onTimer,
    ORDER = T.onAnyOrder,
    STUN = T.onStun, -- registered in onDamage - won't register without
    ROOT = T.onRoot, -- registered in onDamage - won't register without
}

return T
