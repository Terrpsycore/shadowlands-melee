--[[
DRAFT
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.shackle,
        },
        buffs = {
            -- debuff = Ids.buffs.bastionSpearSlow, -- optional
        },
        units = {
            -- source = { Ids.units.ascendedWarrior }, -- optional DAMAGE filter
        },
    },
    balance = {
        radius = 100,
    },
})

local memory = {} -- TODO: save/load

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    -- dummy 1-px range silence with OE disarm
    -- ? visuals

    return
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
        -- uncomment if DAMAGE hook needed:
        -- {
        --     trigger = "DAMAGE",
        --     filter = { source = CONFIG.refs.units.source },
        --     action = onDamage,
        -- },
    },
    config = CONFIG,
}
