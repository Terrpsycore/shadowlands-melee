-- TODO:
-- - rewrite to 1 constant trigger with changing conditions to prevent leaks (will it be enough?)
local function removeControl(unit, action)
    local trig = CreateTrigger()
    TriggerRegisterUnitEvent(trig, unit, EVENT_UNIT_ISSUED_ORDER)
    TriggerRegisterUnitEvent(trig, unit, EVENT_UNIT_ISSUED_TARGET_ORDER)
    TriggerRegisterUnitEvent(trig, unit, EVENT_UNIT_ISSUED_POINT_ORDER)
    TriggerAddAction(trig, function()
        DisableTrigger(trig)
        action()
        EnableTrigger(trig)
    end)
    return trig
end

return removeControl
