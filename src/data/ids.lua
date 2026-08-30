local generated = require("data.generated.ids")
local UnitIds = require("lib.community.types.assets.UnitIds")
local AbilityIds = require("lib.community.types.assets.AbilityIds")
local BuffIds = require("lib.community.types.assets.BuffIds")
local ItemIds = require("lib.community.types.assets.ItemIds")

local function withFallback(overrides, standard)
    return setmetatable(overrides, { __index = standard })
end

return {
    units = withFallback(generated.units, UnitIds),
    abilities = withFallback(generated.abilities, AbilityIds),
    buffs = withFallback(generated.buffs, BuffIds),
    items = withFallback(generated.items, ItemIds),
}
