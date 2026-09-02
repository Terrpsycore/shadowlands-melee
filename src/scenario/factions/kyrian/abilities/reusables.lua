local Ids = require("data.ids")
local Unit = require("utils.unit")

local CONFIG = {
    abilityId = FourCC(Ids.abilities.reusables),
    manaPercent = { 0.33, 0.66, 1.0 },
    costPercent = { 0.25, 0.5, 0.75 },
}

local function getHealthPercent(unit)
    local maxLife = GetUnitState(unit, UNIT_STATE_MAX_LIFE)
    if maxLife <= 0 then
        return 0
    end
    return GetUnitState(unit, UNIT_STATE_LIFE) / maxLife
end

local function isValidTarget(caster, target)
    if not target or target == caster then
        return false
    end
    if not Unit.isAlive(target) then
        return false
    end
    if not IsUnitAlly(target, GetOwningPlayer(caster)) then
        return false
    end
    if not Unit.isMech(target) then
        return false
    end
    if IsUnitType(target, UNIT_TYPE_HERO) then
        return false
    end
    return true
end

local function onCast()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()

    if not isValidTarget(caster, target) then
        return
    end

    local level = GetUnitAbilityLevel(caster, CONFIG.abilityId)
    local manaPercent = CONFIG.manaPercent[level]
    local costPercent = CONFIG.costPercent[level]
    local healthPercent = getHealthPercent(target)

    local targetMana = GetUnitState(target, UNIT_STATE_MANA)
    local unitTypeId = GetUnitTypeId(target)
    local goldCost = GetUnitGoldCost(unitTypeId)
    local woodCost = GetUnitWoodCost(unitTypeId)
    local owner = GetOwningPlayer(caster)

    KillUnit(target)

    local manaGain = targetMana * manaPercent
    local currentMana = GetUnitState(caster, UNIT_STATE_MANA)
    local maxMana = GetUnitState(caster, UNIT_STATE_MAX_MANA)
    SetUnitState(caster, UNIT_STATE_MANA, math.min(currentMana + manaGain, maxMana))

    AdjustPlayerStateBJ(
        math.floor(goldCost * costPercent * healthPercent),
        owner,
        PLAYER_STATE_RESOURCE_GOLD
    )
    AdjustPlayerStateBJ(
        math.floor(woodCost * costPercent * healthPercent),
        owner,
        PLAYER_STATE_RESOURCE_LUMBER
    )
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_CAST",
            spellId = CONFIG.abilityId,
            action = onCast,
        },
    },
    config = CONFIG,
}
