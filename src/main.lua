require("lib.init")

require("tests.init")

local dump = require("utils.logger")

Debug.original.print("Hello warcraft-vscode !")

-- src/main.lua
local Ids = require("data.generated.ids")
CreateUnit(Player(0), FourCC(Ids.units.aspirant), 219.4, -90.4, 293.630)
CreateUnit(Player(0), FourCC(Ids.units.aspirant), 219.4, -90.4, 293.630)
CreateUnit(Player(0), FourCC(Ids.units.praetor), 219.4, -90.4, 293.630)
CreateUnit(Player(0), FourCC(Ids.units.larion), 219.4, -90.4, 293.630)
CreateUnit(Player(1), FourCC(Ids.units.aspirant), 219.4, -90.4, 293.630)

-- CreateUnit(Player(0), FourCC(Ids.paladin), 219.4, -90.4, 293.630)

local item = CreateItemLoc(FourCC(Ids.items.dummyHeroItem), Location(200, -100))

Debug.original.print("IngameConsole:", IngameConsole ~= nil)

dump("test", { message = "test" })

dump("item", item)

require("scenario.triggers")
