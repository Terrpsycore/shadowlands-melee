local Slugs = require("lib.slugs")
local raw = require("data.generated.unit_meta")

local byCode = {}
for code, meta in pairs(raw) do
    byCode[FourCC(code)] = meta
end

---@param unitTypeId integer
---@return table|nil
local function get(unitTypeId)
    return byCode[unitTypeId]
end

return {
    get = get,
    ---@param unitTypeId integer
    leavesCorpse = function(unitTypeId)
        local meta = get(unitTypeId)
        return meta ~= nil and meta.corpse
    end,
    ---@param unitTypeId integer
    canRevive = function(unitTypeId)
        local meta = get(unitTypeId)
        return meta ~= nil and meta.revive
    end,
    ---@param unitTypeId integer
    ---@return UnitSlug|nil
    slug = function(unitTypeId)
        local meta = get(unitTypeId)
        return meta and meta.slug or Slugs.unit(unitTypeId)
    end,
}
