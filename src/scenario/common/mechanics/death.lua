--[[
TODO:
- clean stale corpses data & hidden source units
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Unit = require("utils.unit")
local dump = require("utils.logger")

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

--- @param info damageInfo
local function onLethalDamage(info)
    local target = info.target
    local owner = GetOwningPlayer(target)

    for _, v in ipairs({ UNIT_TYPE_HERO, UNIT_TYPE_STRUCTURE, UNIT_TYPE_MECHANICAL, UNIT_TYPE_SAPPER }) do
        if IsUnitType(target, v) then
            return
        end
    end

    SetUnitInvulnerable(target, true)
    ShowUnitHide(target)
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

    local corpse = CreateUnit(owner, GetUnitTypeId(target), GetUnitX(target), GetUnitY(target), GetUnitFacing(target))
    KillUnit(corpse) -- CAUTION: onDeath triggers

    Storage:set(corpse, "originalOwner", GetPlayerId(owner))
    Storage:set(corpse, "unit", target)
    Storage:set(corpse, "isPeon", isPeon)
    Storage:set(corpse, "reviveAfter", GetUnitState(target, UNIT_STATE_MAX_LIFE) // 500)
    dump("\nonLethalDamage set", corpse, target, UnitAlive(target))
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
