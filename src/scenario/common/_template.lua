local Ids = require("data.ids")
local Dummy = require("utils.dummy")
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

local function onSpell() end
local function onDeath() end
local function onDamage(info) end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.abilityId,
            action = onSpell,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = FourCC(Ids.units.praetor) },
            action = onDeath,
        },
        {
            trigger = "DAMAGE",
            filter = { target = { FourCC(Ids.units.steward), FourCC(Ids.units.aspirant) } },
            action = onDamage,
        },
    },
    config = CONFIG,
}
