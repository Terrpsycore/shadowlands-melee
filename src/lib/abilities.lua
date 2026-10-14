local Ids = require("data.ids")
local Slugs = require("lib.slugs")
local raw = require("data.generated.ability_meta")

---@alias OrderMode "on" | "off" | "activate" | "deactivate"

---@param orderString string
---@param context string
---@return integer
local function resolveOrderId(orderString, context)
    local orderId = String2OrderIdBJ(orderString)
    if orderId == 0 then
        error(string.format("unrecognized order string %q (%s)", orderString, context))
    end
    return orderId
end

local byCode = {}
local excludedByCode = {}

for code, meta in pairs(raw) do
    if meta.orderExcluded then
        excludedByCode[FourCC(code)] = meta.slug
    elseif meta.order ~= nil then
        local entry = { slug = meta.slug }
        if type(meta.order) == "string" then
            ---@diagnostic disable-next-line: param-type-mismatch
            entry.orderIdOn = resolveOrderId(meta.order, string.format("ability %q on", meta.slug))
        elseif type(meta.order) == "table" then
            entry.orderIdOn = resolveOrderId(meta.order.on, string.format("ability %q on", meta.slug))
            entry.orderIdOff = resolveOrderId(meta.order.off, string.format("ability %q off", meta.slug))
        end
        byCode[FourCC(code)] = entry
    end
end

---@param abilityTypeId integer
---@return string
local function formatTypeId(abilityTypeId)
    return string.pack(">I4", abilityTypeId)
end

---@param slug AbilitySlug
---@return string
local function id(slug)
    local rawId = Ids.abilities[slug]
    if rawId == nil then
        error(string.format("unknown ability slug %q", slug))
    end
    return rawId
end

---@param slug AbilitySlug
---@return integer
local function fourcc(slug)
    return FourCC(id(slug))
end

---@param target AbilitySlug|integer
---@return integer
local function resolveTypeId(target)
    if type(target) == "string" then
        return fourcc(target)
    end
    if type(target) == "number" then
        return target
    end
    error(string.format("orderId: expected slug or abilityTypeId, got %s", type(target)))
end

---@param mode? OrderMode
---@return boolean wantOff
local function wantOffOrder(mode)
    if mode == nil or mode == "on" or mode == "activate" then
        return false
    end
    if mode == "off" or mode == "deactivate" then
        return true
    end
    error(string.format("orderId: unknown mode %q", mode))
end

---@param abilityTypeId integer
---@return table
local function get(abilityTypeId)
    local excludedSlug = excludedByCode[abilityTypeId]
    if excludedSlug then
        error(string.format("ability %q has no cast order (orderExcludes)", excludedSlug))
    end
    local meta = byCode[abilityTypeId]
    if meta == nil then
        local slug = Slugs.ability(abilityTypeId)
        if slug then
            error(string.format("ability %q has no cast order (add data.order or orderExcludes)", slug))
        end
        error(string.format("ability has no cast order (typeId %s)", formatTypeId(abilityTypeId)))
    end
    return meta
end

---@param target AbilitySlug|integer
---@param mode? OrderMode
---@return integer
local function orderId(target, mode)
    local abilityTypeId = resolveTypeId(target)
    local meta = get(abilityTypeId)
    if wantOffOrder(mode) then
        if meta.orderIdOff == nil then
            error(string.format("ability %q has no off order (use order = { on = ..., off = ... } in data)", meta.slug))
        end
        return meta.orderIdOff
    end
    if meta.orderIdOn == nil then
        error(string.format("ability %q has no on order", meta.slug))
    end
    return meta.orderIdOn
end

return {
    id = id,
    fourcc = fourcc,
    get = get,
    orderId = orderId,
}
