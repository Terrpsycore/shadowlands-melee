local ok, generated = pcall(require, "data.generated.ids")
if not ok then
    generated = { units = {}, abilities = {}, buffs = {}, items = {} }
end
local UnitIds = require("vendor.assets.UnitIds")
local AbilityIds = require("vendor.assets.AbilityIds")
local BuffIds = require("vendor.assets.BuffIds")
local ItemIds = require("vendor.assets.ItemIds")

local function withFallback(overrides, standard)
    return setmetatable(overrides, { __index = standard })
end

return {
    units = withFallback(generated.units, UnitIds),
    abilities = withFallback(generated.abilities, AbilityIds),
    buffs = withFallback(generated.buffs, BuffIds),
    items = withFallback(generated.items, ItemIds),
}
