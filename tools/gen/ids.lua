---@class SourceDef
---@field domain string
---@field db table<string, any>
---@field prefixOf fun(row: any): string

---@class AssignedMap
---@field units table<string, string>
---@field abilities table<string, string>
---@field items table<string, string>
---@field buffs table<string, string>
---@field upgrades table<string, string>

---@class DomainSlugs
---@field units string[]
---@field abilities string[]
---@field items string[]
---@field buffs string[]
---@field upgrades string[]

local GENERATED_DIR = "src/data/generated"
local winPath = GENERATED_DIR:gsub("/", "\\")
os.execute('if not exist "' .. winPath .. '" mkdir "' .. winPath .. '"')

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
    {
        domain = "upgrades",
        db = require("data.upgrades"),
        prefixOf = function()
            return "R"
        end,
    },
}

local OUT_PATH = "src/data/generated/ids.lua"
local SLUGS_OUT_PATH = "src/data/generated/id_slugs.lua"
local REVERSE_OUT_PATH = "src/data/generated/id_reverse.lua"

local SLUG_ALIAS_BY_DOMAIN = {
    abilities = "AbilitySlug",
    units = "UnitSlug",
    buffs = "BuffSlug",
    items = "ItemSlug",
    upgrades = "UpgradeSlug",
}

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
    self:pruneOrphans(database)
    self:validate(database)
    local sortedIds = self:sortIds(database)

    self:write(database, sortedIds)
    self:writeSlugAliases(sortedIds)
    self:writeReverse(database, sortedIds)

    local genItemMeta = dofile("tools/gen/item_meta.lua")
    genItemMeta(database.items, require("data.items"))

    local genUnitMeta = dofile("tools/gen/unit_meta.lua")
    genUnitMeta(database.units, require("data.units"))
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
function Generator:pruneOrphans(database)
    for _, source in ipairs(SOURCES) do
        local domainAssigned = database[source.domain]
        for slug in pairs(domainAssigned) do
            if not source.db[slug] then
                domainAssigned[slug] = nil
            end
        end
    end
end

--- @param database AssignedMap
function Generator:validate(database)
    local idOwner = {}
    for _, source in ipairs(SOURCES) do
        local domain = source.domain
        local seenInDomain = {}
        for slug, id in pairs(database[domain]) do
            if seenInDomain[id] then
                error(
                    string.format(
                        "duplicate id %s in %s: %s and %s",
                        id,
                        domain,
                        seenInDomain[id],
                        slug
                    )
                )
            end
            seenInDomain[id] = slug

            local owner = idOwner[id]
            if owner then
                error(
                    string.format(
                        "cross-domain id collision %s: %s.%s and %s.%s",
                        id,
                        owner.domain,
                        owner.slug,
                        domain,
                        slug
                    )
                )
            end
            idOwner[id] = { domain = domain, slug = slug }
        end
    end
end

--- @param database AssignedMap
function Generator:registerNewIds(database)
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
        for slug in pairs(database[source.domain]) do
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

--- @param database AssignedMap
--- @param sortedIds DomainSlugs
function Generator:writeReverse(database, sortedIds)
    local f = assert(io.open(REVERSE_OUT_PATH, "w"))
    f:write("return {\n")
    for _, source in ipairs(SOURCES) do
        local domain = source.domain
        f:write(("    %s = {\n"):format(domain))
        for _, slug in ipairs(sortedIds[domain]) do
            local id = database[domain][slug]
            f:write(("        [%q] = %q,\n"):format(id, slug))
        end
        f:write("    },\n")
    end
    f:write("}\n")
    f:close()
end

--- @param sortedIds DomainSlugs
function Generator:writeSlugAliases(sortedIds)
    local f = assert(io.open(SLUGS_OUT_PATH, "w"))
    f:write("---@meta\n\n")
    for _, source in ipairs(SOURCES) do
        local domain = source.domain
        local aliasName = SLUG_ALIAS_BY_DOMAIN[domain]
        f:write(("---@alias %s\n"):format(aliasName))
        local slugs = sortedIds[domain]
        for i, slug in ipairs(slugs) do
            local prefix = i == 1 and "---" or "---|"
            f:write(('%s "%s"\n'):format(prefix, slug))
        end
        f:write("\n")
    end
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
