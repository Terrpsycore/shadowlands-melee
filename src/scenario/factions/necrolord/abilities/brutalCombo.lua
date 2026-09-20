--[[
TODO:
- fade with stale time
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.brutalCombo,
        },
        units = {
            carrier = Ids.units.gladiatorHero,
        },
    },
    balance = {
        critModifier = { 1.6, 2, 2.4 },
    },
})

local memory = {} -- TODO: save/load

local function onPreDamage(info)
    if not info.isAttack then
        return
    end

    local unit = info.source
    local level = GetUnitAbilityLevel(unit, CONFIG.refs.abilities.main)
    if level == 0 then
        return
    end

    if memory[unit] == nil then
        memory[unit] = 1 -- attacks before crit
    elseif memory[unit] > 0 then
        memory[unit] = memory[unit] - 1
    elseif memory[unit] == 0 then
        memory[unit] = 2

        local before = info.damage
        info.damage = info.damage * CONFIG.balance.critModifier[level]
        dump("brutalCombo hit - ", before, "->", info.damage)
        -- Create the classic red floating text
        local text = CreateTextTagUnitBJ(string.format("%.0f!", info.damage), info.target, 0, 10, 100, 0, 0, 0)
        SetTextTagVelocityBJ(text, 64, 90)
        SetTextTagPermanent(text, false)
        SetTextTagLifespan(text, 2.0)
        SetTextTagFadepoint(text, 1.5)
    else
        error("Broken brutalCombo memory value")
    end
end

return {
    triggers = {
        {
            trigger = "PRE_DAMAGE",
            filter = { source = CONFIG.refs.units.carrier },
            action = onPreDamage,
        },
    },
    config = CONFIG,
}
