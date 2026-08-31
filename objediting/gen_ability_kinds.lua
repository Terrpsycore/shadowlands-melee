package.path = table.concat({ package.path, "src/?.lua", "src/?/init.lua" }, ";")

local AbilityIds = require("lib.community.types.assets.AbilityIds")

local srcPath = "src/lib/community/types/assets/objediting/object/AbilityObjEditing.lua"
local classesPath = "src/data/generated/ability_classes.lua"
local factoriesPath = "src/data/generated/ability_factories.lua"

local identPattern = "^[%a_][%w_]*$"

local function isIdent(name)
    return type(name) == "string" and name:match(identPattern) ~= nil
end

local src = assert(io.open(srcPath, "r"))
local text = src:read("*a")
src:close()

local classesByParent = {}
for className, parentId in
    text:gmatch(
        "function (AbilityDefinition[%w]+):constructor%(id%)%s+self%.def = createDefinition%(DefinitionType%.Ability, id, '([^']+)'%)"
    )
do
    local list = classesByParent[parentId]
    if not list then
        list = {}
        classesByParent[parentId] = list
    end
    local seen = false
    for _, existing in ipairs(list) do
        if existing == className then
            seen = true
            break
        end
    end
    if not seen then
        list[#list + 1] = className
    end
end

local classByParent = {}
for parentId, list in pairs(classesByParent) do
    table.sort(list)
    classByParent[parentId] = list[1]
end

if next(classByParent) == nil then
    error("no ability constructors parsed from " .. srcPath)
end

local keysByParent = {}
for key, parentId in pairs(AbilityIds) do
    if type(parentId) == "string" then
        local keys = keysByParent[parentId]
        if not keys then
            keys = {}
            keysByParent[parentId] = keys
        end
        keys[#keys + 1] = key
    end
end

local parentIds = {}
for parentId in pairs(classByParent) do
    parentIds[#parentIds + 1] = parentId
end
table.sort(parentIds)

local factoryRows = {}
for _, parentId in ipairs(parentIds) do
    local keys = keysByParent[parentId]
    if keys then
        table.sort(keys)
        for _, key in ipairs(keys) do
            if not isIdent(key) then
                error("AbilityIds key is not a Lua identifier: " .. tostring(key))
            end
            factoryRows[#factoryRows + 1] = {
                key = key,
                className = classByParent[parentId],
            }
        end
    end
end

local function formatKey(id)
    if isIdent(id) then
        return id
    end
    return ("[%q]"):format(id)
end

local classesFile = assert(io.open(classesPath, "w"))
classesFile:write("return {\n")
for _, parentId in ipairs(parentIds) do
    classesFile:write(("    %s = %s,\n"):format(formatKey(parentId), classByParent[parentId]))
end
classesFile:write("}\n")
classesFile:close()

local function factoryClassName(key)
    return "AbilityFactory" .. key:sub(1, 1):upper() .. key:sub(2)
end

local factoriesFile = assert(io.open(factoriesPath, "w"))
factoriesFile:write('local AbilityIds = require("lib.community.types.assets.AbilityIds")\n\n')
factoriesFile:write("---@class AbilityRow<T: AbilityDefinition>\n")
factoriesFile:write("---@field parent string\n")
factoriesFile:write("---@field name? string\n")
factoriesFile:write("---@field levels? integer\n")
factoriesFile:write("---@field buffs? string[]\n")
factoriesFile:write("---@field autocastRange? number\n")
factoriesFile:write("---@field options? integer\n")
factoriesFile:write("---@field buttonNormalX? integer\n")
factoriesFile:write("---@field buttonNormalY? integer\n")
factoriesFile:write("---@field apply? fun(a: T)\n\n")
factoriesFile:write("local function pack(parent, data)\n")
factoriesFile:write("    data = data or {}\n")
factoriesFile:write("    data.parent = parent\n")
factoriesFile:write("    return data\n")
factoriesFile:write("end\n\n")
factoriesFile:write("local function identity(fn)\n")
factoriesFile:write("    return fn\n")
factoriesFile:write("end\n\n")
factoriesFile:write("local callMt = {\n")
factoriesFile:write("    __call = function(self, data)\n")
factoriesFile:write("        return pack(self.parent, data)\n")
factoriesFile:write("    end,\n")
factoriesFile:write("}\n\n")
factoriesFile:write("local A = {}\n\n")
for _, row in ipairs(factoryRows) do
    local factoryClass = factoryClassName(row.key)
    factoriesFile:write(("---@class %s\n"):format(factoryClass))
    factoriesFile:write(
        ("---@overload fun(data: AbilityRow<%s>?): AbilityRow<%s>\n"):format(row.className, row.className)
    )
    factoriesFile:write(("---@field apply fun(fn: fun(a: %s)): fun(a: %s)\n\n"):format(row.className, row.className))
    factoriesFile:write(("---@type %s\n"):format(factoryClass))
    factoriesFile:write(("A.%s = setmetatable({\n"):format(row.key))
    factoriesFile:write(("    parent = AbilityIds.%s,\n"):format(row.key))
    factoriesFile:write("    apply = identity,\n")
    factoriesFile:write("}, callMt)\n\n")
end
factoriesFile:write("return A\n")
factoriesFile:close()
