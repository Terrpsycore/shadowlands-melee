package.path = table.concat({
    package.path,
    "../src/?.lua",
    "../src/?/init.lua",
}, ";")

require("lib.objediting.inventory")

local create = dofile("create.lua")

create(require("data.units"), dofile("kinds/units.lua"))
create(require("data.abilities"), dofile("kinds/abilities.lua"))
create(require("data.items"), dofile("kinds/items.lua"))
