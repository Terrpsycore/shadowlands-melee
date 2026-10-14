--- Hot reload without war3map loader: compile patches in _ENV and update live registry / globals.
local Registry = {}

--- Utils modules hot-reloadable via inbox; assign module return value to globals (see docs/hot-reload.md).
Registry.utilsGlobalSetters = {
    ["utils.logger"] = function(value)
        _G.dump = value
    end,
    ["utils.generic"] = function(value)
        _G.Generic = value
    end,
}

local scenarioIndexByModule = nil

local function ensureScenarioIndex()
    if scenarioIndexByModule then
        return scenarioIndexByModule
    end
    scenarioIndexByModule = {}
    local registry = require("scenario.generated.abilities_registry")
    for i, mod in ipairs(registry) do
        scenarioIndexByModule[mod] = i
    end
    return scenarioIndexByModule
end

---@param fileKey string e.g. scenario/factions/.../fly.lua
---@return string|nil moduleName e.g. scenario.factions....fly
function Registry.fileKeyToModule(fileKey)
    fileKey = fileKey:gsub("\\", "/")
    if not fileKey:match("%.lua$") then
        return nil
    end
    return fileKey:sub(1, -5):gsub("/", ".")
end

---@param moduleName string
---@return integer|nil
function Registry.scenarioRegistryIndex(moduleName)
    return ensureScenarioIndex()[moduleName]
end

---@param source string
---@param moduleName string
---@return function|nil loader
---@return string|nil err
function Registry.compileModuleSource(source, moduleName)
    return load(source, "@hotreload:" .. moduleName, "t", _ENV)
end

local function applyScenarioPatch(moduleName, source)
    local idx = Registry.scenarioRegistryIndex(moduleName)
    if not idx then
        return false, "not in abilities_registry: " .. moduleName
    end

    local loader, loadErr = Registry.compileModuleSource(source, moduleName)
    if not loader then
        return false, loadErr or "compile failed"
    end

    local ok, result = pcall(loader)
    if not ok then
        return false, tostring(result)
    end
    if type(result) ~= "table" then
        return false, "scenario module must return a table"
    end

    local catalog = require("scenario.abilities")
    catalog.abilities[idx] = result
    return true
end

local function applyUtilsPatch(moduleName, source)
    local setter = Registry.utilsGlobalSetters[moduleName]
    if not setter then
        return false, "utils reload not wired for " .. moduleName .. " (add to Registry.utilsGlobalSetters)"
    end

    local loader, loadErr = Registry.compileModuleSource(source, moduleName)
    if not loader then
        return false, loadErr or "compile failed"
    end

    local ok, result = pcall(loader)
    if not ok then
        return false, tostring(result)
    end
    setter(result)
    return true
end

--- fileKey prefix (under src/) → apply(moduleName, source)
local patchHandlers = {
    {
        prefix = "scenario/",
        apply = applyScenarioPatch,
    },
    {
        prefix = "utils/",
        apply = applyUtilsPatch,
    },
}

---@param moduleName string
---@param source string
---@return boolean ok
---@return string|nil err
function Registry.applyScenarioPatch(moduleName, source)
    return applyScenarioPatch(moduleName, source)
end

---@param moduleName string
---@param source string
---@return boolean ok
---@return string|nil err
function Registry.applyUtilsPatch(moduleName, source)
    return applyUtilsPatch(moduleName, source)
end

---@param fileKey string
---@param source string
---@return boolean ok
---@return string|nil err
function Registry.applyPatch(fileKey, source)
    fileKey = fileKey:gsub("\\", "/")
    local moduleName = Registry.fileKeyToModule(fileKey)
    if not moduleName then
        return false, "bad file key: " .. tostring(fileKey)
    end

    for _, route in ipairs(patchHandlers) do
        if fileKey:sub(1, #route.prefix) == route.prefix then
            return route.apply(moduleName, source)
        end
    end
    return false, "unsupported path: " .. fileKey
end

return Registry
