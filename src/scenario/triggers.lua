local abilities = require("scenario.abilities")
local dump = require("utils.logger")
local Type = require("utils.type")

local T = {}

T.register = function(callbacks)
    for event, triggers in pairs(callbacks) do
        -- dump("T.register: try - " .. event)
        T.methods[event](triggers)
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

T.onTrain = function(triggers)
    local castTrig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(castTrig, EVENT_PLAYER_UNIT_TRAIN_FINISH)
    TriggerAddAction(castTrig, function()
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
    DAMAGE = T.onDamage,
    TIMER = T.onTimer,
}

local callbacks = {}

for _, ability in ipairs(abilities) do
    for trigger, options in pairs(ability.triggers) do
        if not callbacks[trigger] then
            callbacks[trigger] = {}
        end
        table.insert(callbacks[trigger], options)
    end
end

T.register(callbacks)
