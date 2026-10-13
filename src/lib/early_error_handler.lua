Debug.beginFile("lib.early_error_handler")

local DISPLAY_DURATION = 30.0
---@type string Written to Warcraft III/CustomMapData/ (same as utils.logger).
local ERROR_LOG_FILE = "shadowlands-melee-init-errors.txt"
local PRELOAD_CHUNK = 259

---@type string[]
local errorLogLines = {}

---@param str string
local function stripColorCodes(str)
    return (str:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", ""))
end

---@param line string
local function preloadLogLine(line)
    if line == "" then
        Preload("\n")
        return
    end
    local i = 1
    while i <= #line do
        Preload(line:sub(i, i + PRELOAD_CHUNK - 1) .. "\n")
        i = i + PRELOAD_CHUNK
    end
end

local function flushErrorLogFile()
    if #errorLogLines == 0 then
        return
    end
    pcall(function()
        PreloadGenClear()
        PreloadGenStart()
        for _, line in ipairs(errorLogLines) do
            preloadLogLine(line)
        end
        PreloadGenEnd(ERROR_LOG_FILE)
    end)
end

---@param line string
local function appendErrorLog(line)
    errorLogLines[#errorLogLines + 1] = stripColorCodes(line)
    flushErrorLogFile()
end

---@param str string
local function showOnScreen(str)
    if str == "" then
        return
    end
    pcall(DisplayTimedTextToPlayer, GetLocalPlayer(), 0, 0, DISPLAY_DURATION, str)
end

---Print loading-screen messages cached by DebugUtils (never flushed if init aborts early).
---@return boolean hadAny
local function flushLoadingPrintCache()
    local cache = Debug and Debug.data and Debug.data.printCache
    if type(cache) ~= "table" then
        return false
    end

    local hadAny = false
    local n = cache.n or #cache
    for i = 1, n do
        local str = cache[i]
        if str and str ~= "" then
            hadAny = true
            Debug.original.print(str)
            showOnScreen(str)
            appendErrorLog("[print-cache] " .. str)
        end
    end
    return hadAny
end

---@param level? integer
---@return string
local function captureTraceback(level)
    level = level or 2
    if Debug and Debug.traceback then
        return Debug.traceback(level, 202)
    end
    if debug and debug.traceback then
        return debug.traceback("", level)
    end
    return "(traceback unavailable)"
end

---@param msg any
local function reportError(msg)
    msg = tostring(msg or "unknown init error")
    if Debug.getLocalErrorMsg then
        msg = Debug.getLocalErrorMsg(msg)
    end

    appendErrorLog("ERROR: " .. msg)
    appendErrorLog("Traceback (most recent call first):")
    appendErrorLog(captureTraceback(2))

    local color = (Debug.settings and Debug.settings.colors and Debug.settings.colors.error) or "ff5555"
    local line = "|cff" .. color .. "ERROR at " .. msg .. "|r"
    Debug.original.print(line)
    showOnScreen(line)

    if Debug.settings and Debug.settings.SHOW_TRACE_ON_ERROR and Debug.traceback then
        local trace = "|cff" .. color .. "Traceback (most recent call first):|r\n|cff" .. color
            .. Debug.traceback(2, 202) .. "|r"
        Debug.original.print(trace)
        showOnScreen(trace)
    end
end

local M = {}

---Install before WSCode / main.lua. Handler must return msg for embedded require/xpcall.
function M.install()
    appendErrorLog("--- early_error_handler installed ---")
    seterrorhandler(function(msg)
        if msg and msg ~= "" then
            reportError(msg)
        else
            appendErrorLog("seterrorhandler: (empty error message)")
            appendErrorLog("Traceback (most recent call first):")
            appendErrorLog(captureTraceback(2))
        end
        return msg
    end)
end

---Outer xpcall errfunc for war3map main() bootstrap.
---@param msg any
function M.handleBootstrapFailure(msg)
    appendErrorLog("--- bootstrap failure ---")
    appendErrorLog("bootstrap msg: " .. tostring(msg))
    local hadCache = flushLoadingPrintCache()
    local text = (type(msg) == "string" and msg ~= "") and msg or nil
    if text then
        reportError(text)
    elseif not hadCache then
        reportError("map init failed (empty error message)")
    end
end

---@param line string
function M.log(line)
    appendErrorLog(line)
end

M.ERROR_LOG_FILE = ERROR_LOG_FILE

Debug.endFile()

return M
