local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local MechStorage = require("scenario.storage.mech")

local CONFIG = {
    cooldown = 3,
    chance = 25,
    toggleManacost = 20,
    pulseManacost = 20,
    pulseDamage = 50,
    pulseRadius = 250,

    abilityId = FourCC(Ids.abilities.pulseback),
    toggleAbilityId = FourCC(Ids.abilities.pulsebackToggle),
    pulseAbilityId = FourCC(Ids.abilities.pulsebackPulse),
}

local function applyPulsebackPulse(unit)
    local owner = GetOwningPlayer(unit)
    local x = GetUnitX(unit)
    local y = GetUnitY(unit)

    for _, target in ipairs(Unit.getUnitsInRadius(unit, CONFIG.pulseRadius)) do
        if not IsUnitAlly(target, owner) then
            UnitDamageTarget(
                unit,
                target,
                CONFIG.pulseDamage,
                false,
                false,
                ATTACK_TYPE_MAGIC,
                DAMAGE_TYPE_UNIVERSAL,
                WEAPON_TYPE_WHOKNOWS
            )
        end
    end

    local dummy = Dummy.create(owner, unit, CONFIG.pulseAbilityId)
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
    if not Unit.isOffCooldown(unit, CONFIG.abilityId) then
        return
    end
    if GetRandomReal(0, 100) >= CONFIG.chance then
        return
    end
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    if mana < CONFIG.pulseManacost then
        return
    end
    BlzStartUnitAbilityCooldown(unit, CONFIG.abilityId, CONFIG.cooldown)
    applyPulsebackPulse(unit)
    SetUnitState(unit, UNIT_STATE_MANA, mana - CONFIG.pulseManacost)
end

local function onTurnOn()
    local unit = GetTriggerUnit()
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    SetUnitState(unit, UNIT_STATE_MANA, mana + CONFIG.toggleManacost)
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
            spellId = CONFIG.toggleAbilityId,
            action = onTurnOn,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "unimmolation",
            action = onTurnOff,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            unitType = FourCC(Ids.units.goliath),
            action = onTrain,
        },
        {
            trigger = "DAMAGE",
            action = onDamage,
            target = {
                type = { Ids.units.goliath },
            },
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            unitType = FourCC(Ids.units.goliath),
            action = onDeath,
        },
    },
    config = CONFIG,
}
