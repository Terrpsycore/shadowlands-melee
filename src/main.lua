require("lib.init")
local dump = require("utils.logger")

Debug.original.print("Hello warcraft-vscode !")

-- src/main.lua
local Ids = require("generated.ids")
CreateUnit(Player(0), FourCC(Ids.units.dummy), 219.4, -90.4, 293.630)

CreateUnit(Player(0), FourCC(Ids.paladin), 219.4, -90.4, 293.630)

local item = CreateItemLoc(FourCC(Ids.items.dummyHeroItem), { x = 200, y = -100 })

Debug.original.print("IngameConsole:", IngameConsole ~= nil)

dump({ message = "test" })

dump(item)
