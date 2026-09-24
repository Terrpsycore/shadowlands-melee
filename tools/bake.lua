--- Usage: lua tools/bake.lua
--- Asset catalogs: lua tools/bake_assets.lua  (or: wc3 assets .)

local path = dofile("tools/_path.lua")
local root = path.setup()

local iconsPath = root .. "/src/vendor/assets/generated/Icons.lua"
local iconsFile = io.open(iconsPath, "r")
if not iconsFile then
    error(
        "missing src/vendor/assets/generated/Icons.lua — run asset codegen first:\n"
            .. "  wc3 assets .\n"
            .. "  (or: lua tools/bake_assets.lua)"
    )
end
iconsFile:close()

dofile("tools/gen/objediting_meta.lua")
dofile("tools/gen/ability_kinds.lua")
dofile("tools/gen/ids.lua")
dofile("tools/gen/registries.lua")
dofile("tools/gen/validate_scenario.lua")
