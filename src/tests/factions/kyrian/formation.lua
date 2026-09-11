local Ids = require("data.ids")
local T = require("tests.support.runner").suite("formation")

local formation = require("scenario.factions.kyrian.abilities.formation")

local config = formation.config

local LINK_OFFSET = 200

local function hasFormationBuff(unit)
    return GetUnitAbilityLevel(unit, config.refs.abilities.damageBuff) > 0
        and GetUnitAbilityLevel(unit, config.refs.abilities.speedBuff) > 0
end

local function placePhalynx(case, offsetX)
    local unit = case:createUnit(Ids.units.phalynx)
    local x, y = GetUnitX(unit), GetUnitY(unit)
    SetUnitPosition(unit, x + offsetX, y)
    formation.debug.onTrain(unit)
    return unit
end

T:test("Isolated phalynx gets no buff", function(case)
    local unit = placePhalynx(case, 0)
    formation.debug.onTick()
    assert(not hasFormationBuff(unit), "single phalynx should not receive formation buff")
end)

T:test("Chain of three phalynx gets buff", function(case)
    local left = placePhalynx(case, 0)
    placePhalynx(case, LINK_OFFSET)
    local right = placePhalynx(case, LINK_OFFSET * 2)

    formation.debug.onTick()

    assert(hasFormationBuff(left), "chain phalynx missing formation buff")
    assert(hasFormationBuff(right), "chain phalynx missing formation buff")
end)

T:test("Two phalynx without hub get no buff", function(case)
    local first = placePhalynx(case, 0)
    local second = placePhalynx(case, LINK_OFFSET)

    formation.debug.onTick()

    assert(not hasFormationBuff(first), "pair without degree-2 hub should not get buff")
    assert(not hasFormationBuff(second), "pair without degree-2 hub should not get buff")
end)
