-- objediting/gen_ids.lua
package.path = table.concat({ package.path, "src/?.lua", "src/?/init.lua" }, ";")

local sources = {
    {
        db = require("data.units"),
        prefixOf = function(row)
            return row.parent:sub(1, 1)
        end,
    },
    {
        db = require("data.abilities"),
        prefixOf = function()
            return "A"
        end,
    },
    {
        db = require("data.items"),
        prefixOf = function()
            return "I"
        end,
    },
}

local outPath = "src/generated/ids.lua"

local assigned = (loadfile(outPath) or function()
    return {}
end)()
local used, nextN = {}, {}

for _, id in pairs(assigned) do
    used[id] = true
    local prefix, n = id:match("^(.)(%d+)$")
    if n then
        nextN[prefix] = math.max(nextN[prefix] or 0, tonumber(n) + 1)
    end
end

local slugToPrefix = {}
local slugs = {}

for _, source in ipairs(sources) do
    for slug, row in pairs(source.db) do
        if slugToPrefix[slug] then
            error("duplicate slug: " .. slug)
        end
        slugToPrefix[slug] = source.prefixOf(row)
        slugs[#slugs + 1] = slug
    end
end
table.sort(slugs)

for _, slug in ipairs(slugs) do
    if not assigned[slug] then
        local prefix = slugToPrefix[slug]
        local n = nextN[prefix] or 0
        while used[prefix .. string.format("%03d", n)] do
            n = n + 1
        end
        local id = prefix .. string.format("%03d", n)
        assigned[slug], used[id], nextN[prefix] = id, true, n + 1
    end
end

local f = assert(io.open(outPath, "w"))
f:write("return {\n")
for _, slug in ipairs(slugs) do
    f:write(("    %s = %q,\n"):format(slug, assigned[slug]))
end
f:write("}\n")
f:close()

local genItemMeta = dofile("objediting/gen_item_meta.lua")
genItemMeta(assigned, require("data.items"))
