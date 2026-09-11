local Ids = require("data.ids")
local T = require("tests.support.runner").suite("scan")

local scan = require("scenario.factions.kyrian.abilities.scan")
local MechStorage = require("scenario.storage.mech")

local config = scan.config

local function enableToggle(phalynx)
    IssueImmediateOrder(phalynx, "immolation")
end

T:test("Toggle on enables true sight and storage", function(case)
    local phalynx = case:createUnit(Ids.units.phalynx)

    enableToggle(phalynx)

    return case:delay(0.5, function()
        assert(MechStorage:has(phalynx), "scan toggle not tracked")
        assert(
            GetUnitAbilityLevel(phalynx, config.refs.abilities.trueSight) > 0,
            "true sight not added on toggle"
        )
    end)
end)

T:test("Toggle off clears storage and true sight", function(case)
    local phalynx = case:createUnit(Ids.units.phalynx)
    MechStorage:set(phalynx, "active", true)
    UnitAddAbility(phalynx, config.refs.abilities.trueSight)

    IssueImmediateOrder(phalynx, "unimmolation")

    return case:delay(0.5, function()
        assert(not MechStorage:has(phalynx), "scan toggle not cleared")
        assert(
            GetUnitAbilityLevel(phalynx, config.refs.abilities.trueSight) == 0,
            "true sight not removed on toggle off"
        )
    end)
end)

T:test("Toggle not enabled without enough mana", function(case)
    local phalynx = case:createUnit(Ids.units.phalynx)

    SetUnitState(phalynx, UNIT_STATE_MANA, config.balance.toggleManacost - 1)
    enableToggle(phalynx)

    return case:delay(0.5, function()
        assert(not MechStorage:has(phalynx), "toggle enabled without enough mana")
    end)
end)
