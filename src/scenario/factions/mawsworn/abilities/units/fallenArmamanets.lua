--[[
TODO:
- VISUAL BUG: always shows 1 level of aura. effect works correctly
- upgrade reqs
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.fallenArmaments,
            effect = Ids.abilities.fallenArmamentsEffect,
        },
        buffs = {
            ui = Ids.buffs.fallenArmaments,
        },
        units = {
            carrier = { Ids.units.myrmidon, Ids.units.myrmidonFlying },
        },
    },
    balance = {
        maxStacks = 5,
        flushRate = 0.5,
        fadeTime = 3,
    },
})

--- @type table<unit, {buffApplied: boolean, stacks: integer, fadesAt: number}>
local memory = {} -- TODO: save/load

local function applyEffect(unit)
    if not memory[unit] then
        memory[unit] = { buffApplied = true, stacks = 1 }
    end

    memory[unit].fadesAt = GetElapsedGameTime() + CONFIG.balance.fadeTime

    if memory[unit].stacks == CONFIG.balance.maxStacks then
        return
    else
        memory[unit].stacks = math.min(CONFIG.balance.maxStacks, memory[unit].stacks + 1)
        SetUnitAbilityLevel(unit, CONFIG.refs.abilities.effect, memory[unit].stacks)
    end
end

local function removeEffect(unit)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.effect)
    UnitRemoveBuffBJ(CONFIG.refs.buffs.ui, unit)
    memory[unit] = nil
end

--- @param info damageInfo
local function onAfterDamage(info)
    if not info.isAttack then
        return
    end
    if not GetUnitAbilityLevel(info.source, CONFIG.refs.abilities.main) then
        return
    end

    UnitAddAbility(info.source, CONFIG.refs.abilities.effect)
    if UnitHasBuffBJ(info.source, CONFIG.refs.buffs.ui) then -- TODO: review, visible pause between battle start and AA speed stacking
        applyEffect(info.source)
    end
end

local function onTimer()
    for unit, data in pairs(memory) do
        if GetElapsedGameTime() > data.fadesAt then
            removeEffect(unit)
        end
    end
end

return {
    triggers = {
        {
            trigger = "AFTER_DAMAGE",
            filter = { source = CONFIG.refs.units.carrier },
            action = onAfterDamage,
        },
        { trigger = "TIMER", delta = CONFIG.balance.flushRate, action = onTimer },
    },
    config = CONFIG,
}
