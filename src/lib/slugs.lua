local IdReverse = require("data.id_reverse")

local function buildLookup(domain)
    local lookup = {}
    for id, slug in pairs(IdReverse[domain] or {}) do
        lookup[FourCC(id)] = slug
    end
    return lookup
end

local byDomain = {
    units = buildLookup("units"),
    abilities = buildLookup("abilities"),
    items = buildLookup("items"),
    buffs = buildLookup("buffs"),
}

return {
    ---@param unitTypeId integer
    ---@return UnitSlug|nil
    unit = function(unitTypeId)
        return byDomain.units[unitTypeId]
    end,
    ---@param abilityId integer
    ---@return AbilitySlug|nil
    ability = function(abilityId)
        return byDomain.abilities[abilityId]
    end,
    ---@param itemTypeId integer
    ---@return ItemSlug|nil
    item = function(itemTypeId)
        return byDomain.items[itemTypeId]
    end,
    ---@param buffId integer
    ---@return BuffSlug|nil
    buff = function(buffId)
        return byDomain.buffs[buffId]
    end,
}
