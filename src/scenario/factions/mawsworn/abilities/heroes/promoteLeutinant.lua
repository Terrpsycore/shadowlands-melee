--[[
TODO:
-- ? on skill level learn - update buff
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.promoteLeutinant,
            damage = Ids.abilities.promoteLeutinantDamageBuff,
            hp = Ids.abilities.promoteLeutinantHp,
        },
        units = {},
    },
    balance = {
        diminishing = {
            melee = 1,
            ranged = 2,
        },
    },
})

--- @type table<unit, {unit: unit}>
local memory = {} -- TODO: save/load -- caster to leut
--- @type table<unit, {availableAt: number}>
local leutinants = {} -- leut diminishing

--- @param unit unit
--- @param level integer
local function applyEffect(unit, level)
    leutinants[unit] = {
        availableAt = GetElapsedGameTime(),
    }
    if GetUnitAbilityLevel(unit, CONFIG.refs.abilities.damage) == 0 then
        UnitAddAbility(unit, CONFIG.refs.abilities.damage)
    end
    if GetUnitAbilityLevel(unit, CONFIG.refs.abilities.hp) == 0 then
        UnitAddAbility(unit, CONFIG.refs.abilities.hp)
    end
    SetUnitAbilityLevel(unit, CONFIG.refs.abilities.damage, level)
    SetUnitAbilityLevel(unit, CONFIG.refs.abilities.hp, level)
end

--- @param unit unit
local function removeEffect(unit)
    leutinants[unit] = nil
    UnitRemoveAbility(unit, CONFIG.refs.abilities.damage)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.hp)
end

local function onSpell()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    if memory[caster] then
        removeEffect(memory[caster].unit)
    end

    memory[caster] = { unit = target }
    applyEffect(target, level)
end

--- @param info damageInfo
local function onDamage(info)
    if not info.isAttack then
        return
    end
    if not leutinants[info.source] then
        return
    end

    local now = GetElapsedGameTime()
    if now < leutinants[info.source].availableAt then
        return
    end

    local cooldown
    if info.isMelee then
        cooldown = CONFIG.balance.diminishing.melee
    else
        cooldown = CONFIG.balance.diminishing.ranged
    end

    WS.api.applyWeakenedSoulStack(info.target, 1, GetOwningPlayer(info.source))
    leutinants[info.source].availableAt = now + cooldown
end

return {
    triggers = {
        {
            trigger = "DAMAGE",
            filter = {
                source = CONFIG.refs.units.carrier,
            },
            action = onDamage,
        },
    },
    config = CONFIG,
}
