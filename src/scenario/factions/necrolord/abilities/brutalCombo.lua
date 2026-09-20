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

local function onAfterDamage(info)
    if not info.isAttack then
        return
    end

    local unit = info.source
    local level = GetUnitAbilityLevel(unit, CONFIG.refs.abilities.main)
    if level == 0 then
        return
    end

    local owner = GetOwningPlayer(unit)

    if memory[unit] == nil then
        memory[unit] = 1 -- attacks before crit
    elseif memory[unit] > 1 then
        memory[unit] = memory[unit] - 1
    elseif memory[unit] == 1 then
        memory[unit] = memory[unit] - 1
        UnitAddAbility(unit, CONFIG.refs.abilities.crit)
        SetUnitAbilityLevel(unit, CONFIG.refs.abilities.crit, level)
        dump("brutal 1 GetUnitAbilityLevel(unit, crit)", GetUnitAbilityLevel(unit, CONFIG.refs.abilities.crit))
    elseif memory[unit] == 0 then
        dump("brutal 0 GetUnitAbilityLevel(unit, crit)", GetUnitAbilityLevel(unit, CONFIG.refs.abilities.crit))
        UnitRemoveAbility(unit, CONFIG.refs.abilities.crit)
        memory[unit] = 2
    else
        error("Broken brutalCombo memory value")
    end
end

return {
    triggers = {
        {
            trigger = "AFTER_DAMAGE",
            filter = { source = CONFIG.refs.units.carrier },
            action = onAfterDamage,
        },
    },
    config = CONFIG,
}
