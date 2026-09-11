local Ids = require("data.ids")
local T = require("tests.support.runner").suite("dedication")

local dedication = require("scenario.factions.kyrian.abilities.dedication")
local Storage = require("scenario.storage.dedication")

local config = dedication.config

T:test("Cast applies dedication buff chain", function(case)
    local caster = case:createUnit(Ids.units.wisdom)
    local target = case:createUnit(Ids.units.aspirant)

    IssueTargetOrder(caster, "dedication", target)

    return case:delay(1.5, function()
        assert(UnitHasBuffBJ(target, config.refs.buffs.main), "dedication buff not applied")
        assert(Storage:has(target), "target not tracked in dedication storage")
        assert(
            GetUnitAbilityLevel(target, config.refs.abilities.attackSpeed) > 0,
            "attack speed ability not added"
        )
    end)
end)
