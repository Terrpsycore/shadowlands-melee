local Ids = require("data.ids")
local T = require("tests.support.runner").suite("oneMoreChance")

local oneMoreChance = require("scenario.factions.kyrian.abilities.oneMoreChance")
local Storage = require("scenario.storage.oneMoreChance")

local config = oneMoreChance.config

T:test("Cast adds reincarnation setup to target", function(case)
    local caster = case:createUnit(Ids.units.watcher)
    local target = case:createUnit(Ids.units.aspirant)

    IssueTargetOrder(caster, "onemorechance", target)

    return case:delay(1.5, function()
        assert(UnitHasBuffBJ(target, config.refs.buffs.main), "one more chance buff not applied")
        assert(Storage:has(target), "target not tracked in storage")
        assert(
            GetUnitAbilityLevel(target, config.refs.abilities.cross) > 0,
            "cross ability not added"
        )
        assert(
            GetUnitAbilityLevel(target, config.refs.abilities.reincarnationCheck) > 0,
            "reincarnation check not added"
        )
    end)
end)
