--[[
  ARCHETYPE: on-cast-effect
  TEMPLATE ONLY — copy to scenario/factions/<faction>/abilities/<slug>.lua

  DATA CHECKLIST:
    - data/abilities: {slug} (e.g. A.channelArea, A.channelPoint)
    - optional hidden abilities for dummy debuffs
    - data/buffs.lua for debuff slugs
    - data/units: add "{slug}" to carrier.abilities
    - lua objediting/gen_ids.lua

  STORAGE: usually none
  TEST: cast hits targets in radius; optional DAMAGE hook

  REFERENCE: scenario/factions/kyrian/abilities/bastionSpear.lua
  TRIGGERS: templates/_reference.lua
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

    local targets = Unit.getAllyUnitsInRadius(caster, CONFIG.balance.radius, function(u)
        return IsUnitAliveBJ(u)
    end)

    for _, target in ipairs(targets) do
        Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.dummy, "innerfire")
    end
end

local function onDummySpell()
    local target = GetSpellTargetUnit()
    Storage:add(target)
    if GetUnitAbilityLevel(target, CONFIG.refs.abilities.bonus) then
        UnitAddAbility(target, CONFIG.refs.abilities.bonus)
    end
end

local function onDamage(info)
    if not Storage:have(info.source) then
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
    Storage:forEach(function(u)
        if not UnitHasBuffBJ(u, CONFIG.refs.buffs.main) then
            UnitRemoveAbility(u, CONFIG.refs.abilities.bonus)
            Storage:clear(u)
        end
    end)
end

local function onDeath()
    local unit = GetDyingUnit()
    if not Storage:have(unit) then
        return
    end
    Storage:clear(unit)
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
