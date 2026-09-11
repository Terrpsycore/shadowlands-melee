--- Death behavior flags from unit data (`corpse`, `revive`).
--- Defaults: both true. Heroes and Mechanical units: both false.

---@param unitData table unit row from data.units
---@return boolean
local function leavesCorpse(unitData)
    if unitData.class == "hero" or unitData.classification == "Mechanical" then
        return false
    end
    if unitData.corpse ~= nil then
        return unitData.corpse
    end
    return true
end

---@param unitData table unit row from data.units
---@return boolean
local function canRevive(unitData)
    if unitData.class == "hero" or unitData.classification == "Mechanical" then
        return false
    end
    if unitData.revive ~= nil then
        return unitData.revive
    end
    return true
end

return {
    leavesCorpse = leavesCorpse,
    canRevive = canRevive,
}
