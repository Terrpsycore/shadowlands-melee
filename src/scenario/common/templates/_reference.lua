--[[
  REFERENCE ONLY — do not require in scenario/abilities.lua.

  Encyclopedia of all trigger types supported by lib/triggers/callbacks.lua.
  Copy individual trigger blocks into your ability module, or start from an
  archetype template in this folder.

  See also: scenario/common/_template.lua (index of archetypes).
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.defenceProtocol,
            toggle = Ids.abilities.defenceProtocolToggle,
            buff = Ids.abilities.defenceProtocolBuff,
            dummy = Ids.abilities.pulsebackPulse,
        },
        buffs = {
            main = Ids.buffs.defenceProtocol,
        },
        units = {
            carrier = Ids.units.praetor,
            protected = { Ids.units.steward, Ids.units.aspirant },
            dummy = Ids.units.dummy,
        },
        items = {
            main = Ids.items.dummyHeroItem,
        },
    },
    balance = {
        cooldown = 5,
        manacost = 20,
        radius = 600,
        tickSeconds = 0.5,
    },
})

-- SPELL_CAST: fires when cast starts (before effect). Use for validation / early cancel.
-- API: GetTriggerUnit(), GetSpellTargetUnit(), GetSpellTargetX/Y()
local function onSpellCast() end

-- SPELL_EFFECT: fires when spell lands. Most common for active abilities.
-- API: GetTriggerUnit(), GetSpellTargetUnit(), GetSpellTargetX/Y()
local function onSpellEffect() end

-- SPELL_ENDCAST: fires when channel ends (success or interrupt).
-- API: GetTriggerUnit()
local function onSpellEndcast() end

-- ISSUED_ORDER: specific immediate order (e.g. unimmolation for toggle-off).
-- API: GetTriggerUnit(), GetIssuedOrderId()
local function onIssuedOrder() end

-- ISSUED_TARGET_ORDER: any target order. Rarely used directly; prefer ISSUED_ORDER + order or ORDER.
-- API: GetTriggerUnit(), GetOrderedUnit()
local function onIssuedTargetOrder() end

-- ISSUED_POINT_ORDER: any point order. Rarely used directly.
-- API: GetTriggerUnit(), GetOrderPointX/Y()
local function onIssuedPointOrder() end

-- ORDER: any order (immediate, point, target). Use when you need all order types.
-- API: GetTriggerUnit(), GetIssuedOrderId(), GetOrderedUnit(), GetOrderPointX/Y()
local function onAnyOrder() end

-- ATTACKED: unit started attacking. filter.source = attacker, filter.target = attacked unit.
-- API: GetAttacker(), GetTriggerUnit() (attacked unit)
local function onAttacked() end

-- DEATH: unit died. filter.target = dying unit type.
-- API: GetDyingUnit(), GetKillingUnit()
local function onDeath() end

-- TRAIN_FINISH: unit trained from building. filter.source = building, filter.target = trained unit type.
-- API: GetTriggerUnit(), GetTrainedUnit()
local function onTrainFinish() end

-- SUMMON: unit summoned. filter.target = summoned unit type.
-- API: GetSummoningUnit(), GetSummonedUnit()
local function onSummon() end

-- SELECTED: unit selected by player.
-- API: GetTriggerUnit()
local function onSelected() end

-- PRE_DAMAGE: modify damage before applied. info.damage is writable.
-- info: { source, target, damage, isAttack, isSpell, ... }
-- filter.isAttack / filter.isSpell — optional (damage triggers only)
local function onPreDamage(info) end

-- DAMAGE: on damage event. info: { source, target, damage, isAttack, isSpell, ... }
local function onDamage(info) end

-- AFTER_DAMAGE: after damage applied. info: { source, target, damage, ... }
local function onAfterDamage(info) end

-- TIMER: periodic tick. Set delta in seconds.
local function onTimer() end

-- STUN: custom event when unit gains a registered stun buff (see abilities.buffs.stun).
-- info: { source, target, damage, ... }
local function onStun(info) end

-- ROOT: custom event when unit gains a registered root buff (see abilities.buffs.root).
-- info: { source, target, damage, ... }
local function onRoot(info) end

-- REVIVE: custom event when a unit is revived (e.g. animateDead).
-- ctx: { source, target } — caster and revived unit; fire via Triggers.fireEvent from source ability.
local function onRevive(ctx) end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_CAST",
            spellId = CONFIG.refs.abilities.main,
            action = onSpellCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpellEffect,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_ENDCAST",
            spellId = CONFIG.refs.abilities.main,
            action = onSpellEndcast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "unimmolation",
            action = onIssuedOrder,
        },
        {
            -- Prefer ISSUED_ORDER + order, or ORDER below, unless you need target-only hook.
            trigger = "EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER",
            action = onIssuedTargetOrder,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER",
            action = onIssuedPointOrder,
        },
        {
            trigger = "ORDER",
            action = onAnyOrder,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ATTACKED",
            filter = { source = CONFIG.refs.units.carrier },
            action = onAttacked,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDeath,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onTrainFinish,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SUMMON",
            filter = { target = CONFIG.refs.units.dummy },
            action = onSummon,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SELECTED",
            action = onSelected,
        },
        -- filter.isAttack / filter.isSpell — optional; omit = any damage (damageInfo)
        {
            trigger = "PRE_DAMAGE",
            filter = { target = CONFIG.refs.units.protected },
            action = onPreDamage,
        },
        {
            trigger = "DAMAGE",
            filter = {
                source = CONFIG.refs.units.carrier,
                target = CONFIG.refs.units.protected,
                isAttack = true,
            },
            action = onDamage,
        },
        {
            trigger = "AFTER_DAMAGE",
            filter = {
                source = CONFIG.refs.units.carrier,
                isAttack = true,
            },
            action = onAfterDamage,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.tickSeconds,
            action = onTimer,
        },
        {
            trigger = "STUN",
            action = onStun,
        },
        {
            trigger = "ROOT",
            action = onRoot,
        },
        {
            trigger = "REVIVE",
            filter = { target = CONFIG.refs.units.carrier },
            action = onRevive,
        },
    },
    config = CONFIG,
}
