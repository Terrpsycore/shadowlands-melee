-- TODO
-- - test dispell removes both buffs
local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local Storage = require("scenario.storage.dedication") -- todo: change to anti-air

local CONFIG = {
    fallDamage = 50,
    ensnareAbilityId = Ids.abilities.dummyEnsnare,
}

local function onDisable(info)
    local unit = info.target
    if Unit.isFlying(unit) then -- todo: don't apply again until disable ends
        Dummy.applyDummyOrder(Player(PLAYER_NEUTRAL_AGGRESSIVE), unit, CONFIG.ensnareAbilityId, "ensnare")
        Timed.call(0.5, function()
            Damage.apply(info.source, unit, CONFIG.fallDamage)
        end)
    end
    -- todo: change form (remove control until form changed)
end

return {
    triggers = {
        {
            trigger = "STUN",
            action = onDisable,
        },
        {
            trigger = "ROOT",
            action = onDisable,
        },
    },
    config = CONFIG,
}
