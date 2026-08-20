-- utils/dump.lua
local LOG_COLOR = "bbbbbb"
local DEFAULT_DEPTH = 2
local DEFAULT_DURATION = 8

local function formatValue(v, depth)
    if type(v) == "table" then
        return table.tostring(v, depth) -- DebugUtils: name cache + вложенность
    end
    return tostring(v) -- юниты/игроки с именами из name cache
end

---@param tag? string
---@param ... any
local function dump(tag, ...)
    local n = select("#", ...)
    local parts = {}
    if tag then
        parts[#parts + 1] = tostring(tag)
    end
    for i = 1, n do
        parts[#parts + 1] = formatValue(select(i, ...))
    end
    local msg = "|cff" .. LOG_COLOR .. table.concat(parts, " | ") .. "|r"

    -- print перехвачен DebugUtils → виден в игре, если PRINT_DURATION задан
    Debug.original.print(msg)
end

return dump
