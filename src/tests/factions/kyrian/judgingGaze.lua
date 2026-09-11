local Ids = require("data.ids")
local T = require("tests.support.runner").suite("judgingGaze")

local judgingGaze = require("scenario.factions.kyrian.abilities.judgingGaze")
local Storage = require("scenario.storage.autocast")

local config = judgingGaze.config

T:test("Manual cast applies debuffs", function(case)
    local caster = case:createUnit(Ids.units.watcher)
    local target = case:createUnit(Ids.units.aspirant, Player(PLAYER_NEUTRAL_AGGRESSIVE))

    IssueTargetOrder(caster, "judginggaze", target)

    return case:delay(1, function()
        assert(
            GetUnitAbilityLevel(target, config.refs.abilities.missDebuff) > 0
                or GetUnitAbilityLevel(target, config.refs.abilities.armorDebuff) > 0,
            "judging gaze debuffs not applied"
        )
    end)
end)

T:test("Autocast toggle tracked in storage", function(case)
    local watcher = case:createUnit(Ids.units.watcher)

    IssueImmediateOrder(watcher, "coldarrows")

    return case:delay(0.5, function()
        assert(Storage:has(watcher), "autocast toggle not tracked")
    end)
end)

T:test("Autocast toggle off clears storage", function(case)
    local watcher = case:createUnit(Ids.units.watcher)
    Storage:add(watcher)

    IssueImmediateOrder(watcher, "uncoldarrows")

    return case:delay(0.5, function()
        assert(not Storage:has(watcher), "autocast toggle not cleared")
    end)
end)
