local AbilityIds = require("vendor.assets.AbilityIds")
local AbilityBaseIds = require("data.abilityBaseIds")
local rowFields = dofile("tools/oe/ability_row_fields.lua")

local vendorClassSrc = "src/vendor/assets/objediting/object/AbilityObjEditing.lua"
local localClassGlob = "src/lib/objediting/bases"
local abilityLuaPath = "src/data/abilityPresets.lua"
local classesPath = "src/data/generated/ability_classes.lua"
local factoriesPath = "src/data/generated/ability_factories.lua"
local abilityMetaPath = "src/data/ability.meta.lua"

local identPattern = "^[%a_][%w_]*$"

local function isIdent(name)
    return type(name) == "string" and name:match(identPattern) ~= nil
end

for key in pairs(AbilityBaseIds) do
    if AbilityIds[key] then
        error("abilityBaseIds key overlaps vendor AbilityIds: " .. key)
    end
    if not isIdent(key) then
        error("abilityBaseIds key is not a Lua identifier: " .. tostring(key))
    end
end

local constructorPattern =
    'function (AbilityDefinition[%w]+):constructor%(id%)%s+self%.def = createDefinition%(DefinitionType%.Ability, id, "([^"]+)"%)'

local function parseConstructors(text)
    local classesByParent = {}
    for className, parentId in text:gmatch(constructorPattern) do
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
    return classesByParent
end

local function readFile(path)
    local file = assert(io.open(path, "r"))
    local text = file:read("*a")
    file:close()
    return text
end

local function mergeClassesByParent(into, from)
    for parentId, list in pairs(from) do
        local target = into[parentId]
        if not target then
            into[parentId] = {}
            target = into[parentId]
        end
        for _, className in ipairs(list) do
            local seen = false
            for _, existing in ipairs(target) do
                if existing == className then
                    seen = true
                    break
                end
            end
            if not seen then
                target[#target + 1] = className
            end
        end
    end
end

local classesByParent = parseConstructors(readFile(vendorClassSrc))

local localDir = assert(io.popen('dir /b "' .. localClassGlob:gsub("/", "\\") .. '" 2>nul'))
for name in localDir:lines() do
    if name:match("%.lua$") and name ~= "init.lua" then
        local path = localClassGlob .. "/" .. name
        mergeClassesByParent(classesByParent, parseConstructors(readFile(path)))
    end
end
localDir:close()

local classByParent = {}
for parentId, list in pairs(classesByParent) do
    table.sort(list)
    classByParent[parentId] = list[1]
end

if next(classByParent) == nil then
    error("no ability constructors parsed from vendor or local bases")
end

local keysByParent = {}
local keySource = {}

local function addKey(key, parentId, source)
    if type(parentId) ~= "string" then
        return
    end
    if keySource[key] and keySource[key] ~= source then
        error(string.format("ability id key %q defined in both vendor and local tables", key))
    end
    keySource[key] = source
    local keys = keysByParent[parentId]
    if not keys then
        keys = {}
        keysByParent[parentId] = keys
    end
    keys[#keys + 1] = key
end

for key, parentId in pairs(AbilityIds) do
    addKey(key, parentId, "vendor")
end
for key, parentId in pairs(AbilityBaseIds) do
    addKey(key, parentId, "local")
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
                source = keySource[key],
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
    local text = readFile(path)

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

local function parentAccessor(row)
    if row.source == "local" then
        return ("AbilityBaseIds.%s"):format(row.key)
    end
    return ("AbilityIds.%s"):format(row.key)
end

local factoriesFile = assert(io.open(factoriesPath, "w"))
factoriesFile:write('local AbilityIds = require("vendor.assets.AbilityIds")\n')
factoriesFile:write('local AbilityBaseIds = require("data.abilityBaseIds")\n\n')
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
    factoriesFile:write(("---@field apply? fun(a: %s, level?: integer)\n\n"):format(row.className))
    factoriesFile:write(("---@class %s : AbilityFactory\n"):format(factoryClass))
    factoriesFile:write(
        ("---@field apply fun(fn: fun(a: %s, level?: integer)): fun(a: %s, level?: integer)\n"):format(
            row.className,
            row.className
        )
    )
    factoriesFile:write(("---@overload fun(data?: %s): AbilityRow\n\n"):format(rowInputClass))
    factoriesFile:write(("---@type %s\n"):format(factoryClass))
    factoriesFile:write(("A.%s = setmetatable({\n"):format(row.key))
    factoriesFile:write(("    parent = %s,\n"):format(parentAccessor(row)))
    factoriesFile:write("    apply = identity,\n")
    factoriesFile:write("}, callMt)\n\n")
end
factoriesFile:write("\n---@type AbilityFactories\n")
factoriesFile:write("return A\n")
factoriesFile:close()

local abilityPresets = parseAbilityPresets(abilityLuaPath)

local abilityMetaFile = assert(io.open(abilityMetaPath, "w"))
abilityMetaFile:write("--- Autogenerated by tools/gen/ability_kinds.lua - do not edit\n")
abilityMetaFile:write("---@meta\n\n")
abilityMetaFile:write("---@class AbilityFactoryInventory\n")
abilityMetaFile:write("---@field parent string\n")
abilityMetaFile:write(
    "---@field apply fun(fn: fun(a: AbilityInventory, level?: integer)): fun(a: AbilityInventory, level?: integer)\n\n"
)
abilityMetaFile:write("---@class AbilityModule : AbilityFactories\n")
for _, preset in ipairs(abilityPresets) do
    local factoryClass = factoryClassName(preset.base)
    abilityMetaFile:write(("---@field %s %s\n"):format(preset.name, factoryClass))
end
abilityMetaFile:write("---@field inventory AbilityFactoryInventory\n")
abilityMetaFile:close()
