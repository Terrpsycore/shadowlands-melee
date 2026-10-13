local Bootstrap = {}

function Bootstrap.reregister()
    local T = require("lib.triggers.callbacks")
    local abilities = require("scenario.abilities")

    T.callbacks = {}
    T.buffs.root = {}
    T.buffs.stun = {}

    for _, ability in ipairs(abilities.abilities) do
        for _, options in ipairs(ability.triggers) do
            T.registerCallback(options.trigger, options)
        end
    end

    T.registerEvents(T.callbacks)
    T.registerBuffs("root", abilities.buffs.root)
    T.registerBuffs("stun", abilities.buffs.stun)
end

Bootstrap.reregister()
return Bootstrap
