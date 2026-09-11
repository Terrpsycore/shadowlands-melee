package.path = table.concat({
    package.path,
    "src/?.lua",
    "src/?/init.lua",
    "src/vendor/assets/objediting/?.lua",
    "src/vendor/assets/objediting/?/init.lua",
}, ";")

local AbilityIds = require("vendor.assets.AbilityIds")
local rowFields = dofile("objediting/ability_row_fields.lua")

local srcPath = "src/vendor/assets/objediting/object/AbilityObjEditing.lua"
local abilityLuaPath = "src/data/ability.lua"
local classesPath = "src/data/generated/ability_classes.lua"
local factoriesPath = "src/data/generated/ability_factories.lua"
local abilityMetaPath = "src/data/ability.meta.lua"

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
        'function (AbilityDefinition[%w]+):constructor%(id%)%s+self%.def = createDefinition%(DefinitionType%.Ability, id, "([^"]+)"%)'
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

local function rowInputClassName(key)
    return "AbilityRowInput" .. key:sub(1, 1):upper() .. key:sub(2)
end

local function parseAbilityPresets(path)
    local file = assert(io.open(path, "r"))
    local text = file:read("*a")
    file:close()

    local presets = {}
    for presetName, baseKey in text:gmatch("(%w+) = presetFactory%(F%.(%w+),") do
        if not isIdent(presetName) then
            error("ability preset name is not a Lua identifier: " .. presetName)
        end
        if not isIdent(baseKey) then
            error("ability preset base is not a Lua identifier: " .. baseKey)
        end
        presets[#presets + 1] = { name = presetName, base = baseKey }
    end

    table.sort(presets, function(a, b)
        return a.name < b.name
    end)

    return presets
end

local factoriesFile = assert(io.open(factoriesPath, "w"))
factoriesFile:write('local AbilityIds = require("vendor.assets.AbilityIds")\n\n')
factoriesFile:write("---@class AbilityRowInput\n")
for _, field in ipairs(rowFields) do
    local name, fieldType, optional = field[1], field[2], field.optional
    local marker = optional and "?" or ""
    factoriesFile:write(("---@field %s%s %s\n"):format(name, marker, fieldType))
end
factoriesFile:write("\n---@class AbilityRow : AbilityRowInput\n")
factoriesFile:write("---@field parent string\n\n")
factoriesFile:write("---@class AbilityFactory\n")
factoriesFile:write("---@field parent string\n")
factoriesFile:write("---@overload fun(data?: AbilityRowInput): AbilityRow\n\n")
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
factoriesFile:write("---@class PresetFactory\n")
for _, row in ipairs(factoryRows) do
    local factoryClass = factoryClassName(row.key)
    local rowInputClass = rowInputClassName(row.key)
    factoriesFile:write(
        ("---@overload fun(base: %s, preset: %s): %s\n"):format(
            factoryClass,
            rowInputClass,
            factoryClass
        )
    )
end
factoriesFile:write("\n---@class AbilityFactories\n")
for _, row in ipairs(factoryRows) do
    local factoryClass = factoryClassName(row.key)
    factoriesFile:write(("---@field %s %s\n"):format(row.key, factoryClass))
end
factoriesFile:write("\nlocal A = {}\n\n")
for _, row in ipairs(factoryRows) do
    local factoryClass = factoryClassName(row.key)
    local rowInputClass = rowInputClassName(row.key)
    factoriesFile:write(("---@class %s : AbilityRowInput\n"):format(rowInputClass))
    factoriesFile:write(("---@field apply? fun(a: %s)\n\n"):format(row.className))
    factoriesFile:write(("---@class %s : AbilityFactory\n"):format(factoryClass))
    factoriesFile:write(
        ("---@field apply fun(fn: fun(a: %s)): fun(a: %s)\n"):format(row.className, row.className)
    )
    factoriesFile:write(("---@overload fun(data?: %s): AbilityRow\n\n"):format(rowInputClass))
    factoriesFile:write(("---@type %s\n"):format(factoryClass))
    factoriesFile:write(("A.%s = setmetatable({\n"):format(row.key))
    factoriesFile:write(("    parent = AbilityIds.%s,\n"):format(row.key))
    factoriesFile:write("    apply = identity,\n")
    factoriesFile:write("}, callMt)\n\n")
end
factoriesFile:write("\n---@type AbilityFactories\n")
factoriesFile:write("return A\n")
factoriesFile:close()

local abilityPresets = parseAbilityPresets(abilityLuaPath)

local abilityMetaFile = assert(io.open(abilityMetaPath, "w"))
abilityMetaFile:write("--- Autogenerated by objediting/gen_ability_kinds.lua - do not edit\n")
abilityMetaFile:write("---@meta\n\n")
abilityMetaFile:write("---@class AbilityFactoryInventory\n")
abilityMetaFile:write("---@field parent string\n")
abilityMetaFile:write("---@field apply fun(fn: fun(a: AbilityInventory)): fun(a: AbilityInventory)\n\n")
abilityMetaFile:write("---@class AbilityModule : AbilityFactories\n")
for _, preset in ipairs(abilityPresets) do
    local factoryClass = factoryClassName(preset.base)
    abilityMetaFile:write(("---@field %s %s\n"):format(preset.name, factoryClass))
end
abilityMetaFile:write("---@field inventory AbilityFactoryInventory\n")
abilityMetaFile:close()
