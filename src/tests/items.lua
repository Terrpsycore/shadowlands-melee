local Ids = require("data.ids")
local Items = require("lib.items")
local T = require("tests.support.runner")

T:test("Unit can pick unit item", function(case)
    local unit = case:createUnit(Ids.units.dummy)
    UnitAddAbility(unit, FourCC(Ids.abilities.inventory))

    local unitItem = case:createItem(Ids.items.dummyUnitItem)

    IssueTargetOrder(unit, "smart", unitItem)

    return case:delay(1, function()
        assert(UnitHasItem(unit, unitItem), "unit can't pick unit item")
    end)
end)

T:test("Unit can't pick hero item", function(case)
    local unit = case:createUnit(Ids.units.dummy)
    UnitAddAbility(unit, FourCC(Ids.abilities.inventory))

    local heroItem = case:createItem(Ids.items.dummyHeroItem)

    IssueTargetOrder(unit, "smart", heroItem)

    return case:delay(1, function()
        assert(not UnitHasItem(unit, heroItem), "unit can pick hero item")
    end)
end)

T:test("Hero can pick unit item", function(case)
    local hero = case:createUnit(Ids.units.dummyHero)
    local unitItem = case:createItem(Ids.items.dummyUnitItem)

    IssueTargetOrder(hero, "smart", unitItem)

    return case:delay(1, function()
        assert(UnitHasItem(hero, unitItem), "hero can't pick unit item")
    end)
end)

T:test("Hero can pick hero item", function(case)
    local hero = case:createUnit(Ids.units.dummyHero)
    local heroItem = case:createItem(Ids.items.dummyHeroItem)

    IssueTargetOrder(hero, "smart", heroItem)

    return case:delay(1, function()
        assert(UnitHasItem(hero, heroItem), "hero can't pick hero item")
    end)
end)
