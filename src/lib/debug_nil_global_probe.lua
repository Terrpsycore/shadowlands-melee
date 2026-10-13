---Dev probe: profile DebugUtils _G.__index (nil-global warnings). Idempotent install.
local M = {}

local wrapped = false
local hooksInstalled = false

local WATCH_KEYS = {
    ordersuccess = true,
}

local SLOW_SEC = 0

local probeActive = false
local acc = { traceback = 0, print = 0, tbCalls = 0, printCalls = 0 }

local origTraceback
local printAtHook

local function sourceMapSize()
    if Debug and Debug.data and Debug.data.sourceMap then
        return #Debug.data.sourceMap
    end
    return -1
end

local function resetAcc()
    acc.traceback = 0
    acc.print = 0
    acc.tbCalls = 0
    acc.printCalls = 0
end

local function installHooks()
    if hooksInstalled or not Debug or not Debug.traceback then
        return
    end
    origTraceback = Debug.traceback
    printAtHook = print

    Debug.traceback = function(startDepth, endDepth)
        if not probeActive then
            return origTraceback(startDepth, endDepth)
        end
        local t0 = os.clock()
        acc.tbCalls = acc.tbCalls + 1
        local r = origTraceback(startDepth, endDepth)
        acc.traceback = acc.traceback + os.clock() - t0
        return r
    end

    print = function(...)
        if not probeActive then
            return printAtHook(...)
        end
        local t0 = os.clock()
        acc.printCalls = acc.printCalls + 1
        printAtHook(...)
        acc.print = acc.print + os.clock() - t0
    end

    hooksInstalled = true
end

local function logBreakdown(k, dt, rawNil, tag)
    if not Debug or not Debug.original then
        return
    end
    local other = dt - acc.traceback - acc.print
    if other < 0 then
        other = 0
    end
    Debug.original.print(string.format(
        "|cffffaa00[nil-probe] %s _G.%s total=%.4fs rawNil=%s sourceMap=%d | tb=%.4fs(%d) print=%.4fs(%d) other=%.4fs wrapped=%s|r",
        tag or "read",
        tostring(k),
        dt,
        tostring(rawNil),
        sourceMapSize(),
        acc.traceback,
        acc.tbCalls,
        acc.print,
        acc.printCalls,
        other,
        tostring(wrapped)
    ))
end

function M.ensureWrapped()
    installHooks()
    if wrapped then
        return true
    end

    local mt = getmetatable(_G)
    if not mt then
        if Debug and Debug.original then
            Debug.original.print("|cffff5555[nil-probe] ensureWrapped: _G has no metatable|r")
        end
        return false
    end

    local idx = mt.__index
    if type(idx) ~= "function" then
        if Debug and Debug.original then
            Debug.original.print(string.format(
                "|cffff5555[nil-probe] ensureWrapped: __index is %s (nil warnings likely off)|r",
                type(idx)
            ))
        end
        return false
    end

    local inner = idx
    mt.__index = function(t, k)
        local watch = WATCH_KEYS[k]
        local rawNil = rawget(t, k) == nil
        if not watch and SLOW_SEC <= 0 then
            return inner(t, k)
        end

        resetAcc()
        probeActive = true
        local t0 = os.clock()
        local v = inner(t, k)
        local dt = os.clock() - t0
        probeActive = false

        if watch or dt >= SLOW_SEC then
            logBreakdown(k, dt, rawNil, "via __index")
        end
        return v
    end
    wrapped = true
    return true
end

---Explicit global read (use from fly.lua — always logs for WATCH_KEYS).
---@param name string
---@return any
function M.readGlobal(name)
    if Debug and Debug.original then
        Debug.original.print("|cff88ccff[nil-probe] readGlobal start: " .. tostring(name) .. "|r")
    end
    M.ensureWrapped()
    local raw = rawget(_G, name)
    if Debug and Debug.original then
        Debug.original.print("|cff88ccff[nil-probe] readGlobal rawget=" .. tostring(raw) .. "|r")
    end
    resetAcc()
    probeActive = true
    local t0 = os.clock()
    local ok, v = pcall(function()
        return _G[name]
    end)
    local dt = os.clock() - t0
    probeActive = false
    if Debug and Debug.original then
        Debug.original.print("|cff88ccff[nil-probe] readGlobal pcall ok=" .. tostring(ok) .. " dt=" .. string.format("%.4f", dt) .. "|r")
    end
    if not ok then
        if Debug and Debug.original then
            Debug.original.print("|cffff5555[nil-probe] readGlobal error: " .. tostring(v) .. "|r")
        end
        error(v, 0)
    end
    if WATCH_KEYS[name] or dt >= SLOW_SEC then
        logBreakdown(name, dt, raw == nil, "readGlobal")
    end
    return v
end

local function wrapNilGlobalIndex()
    M.ensureWrapped()
end

function M.install()
    if not Debug or not Debug.original or not os or not os.clock then
        return
    end

    local origMark = MarkGameStarted
    if type(origMark) ~= "function" then
        return
    end

    MarkGameStarted = function()
        origMark()
        wrapNilGlobalIndex()
        Debug.original.print(string.format(
            "|cff88ccff[nil-probe] MarkGameStarted: sourceMap=%d SHOW_TRACE_NIL=%s WARNING_NIL=%s wrapped=%s|r",
            sourceMapSize(),
            tostring(Debug.settings and Debug.settings.SHOW_TRACE_FOR_NIL_WARNINGS),
            tostring(Debug.settings and Debug.settings.WARNING_FOR_NIL_GLOBALS),
            tostring(wrapped)
        ))
    end

    if rawget(_G, "bj_gameStarted") and bj_gameStarted then
        wrapNilGlobalIndex()
    end
end

function M.logBootstrapState(wscodeEnabled)
    if not Debug or not Debug.original then
        return
    end
    local hook = require("lib.nil_global_hook")
    Debug.original.print(string.format(
        "|cff88ccff[nil-probe] bootstrap: ENABLE_WSCODE=%s sourceMap=%d nilHookDepth=%d WSCode=%s|r",
        tostring(wscodeEnabled),
        sourceMapSize(),
        hook.getSuppressDepth and hook.getSuppressDepth() or -1,
        tostring(rawget(_G, "WSCode") ~= nil)
    ))
end

function M.logPostMainState()
    if not Debug or not Debug.original then
        return
    end
    local bootstrap = require("lib.bootstrap_config")
    local mt = getmetatable(_G)
    local indexKind = mt and mt.__index and type(mt.__index) or "none"
    M.ensureWrapped()
    Debug.original.print(string.format(
        "|cff88ccff[nil-probe] post-main: ENABLE_WSCODE=%s sourceMap=%d __index=%s WSCode=%s wrapped=%s|r",
        tostring(bootstrap.ENABLE_WSCODE),
        sourceMapSize(),
        indexKind,
        tostring(rawget(_G, "WSCode") ~= nil),
        tostring(wrapped)
    ))

    if Timed and Timed.call then
        Timed.call(1, function()
            M.ensureWrapped()
            Debug.original.print(string.format(
                "|cff88ccff[nil-probe] post-start+1s: wrapped=%s __index=%s|r",
                tostring(wrapped),
                getmetatable(_G) and type(getmetatable(_G).__index) or "none"
            ))
        end)
    end
end

return M
