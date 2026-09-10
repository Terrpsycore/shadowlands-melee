local Ids = require("data.ids")
local Items = require("lib.items")
local T = require("tests.support.runner").suite("pride")

local pride = require("scenario.factions.kyrian.abilities.pride")

local function populate(case, biggerUnits, equalUnits, lesserUnits, player)
    local result = { unit = nil, bigger = {}, equal = {}, lesser = {} }
    local unit = case:createUnit(Ids.units.larion)
    local baseHP = BlzGetUnitMaxHP(unit)

    pride.debug.onTrain(unit)
    case:addFlushCallback(function()
        -- pride.debug.onDeath(unit)
    end)

    result.unit = unit
    for i = 1, biggerUnits do
        local u = case:createUnit(Ids.units.aspirant, player)
        BlzSetUnitMaxHP(u, baseHP + 1)
        table.insert(result.bigger, u)
    end
    for i = 1, equalUnits do
        local u = case:createUnit(Ids.units.aspirant, player)
        BlzSetUnitMaxHP(u, baseHP)
        table.insert(result.equal, u)
    end
    for i = 1, lesserUnits do
        local u = case:createUnit(Ids.units.aspirant, player)
        BlzSetUnitMaxHP(u, baseHP - 1)
        table.insert(result.lesser, u)
    end
    return result
end

local function testPrideLevelCalc(case, unitsData, expectedResult)
    local populated = populate(case, unitsData.bigger, unitsData.equal, unitsData.lesser)
    pride.debug.applyPride(populated.unit)

    local prideLevel = GetUnitAbilityLevel(populated.unit, pride.config.refs.abilities.damage)
    assert(
        prideLevel == expectedResult,
        "Invalid prideLevel value = " .. prideLevel .. ", expected = " .. expectedResult
    )
end

T:test("No damage bonus by default", function(case)
    testPrideLevelCalc(case, { bigger = 0, equal = 0, lesser = 0 }, 0)
end)

T:test("+1 strict", function(case)
    testPrideLevelCalc(case, { bigger = 0, equal = 0, lesser = 1 }, 1)
end)

T:test("+5 strict", function(case)
    testPrideLevelCalc(case, { bigger = 0, equal = 0, lesser = 5 }, 5)
end)

T:test("+5 max", function(case)
    testPrideLevelCalc(case, { bigger = 0, equal = 0, lesser = 6 }, 5)
end)

T:test("Bigger creatures negate bonus", function(case)
    testPrideLevelCalc(case, { bigger = 5, equal = 0, lesser = 5 }, 0)
end)

T:test("Equal creatures negate bonus", function(case)
    testPrideLevelCalc(case, { bigger = 1, equal = 1, lesser = 5 }, 3)
end)
