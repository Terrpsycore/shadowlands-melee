local Ids = require("data.ids")
local Slugs = require("lib.slugs")
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
    ---@param itemTypeId integer
    ---@return UnitSlug|nil
    getCorpseOf = function(itemTypeId)
        return get(itemTypeId).corpseOf
    end,
    ---@param unitTypeId integer
    ---@return integer|nil
    getCorpseItemId = function(unitTypeId)
        local unitSlug = Slugs.unit(unitTypeId)
        if not unitSlug then
            return nil
        end
        local itemId = Ids.items[unitSlug .. "Corpse"]
        return itemId and FourCC(itemId) or nil
    end,
}
