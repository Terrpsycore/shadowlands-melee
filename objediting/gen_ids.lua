---@class SourceDef
---@field domain string
---@field db table<string, any>
---@field prefixOf fun(row: any): string

---@class AssignedMap
---@field units table<string, string>
---@field abilities table<string, string>
---@field items table<string, string>
---@field buffs table<string, string>

---@class DomainSlugs
---@field units string[]
---@field abilities string[]
---@field items string[]
---@field buffs string[]

package.path = table.concat({ package.path, "src/?.lua", "src/?/init.lua" }, ";")

local SOURCES = {
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

local OUT_PATH = "src/data/generated/ids.lua"

---@class Generator
---@field usedIds table<string, boolean>
---@field nextCounters table<string, integer>
local Generator = {}
Generator.__index = Generator

--- @return Generator
function Generator:new()
    return setmetatable({
        usedIds = {},
        nextCounters = {},
    }, Generator)
end

function Generator:generateIds()
    local previous = self:loadPreviousState()
    local database = self:registerNewIds(previous)
    local sortedIds = self:sortIds(database)

    self:write(database, sortedIds)

    local genItemMeta = dofile("objediting/gen_item_meta.lua")
    genItemMeta(database.items, require("data.items"))
    dofile("objediting/gen_ability_kinds.lua")
end

--- @return AssignedMap
function Generator:loadPreviousState()
    local previous = (loadfile(OUT_PATH) or function()
        return {}
    end)()

    local assigned = {}
    for _, source in ipairs(SOURCES) do
        assigned[source.domain] = {}
    end

    for domain, map in pairs(previous) do
        for slug, id in pairs(map) do
            self:mark(id)
            assigned[domain][slug] = id
        end
    end

    return assigned
end

--- @param database AssignedMap
function Generator:registerNewIds(database)
    -- Mutates <database> table param
    for _, source in ipairs(SOURCES) do
        local domainAssigned = database[source.domain]
        for slug in pairs(source.db) do
            if not domainAssigned[slug] then
                domainAssigned[slug] = self:next(source.prefixOf(source.db[slug]))
            end
        end
    end
    return database
end

--- @param database AssignedMap
--- @return DomainSlugs
function Generator:sortIds(database)
    local domainSlugs = {}
    for _, source in ipairs(SOURCES) do
        local slugs = {}
        for slug in pairs(database[source.domain]) do -- pairs(source.db) - before
            slugs[#slugs + 1] = slug
        end
        table.sort(slugs)
        domainSlugs[source.domain] = slugs
    end
    return domainSlugs
end

--- @param database AssignedMap
--- @param sortedIds DomainSlugs
function Generator:write(database, sortedIds)
    local f = assert(io.open(OUT_PATH, "w"))
    f:write("return {\n")
    for _, source in ipairs(SOURCES) do
        local domain = source.domain
        f:write(("    %s = {\n"):format(domain))
        for _, slug in ipairs(sortedIds[domain]) do
            f:write(("        %s = %q,\n"):format(slug, database[domain][slug]))
        end
        f:write("    },\n")
    end
    f:write("}\n")
    f:close()
end

--- @param id string
function Generator:mark(id)
    self.usedIds[id] = true

    local prefix, num = id:match("^(.)(%d+)$")
    if num then
        local n = tonumber(num)
        self.nextCounters[prefix] = math.max(self.nextCounters[prefix] or 100, n + 1)
    end
end

--- @param prefix string
--- @return string
function Generator:next(prefix)
    local counter = self.nextCounters[prefix] or 100

    while self.usedIds[prefix .. string.format("%03d", counter)] do
        counter = counter + 1
    end

    local id = prefix .. string.format("%03d", counter)
    self.usedIds[id] = true
    self.nextCounters[prefix] = counter + 1

    return id
end

Generator:new():generateIds()
