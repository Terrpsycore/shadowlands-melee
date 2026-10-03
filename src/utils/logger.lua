-- utils/dump.lua
local LOG_COLOR = "bbbbbb"
local LOG_FILE = "shadowlands-melee.txt"
local PRELOAD_LIMIT = 259

---@type string[]
local logBuffer = {}

local function formatValue(v, depth)
    if type(v) == "table" then
        return table.tostring(v, depth) -- DebugUtils: name cache + вложенность
    end
    if type(v) == "userdata" then
        local isUnit = pcall(GetUnitTypeId, v)
        if isUnit then
            return GetUnitName(v)
            -- return GetUnitName(v) .. "[" .. tostring(v) .. "]"
        end
        local isItem = pcall(GetItemTypeId, v)
        if isItem then
            return GetItemName(v)
            -- return GetItemName(v) .. "[" .. tostring(v) .. "]"
        end
        local isAbility = pcall(GetSpellAbilityId, v)
        if isAbility then
            return GetAbilityName(v)
            -- return GetItemName(v) .. "[" .. tostring(v) .. "]"
        end
    end
    return tostring(v) -- юниты/игроки с именами из name cache
end

---@param line string
local function preloadLine(line)
    if line == "" then
        Preload("\n")
        return
    end

    local i = 1
    while i <= #line do
        Preload(line:sub(i, i + PRELOAD_LIMIT - 1) .. "\n")
        i = i + PRELOAD_LIMIT
    end
end

local function flushLog()
    if #logBuffer == 0 then
        return
    end

    local ok, err = pcall(function()
        PreloadGenClear()
        PreloadGenStart()
        for _, line in ipairs(logBuffer) do
            preloadLine(line)
        end
        PreloadGenEnd(LOG_FILE)
    end)

    if not ok then
        Debug.original.print("|cffff5555logger flush failed: " .. tostring(err) .. "|r")
    end
end

---@param line string
local function appendLog(line)
    logBuffer[#logBuffer + 1] = line
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
    local plain = table.concat(parts, " | ")
    local msg = "|cff" .. LOG_COLOR .. plain .. "|r"

    -- print перехвачен DebugUtils → виден в игре, если PRINT_DURATION задан
    Debug.original.print(msg)
    appendLog(plain)
end

---@class Logger
---@field flush fun()
---@field log fun(line: string)
---@field mark fun(line: string)
local logger = setmetatable({
    flush = flushLog,
    log = appendLog,
    mark = appendLog,
}, {
    __call = function(_, tag, ...)
        dump(tag, ...)
    end,
})

return logger
