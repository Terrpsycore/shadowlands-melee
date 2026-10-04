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
            debuff = Ids.abilities.malignantBolt,
        },
        buffs = {
            main = Ids.buffs.malignantBolt,
        },
        units = {
            carrier = { Ids.units.arbalest },
        },
    },
    balance = {
        checkRate = 0.1,
        penaltyDamage = 100,
        -- duration=
    },
})

--- @alias TargetInfo {baseRegen: float, lastHp: float}

--- @type table<unit,any>
local memory = {} -- TODO: save/load

--- @param info damageInfo
local function onAfterDamage(info)
    if not info.isAttack then
        return
    end
    Timed.call(0.00, function()
        if not memory[info.target] and UnitHasBuffBJ(info.target, CONFIG.refs.buffs.main) then
            local baseRegenRaw = BlzGetUnitRealField(info.target, UNIT_RF_HIT_POINTS_REGENERATION_RATE)
            memory[info.target] = {
                source = info.source,
                owner = GetOwningPlayer(info.source),
                baseRegen = baseRegenRaw * CONFIG.balance.checkRate,
                lastHp = GetUnitState(info.target, UNIT_STATE_LIFE),
            }
        end
    end)
end

local function onTimer()
    local flushQueue = {}
    for unit, data in pairs(memory) do
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            table.insert(flushQueue, unit)
        else
            local hp = GetUnitState(unit, UNIT_STATE_LIFE)
            local d = hp - data.lastHp
            if d > 0 and d > (data.baseRegen * 1.5) then
                Damage.apply(data.source, unit, CONFIG.balance.penaltyDamage, false, false, ATTACK_TYPE_CHAOS)
                UnitRemoveBuffBJ(CONFIG.refs.buffs.main, unit)
                -- table.insert(flushQueue, unit)
            end
        end
    end
    for _, v in ipairs(flushQueue) do
        memory[v] = nil
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
            delta = CONFIG.balance.checkRate,
            action = onTimer,
        },
    },
    config = CONFIG,
}
