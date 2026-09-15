local Slugs = require("lib.slugs")
local UnitData = require("data.units")
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

---@param unitTypeId integer
---@return UnitSlug|nil
local function slug(unitTypeId)
    local meta = get(unitTypeId)
    return meta and meta.slug or Slugs.unit(unitTypeId)
end

---@param unitTypeId integer
---@return string|nil
local function faction(unitTypeId)
    local unitSlug = slug(unitTypeId)
    if not unitSlug then
        return nil
    end
    local row = UnitData[unitSlug]
    return row and row.faction or nil
end

return {
    get = get,
    slug = slug,
    faction = faction,
    ---@param unit unit
    ---@return string|nil
    factionOf = function(unit)
        return faction(GetUnitTypeId(unit))
    end,
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
}
