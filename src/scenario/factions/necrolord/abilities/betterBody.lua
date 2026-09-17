--[[
TODO:
- check cast interrupts on stun
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

-- local Storage = require("scenario.storage.sporeCloud")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.betterBody,
            possession = Ids.abilities.betterBodyPossession,
        },
        buffs = {
            --
        },
        units = {
            --
        },
    },
    balance = {
        ticks = 4,
        tickDelta = 0.25,
    },
})

local function onSpellFinish()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()

    UnitAddAbility(caster, CONFIG.refs.abilities.possession)
    IssueTargetOrder(caster, "possession", target)
end

local function onPossession()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()

    local casterMaxMana = GetUnitState(caster, UNIT_STATE_MAX_MANA)
    local targetMaxMana = GetUnitState(target, UNIT_STATE_MAX_MANA)

    if targetMaxMana < casterMaxMana then
        SetUnitState(target, UNIT_STATE_MAX_MANA, casterMaxMana)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_FINISH",
            spellId = CONFIG.refs.abilities.main,
            action = onSpellFinish,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.possession,
            action = onPossession,
        },
    },
    config = CONFIG,
}
