local abilities = require("scenario.abilities")
local dump = require("utils.logger")

-- собрать обработчики
local spellHandlers = {} -- spellId (FourCC) -> action
local timers = {}

for _, ability in ipairs(abilities) do
    local t = ability.triggers
    if not t then
        goto continue
    end

    local spell = t.EVENT_PLAYER_UNIT_SPELL_EFFECT
    if spell then
        spellHandlers[FourCC(spell.spellId)] = spell.action
    end

    if t.TIMER then
        timers[#timers + 1] = t.TIMER
    end

    ::continue::
end

-- один общий триггер на SPELL_EFFECT
local castTrig = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(castTrig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
TriggerAddAction(castTrig, function()
    local handler = spellHandlers[GetSpellAbilityId()]
    dump("triggered ability casted", not not handler)
    if handler then
        handler()
    end
end)

-- таймеры — по одному на каждый delta или один общий с диспетчером
for _, timer in ipairs(timers) do
    -- Timed.call / CreateTimer по вашему Timed.lua
end
