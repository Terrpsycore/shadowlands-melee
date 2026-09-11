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
local dump = require("utils.logger")

local Storage = require("scenario.storage.death")

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

local function onCastStart()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local corpse = GetSpellTargetUnit()

    Unit.substractMana(caster, CONFIG.balance.manaCost)
    IssueImmediateOrder(caster, "stop")

    if corpse == nil then
        Unit.restoreMana(caster, CONFIG.balance.manaCost)
        return
    end

    local corpseInfo = Storage:open(corpse)

    if corpseInfo then
        dump("revifeAfter", corpseInfo.reviveAfter)
        if corpseInfo.reviveAfter > 0 then
            corpseInfo.reviveAfter = corpseInfo.reviveAfter - 1
            return
        end

        local resurrectUnit = corpseInfo.unit
        SetUnitOwner(resurrectUnit, owner, true)
        SetUnitState(resurrectUnit, UNIT_STATE_LIFE, GetUnitState(resurrectUnit, UNIT_STATE_MAX_LIFE))
        SetUnitInvulnerable(resurrectUnit, false)
        ShowUnitShow(resurrectUnit)
        if not corpseInfo.isPeon then
            UnitRemoveType(resurrectUnit, UNIT_TYPE_PEON)
        end
        Storage:clear(corpse)
        RemoveUnit(corpse)
    end
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
}
