local Ids = require("data.ids")
local T = require("tests.support.runner").suite("vanish")

local vanish = require("scenario.factions.necrolord.abilities.vanish")

local config = vanish.config

T:test("Cast applies invisibility dummy", function(case)
    local spy = case:createUnit(Ids.units.aranakkSpy)
    UnitAddAbility(spy, config.refs.abilities.main)

    IssueImmediateOrder(spy, "vanish")

    return case:delay(1.5, function()
        assert(
            GetUnitAbilityLevel(spy, config.refs.abilities.dummy) > 0
                or BlzGetUnitAbilityCooldownRemaining(spy, config.refs.abilities.main) > 0,
            "vanish cast had no effect"
        )
    end)
end)
