local Ids = require("data.ids")
local T = require("tests.support.runner").suite("memoryPeer")

local memoryPeer = require("scenario.factions.kyrian.abilities.memoryPeer")
local Storage = require("scenario.storage.memoryPeer")

local config = memoryPeer.config

T:test("Cast marks target with memory peer buff", function(case)
    local caster = case:createUnit(Ids.units.watcher)
    local target = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    IssueTargetOrder(caster, "memorypeer", target)

    return case:delay(2, function()
        assert(UnitHasBuffBJ(target, config.refs.buffs.main), "memory peer buff not applied")
        assert(Storage:get(target, "summonsLeast") > 0, "target summon counter not initialized")
    end)
end)
