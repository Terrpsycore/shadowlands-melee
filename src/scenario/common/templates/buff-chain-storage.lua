--[[
  ARCHETYPE: buff-chain-storage
  TEMPLATE ONLY — copy to scenario/factions/<faction>/abilities/<slug>.lua

  DATA CHECKLIST:
    - data/abilities: {slug} (visible cast)
    - data/abilities: {slug}*Dummy / *Buff (hidden appliers)
    - data/buffs.lua: effect buffs
    - scenario/storage/{slug}.lua — per-target state
    - data/units: add "{slug}" to carrier.abilities
    - lua tools/bake.lua

  STORAGE: dedicated per-target fields
  TEST: cast applies buff; condition removes buff; dispell cleanup

  REFERENCE: dedication.lua, deepMeditation.lua
  TRIGGERS: templates/_reference.lua
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

-- local Storage = require("scenario.storage.dedication") -- CHANGE storage module

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.dedication, -- CHANGE slug
            damageBuff = Ids.abilities.dedicationDamageBuff,
            followUp = Ids.abilities.dedicationAttackSpeedBuff, -- optional second step
        },
        buffs = {
            main = Ids.buffs.dedication,
        },
    },
    balance = {
        tickSeconds = 0.03,
        damageThreshold = 50, -- for deepMeditation-style break-on-damage
    },
})

local function removeEffect(unit)
    UnitRemoveBuffBJ(CONFIG.refs.buffs.main, unit)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.followUp)
    -- Storage:drop(unit)
end

local function onCast()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()

    Dummy.applyDummyOrder(GetOwningPlayer(caster), target, CONFIG.refs.abilities.damageBuff, "innerfire")
end

local function onDummyCast()
    local unit = GetSpellTargetUnit()
    UnitAddAbility(unit, CONFIG.refs.abilities.followUp)
    -- Storage:set(unit, "field", initialValue)
end

local function onAttack()
    -- optional: break effect when target changes (dedication)
    local unit = GetAttacker()
    local target = GetTriggerUnit()
end

local function onDamage(info)
    -- optional: break effect when damage threshold exceeded (deepMeditation)
end

local function onFrame()
    -- Storage:forEach — check buff still present, cleanup if not
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.damageBuff,
            action = onDummyCast,
        },
        -- pick ATTACKED or DAMAGE depending on break condition:
        -- {
        --     trigger = "EVENT_PLAYER_UNIT_ATTACKED",
        --     action = onAttack,
        -- },
        -- {
        --     trigger = "DAMAGE",
        --     action = onDamage,
        -- },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.tickSeconds,
            action = onFrame,
        },
    },
    config = CONFIG,
}
