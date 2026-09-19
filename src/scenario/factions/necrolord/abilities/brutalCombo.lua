--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.brutalCombo,
            crit = Ids.abilities.brutalComboCrit,
        },
        units = {
            carrier = Ids.units.gladiatorHero,
        },
    },
})

local memory = {} -- TODO: save/load

local function onDamage(info)
    if not info.isAttack then
        return
    end

    local unit = info.source
    local level = GetUnitAbilityLevel(unit, CONFIG.refs.abilities.main)
    if level == 0 then
        return
    end

    if memory[unit] == nil then
        memory[unit] = 2 -- attacks before crit
    elseif memory[unit] > 0 then
        memory[unit] = memory[unit] - 1
    elseif memory[unit] == 0 then
        UnitRemoveAbility(unit, CONFIG.refs.abilities.crit)
    else
        error("Broken brutalCombo memory value")
    end
end

local function onStartAttack(info)
    local unit = GetAttacker()

    local level = GetUnitAbilityLevel(unit, CONFIG.refs.abilities.main)
    if level == 0 then
        return
    end

    if memory[unit] == 0 then
        UnitAddAbility(unit, CONFIG.refs.abilities.crit)
        SetUnitAbilityLevel(unit, CONFIG.refs.abilities.crit, level)
        memory[unit] = 2
    elseif GetUnitAbilityLevel(unit, CONFIG.refs.abilities.crit) > 0 then
        UnitRemoveAbility(unit, CONFIG.refs.abilities.crit)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_ATTACKED",
            filter = { source = CONFIG.refs.units.carrier },
            action = onStartAttack,
        },
        {
            trigger = "DAMAGE",
            filter = { source = CONFIG.refs.units.carrier },
            action = onDamage,
        },
    },
    config = CONFIG,
}
