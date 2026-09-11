--[[
TODO:
- fire onDeath even on fake death ? most likely yes
- clean stale corpses data & hidden source units
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Slugs = require("lib.slugs")
local Units = require("lib.units")

local Storage = require("scenario.storage.death")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.animaBarrage, -- CHANGE slug (effect ability)
            toggle = Ids.abilities.animaBarrageToggle,
        },
        units = {
            carrier = Ids.units.colossus, -- CHANGE carrier
        },
    },
    balance = {
        manacost = 5,
        radius = 500,
    },
})

local function shouldUseFakeDeath(target)
    if IsUnitType(target, UNIT_TYPE_STRUCTURE) or IsUnitType(target, UNIT_TYPE_SAPPER) then
        return false
    end

    local unitTypeId = GetUnitTypeId(target)
    if Slugs.unit(unitTypeId) then
        return Units.canRevive(unitTypeId)
    end

    for _, v in ipairs({ UNIT_TYPE_HERO, UNIT_TYPE_MECHANICAL }) do
        if IsUnitType(target, v) then
            return false
        end
    end

    return true
end

--- @param info damageInfo
local function onLethalDamage(info)
    local target = info.target
    if not shouldUseFakeDeath(target) then
        return
    end

    local owner = GetOwningPlayer(target)
    local unitTypeId = GetUnitTypeId(target)
    local leavesCorpse = Slugs.unit(unitTypeId) and Units.leavesCorpse(unitTypeId) or true

    SetUnitInvulnerable(target, true)
    ShowUnitHide(target)
    SetUnitUseFood(target, false)
    SetUnitState(target, UNIT_STATE_LIFE, 1)
    Damage.life = 1
    info.damage = 0

    UnitRemoveBuffs(target, true, true)
    IssueImmediateOrder(target, "hold")
    SetUnitOwner(target, Player(PLAYER_NEUTRAL_PASSIVE), false)

    local isPeon = IsUnitType(target, UNIT_TYPE_PEON)
    if not isPeon then
        UnitAddType(target, UNIT_TYPE_PEON)
    end

    local storageUnit = target
    if leavesCorpse then
        storageUnit = CreateUnit(owner, unitTypeId, GetUnitX(target), GetUnitY(target), GetUnitFacing(target))
        KillUnit(storageUnit) -- CAUTION: onDeath triggers
    end

    Storage:set(storageUnit, "originalOwner", GetPlayerId(owner))
    Storage:set(storageUnit, "unit", target)
    Storage:set(storageUnit, "isPeon", isPeon)
    Storage:set(storageUnit, "reviveAfter", GetUnitState(target, UNIT_STATE_MAX_LIFE) // 500)
end

return {
    triggers = {
        {
            trigger = "LETHAL_DAMAGE",
            action = onLethalDamage,
        },
    },
    config = CONFIG,
}
