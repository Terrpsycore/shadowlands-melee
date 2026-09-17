--[[
TODO:
- fix possession cast time lag (prob won't work now because of unit animation)
- check cast interrupts on stun
- save to "POSSESSED" storage (kyrian loyalty)
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
            --
            applyLimb = Ids.abilities.betterBody,
            scissorSoul = Ids.abilities.scissorSoul,
        },
        buffs = {
            --
        },
        units = {
            --
        },
    },
    balance = {
        --
    },
})

local function onSpellFinish()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()

    Unit.face(caster, target)
    UnitAddAbility(caster, CONFIG.refs.abilities.possession)
    IssueTargetOrder(caster, "possession", target)
    UnitRemoveAbility(caster, CONFIG.refs.abilities.possession) -- TODO: hide active ability, remove on cast or after short delay
end

local function onPossession()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()

    local casterMaxMana = GetUnitState(caster, UNIT_STATE_MAX_MANA)
    local targetMaxMana = GetUnitState(target, UNIT_STATE_MAX_MANA)

    if targetMaxMana < casterMaxMana then
        SetUnitState(target, UNIT_STATE_MAX_MANA, casterMaxMana)
    end

    local abilities = { CONFIG.refs.abilities.applyLimb, CONFIG.refs.abilities.scissorSoul, CONFIG.refs.abilities.main }
    for _, a in ipairs(abilities) do
        if GetUnitAbilityLevel(target, a) == 0 then
            UnitAddAbility(target, a)
        end
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
