---@class TriggerFilter
---@field source? integer|integer[]
---@field target? integer|integer[]

---@class TriggerDefinition
---@field trigger string
---@field action fun(ctx?: any)
---@field spellId? integer
---@field order? string
---@field delta? number
---@field filter? TriggerFilter
---@field _sourceTypes? table<integer, boolean>
---@field _targetTypes? table<integer, boolean>

local Filter = {}

local function assertFourCC(value, trigger, field)
    if type(value) == "string" then
        error(string.format(
            'trigger "%s" filter.%s: expected FourCC id, got string %q — wrap with FourCC(...)',
            trigger,
            field,
            value
        ))
    end
    if type(value) ~= "number" then
        error(string.format(
            'trigger "%s" filter.%s: expected FourCC id (number), got %s',
            trigger,
            field,
            type(value)
        ))
    end
    return value
end

local function toTypeSet(value, trigger, field)
    if value == nil then
        return nil
    end
    local set = {}
    if type(value) == "table" then
        for i, v in ipairs(value) do
            set[assertFourCC(v, trigger, field .. "[" .. i .. "]")] = true
        end
    else
        set[assertFourCC(value, trigger, field)] = true
    end
    return set
end

---@param entry TriggerDefinition
function Filter.compileTrigger(entry)
    local filter = entry.filter
    if not filter then
        return
    end
    entry._sourceTypes = toTypeSet(filter.source, entry.trigger, "source")
    entry._targetTypes = toTypeSet(filter.target, entry.trigger, "target")
end

---@param set? table<integer, boolean>
---@param unit unit
local function matchesTypeSet(set, unit)
    if not set then
        return true
    end
    if not unit then
        return false
    end
    return set[GetUnitTypeId(unit)] == true
end

---@param trigger TriggerDefinition
local function matchesDamageFilters(trigger, info)
    if not matchesTypeSet(trigger._sourceTypes, info.source) then
        return false
    end
    if not matchesTypeSet(trigger._targetTypes, info.target) then
        return false
    end
    return true
end

---@param triggers TriggerDefinition[]
---@param info table
function Filter.runFilteredDamageTriggers(triggers, info)
    for _, trigger in ipairs(triggers) do
        if matchesDamageFilters(trigger, info) then
            trigger.action(info)
        end
    end
end

---@param triggers TriggerDefinition[]
---@param unit unit
---@param field "source"|"target"
function Filter.runUnitTriggers(triggers, unit, field)
    for _, trigger in ipairs(triggers) do
        local set = field == "source" and trigger._sourceTypes or trigger._targetTypes
        if matchesTypeSet(set, unit) then
            trigger.action()
        end
    end
end

return Filter
