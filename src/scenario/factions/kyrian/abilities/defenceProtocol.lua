-- Toggle Ability
-- use storage
-- check GetIssuedOrderId for toggle on off

local Ids = require("data.generated.ids")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local CONFIG = {
    radius = 600,
}

-- @
local function onDamageEvent(attacker, target) end

return {
    triggers = {
        -- damage event
        DAMAGE = {
            event = Damage.damagedEvent,
            action = onDamageEvent,
            target = {
                type = { Ids.units.steward, Ids.units.aspirant },
            },
        },
    },
    config = CONFIG,
}
