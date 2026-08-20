local raw = require("data.generated.item_meta")

local byCode = {}
for code, meta in pairs(raw) do
    byCode[FourCC(code)] = meta
end

local function fourccToString(itemTypeId)
    return string.pack(">I4", itemTypeId)
end

---@param itemTypeId integer
local function get(itemTypeId)
    local meta = byCode[itemTypeId]
    if not meta then
        error("unknown item type id: " .. fourccToString(itemTypeId))
    end
    return meta
end

return {
    get = get,
    ---@param itemTypeId integer
    isHero = function(itemTypeId)
        return get(itemTypeId).hero
    end,
    ---@param itemTypeId integer
    isUnique = function(itemTypeId)
        return get(itemTypeId).unique
    end,
}
