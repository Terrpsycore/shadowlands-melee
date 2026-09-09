-- TODO:
-- - repeated damage on already stunned target don't fire STUN event again
local Ids = require("data.ids")
local dump = require("utils.logger")

local T = require("tests.support.runner")

local huntedAnimal = require("scenario.factions.kyrian.abilities.huntedAnimal")
local config = huntedAnimal.config

T:test("onStun callback run", function(case)
    local larion = case:createUnit(Ids.units.aspirant)
    case:applyDummyOrder(Player(PLAYER_NEUTRAL_AGGRESSIVE), larion, FourCC(Ids.abilities.stormBolt), "thunderbolt")

    return case:delay(2, function()
        assert(UnitHasBuffBJ(larion, config.refs.buffs.main), "larion doesn't receive buff")
    end)
end)
