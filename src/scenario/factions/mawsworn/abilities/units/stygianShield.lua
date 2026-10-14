--[[
TODO:
-- BUG: info.damage == 0, but unit gets full damage anyway
-- ? diminishing
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.stygianShield,
            buff = Ids.abilities.stygianShieldBuff,
        },
        buffs = {
            -- cooldown = Ids.buffs.stygianShieldCooldown,
            main = Ids.buffs.stygianShield,
        },
        units = {
            carrier = { Ids.units.runesmith },
        },
    },
    balance = {
        shieldAmount = 300,
    },
})

--- @type table<unit,{shieldAmount: number}>
local memory = {} -- TODO: save/load

--- @type table<unit,boolean>
local shieldSourceQueue = {}

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    if shieldSourceQueue[target] then
        dump("Stygian Shield source already used")
        return
    end

    Dummy.applyDummyOrder(owner, caster, CONFIG.refs.abilities.buff, "acidbomb")

    shieldSourceQueue[target] = true
    Timed.call(0.1, function()
        shieldSourceQueue[target] = nil
        memory[caster] = {
            shieldAmount = CONFIG.balance.shieldAmount,
        }
    end)
    return
end

--- @param info damageInfo
local function onDamage(info)
    if not memory[info.target] then
        dump("stygianShield no memory - break")
        return
    end
    if not UnitHasBuffBJ(info.target, CONFIG.refs.buffs.main) then
        dump("stygianShield no buff - break")
        memory[info.target] = nil
        return
    end
    local shieldAmount = memory[info.target].shieldAmount
    if shieldAmount then
        local soaked = math.min(info.damage, shieldAmount)
        dump("stygianShield shieldAmount before", info.damage)
        info.damage = info.damage - soaked -- BUG
        dump("stygianShield shieldAmount after", info.damage, "soaked", soaked)

        memory[info.target].shieldAmount = shieldAmount - soaked
        if soaked == shieldAmount then
            UnitRemoveBuffBJ(CONFIG.refs.buffs.main, info.target)
        end
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
            trigger = "AFTER_DAMAGE",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDamage,
        },
    },
    config = CONFIG,
}
