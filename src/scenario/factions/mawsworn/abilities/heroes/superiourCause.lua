--[[
1. after damage -> apply shield once and start casting
2. on damage -> reduce shield
3. on cast finish -> detonate

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
            main = Ids.abilities.superiourCause,
            shield = Ids.abilities.superiourCauseShield,
            dummy = Ids.abilities.superiourCauseDummy,
            detonate = Ids.abilities.superiourCauseDetonate,
        },
        buffs = {
            main = Ids.buffs.superiourCause,
        },
        units = {},
    },
    balance = {
        shieldAmount = 50,
    },
})

--- @type table<unit, {shieldAmount: integer}>
local memory = {} -- TODO: save/load /+/ cleaning

--- @param unit unit
--- @param level integer
local function applyEffect(unit, level)
    local owner = GetOwningPlayer(unit)
    memory[unit] = {
        shieldAmount = CONFIG.balance.shieldAmount,
    }
    Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.shield, "acidbomb", level)

    UnitAddAbility(unit, CONFIG.refs.abilities.dummy)
    SetUnitAbilityLevel(unit, CONFIG.refs.abilities.dummy, level)
    IssueImmediateOrder(unit, "channel")
    -- UnitRemoveAbility(unit, CONFIG.refs.abilities.dummy)
end

--- @param unit unit
--- @param level integer
local function applyDetonate(unit, level)
    local owner = GetOwningPlayer(unit)
    memory[unit] = nil

    UnitAddAbility(unit, CONFIG.refs.abilities.detonate)
    SetUnitAbilityLevel(unit, CONFIG.refs.abilities.detonate, level)
    IssueTargetOrder(unit, "selfdestruct", unit)
end

--- @param info damageInfo
local function onLethalDamage(info)
    if not UnitHasBuffBJ(info.target, CONFIG.refs.buffs.main) then
        return
    end
    if memory[info.target] then
        return
    end

    -- TODO: find hero -> get level | OR cache aura level
    local level = 1
    applyEffect(info.target, level)

    Damage.life = 1 -- HACK: turn off next onLethalDamage callback in chain
end

--- @param info damageInfo
local function onDamage(info)
    if not memory[info.target] then
        return
    end

    local shieldAmount = memory[info.target].shieldAmount
    if shieldAmount then
        local soaked = math.min(info.damage, shieldAmount)
        info.damage = info.damage - soaked

        memory[info.target].shieldAmount = shieldAmount - soaked
        if soaked == shieldAmount then
            UnitRemoveBuffBJ(CONFIG.refs.buffs.main, info.target)
        end
    end
end

local function onSpell()
    local unit = GetTriggerUnit()
    local level = GetUnitAbilityLevel(unit, CONFIG.refs.abilities.dummy)

    applyDetonate(unit, level)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_FINISH",
            spellId = CONFIG.refs.abilities.dummy,
            action = onSpell,
        },
        {
            trigger = "DAMAGE",
            priority = -1000, -- later than all
            filter = {
                source = CONFIG.refs.units.carrier,
            },
            action = onDamage,
        },
        {
            trigger = "LETHAL_DAMAGE",
            priority = 1000, -- earlier than all
            action = onLethalDamage,
        },
    },
    config = CONFIG,
}
