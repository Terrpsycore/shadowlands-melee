Debug.beginFile("lib.wscode_require_debug")

---Dev-only: load scenario preload modules through WSCode debug transpile (breakpoints / Variables).
local bootstrap = require("lib.bootstrap_config")

local M = {}

local installed = false

---@param filename string preload path (forward slashes)
---@return boolean
local function shouldTranspile(filename)
    if not bootstrap.ENABLE_WSCODE or not bootstrap.ENABLE_WSCODE_SCENARIO_DEBUG then
        return false
    end
    if type(filename) ~= "string" then
        return false
    end
    filename = filename:gsub("\\", "/")
    if not filename:find("^scenario/", 1, true) then
        return false
    end
    if filename:find("^scenario/generated/", 1, true) then
        return false
    end
    return true
end

---@param filename string
---@return string tab
local function resolveTab(filename)
    local ok, index = pcall(require, "scenario.generated.wscode_tab_index")
    if ok and index and index.byPath then
        local key = filename:gsub("\\", "/")
        local entry = index.byPath[key] or index.byPath["@" .. key]
        if entry and entry.tab then
            return entry.tab
        end
    end
    local base = filename:match("([^/]+%.lua)$")
    return base and base:gsub("%.lua$", "") or filename
end

---@param filename string
---@return string?
local function readSource(filename)
    local read = rawget(_G, "__MAP_PRELOAD_SOURCE__")
    if type(read) ~= "function" then
        local pkg = rawget(_G, "package")
        if type(pkg) == "table" and type(pkg.source) == "function" then
            read = pkg.source
        end
    end
    if type(read) == "function" then
        return read(filename)
    end
    return nil
end

---@param filename string
---@param mode string|nil
---@param env table|nil
---@param level integer|nil
---@param inner fun(filename: string, mode?: string, env?: table, level?: integer): function?, string?
---@return function?
---@return string? err
local function compileScenarioDebug(filename, mode, env, level, inner)
    local wscode = rawget(_G, "WSCode")
    if not wscode or type(wscode.CompileRequireModule) ~= "function" then
        return inner(filename, mode, env, level)
    end

    local source = readSource(filename)
    if not source then
        Debug.original.print("|cffff8800[wscode-require] no source for " .. filename .. ", raw load|r")
        return inner(filename, mode, env, level)
    end

    local tab = resolveTab(filename)
    local chunkName = "@" .. filename:gsub("\\", "/")
    local func, err = wscode.CompileRequireModule(tab, source, chunkName)
    if not func then
        Debug.original.print("|cffff8800[wscode-require] transpile failed " .. filename .. ": " .. tostring(err) .. " — raw load|r")
        return inner(filename, mode, env, level)
    end

    return func
end

function M.install()
    if installed then
        return
    end
    if not bootstrap.ENABLE_WSCODE or not bootstrap.ENABLE_WSCODE_SCENARIO_DEBUG then
        return
    end

    rawset(_G, "__MAP_COMPILEFILE_HOOK__", function(filename, mode, env, level, inner)
        if shouldTranspile(filename) then
            return compileScenarioDebug(filename, mode, env, level, inner)
        end
        return inner(filename, mode, env, level)
    end)

    installed = true
    Debug.original.print("|cff88ff88[wscode-require] scenario → WSCode debug transpile (compilefile hook)|r")
end

Debug.endFile()

return M
