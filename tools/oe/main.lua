--- Usage: lua tools/oe/main.lua

local path = dofile("tools/_path.lua")
path.setup()

require("lib.objediting.inventory")

local Ids = require("data.generated.ids")
local create = dofile("tools/oe/create.lua")

create(require("data.buffs"), dofile("tools/oe/kinds/buffs.lua"), Ids.buffs)
create(require("data.abilities"), dofile("tools/oe/kinds/abilities.lua"), Ids.abilities)
create(require("data.units"), dofile("tools/oe/kinds/units.lua"), Ids.units)
create(require("data.items"), dofile("tools/oe/kinds/items.lua"), Ids.items)
