-- objediting/gen_ids.lua
package.path = table.concat({ package.path, "src/?.lua", "src/?/init.lua" }, ";")

local sources = {
    {
        domain = "units",
        db = require("data.units"),
        prefixOf = function(row)
            return row.parent:sub(1, 1)
        end,
    },
    {
        domain = "abilities",
        db = require("data.abilities"),
        prefixOf = function()
            return "A"
        end,
    },
    {
        domain = "items",
        db = require("data.items"),
        prefixOf = function()
            return "I"
        end,
    },
    {
        domain = "buffs",
        db = require("data.buffs"),
        prefixOf = function()
            return "B"
        end,
    },
}

local outPath = "src/data/generated/ids.lua"

local previous = (loadfile(outPath) or function()
    return {}
end)()
local used, nextN = {}, {}

local function markId(id)
    if type(id) ~= "string" then
        return
    end
    used[id] = true
    local prefix, n = id:match("^(.)(%d+)$")
    if n then
        nextN[prefix] = math.max(nextN[prefix] or 100, tonumber(n) + 1)
    end
end

local assigned = {}
for _, source in ipairs(sources) do
    assigned[source.domain] = {}
end

local nested = false
for _, source in ipairs(sources) do
    if type(previous[source.domain]) == "table" then
        nested = true
        break
    end
end

if nested then
    for domain, map in pairs(previous) do
        if type(map) == "table" then
            for slug, id in pairs(map) do
                markId(id)
                if assigned[domain] and type(id) == "string" then
                    assigned[domain][slug] = id
                end
            end
        end
    end
else
    local slugToDomain = {}
    for _, source in ipairs(sources) do
        for slug in pairs(source.db) do
            slugToDomain[slug] = source.domain
        end
    end
    for slug, id in pairs(previous) do
        markId(id)
        local domain = slugToDomain[slug]
        if domain and type(id) == "string" then
            assigned[domain][slug] = id
        end
    end
end

local function nextId(prefix)
    local n = nextN[prefix] or 100
    while used[prefix .. string.format("%03d", n)] do
        n = n + 1
    end
    local id = prefix .. string.format("%03d", n)
    used[id] = true
    nextN[prefix] = n + 1
    return id
end

local domainSlugs = {}
for _, source in ipairs(sources) do
    local slugs = {}
    for slug in pairs(source.db) do
        slugs[#slugs + 1] = slug
    end
    table.sort(slugs)
    domainSlugs[source.domain] = slugs

    local domainAssigned = assigned[source.domain]
    for _, slug in ipairs(slugs) do
        if not domainAssigned[slug] then
            domainAssigned[slug] = nextId(source.prefixOf(source.db[slug]))
        end
    end
end

local f = assert(io.open(outPath, "w"))
f:write("return {\n")
for _, source in ipairs(sources) do
    local domain = source.domain
    f:write(("    %s = {\n"):format(domain))
    for _, slug in ipairs(domainSlugs[domain]) do
        f:write(("        %s = %q,\n"):format(slug, assigned[domain][slug]))
    end
    f:write("    },\n")
end
f:write("}\n")
f:close()

local genItemMeta = dofile("objediting/gen_item_meta.lua")
genItemMeta(assigned.items, require("data.items"))
