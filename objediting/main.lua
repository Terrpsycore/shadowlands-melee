package.path = table.concat({
    package.path,
    "../src/?.lua",
    "../src/?/init.lua",
}, ";")

require("lib.objediting.inventory")

local Ids = require("data.generated.ids")
local create = dofile("create.lua")

create(require("data.abilities"), dofile("kinds/abilities.lua"), Ids.abilities)
create(require("data.units"), dofile("kinds/units.lua"), Ids.units)
create(require("data.items"), dofile("kinds/items.lua"), Ids.items)
