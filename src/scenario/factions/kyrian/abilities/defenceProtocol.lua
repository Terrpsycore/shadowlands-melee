local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local MechStorage = require("scenario.storage.mech")

local CONFIG = {
    radius = 600,
    cooldown = 5,
    manacost = 20,

    buffId = FourCC(Ids.buffs.defenceProtocol),

    abilityId = FourCC(Ids.abilities.defenceProtocol),
    dummyAbilityId = FourCC(Ids.abilities.defenceProtocolBuff),
    toggleAbilityId = FourCC(Ids.abilities.defenceProtocolToggle),
}

local function activateDefenceProtocol(event, unit)
    if IsUnitAlly(event.target, GetOwningPlayer(event.source)) then
        return
    end
    if not MechStorage:get(unit, "active") then
        return
    end
    if not Unit.isOffCooldown(unit, CONFIG.abilityId) then
        return
    end
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    if mana < CONFIG.manacost then
        return
    end
    BlzStartUnitAbilityCooldown(unit, CONFIG.abilityId, CONFIG.cooldown)
    Dummy.applyDummyOrder(GetOwningPlayer(unit), unit, CONFIG.dummyAbilityId, "bloodlust")
    SetUnitState(unit, UNIT_STATE_MANA, mana - CONFIG.manacost)
end

local function onTurnOn()
    local unit = GetTriggerUnit()
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    SetUnitState(unit, UNIT_STATE_MANA, mana + CONFIG.manacost)
    dump("onTurnOn defenceProtocol", mana, mana + CONFIG.manacost)
    MechStorage:set(unit, "active", true)
end

local function onTurnOff()
    local unit = GetTriggerUnit()
    MechStorage:set(unit, "active", false)
end

local function onDeath()
    MechStorage:clear(GetDyingUnit())
end

local function onDamageEvent(info)
    local nearbyPraetors = Unit.getAllyUnitsOfTypeInRadius(info.target, FourCC(Ids.units.praetor), CONFIG.radius)
    for _, unit in ipairs(nearbyPraetors) do
        activateDefenceProtocol(info, unit)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.toggleAbilityId,
            action = onTurnOn,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "unimmolation",
            action = onTurnOff,
        },
        {
            trigger = "DAMAGE",
            filter = { target = { FourCC(Ids.units.steward), FourCC(Ids.units.aspirant) } },
            action = onDamageEvent,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = FourCC(Ids.units.praetor) },
            action = onDeath,
        },
    },
    config = CONFIG,
}
