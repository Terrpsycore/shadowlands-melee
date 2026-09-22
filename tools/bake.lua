--- Usage: lua tools/bake.lua

local path = dofile("tools/_path.lua")
path.setup()

dofile("tools/gen/objediting_meta.lua")
dofile("tools/gen/ability_kinds.lua")
dofile("tools/gen/ids.lua")
dofile("tools/gen/registries.lua")
dofile("tools/gen/validate_scenario.lua")
