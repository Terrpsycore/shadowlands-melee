--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.foulBite,
        },
        buffs = {
            main = Ids.buffs.foulBite,
        },
        units = {
            carrier = { Ids.units.soulEater },
        },
    },
    balance = {
        damagePerStack = 10,
        maxStacks = 10,
    },
})

local memory = {} -- TODO: save/load

--- First hit doesn't count
--- @param info damageInfo
local function onAfterDamage(info)
    if not info.isAttack then
        return
    end
    if not UnitHasBuffBJ(info.target, CONFIG.refs.buffs.main) then
        return
    end

    if not memory[info.target] then
        memory[info.target] = {
            source = info.source,
            stacks = 0,
        }
    end
    memory[info.target].stacks = memory[info.target].stacks + 1
end

local function onTimer()
    for unit, data in pairs(memory) do
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            Damage.apply(
                data.source,
                unit,
                data.stacks * CONFIG.balance.damagePerStack,
                false,
                false,
                ATTACK_TYPE_CHAOS,
                DAMAGE_TYPE_POISON
            )
            memory[unit] = nil
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
        { trigger = "TIMER", delta = 0.5, action = onTimer },
    },
    config = CONFIG,
}
