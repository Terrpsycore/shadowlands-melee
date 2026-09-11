local Ids = require("data.ids")

local T = require("tests.support.runner").suite("onRevive")

local Callback = require("lib.triggers.callbacks")

T:test("onRevive fires with matching filter", function(case)
    local triggered = nil

    local caster = case:createUnit(Ids.units.dummy, nil, true)
    local target = case:createUnit(Ids.units.dummyTarget, nil, true)

    Callback.registerCallback("REVIVE", {
        trigger = "REVIVE",
        filter = { target = FourCC(Ids.units.dummyTarget) },
        action = function(ctx)
            if ctx.target == target then
                triggered = true
            end
        end,
    })

    Callback.fireEvent("REVIVE", { source = caster, target = target })
    assert(triggered == true, "onRevive didn't fire")
end)

T:test("onRevive skips when ctx missing target for filter", function(case)
    local triggered = false

    local caster = case:createUnit(Ids.units.dummy, nil, true)

    Callback.registerCallback("REVIVE", {
        trigger = "REVIVE",
        filter = { target = FourCC(Ids.units.dummyTarget) },
        action = function()
            triggered = true
        end,
    })

    Callback.fireEvent("REVIVE", { source = caster })
    assert(triggered == false, "onRevive fired without matching ctx.target")
end)

T:test("onRevive skips when ctx is empty", function(case)
    local triggered = false

    Callback.registerCallback("REVIVE", {
        trigger = "REVIVE",
        filter = { target = FourCC(Ids.units.dummyTarget) },
        action = function()
            triggered = true
        end,
    })

    Callback.fireEvent("REVIVE", {})
    assert(triggered == false, "onRevive fired with empty ctx")
end)
