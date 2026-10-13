---Temporarily bypass DebugUtils nil-global __index on _G (WSCode editor UI callbacks).
local savedIndex = nil
local suppressDepth = 0

local function suppress()
    local mt = getmetatable(_G)
    if not mt then
        return
    end
    if suppressDepth == 0 then
        savedIndex = mt.__index
        mt.__index = function(t, k)
            return rawget(t, k)
        end
    end
    suppressDepth = suppressDepth + 1
end

local function restore()
    local mt = getmetatable(_G)
    if not mt then
        return
    end
    if suppressDepth <= 0 then
        return
    end
    suppressDepth = suppressDepth - 1
    if suppressDepth == 0 then
        mt.__index = savedIndex
        savedIndex = nil
    end
end

---@param fn function
local function withSuppressed(fn)
    suppress()
    local ok, err = pcall(fn)
    restore()
    if not ok then
        error(err, 0)
    end
end

local function getSuppressDepth()
    return suppressDepth
end

return {
    suppress = suppress,
    restore = restore,
    withSuppressed = withSuppressed,
    getSuppressDepth = getSuppressDepth,
}
