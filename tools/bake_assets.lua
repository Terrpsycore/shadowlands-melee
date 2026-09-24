--- Regenerate asset catalogs (Icons, Models, …) and sync custom imports.
--- Usage: lua tools/bake_assets.lua

local path = dofile("tools/_path.lua")
path.setup()

dofile("tools/gen/asset_catalogs.lua")
dofile("tools/gen/sync_imports.lua")
