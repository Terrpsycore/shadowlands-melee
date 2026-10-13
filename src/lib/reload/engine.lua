---@class ReloadEngine
--- Tracks WC3 triggers/timers registered by lib.triggers and supports teardown before hot reload.
local Engine = {
    triggers = {},
    timers = {},
}

---@param handle trigger
function Engine.trackTrigger(handle)
    if handle then
        Engine.triggers[#Engine.triggers + 1] = handle
    end
end

---@param handle timer
function Engine.trackTimer(handle)
    if handle then
        Engine.timers[#Engine.timers + 1] = handle
    end
end

function Engine.teardown()
    for i = 1, #Engine.triggers do
        local trig = Engine.triggers[i]
        if trig then
            DisableTrigger(trig)
            DestroyTrigger(trig)
        end
    end
    Engine.triggers = {}

    for i = 1, #Engine.timers do
        local t = Engine.timers[i]
        if t then
            PauseTimer(t)
            DestroyTimer(t)
        end
    end
    Engine.timers = {}

    if Damage and Damage.clearListeners then
        Damage.clearListeners()
    end
end

return Engine
