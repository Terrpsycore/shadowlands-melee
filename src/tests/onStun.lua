-- TODO:
-- - repeated damage on already stunned target don't fire STUN event again
local Ids = require("data.ids")
local dump = require("utils.logger")

local T = require("tests.support.runner").suite("onStun")

local Callback = require("lib.triggers.callbacks")

T:test("onStun callback run", function(case)
    local triggered = nil

    local target = case:createUnit(Ids.units.dummyTarget, nil, true)
    Callback.registerCallback("STUN", {
        action = function(info)
            if info.target == target then
                triggered = true
            end
        end,
    })
    local r =
        case:applyDummyOrder(Player(PLAYER_NEUTRAL_AGGRESSIVE), target, FourCC(Ids.abilities.stormBolt), "thunderbolt")

    return case:delay(2, function()
        assert(triggered == true, "onStun didn't fire")
    end)
end)
