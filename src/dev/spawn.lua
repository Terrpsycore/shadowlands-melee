local Ids = require("data.ids")

local function run()
    Debug.original.print("Hello warcraft-vscode !")

    CreateUnit(Player(0), FourCC(Ids.units.steward), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.aspirant), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.aspirant), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.praetor), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.praetor), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.purity), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.larion), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.loyalty), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.wisdom), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.goliath), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.animateWarrior), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.necromancer), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.necromancer), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.necromancer), 219.4, -90.4, 293.630)
    CreateUnit(Player(0), FourCC(Ids.units.aranakkSpy), 219.4, -90.4, 293.630)

    local PhalynxStorage = require("scenario.storage.phalynx")
    PhalynxStorage:add(CreateUnit(Player(0), FourCC(Ids.units.phalynx), 219.4, -90.4, 293.630))
    PhalynxStorage:add(CreateUnit(Player(0), FourCC(Ids.units.phalynx), 219.4, -90.4, 293.630))
    PhalynxStorage:add(CreateUnit(Player(0), FourCC(Ids.units.phalynx), 219.4, -90.4, 293.630))
    CreateUnit(Player(0), FourCC(Ids.units.colossus), 219.4, -90.4, 293.630)

    local h1 = CreateUnit(Player(0), FourCC(Ids.units.watcher), 219.4, -90.4, 293.630)
    local h2 = CreateUnit(Player(0), FourCC(Ids.units.forgelite), 219.4, -90.4, 293.630)
    SetHeroLevel(h1, 10, false)
    SetHeroLevel(h2, 10, false)

    CreateUnit(Player(1), FourCC(Ids.units.aspirant), -1000.4, -90.4, 293.630)
    CreateUnit(Player(1), FourCC(Ids.units.aspirant), -1000.4, -90.4, 293.630)
    CreateUnit(Player(1), FourCC(Ids.units.shade), -1000.4, -90.4, 293.630)

    local i = CreateUnit(Player(1), FourCC(Ids.units.dummyInvis), -1000.4, -90.4, 293.630)
    IssueImmediateOrder(i, "windwalk")
    IssueImmediateOrder(i, "hold")

    local e = CreateUnit(Player(1), FourCC(Ids.units.aspirant), 219.4, -90.4, 293.630)
    BlzSetUnitMaxHP(e, 1)
    local g = CreateUnit(Player(0), FourCC(Ids.units.abomination), 219.4, -90.4, 293.630)
    SetUnitState(g, UNIT_STATE_LIFE, 1)

    CreateItemLoc(FourCC(Ids.items.dummyHeroItem), Location(200, -100))

    Debug.original.print("IngameConsole:", IngameConsole ~= nil)

    SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 100000)
    SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_LUMBER, 100000)
    SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_FOOD_CAP, 70)
end

return {
    run = run,
}
