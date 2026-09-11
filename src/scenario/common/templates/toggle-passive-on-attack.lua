--[[
  ARCHETYPE: toggle-passive-on-attack
  TEMPLATE ONLY — copy to scenario/factions/<faction>/abilities/<slug>.lua

  DATA CHECKLIST:
    - data/abilities: {slug} (passive effect ability, added/removed on toggle)
    - data/abilities: {slug}Toggle (A.immolationToggle)
    - data/units: add "{slug}Toggle" to carrier.abilities
    - lua objediting/gen_ids.lua

  STORAGE: scenario.storage.mech
  TEST: toggle on/off, attack triggers mana spend, train default-on

  REFERENCE: scenario/factions/kyrian/abilities/animaBarrage.lua
  TRIGGERS: templates/_reference.lua
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Unit = require("utils.unit")

local MechStorage = require("scenario.storage.mech")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.animaBarrage, -- CHANGE slug (effect ability)
            toggle = Ids.abilities.animaBarrageToggle,
        },
        units = {
            carrier = Ids.units.colossus, -- CHANGE carrier
        },
    },
    balance = {
        manacost = 5,
        radius = 500,
    },
})

local function onTurnOn()
    local unit = GetTriggerUnit()
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    SetUnitState(unit, UNIT_STATE_MANA, mana + CONFIG.balance.manacost)
    UnitAddAbility(unit, CONFIG.refs.abilities.main)
    MechStorage:set(unit, "active", true)
end

local function onTurnOff()
    local unit = GetTriggerUnit()
    UnitRemoveAbility(unit, CONFIG.refs.abilities.main)
    MechStorage:set(unit, "active", false)
end

local function onTrain()
    local unit = GetTrainedUnit()
    MechStorage:set(unit, "active", true)
end

local function onDeath()
    MechStorage:clear(GetDyingUnit())
end

local function onAttack()
    local unit = GetAttacker()
    if not MechStorage:get(unit, "active") then
        return
    end

    -- === UNIQUE LOGIC: check conditions, spend mana ===
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    if mana < CONFIG.balance.manacost then
        return
    end
    SetUnitState(unit, UNIT_STATE_MANA, mana - CONFIG.balance.manacost)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.toggle,
            action = onTurnOn,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "unimmolation",
            action = onTurnOff,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onTrain,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ATTACKED",
            filter = { source = CONFIG.refs.units.carrier },
            action = onAttack,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDeath,
        },
    },
    config = CONFIG,
}
