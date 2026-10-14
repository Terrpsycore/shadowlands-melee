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

---@param moduleName string
---@param source string
---@return boolean ok
---@return table|nil commit { kind = "scenario", idx = number, value = table } | { kind = "utils", setter = function, value = any }
---@return string|nil err
local function loadPatchCommit(moduleName, source)
    local idx = Registry.scenarioRegistryIndex(moduleName)
    if idx then
        local loader, loadErr = Registry.compileModuleSource(source, moduleName)
        if not loader then
            return false, nil, loadErr or "compile failed"
        end
        local ok, result = pcall(loader)
        if not ok then
            return false, nil, tostring(result)
        end
        if type(result) ~= "table" then
            return false, nil, "scenario module must return a table"
        end
        return true, { kind = "scenario", idx = idx, value = result }
    end

    local setter = Registry.utilsGlobalSetters[moduleName]
    if setter then
        local loader, loadErr = Registry.compileModuleSource(source, moduleName)
        if not loader then
            return false, nil, loadErr or "compile failed"
        end
        local ok, result = pcall(loader)
        if not ok then
            return false, nil, tostring(result)
        end
        return true, { kind = "utils", setter = setter, value = result }
    end

    if moduleName:match("^scenario%.") then
        return false, nil, "not in abilities_registry: " .. moduleName
    end
    if moduleName:match("^utils%.") then
        return false, nil, "utils reload not wired for " .. moduleName .. " (add to Registry.utilsGlobalSetters)"
    end
    return false, nil, "unsupported module: " .. moduleName
end

local function commitPatch(entry)
    if entry.kind == "scenario" then
        local catalog = require("scenario.abilities")
        catalog.abilities[entry.idx] = entry.value
        return
    end
    entry.setter(entry.value)
end

local function applyScenarioPatch(moduleName, source)
    local ok, commit, err = loadPatchCommit(moduleName, source)
    if not ok then
        return false, err
    end
    if commit.kind ~= "scenario" then
        return false, "not a scenario module: " .. moduleName
    end
    commitPatch(commit)
    return true
end

local function applyUtilsPatch(moduleName, source)
    local ok, commit, err = loadPatchCommit(moduleName, source)
    if not ok then
        return false, err
    end
    if commit.kind ~= "utils" then
        return false, "not a utils module: " .. moduleName
    end
    commitPatch(commit)
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

--- Validate all patches, then commit (no partial catalog updates on batch failure).
---@param patches { file: string, source: string }[]
---@return boolean ok
---@return string|nil err
function Registry.applyPatches(patches)
    local commits = {}
    for _, patch in ipairs(patches) do
        local fileKey = patch.file:gsub("\\", "/")
        local moduleName = Registry.fileKeyToModule(fileKey)
        if not moduleName then
            return false, "bad file key: " .. tostring(fileKey)
        end

        local routed = false
        for _, route in ipairs(patchHandlers) do
            if fileKey:sub(1, #route.prefix) == route.prefix then
                routed = true
                break
            end
        end
        if not routed then
            return false, "unsupported path: " .. fileKey
        end

        local ok, commit, err = loadPatchCommit(moduleName, patch.source)
        if not ok then
            return false, fileKey .. ": " .. tostring(err)
        end
        commits[#commits + 1] = commit
    end

    for i = 1, #commits do
        commitPatch(commits[i])
    end
    return true
end

return Registry
