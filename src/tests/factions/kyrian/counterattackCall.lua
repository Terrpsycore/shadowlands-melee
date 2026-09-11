local Ids = require("data.ids")
local T = require("tests.support.runner").suite("counterattackCall")

local counterattackCall = require("scenario.factions.kyrian.abilities.counterattackCall")
local Storage = require("scenario.storage.counterattackCall")

local config = counterattackCall.config

T:test("Cast buffs allies in radius", function(case)
    local caster = case:createUnit(Ids.units.watcher)
    UnitAddAbility(caster, config.refs.abilities.main)
    SetUnitAbilityLevel(caster, config.refs.abilities.main, 1)

    local ally = case:createUnit(Ids.units.aspirant)
    local cx, cy = GetUnitX(caster), GetUnitY(caster)
    SetUnitPosition(ally, cx + 100, cy)

    IssueImmediateOrder(caster, "counterattackcall")

    return case:delay(1, function()
        assert(UnitHasBuffBJ(ally, config.refs.buffs.main), "ally did not receive counterattack buff")
        assert(Storage:has(ally), "ally not tracked in storage")
    end)
end)

T:test("Death clears storage entry", function(case)
    local unit = case:createUnit(Ids.units.aspirant)
    Storage:add(unit)
    assert(Storage:has(unit), "setup failed")

    KillUnit(unit)

    return case:delay(0.5, function()
        assert(not Storage:has(unit), "storage not cleared on death")
    end)
end)
