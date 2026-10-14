--- Resolve effective cast order for ability data rows (bake-time).
--- Priority: explicit data.order > vanilla parent catalog > error.

local Orders = require("data.generated.Orders")

---@param orderStr string
---@param slug string
---@param label string
local function assertCatalogOrder(orderStr, slug, label)
    if Orders[orderStr] == nil then
        error(string.format("unknown order string %q on ability %q (%s)", orderStr, slug, label))
    end
end

---@param value string|{ on: string, off: string }
---@param slug string
local function validateOrder(value, slug)
    if type(value) == "string" then
        assertCatalogOrder(value, slug, "order")
        return value
    end
    if type(value) == "table" and type(value.on) == "string" and type(value.off) == "string" then
        assertCatalogOrder(value.on, slug, "order.on")
        assertCatalogOrder(value.off, slug, "order.off")
        return { on = value.on, off = value.off }
    end
    error("invalid order on ability " .. slug)
end

---@param orders string[]
---@return string|{ on: string, off: string }|nil
local function collapseOrderList(orders)
    local unique = {}
    local list = {}
    for _, o in ipairs(orders) do
        if o ~= "" and unique[o] == nil then
            unique[o] = true
            list[#list + 1] = o
        end
    end
    if #list == 0 then
        return nil
    end
    if #list == 1 then
        return list[1]
    end

    local off
    for _, o in ipairs(list) do
        if o:match("off$") then
            off = o
            break
        end
    end
    if not off then
        for _, o in ipairs(list) do
            if o:match("^un[%a]") then
                off = o
                break
            end
        end
    end

    local on
    for _, o in ipairs(list) do
        if o ~= off and not o:match("on$") and not o:match("off$") and not o:match("^un[%a]") then
            on = o
            break
        end
    end
    if not on then
        for _, o in ipairs(list) do
            if o ~= off then
                on = o
                break
            end
        end
    end

    if on and off then
        return { on = on, off = off }
    end
    if on then
        return on
    end
    return list[1]
end

---@param vanillaByParent table<string, string|{ on: string, off: string }>
---@param parent string
---@return string|{ on: string, off: string }|nil
local function orderFromParent(vanillaByParent, parent)
    if type(parent) ~= "string" or parent == "" then
        return nil
    end
    return vanillaByParent[parent]
end

---@param data table
---@param slug string
---@param vanillaByParent table<string, string|{ on: string, off: string }>
---@return string|{ on: string, off: string }|nil resolved
---@return boolean excluded
local function resolve(data, slug, vanillaByParent, orderExcludes)
    if orderExcludes[slug] then
        return nil, true
    end
    if data.order ~= nil then
        return validateOrder(data.order, slug), false
    end
    local inherited = orderFromParent(vanillaByParent, data.parent)
    if inherited == nil then
        -- Passive / dummy parent with no WC3 cast order — not castable via orderId.
        return nil, true
    end
    return validateOrder(inherited, slug), false
end

return {
    collapseOrderList = collapseOrderList,
    validateOrder = validateOrder,
    resolve = resolve,
}
