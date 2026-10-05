--[[
TODO:
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
            effect = Ids.abilities.fallenArmaments,
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
    },
})

--- @type table<unit, {stacks: integer}>
local memory = {} -- TODO: save/load

local function applyEffect(unit)
    if not memory[unit] then
        memory[unit].stacks = 1
        UnitAddAbility(unit, CONFIG.refs.abilities.effect)
    elseif memory[unit].stacks == CONFIG.balance.maxStacks then
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

    if UnitHasBuffBJ(info.source, CONFIG.refs.buffs.ui) then -- TODO: review, visible pause between battle start and AA speed stacking
        applyEffect(info.source)
    end
end

local function onTimer()
    for unit, data in pairs(memory) do
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
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
