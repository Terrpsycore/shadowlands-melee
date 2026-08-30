-- TODO:
-- - use conditions
local abilities = require("scenario.abilities")
local dump = require("utils.logger")
local Type = require("utils.type")

local T = {
    callbacks = {},
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

T.fireEvent = function(event)
    local callbacks = T.callbacks[event]
    for k, callback in pairs(callbacks[event]) do
        callback()
    end
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

T.onSpell = function(triggers)
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
            trigger.action()
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
    EVENT_PLAYER_UNIT_SPELL_EFFECT = T.onSpell,
    EVENT_PLAYER_UNIT_TRAIN_FINISH = T.onTrain,
    EVENT_PLAYER_UNIT_DEATH = T.onDeath,
    EVENT_PLAYER_UNIT_ISSUED_ORDER = T.onOrder,
    EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER = T.onPointOrder,
    EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER = T.onTargetOrder,
    DAMAGE = T.onDamage,
    TIMER = T.onTimer,
    ORDER = T.onAnyOrder,
    STUN = T.onStun,
    ROOT = T.onRoot,
}

local callbacks = {}

for _, ability in ipairs(abilities) do
    if ability.triggers[1] then
        for _, options in ipairs(ability.triggers) do
            T.registerCallback(options.trigger, options)
        end
    else
        for event, options in pairs(ability.triggers) do
            T.registerCallback(event, options)
        end
    end
end

T.registerEvents(T.callbacks)

return T
