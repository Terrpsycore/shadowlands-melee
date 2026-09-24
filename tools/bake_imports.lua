--- Sync referenced custom icons into imports/.
--- Usage: lua tools/bake_imports.lua

local path = dofile("tools/_path.lua")
path.setup()

dofile("tools/gen/sync_imports.lua")
