---Run fn in a fresh coroutine so WSCode breakpoints / Variables work (TriggerAddAction is not yieldable).
local bootstrap = require("lib.bootstrap_config")

local M = {}

---@param fn function
---@param ... any
---@return any ...
function M.run(fn, ...)
    if type(fn) ~= "function" then
        return
    end
    if not (bootstrap.ENABLE_WSCODE and bootstrap.ENABLE_WSCODE_SCENARIO_DEBUG) then
        return fn(...)
    end

    local co = coroutine.create(fn)
    local ok, a, b, c, d, e, f = coroutine.resume(co, ...)
    if not ok then
        error(a, 0)
    end
    if coroutine.status(co) == "dead" then
        return a, b, c, d, e, f
    end
    -- Suspended (breakpoint); WSCode Continue will resume currentCoroutine[tab].
end

return M
