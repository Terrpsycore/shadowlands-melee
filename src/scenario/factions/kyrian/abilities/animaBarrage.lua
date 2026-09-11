local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local dump = require("utils.logger")
local Unit = require("utils.unit")

local MechStorage = require("scenario.storage.mech")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.animaBarrage,
            toggle = Ids.abilities.animaBarrageToggle,
        },
        units = {
            carrier = Ids.units.colossus,
        },
    },
    balance = {
        manacost = 5,
        radius = 500,
    },
})

local function onTurnOn()
    local unit = GetTriggerUnit()
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    SetUnitState(unit, UNIT_STATE_MANA, mana + CONFIG.balance.manacost)
    UnitAddAbility(unit, CONFIG.refs.abilities.main)
    MechStorage:set(unit, "active", true)
end

local function onTurnOff()
    local unit = GetTriggerUnit()
    UnitRemoveAbility(unit, CONFIG.refs.abilities.main)
    MechStorage:drop(GetTriggerUnit())
end

local function onTrain()
    local unit = GetTrainedUnit()
    MechStorage:set(unit, "active", true)
end

local function onDeath()
    MechStorage:drop(GetDyingUnit())
end

local function onAttack()
    local unit = GetAttacker()
    local nearbyAirUnits = Unit.getUnitsInRadius(unit, CONFIG.balance.radius, function(u)
        return Unit.isFlying(u) and not IsUnitAlly(u, GetOwningPlayer(unit))
    end)
    dump("onAttack animaBarrage", MechStorage:has(unit))
    if MechStorage:has(unit) and #nearbyAirUnits > 0 then
        local mana = GetUnitState(unit, UNIT_STATE_MANA)
        if mana < CONFIG.balance.manacost then
            return
        end
        SetUnitState(unit, UNIT_STATE_MANA, mana - CONFIG.balance.manacost)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.toggle,
            action = onTurnOn,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "unimmolation",
            action = onTurnOff,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onTrain,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ATTACKED",
            filter = { source = CONFIG.refs.units.carrier },
            action = onAttack,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDeath,
        },
    },
    config = CONFIG,
}
