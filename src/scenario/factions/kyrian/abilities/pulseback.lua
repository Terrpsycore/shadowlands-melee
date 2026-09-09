local Ids = require("data.ids")
local AbilityConfig = require("scenario.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local MechStorage = require("scenario.storage.mech")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.pulseback,
            toggle = Ids.abilities.pulsebackToggle,
            pulse = Ids.abilities.pulsebackPulse,
        },
        units = {
            carrier = Ids.units.goliath,
        },
    },
    balance = {
        cooldown = 3,
        chance = 25,
        toggleManacost = 20,
        pulseManacost = 20,
        pulseDamage = 50,
        pulseRadius = 250,
    },
})

local function applyPulsebackPulse(unit)
    local owner = GetOwningPlayer(unit)
    local x = GetUnitX(unit)
    local y = GetUnitY(unit)

    for _, target in ipairs(Unit.getUnitsInRadius(unit, CONFIG.balance.pulseRadius)) do
        if not IsUnitAlly(target, owner) then
            UnitDamageTarget(
                unit,
                target,
                CONFIG.balance.pulseDamage,
                false,
                false,
                ATTACK_TYPE_MAGIC,
                DAMAGE_TYPE_UNIVERSAL,
                WEAPON_TYPE_WHOKNOWS
            )
        end
    end

    local dummy = Dummy.create(owner, unit, CONFIG.refs.abilities.pulse)
    IssuePointOrder(dummy, "blizzard", x, y)
end

local function tryActivatePulseback(info)
    local unit = info.target
    if IsUnitAlly(info.source, GetOwningPlayer(unit)) then
        return
    end
    if MechStorage:get(unit, "active") == false then
        return
    end
    if not Unit.isOffCooldown(unit, CONFIG.refs.abilities.main) then
        return
    end
    if GetRandomReal(0, 100) >= CONFIG.balance.chance then
        return
    end
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    if mana < CONFIG.balance.pulseManacost then
        return
    end
    BlzStartUnitAbilityCooldown(unit, CONFIG.refs.abilities.main, CONFIG.balance.cooldown)
    applyPulsebackPulse(unit)
    SetUnitState(unit, UNIT_STATE_MANA, mana - CONFIG.balance.pulseManacost)
end

local function onTurnOn()
    local unit = GetTriggerUnit()
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    SetUnitState(unit, UNIT_STATE_MANA, mana + CONFIG.balance.toggleManacost)
    MechStorage:set(unit, "active", true)
end

local function onTurnOff()
    MechStorage:set(GetTriggerUnit(), "active", false)
end

local function onTrain()
    local unit = GetTrainedUnit()
    MechStorage:set(unit, "active", true)
    IssueImmediateOrder(unit, "immolation")
end

local function onDeath()
    MechStorage:clear(GetDyingUnit())
end

local function onDamage(info)
    tryActivatePulseback(info)
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
            trigger = "DAMAGE",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDamage,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDeath,
        },
    },
    config = CONFIG,
}
