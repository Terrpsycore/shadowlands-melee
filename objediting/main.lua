-- Entry point for wc3 objediting (warcraft-vscode).
-- Implementation lives in tools/oe/.

local src = debug.getinfo(1, "S").source
if src:sub(1, 1) == "@" then
    src = src:sub(2)
end
src = src:gsub("\\", "/")
local root = src:match("^(.*)/objediting/") or "."

os.chdir(root)
dofile("tools/oe/main.lua")
