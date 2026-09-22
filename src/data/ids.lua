local ok, generated = pcall(require, "data.generated.ids")
if not ok then
    generated = { units = {}, abilities = {}, buffs = {}, items = {}, upgrades = {} }
end
local UnitIds = require("vendor.assets.UnitIds")
local AbilityIds = require("vendor.assets.AbilityIds")
local BuffIds = require("vendor.assets.BuffIds")
local ItemIds = require("vendor.assets.ItemIds")
local UpgradeIds = require("vendor.assets.UpgradeIds")

local function withFallback(overrides, standard)
    return setmetatable(overrides, { __index = standard })
end

return {
    units = withFallback(generated.units or {}, UnitIds),
    abilities = withFallback(generated.abilities or {}, AbilityIds),
    buffs = withFallback(generated.buffs or {}, BuffIds),
    items = withFallback(generated.items or {}, ItemIds),
    upgrades = withFallback(generated.upgrades or {}, UpgradeIds),
}
