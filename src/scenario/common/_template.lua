local Ids = require("data.generated.ids")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local CONFIG = {
    -- radius = 600,
    -- cooldown = 5,

    -- buffId = FourCC(Ids.buffs.defenceProtocol),

    abilityId = FourCC(Ids.abilities.defenceProtocol),
    dummyAbilityId = FourCC(Ids.abilities.defenceProtocolBuff),
    -- requiredUpgradeId = nil,
}

return {
    triggers = {},
    config = CONFIG,
}
