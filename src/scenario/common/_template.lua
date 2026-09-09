local Ids = require("data.ids")
local AbilityConfig = require("scenario.config")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.defenceProtocol,
            buff = Ids.abilities.defenceProtocolBuff,
        },
        units = {
            carrier = Ids.units.praetor,
            protected = { Ids.units.steward, Ids.units.aspirant },
        },
    },
    balance = {
        -- radius = 600,
        -- cooldown = 5,
        -- requiredUpgradeId = nil,
    },
})

local function onSpell() end
local function onDeath() end
local function onDamage(info) end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDeath,
        },
        {
            trigger = "DAMAGE",
            filter = { target = CONFIG.refs.units.protected },
            action = onDamage,
        },
    },
    config = CONFIG,
}
