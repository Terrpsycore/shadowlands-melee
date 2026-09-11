local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local MechStorage = require("scenario.storage.mech")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.defenceProtocol,
            toggle = Ids.abilities.defenceProtocolToggle,
            buff = Ids.abilities.defenceProtocolBuff,
        },
        buffs = {
            main = Ids.buffs.defenceProtocol,
        },
        units = {
            carrier = Ids.units.praetor,
            protected = { Ids.units.steward, Ids.units.aspirant },
        },
    },
    balance = {
        radius = 600,
        cooldown = 5,
        manacost = 20,
    },
})

local function activateDefenceProtocol(event, unit)
    if IsUnitAlly(event.target, GetOwningPlayer(event.source)) then
        return
    end
    if not MechStorage:has(unit) then
        return
    end
    if not Unit.isOffCooldown(unit, CONFIG.refs.abilities.main) then
        return
    end
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    if mana < CONFIG.balance.manacost then
        return
    end
    BlzStartUnitAbilityCooldown(unit, CONFIG.refs.abilities.main, CONFIG.balance.cooldown)
    Dummy.applyDummyOrder(GetOwningPlayer(unit), unit, CONFIG.refs.abilities.buff, "bloodlust")
    SetUnitState(unit, UNIT_STATE_MANA, mana - CONFIG.balance.manacost)
end

local function onTurnOn()
    local unit = GetTriggerUnit()
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    SetUnitState(unit, UNIT_STATE_MANA, mana + CONFIG.balance.manacost)
    -- dump("onTurnOn defenceProtocol", mana, mana + CONFIG.balance.manacost)
    MechStorage:set(unit, "active", true)
end

local function onTurnOff()
    local unit = GetTriggerUnit()
    MechStorage:drop(unit)
end

local function onDeath()
    MechStorage:drop(GetDyingUnit())
end

local function onDamageEvent(info)
    local nearbyPraetors =
        Unit.getAllyUnitsOfTypeInRadius(info.target, CONFIG.refs.units.carrier, CONFIG.balance.radius)
    for _, unit in ipairs(nearbyPraetors) do
        activateDefenceProtocol(info, unit)
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
            trigger = "DAMAGE",
            filter = { target = CONFIG.refs.units.protected },
            action = onDamageEvent,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDeath,
        },
    },
    config = CONFIG,
}
