require("lib.init")

require("tests.init")

local dump = require("utils.logger")

Debug.original.print("Hello warcraft-vscode !")

-- src/main.lua
local Ids = require("data.generated.ids")
CreateUnit(Player(0), FourCC(Ids.units.steward), 219.4, -90.4, 293.630)
CreateUnit(Player(0), FourCC(Ids.units.aspirant), 219.4, -90.4, 293.630)
CreateUnit(Player(0), FourCC(Ids.units.aspirant), 219.4, -90.4, 293.630)
CreateUnit(Player(0), FourCC(Ids.units.praetor), 219.4, -90.4, 293.630)
CreateUnit(Player(0), FourCC(Ids.units.praetor), 219.4, -90.4, 293.630)
CreateUnit(Player(0), FourCC(Ids.units.purity), 219.4, -90.4, 293.630)
CreateUnit(Player(0), FourCC(Ids.units.larion), 219.4, -90.4, 293.630)
CreateUnit(Player(1), FourCC(Ids.units.aspirant), 219.4, -90.4, 293.630)
local e = CreateUnit(Player(1), FourCC(Ids.units.aspirant), 219.4, -90.4, 293.630)
BlzSetUnitMaxHP(e, 1)

-- CreateUnit(Player(0), FourCC(Ids.paladin), 219.4, -90.4, 293.630)

local item = CreateItemLoc(FourCC(Ids.items.dummyHeroItem), Location(200, -100))

Debug.original.print("IngameConsole:", IngameConsole ~= nil)

require("scenario.triggers")

local Storage = require("lib.storage.storage")
Storage.initAll()

local formation = require("scenario.factions.kyrian.abilities.formation")
for i = 1, 12 do
    -- local phalynx = CreateUnit(Player(0), FourCC(Ids.units.phalynx), 219.4, -90.4, 293.630)
    -- formation.debug.onTrain(phalynx)
end
