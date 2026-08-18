local Ids = require("generated.ids")
local Items = require("lib.items")

Timed.call(0, function()
    local x, y = -100, -100
    local unit = CreateUnit(Player(0), FourCC(Ids.units.dummy), x, y, 270)
    UnitAddAbility(unit, FourCC(Ids.abilities.inventory))
    local unitItem = CreateItem(FourCC(Ids.items.dummyUnitItem), x + 32, y)

    IssueTargetOrder(unit, "smart", unitItem)
    Timed.call(1, function()
        local ok = UnitHasItem(unit, unitItem)
        DisplayTextToPlayer(
            GetLocalPlayer(),
            0,
            0,
            ok and "OK: unit can pick unit item" or "ERROR: unit can't pick unit item"
        )
        RemoveItem(unitItem)
        RemoveUnit(unit)
    end)
end)

Timed.call(0, function()
    local x, y = -100, -100
    local unit = CreateUnit(Player(0), FourCC(Ids.units.dummy), x, y, 270)
    UnitAddAbility(unit, FourCC(Ids.abilities.inventory))
    local heroItem = CreateItem(FourCC(Ids.items.dummyHeroItem), x + 32, y)

    IssueTargetOrder(unit, "smart", heroItem)
    Timed.call(1, function()
        local ok = not UnitHasItem(unit, heroItem)
        DisplayTextToPlayer(
            GetLocalPlayer(),
            0,
            0,
            ok and "OK: unit can't pick hero item" or "ERROR: unit can pick hero item"
        )
        RemoveItem(heroItem)
        RemoveUnit(unit)
    end)
end)

Timed.call(0, function()
    local x, y = -100, -100
    local hero = CreateUnit(Player(0), FourCC(Ids.units.dummyHero), x, y, 270)
    local unitItem = CreateItem(FourCC(Ids.items.dummyUnitItem), x + 32, y)

    IssueTargetOrder(hero, "smart", unitItem)
    Timed.call(1, function()
        local ok = UnitHasItem(hero, unitItem)
        DisplayTextToPlayer(
            GetLocalPlayer(),
            0,
            0,
            ok and "OK: hero can pick unit item" or "ERROR: hero can't pick unit item"
        )
        RemoveItem(unitItem)
        RemoveUnit(hero)
    end)
end)

Timed.call(0, function()
    local x, y = -100, -100
    local hero = CreateUnit(Player(0), FourCC(Ids.units.dummyHero), x, y, 270)
    local heroItem = CreateItem(FourCC(Ids.items.dummyHeroItem), x + 32, y)

    IssueTargetOrder(hero, "smart", heroItem)
    Timed.call(1, function()
        local ok = UnitHasItem(hero, heroItem)
        DisplayTextToPlayer(
            GetLocalPlayer(),
            0,
            0,
            ok and "OK: hero can pick hero item" or "ERROR: hero can't pick hero item"
        )
        RemoveItem(heroItem)
        RemoveUnit(hero)
    end)
end)
