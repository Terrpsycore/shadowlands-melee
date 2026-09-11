--[[
-- TODO:
-- - add max targets
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.counterattackCall")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.counterattackCall,
            dummy = Ids.abilities.counterattackCallDummy,
            bonus = Ids.abilities.counterattackCallBonus,
        },
        buffs = {
            main = Ids.buffs.counterattackCall,
        },
    },
    balance = {
        radius = 500,
        tick = 0.03,
    },
})

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    local targets = Unit.getAllyUnitsInRadius(caster, CONFIG.balance.radius, function(u)
        return IsUnitAliveBJ(u)
    end)

    for _, target in ipairs(targets) do
        Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.dummy, "innerfire", level)
    end
end

local function onDummySpell()
    local target = GetSpellTargetUnit()
    Storage:add(target)
    local level = GetUnitAbilityLevel(target, CONFIG.refs.abilities.bonus)
    if level then
        UnitAddAbility(target, CONFIG.refs.abilities.bonus)
        SetUnitAbilityLevel(target, CONFIG.refs.abilities.bonus, level)
    end
end

local function onDamage(info)
    if not Storage:has(info.source) then
        return
    end
    if UnitHasBuffBJ(info.source, CONFIG.refs.buffs.main) then
        info.damage = info.damage + 20
    end
end

local function onTimer()
    -- optional: modify damage when debuff present
    -- iterate storage
    -- if buff faded - remove bonus damage ability
    Storage:each(function(u)
        if not UnitHasBuffBJ(u, CONFIG.refs.buffs.main) then
            UnitRemoveAbility(u, CONFIG.refs.abilities.bonus)
            Storage:drop(u)
        end
    end)
end

local function onDeath()
    local unit = GetDyingUnit()
    if not Storage:has(unit) then
        return
    end
    Storage:drop(unit)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.dummy,
            action = onDummySpell,
        },
        {
            trigger = "DAMAGE",
            filter = { source = CONFIG.refs.units.source },
            action = onDamage,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.tick,
            action = onTimer,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            action = onDeath,
        },
    },
    config = CONFIG,
}
