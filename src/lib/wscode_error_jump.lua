Debug.beginFile("lib.wscode_error_jump")

---Jump WSCode editor to @preload-path errors (require-based scenario modules).
local bootstrap = require("lib.bootstrap_config")
require("vendor.ext.Timed")

local M = {}

local installed = false
local prevErrorHandler
local tabIndex
---@type fun(filename: string): string?|nil
local preloadSourceFn

local function logSkip(reason)
    Debug.original.print("|cffff8800[wscode-jump] " .. reason .. "|r")
end

---@param rawMsg string
---@return string? preloadPath
---@return integer? line
local function parsePreloadLocation(rawMsg)
    if type(rawMsg) ~= "string" or rawMsg == "" then
        return nil, nil
    end
    local path, line = rawMsg:match("(@?[^:\n]+%.lua):(%d+):")
    if not path or not line then
        return nil, nil
    end
    path = path:gsub("\\", "/"):gsub("^@", "")
    if path:sub(1, 4) == "src/" then
        path = path:sub(5)
    end
    if path:find("^factions/", 1, true) then
        path = "scenario/" .. path
    end
    return path, tonumber(line)
end

---@return table?
local function getTabIndex()
    if tabIndex then
        return tabIndex
    end
    local ok, loaded = pcall(require, "scenario.generated.wscode_tab_index")
    if ok and loaded and loaded.byPath then
        tabIndex = loaded
        return tabIndex
    end
    logSkip("index missing (run bake): " .. tostring(loaded))
    return nil
end

---@param path string
---@return { tab: string, preloadKey: string }?
local function resolveEntry(path)
    local index = getTabIndex()
    if index then
        local entry = index.byPath[path]
        if entry then
            return entry
        end
        local fileName = path:match("([^/]+%.lua)$")
        if fileName then
            local suffix = "/" .. fileName
            local bestKey
            for key, entryValue in pairs(index.byPath) do
                if key:sub(-#suffix) == suffix and (not bestKey or #key > #bestKey) then
                    bestKey = key
                    entry = entryValue
                end
            end
            if entry then
                return entry
            end
        end
    end

    if path:find("^scenario/", 1, true) then
        return {
            tab = path:gsub("^scenario/", ""):gsub("%.lua$", ""),
            preloadKey = path,
        }
    end
    return nil
end

---@param preloadKey string
---@return string?
local function readPreloadSource(preloadKey)
    local read = preloadSourceFn
    if type(read) ~= "function" then
        read = rawget(_G, "__MAP_PRELOAD_SOURCE__")
    end
    if type(read) ~= "function" then
        return nil, "preload reader missing (rebuild map; see build/war3map_loader_snippet.lua)"
    end
    local keys = {
        preloadKey,
        preloadKey:gsub("/", "\\"),
        preloadKey:gsub("^scenario/", ""),
        preloadKey:match("([^/]+%.lua)$"),
    }
    for _, key in ipairs(keys) do
        if key then
            local source = read(key)
            if type(source) == "string" and source ~= "" then
                return source
            end
        end
    end
    return nil, "not in map preload (key " .. preloadKey .. ")"
end

---@param path string
---@return boolean
local function isScenarioPreloadPath(path)
    return type(path) == "string" and path:sub(1, 9) == "scenario/"
end

---@param tab string
---@param preloadKey string
---@param line integer
local function performJump(tab, preloadKey, line)
    local wscode = rawget(_G, "WSCode")
    if not wscode then
        logSkip("WSCode not loaded")
        return
    end
    if type(wscode.StoreCode) ~= "function" then
        logSkip("WSCode.StoreCode missing (rebuild map with vendor patch)")
        return
    end

    local source, sourceErr = readPreloadSource(preloadKey)
    if not source then
        logSkip("no preload: " .. tostring(sourceErr))
        return
    end

    if type(wscode.Initialize) == "function" then
        wscode.Initialize()
    end
    if type(wscode.ForceDebugUI) == "function" then
        wscode.ForceDebugUI()
    end

    local ok, err = pcall(wscode.StoreCode, tab, source)
    if not ok then
        logSkip("StoreCode failed: " .. tostring(err))
        return
    end

    if type(wscode.JumpToError) == "function" then
        pcall(wscode.JumpToError, tab, line)
    end
    if type(wscode.Show) == "function" then
        wscode.Show(true)
    end
    if type(wscode.SwitchToTab) == "function" then
        wscode.SwitchToTab(tab)
    end
    if type(wscode.JumpToLine) == "function" then
        wscode.JumpToLine(line, true)
    end
    -- TeamColor00 — same texture family as WSCode error highlight (no extra locals in vendor).
    if type(wscode.HighlightLines) == "function" then
        pcall(wscode.HighlightLines, line, 0, line, tab)
    end
    if wscode.LockEditor then
        wscode.LockEditor(false)
    end
    logSkip("opened " .. tab .. " line " .. tostring(line))
end

---@param rawMsg any
local function tryJumpFromRawError(rawMsg)
    if not bootstrap.ENABLE_WSCODE then
        return
    end

    local text = tostring(rawMsg or "")
    local path, line = parsePreloadLocation(text)
    if not path or not line then
        logSkip("parse failed: " .. text:sub(1, 120))
        return
    end

    if not isScenarioPreloadPath(path) then
        return
    end

    local entry = resolveEntry(path)
    if not entry then
        logSkip("no tab mapping for " .. path)
        return
    end

    logSkip("schedule " .. entry.tab .. " line " .. tostring(line))
    local deferred = function()
        pcall(performJump, entry.tab, entry.preloadKey, line)
    end
    if Timed and Timed.call then
        Timed.call(0, deferred)
    else
        deferred()
    end
end

function M.install()
    if installed or not bootstrap.ENABLE_WSCODE then
        return
    end
    if not Debug or type(Debug.errorHandler) ~= "function" then
        return
    end

    preloadSourceFn = rawget(_G, "__MAP_PRELOAD_SOURCE__")
    if type(preloadSourceFn) ~= "function" then
        local pkg = rawget(_G, "package")
        if type(pkg) == "table" and type(pkg.source) == "function" then
            preloadSourceFn = pkg.source
        end
    end
    if type(preloadSourceFn) ~= "function" then
        Debug.original.print("|cffff8800[wscode-jump] install: no preload reader — rebuild (build/war3map_loader_snippet.lua)|r")
    end

    prevErrorHandler = Debug.errorHandler
    ---@diagnostic disable-next-line: duplicate-set-field
    Debug.errorHandler = function(errorMsg, startDepth, returnErrorMsg_yn)
        local ret = prevErrorHandler(errorMsg, startDepth, returnErrorMsg_yn)
        pcall(tryJumpFromRawError, errorMsg)
        return ret
    end

    installed = true
end

Debug.endFile()

return M
