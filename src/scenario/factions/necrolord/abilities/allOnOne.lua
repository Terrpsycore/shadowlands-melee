--[[
TODO:
- maybe UI-visible armor decrease during buff
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.allOnOne,
            effect = Ids.abilities.allOnOneSplash,
        },
        buffs = {
            main = Ids.buffs.allOnOne,
        },
        units = {
            carrier = Ids.units.gladiatorHero,
        },
    },
    balance = {
        flushDelta = 0.2,
        radius = 100,
    },
})

local memory = {} -- TODO: save/load

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)

    UnitAddAbility(caster, CONFIG.refs.abilities.effect)
    table.insert(memory, caster)

    local targets = Unit.getUnitsInRadius(caster, CONFIG.balance.radius, function(u)
        return IsUnitEnemy(u, owner)
    end)
    for _, target in ipairs(targets) do
        IssueTargetOrder(target, "attack", caster)
    end
end

--- @param info damageInfo
local function onDamage(info)
    if not info.isAttack then
        return
    end
    info.damageType = DAMAGE_TYPE_ENHANCED
end

local function onTimer(info)
    local flushQueue = {}
    for i, unit in ipairs(memory) do
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            UnitRemoveAbility(unit, CONFIG.refs.abilities.effect)
            table.insert(flushQueue, i)
        end
    end
    for _, index in ipairs(flushQueue) do
        table.remove(memory, index)
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
            trigger = "DAMAGE",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDamage,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.flushDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
