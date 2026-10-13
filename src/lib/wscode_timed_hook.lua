---Wrap Timed callbacks in yieldable coroutines (WSCode breakpoints / Variables).
local bootstrap = require("lib.bootstrap_config")
local Yield = require("lib.wscode_yieldable")

local M = {}
local installed = false

---@param fn any
---@return function?
local function wrapFn(fn)
    if type(fn) ~= "function" then
        return fn
    end
    if not (bootstrap.ENABLE_WSCODE and bootstrap.ENABLE_WSCODE_SCENARIO_DEBUG) then
        return fn
    end
    return function(...)
        Yield.run(fn, ...)
    end
end

function M.install()
    if installed then
        return
    end
    if not (bootstrap.ENABLE_WSCODE and bootstrap.ENABLE_WSCODE_SCENARIO_DEBUG) then
        return
    end
    local timed = rawget(_G, "Timed")
    if type(timed) ~= "table" or type(timed.call) ~= "function" then
        return
    end

    local rawCall = timed.call
    ---@diagnostic disable-next-line: duplicate-set-field
    timed.call = function(delay, userFunc)
        if type(delay) == "function" then
            userFunc, delay = delay, userFunc
        end
        userFunc = wrapFn(userFunc)
        return rawCall(delay, userFunc)
    end

    if type(timed.echo) == "function" then
        local rawEcho = timed.echo
        ---@diagnostic disable-next-line: duplicate-set-field
        timed.echo = function(timeout, duration, userFunc, onExpire, tolerance)
            if type(timeout) == "function" then
                userFunc, timeout, duration = timeout, duration, userFunc
            elseif not userFunc then
                userFunc, duration = duration, nil
            end
            userFunc = wrapFn(userFunc)
            return rawEcho(timeout, duration, userFunc, onExpire, tolerance)
        end
    end

    installed = true
end

return M
