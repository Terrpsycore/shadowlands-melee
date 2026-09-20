---@class TriggerFilter
---@field source? integer|integer[]
---@field target? integer|integer[]

---@class TriggerDefinition
---@field trigger? string
---@field action fun(ctx?: any)
---@field spellId? integer|integer[]
---@field order? string
---@field delta? number
---@field priority? number
---@field filter? TriggerFilter
---@field _spellIds? table<integer, boolean>
---@field _sourceTypes? table<integer, boolean>
---@field _targetTypes? table<integer, boolean>
---@field _orderId? integer

local Filter = {}

local function assertFourCC(value, trigger, field)
    if type(value) == "string" then
        error(string.format(
            'trigger "%s" %s: expected FourCC id, got string %q — wrap with FourCC(...)',
            trigger,
            field,
            value
        ))
    end
    if type(value) ~= "number" then
        error(string.format(
            'trigger "%s" %s: expected FourCC id (number), got %s',
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

---@param set? table<integer, boolean>
---@param value? integer
local function inSet(set, value)
    return set == nil or set[value] == true
end

---@param trigger TriggerDefinition
---@param ctx { source?: unit, target?: unit, spellId?: integer, orderId?: integer }
function Filter.matches(trigger, ctx)
    ctx = ctx or {}
    if not inSet(trigger._spellIds, ctx.spellId) then
        return false
    end
    if trigger._orderId and ctx.orderId ~= trigger._orderId then
        return false
    end
    if not inSet(trigger._sourceTypes, ctx.source and GetUnitTypeId(ctx.source)) then
        return false
    end
    if not inSet(trigger._targetTypes, ctx.target and GetUnitTypeId(ctx.target)) then
        return false
    end
    return true
end

---@param entry TriggerDefinition
function Filter.compileTrigger(entry)
    local triggerName = entry.trigger or "callback"
    local filter = entry.filter

    entry._spellIds = toTypeSet(entry.spellId, triggerName, "spellId")
    if entry.order then
        entry._orderId = String2OrderIdBJ(entry.order)
    end
    if filter then
        entry._sourceTypes = toTypeSet(filter.source, triggerName, "filter.source")
        entry._targetTypes = toTypeSet(filter.target, triggerName, "filter.target")
    end
end

---@param triggers TriggerDefinition[]
---@param ctx? { source?: unit, target?: unit, spellId?: integer, orderId?: integer }
---@param passCtx? boolean
function Filter.run(triggers, ctx, passCtx)
    ctx = ctx or {}
    for _, trigger in ipairs(triggers) do
        if Filter.matches(trigger, ctx) then
            if passCtx then
                trigger.action(ctx)
            else
                trigger.action()
            end
        end
    end
end

return Filter
