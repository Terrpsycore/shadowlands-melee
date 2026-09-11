--[[
  ARCHETYPE: toggle-passive-on-damage
  TEMPLATE ONLY — copy to scenario/factions/<faction>/abilities/<slug>.lua

  DATA CHECKLIST:
    - data/abilities: {slug} (A.exhumeBased — hidden CD holder)
    - data/abilities: {slug}Toggle (A.immolationToggle)
    - data/abilities: {slug}Buff or {slug}Pulse (dummy effect, optional)
    - data/buffs.lua (if buff applied)
    - data/units: add "{slug}Toggle" to carrier.abilities
    - lua tools/bake.lua

  STORAGE: scenario.storage.mech (shared toggle state)
  TEST: toggle on/off, damage triggers effect, cooldown, mana cost

  REFERENCE: defenceProtocol.lua, pulseback.lua
  TRIGGERS: templates/_reference.lua
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local MechStorage = require("scenario.storage.mech")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.defenceProtocol, -- CHANGE slug (CD holder)
            toggle = Ids.abilities.defenceProtocolToggle,
            buff = Ids.abilities.defenceProtocolBuff, -- optional dummy
        },
        buffs = {
            main = Ids.buffs.defenceProtocol, -- optional
        },
        units = {
            carrier = Ids.units.praetor, -- CHANGE carrier
            protected = { Ids.units.steward, Ids.units.aspirant }, -- DAMAGE filter target
        },
    },
    balance = {
        cooldown = 5,
        manacost = 20,
        radius = 600, -- if effect searches nearby carriers
        chance = nil, -- set number (0-100) for random proc, nil = always
    },
})

-- === UNIQUE LOGIC: implement effect ===
local function effect(unit, info)
    -- defenceProtocol: Dummy.applyDummyOrder(..., "bloodlust")
    -- pulseback: AoE damage + blizzard visual
end

local function tryActivate(info)
    local unit = info.target -- CHANGE: may be nearby carrier instead
    if MechStorage:get(unit, "active") == false then
        return
    end
    if not Unit.isOffCooldown(unit, CONFIG.refs.abilities.main) then
        return
    end
    if CONFIG.balance.chance and GetRandomReal(0, 100) >= CONFIG.balance.chance then
        return
    end
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    if mana < CONFIG.balance.manacost then
        return
    end
    BlzStartUnitAbilityCooldown(unit, CONFIG.refs.abilities.main, CONFIG.balance.cooldown)
    effect(unit, info)
    SetUnitState(unit, UNIT_STATE_MANA, mana - CONFIG.balance.manacost)
end

local function onTurnOn()
    local unit = GetTriggerUnit()
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    SetUnitState(unit, UNIT_STATE_MANA, mana + CONFIG.balance.manacost)
    MechStorage:set(unit, "active", true)
end

local function onTurnOff()
    MechStorage:set(GetTriggerUnit(), "active", false)
end

local function onTrain()
    local unit = GetTrainedUnit()
    MechStorage:set(unit, "active", true)
    IssueImmediateOrder(unit, "immolation") -- default-on; remove if not needed
end

local function onDeath()
    MechStorage:clear(GetDyingUnit())
end

local function onDamage(info)
    tryActivate(info)
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
            trigger = "DAMAGE",
            filter = { target = CONFIG.refs.units.protected },
            action = onDamage,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDeath,
        },
        -- uncomment for default-on at train:
        -- {
        --     trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
        --     filter = { target = CONFIG.refs.units.carrier },
        --     action = onTrain,
        -- },
    },
    config = CONFIG,
}
