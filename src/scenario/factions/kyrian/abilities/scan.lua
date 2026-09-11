-- TODO:
-- - [BUG] onDeath nil error
-- - handle stale pending targets
-- - adjust scan radius to current vision radius (can be affected by Fae debuff)
local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local dump = require("utils.logger")
local Unit = require("utils.unit")

local MechStorage = require("scenario.storage.mech")
local PhalynxStorage = require("scenario.storage.phalynx")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            toggle = Ids.abilities.scanToggle,
            trueSight = Ids.abilities.trueSight,
            revealArea = Ids.abilities.scanRevealArea,
            reveal = Ids.abilities.scanReveal,
            speedBuff = Ids.abilities.scanBuffSpeed,
            damageBuff = Ids.abilities.scanBuffDamage,
        },
        buffs = {
            reveal = Ids.buffs.scanReveal,
            speed = Ids.buffs.scanBuffSpeed,
            damage = Ids.buffs.scanBuffDamage,
        },
        units = {
            carrier = Ids.units.phalynx,
        },
    },
    balance = {
        toggleManacost = 10,
        scanRadius = 600,
    },
})

local pendingReveal = {} -- target: unit, processed, queuedAt

local function onTurnOn()
    local unit = GetTriggerUnit()
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    SetUnitState(unit, UNIT_STATE_MANA, mana + CONFIG.balance.toggleManacost)
    UnitAddAbility(unit, CONFIG.refs.abilities.trueSight)
    MechStorage:set(unit, "active", true)
end

local function onTurnOff()
    local unit = GetTriggerUnit()
    UnitRemoveAbility(unit, CONFIG.refs.abilities.trueSight)
    MechStorage:set(GetTriggerUnit(), "active", false)
end

local function onDeath()
    MechStorage:clear(GetDyingUnit())
    PhalynxStorage:remove(GetDyingUnit())
end

local function afterDamage(info)
    if UnitHasBuffBJ(info.source, CONFIG.refs.buffs.speed) then
        UnitRemoveBuffBJ(CONFIG.refs.buffs.speed, info.source)
    end
    if UnitHasBuffBJ(info.source, CONFIG.refs.buffs.damage) then
        UnitRemoveBuffBJ(CONFIG.refs.buffs.damage, info.source)
    end
end

local function onReveal()
    local target = GetSpellTargetUnit()
    pendingReveal[target] = nil
end

local function onTimerScan()
    PhalynxStorage:forEach(function(unit)
        local owner = GetOwningPlayer(unit)
        if not MechStorage:get(unit, "active") then
            return
        end
        for _, u in
            ipairs(Unit.getUnitsInRadius(unit, CONFIG.balance.scanRadius, function(t)
                return (
                    not pendingReveal[t]
                    and not IsUnitAlly(t, owner)
                    and Unit.hasInvisibilityBuff(t)
                    and not UnitHasBuffBJ(t, CONFIG.refs.buffs.reveal)
                )
            end))
        do
            pendingReveal[u] = { unit = unit, ordered = false }
        end
    end)
end

local function onTimerReveal()
    for target, data in pairs(pendingReveal) do
        if data.processed then
            goto continue
        end

        pendingReveal[target].processed = true

        local unit = data.unit
        local owner = GetOwningPlayer(unit)
        Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.reveal, "faeriefire")
        Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.speedBuff, "bloodlust")
        Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.damageBuff, "innerfire")

        ::continue::
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.toggle,
            action = onTurnOn,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.reveal,
            action = onReveal,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "unimmolation",
            action = onTurnOff,
        },
        {
            trigger = "AFTER_DAMAGE",
            filter = { source = CONFIG.refs.units.carrier },
            action = afterDamage,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDeath,
        },
        {
            trigger = "TIMER",
            delta = 0.5,
            action = onTimerScan,
        },
        {
            trigger = "TIMER",
            delta = 0.03,
            action = onTimerReveal,
        },
    },
    config = CONFIG,
}
