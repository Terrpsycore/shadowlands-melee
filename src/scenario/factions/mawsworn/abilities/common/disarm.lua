--[[
TODO:
-- ? diminishing
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.disarm,
            debuff = Ids.abilities.disarmDummy,
            effect = Ids.abilities.disableAttackEffect,
        },
        buffs = {
            init = Ids.buffs.disarmInit,
            main = Ids.buffs.disarm,
        },
        units = {
            carrier = { Ids.units.shackler, Ids.units.vanguard },
        },
    },
    balance = {
        radius = 100,
    },
})

--- @type unit[]
local memory = {} -- TODO: save/load

--- @param info damageInfo
local function onAfterDamage(info)
    if not info.isAttack then
        return
    end
    local owner = GetOwningPlayer(info.source)

    Timed.call(0.00, function()
        dump("disarm onAfterDamage timer")
        if UnitHasBuffBJ(info.target, CONFIG.refs.buffs.init) then
            dump("disarm onAfterDamage UnitRemoveBuffBJ")
            UnitRemoveBuffBJ(CONFIG.refs.buffs.init, info.target)
            UnitAddAbility(info.target, CONFIG.refs.abilities.effect)
            Dummy.applyDummyOrder(owner, info.target, CONFIG.refs.abilities.debuff, "acidbomb")
            Timed.call(0.1, function()
                if not Generic.contains(memory, info.target) then
                    table.insert(memory, info.target)
                end
            end)
        end
    end)

    -- ? visuals

    return
end

local function onTimer()
    for i = #memory, 1, -1 do
        local unit = memory[i]
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            UnitRemoveAbility(unit, CONFIG.refs.abilities.effect)
            table.remove(memory, i)
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
        {
            trigger = "TIMER",
            delta = 0.25,
            action = onTimer,
        },
    },
    config = CONFIG,
}
