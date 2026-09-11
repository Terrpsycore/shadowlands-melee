--[[
TODO:
- BUG: some mechanical units spawn corpses
- visual effect
- check dispell damage
- revive block mechanic
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.death")
local Triggers = require("lib.triggers.callbacks")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.animateDead,
        },
    },
    balance = {
        manaCost = 100,
        searchRadiusPoint = 400,
        -- tuning values
    },
})

local function tryRevive(caster, corpse)
    local owner = GetOwningPlayer(caster)

    Unit.substractMana(caster, CONFIG.balance.manaCost)
    IssueImmediateOrder(caster, "stop")

    if corpse == nil then
        Unit.restoreMana(caster, CONFIG.balance.manaCost)
        return false
    end

    local corpseInfo = Storage:bind(corpse)

    if corpseInfo then
        if corpseInfo.reviveAfter > 0 then
            corpseInfo.reviveAfter = corpseInfo.reviveAfter - 1
            return false
        end

        local resurrectUnit = corpseInfo.unit
        SetUnitOwner(resurrectUnit, owner, true)
        SetUnitState(resurrectUnit, UNIT_STATE_LIFE, GetUnitState(resurrectUnit, UNIT_STATE_MAX_LIFE))
        SetUnitInvulnerable(resurrectUnit, false)
        ShowUnitShow(resurrectUnit)
        SetUnitUseFood(resurrectUnit, true)
        if not corpseInfo.isPeon then
            UnitRemoveType(resurrectUnit, UNIT_TYPE_PEON)
        end
        Triggers.fireEvent("REVIVE", { source = caster, target = resurrectUnit })
        Storage:drop(corpse)
        RemoveUnit(corpse)
        return true
    end

    return false
end

local function onCastStart()
    tryRevive(GetTriggerUnit(), GetSpellTargetUnit())
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_CAST",
            spellId = CONFIG.refs.abilities.main,
            action = onCastStart,
        },
    },
    config = CONFIG,
    debug = {
        tryRevive = tryRevive,
    },
}
