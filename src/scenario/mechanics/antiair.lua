-- TODO
-- - test dispell removes both buffs
local Ids = require("data.ids")
local AbilityConfig = require("scenario.config")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local Storage = require("scenario.storage.dedication") -- todo: change to anti-air

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            ensnare = Ids.abilities.dummyEnsnare,
        },
    },
    balance = {
        fallDamage = 50,
    },
})

local function onDisable(info)
    local unit = info.target
    if Unit.isFlying(unit) then -- todo: don't apply again until disable ends
        Dummy.applyDummyOrder(Player(PLAYER_NEUTRAL_AGGRESSIVE), unit, CONFIG.refs.abilities.ensnare, "ensnare")
        Timed.call(0.5, function()
            Damage.apply(info.source, unit, CONFIG.balance.fallDamage)
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
