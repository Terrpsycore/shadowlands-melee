local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local dump = require("utils.logger")
local Unit = require("utils.unit")

local MechStorage = require("scenario.storage.mech")

local CONFIG = {
    manacost = 5,
    radius = 500,
    toggleAbility = FourCC(Ids.abilities.animaBarrageToggle),
    effectAbility = FourCC(Ids.abilities.animaBarrage),
}

local function onTurnOn()
    local unit = GetTriggerUnit()
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    SetUnitState(unit, UNIT_STATE_MANA, mana + CONFIG.manacost)
    UnitAddAbility(unit, CONFIG.effectAbility)
    MechStorage:set(unit, "active", true)
end

local function onTurnOff()
    local unit = GetTriggerUnit()
    UnitRemoveAbility(unit, CONFIG.effectAbility)
    MechStorage:set(GetTriggerUnit(), "active", false)
end

local function onTrain()
    local unit = GetTrainedUnit()
    MechStorage:set(unit, "active", true)
end

local function onDeath()
    MechStorage:clear(GetDyingUnit())
end

local function onAttack()
    local unit = GetAttacker()
    local nearbyAirUnits = Unit.getUnitsInRadius(unit, CONFIG.radius, function(u)
        return Unit.isFlying(u) and not IsUnitAlly(u, GetOwningPlayer(unit))
    end)
    dump("onAttack animaBarrage", MechStorage:get(unit, "active"))
    if MechStorage:get(unit, "active") and #nearbyAirUnits > 0 then
        local mana = GetUnitState(unit, UNIT_STATE_MANA)
        if mana < CONFIG.manacost then
            return
        end
        SetUnitState(unit, UNIT_STATE_MANA, mana - CONFIG.manacost)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.toggleAbility,
            action = onTurnOn,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "unimmolation",
            action = onTurnOff,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            filter = { target = FourCC(Ids.units.colossus) },
            action = onTrain,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ATTACKED",
            filter = { source = FourCC(Ids.units.colossus) },
            action = onAttack,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = FourCC(Ids.units.colossus) },
            action = onDeath,
        },
    },
    config = CONFIG,
}
