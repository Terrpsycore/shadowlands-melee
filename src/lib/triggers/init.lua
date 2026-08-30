local T = require("lib.triggers.callbacks")
local abilities = require("scenario.abilities")

for _, ability in ipairs(abilities.abilities) do
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
T.registerBuffs("root", abilities.buffs.stun)
T.registerBuffs("stun", abilities.buffs.stun)
