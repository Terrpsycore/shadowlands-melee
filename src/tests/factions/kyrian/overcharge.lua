local Ids = require("data.ids")
local T = require("tests.support.runner").suite("overcharge")

local overcharge = require("scenario.factions.kyrian.abilities.overcharge")

local config = overcharge.config

T:test("Buffs full-mana mech ally in radius", function(case)
    local hero = case:createUnit(Ids.units.forgelite)
    local mech = case:createUnit(Ids.units.goliath)

    local hx, hy = GetUnitX(hero), GetUnitY(hero)
    SetUnitPosition(mech, hx + 100, hy)

    SetUnitState(mech, UNIT_STATE_MANA, GetUnitState(mech, UNIT_STATE_MAX_MANA))
    IssueImmediateOrder(hero, "overcharge")

    return case:delay(1, function()
        assert(
            GetUnitAbilityLevel(mech, config.refs.abilities.damageBuff) > 0,
            "damage buff not applied to full-mana mech"
        )
        assert(
            GetUnitAbilityLevel(mech, config.refs.abilities.speedBuff) > 0,
            "speed buff not applied to full-mana mech"
        )
    end)
end)

T:test("Skips mech without full mana", function(case)
    local hero = case:createUnit(Ids.units.forgelite)
    local mech = case:createUnit(Ids.units.goliath)

    local hx, hy = GetUnitX(hero), GetUnitY(hero)
    SetUnitPosition(mech, hx + 100, hy)

    SetUnitState(mech, UNIT_STATE_MANA, 0)
    IssueImmediateOrder(hero, "overcharge")

    return case:delay(1, function()
        assert(
            GetUnitAbilityLevel(mech, config.refs.abilities.damageBuff) == 0,
            "damage buff applied without full mana"
        )
    end)
end)
