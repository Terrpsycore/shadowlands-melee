--- Usage: lua tools/bake.lua

local path = dofile("tools/_path.lua")
path.setup()

dofile("tools/gen/ability_kinds.lua")
dofile("tools/gen/ids.lua")
dofile("tools/gen/registries.lua")
