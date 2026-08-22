local abilities = require("scenario.abilities")
local dump = require("utils.logger")

local callbacks = {}

for _, ability in ipairs(abilities) do
    for trigger, options in pairs(ability.triggers) do
        if not callbacks[trigger] then
            callbacks[trigger] = {}
        end
        table.insert(callbacks[trigger], options)
    end
end

for event, triggers in pairs(callbacks) do
    if event == "EVENT_PLAYER_UNIT_SPELL_EFFECT" then
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
    elseif event == "DAMAGE" then
    elseif event == "TIMER" then
        for _, timer in ipairs(triggers) do
            TimerStart(CreateTimer(), timer.delta, true, function()
                timer.action()
            end)
        end
    end
end

--[[

        Damage.register(Damage.damagedEvent, function()
            local d = Damage.index
            if d.damage <= 0 then
                return
            end -- skip zero-damage hits
            OnUnitDamaged(d, d.source, d.target)
        end, 1.0)
--]]
