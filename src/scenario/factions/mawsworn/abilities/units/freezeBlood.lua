--[[
TODO:
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.freezeBlood,
        },
        buffs = {
            main = Ids.buffs.freezeBlood,
        },
        units = {},
    },
    balance = {
        checkRate = 0.1,
    },
})

--- @alias FreezeBloodTargetInfo {baseRegen: number, lastHp: number}

--- @type table<unit,FreezeBloodTargetInfo>
local memory = {} -- TODO: save/load

local function onSpell()
    local target = GetSpellTargetUnit()

    local baseRegenRaw = BlzGetUnitRealField(target, UNIT_RF_HIT_POINTS_REGENERATION_RATE)
    memory[target] = {
        baseRegen = baseRegenRaw * CONFIG.balance.checkRate,
        lastHp = GetUnitState(target, UNIT_STATE_LIFE),
    }
    return
end

local function onTimer()
    local flushQueue = {}
    for unit, data in pairs(memory) do
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            table.insert(flushQueue, unit)
            dump("freezeBlood timer", unit, "flush")
        else
            local hp = GetUnitState(unit, UNIT_STATE_LIFE)
            local d = hp - data.lastHp
            if d > 0 and d < (data.baseRegen * 3) then
                SetUnitState(unit, UNIT_STATE_LIFE, data.lastHp)
            else
                data.lastHp = hp
            end
            dump("freezeBlood timer", unit, "d", d)
        end
    end
    for _, v in ipairs(flushQueue) do
        memory[v] = nil
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.checkRate,
            action = onTimer,
        },
    },
    config = CONFIG,
}
