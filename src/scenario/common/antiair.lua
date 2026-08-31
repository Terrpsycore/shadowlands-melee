-- TODO
-- - test dispell removes both buffs
local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local Storage = require("scenario.storage.dedication")

local CONFIG = {
    ensnareAbilityId = Ids.abilities.dummyEnsnare,
}

local function onDisable(info)
    local unit = info.target
    Dummy.applyDummyOrder(Player(PLAYER_NEUTRAL_AGGRESSIVE), unit, CONFIG.ensnareAbilityId, "ensnare")
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
