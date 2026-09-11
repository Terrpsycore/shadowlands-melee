local M = {}

function M.repoRoot()
    local source = debug.getinfo(1, "S").source
    if source:sub(1, 1) == "@" then
        source = source:sub(2)
    end
    source = source:gsub("\\", "/")
    local toolsDir = source:match("^(.*)/[^/]+$")
    if toolsDir and toolsDir:match("/tools$") then
        return toolsDir:gsub("/tools$", "")
    end
    return "."
end

function M.setup()
    local root = M.repoRoot()
    package.path = table.concat({
        package.path,
        root .. "/src/?.lua",
        root .. "/src/?/init.lua",
        root .. "/src/vendor/assets/objediting/?.lua",
        root .. "/src/vendor/assets/objediting/?/init.lua",
    }, ";")
    return root
end

return M
