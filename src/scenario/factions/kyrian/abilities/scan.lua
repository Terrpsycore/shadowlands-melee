-- TODO:
-- - handle stale pending targets
-- - adjust scan radius to current vision radius (can be affected by Fae debuff)
local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local dump = require("utils.logger")
local Unit = require("utils.unit")

local MechStorage = require("scenario.storage.mech")
local PhalynxStorage = require("scenario.storage.phalynx")

local CONFIG = {
    toggleManacost = 10,
    scanToggleAbility = FourCC(Ids.abilities.scanToggle),
    scanRevealTrueSightAbility = FourCC(Ids.abilities.trueSight),
    scanRevealAreaAbility = FourCC(Ids.abilities.scanRevealArea),
    scanRevealAbility = FourCC(Ids.abilities.scanReveal),
    scanRevealBuff = FourCC(Ids.buffs.scanReveal),
    scanBuffSpeedAbility = FourCC(Ids.abilities.scanBuffSpeed),
    scanSpeedBuff = FourCC(Ids.buffs.scanBuffSpeed),
    scanBuffDamageAbility = FourCC(Ids.abilities.scanBuffDamage),
    scanDamageBuff = FourCC(Ids.buffs.scanBuffDamage),
}

local pendingReveal = {} -- target: unit, processed, queuedAt

local function onTurnOn()
    local unit = GetTriggerUnit()
    local mana = GetUnitState(unit, UNIT_STATE_MANA)
    SetUnitState(unit, UNIT_STATE_MANA, mana + CONFIG.toggleManacost)
    UnitAddAbility(unit, CONFIG.scanRevealTrueSightAbility)
    MechStorage:set(unit, "active", true)
end

local function onTurnOff()
    local unit = GetTriggerUnit()
    UnitRemoveAbility(unit, CONFIG.scanRevealTrueSightAbility)
    MechStorage:set(GetTriggerUnit(), "active", false)
end

local function onDeath()
    MechStorage:clear(GetDyingUnit())
    PhalynxStorage:clear(GetDyingUnit())
end

local function afterDamage(info)
    if UnitHasBuffBJ(info.source, CONFIG.scanSpeedBuff) then
        UnitRemoveBuffBJ(CONFIG.scanSpeedBuff, info.source)
    end
    if UnitHasBuffBJ(info.source, CONFIG.scanDamageBuff) then
        UnitRemoveBuffBJ(CONFIG.scanDamageBuff, info.source)
    end
end

local function onReveal()
    local target = GetSpellTargetUnit()
    pendingReveal[target] = nil
end

local function onTimerScan()
    -- dump("onTimerScan tick")
    PhalynxStorage:forEach(function(unit)
        local owner = GetOwningPlayer(unit)
        if not MechStorage:get(unit, "active") then
            return
        end
        -- dump("onTimerScan triggered")
        for _, u in
            ipairs(Unit.getUnitsInRadius(unit, 600, function(t)
                return (
                    not pendingReveal[t]
                    and not IsUnitAlly(t, owner)
                    and Unit.hasInvisibilityBuff(t)
                    and not UnitHasBuffBJ(t, CONFIG.scanRevealBuff)
                )
            end))
        do
            pendingReveal[u] = { unit = unit, ordered = false }
        end
    end)
end

local function onTimerReveal()
    -- dump("onTimerScan tick")
    for target, data in pairs(pendingReveal) do
        if data.processed then
            goto continue
        end

        pendingReveal[target].processed = true

        -- dump("onTimerReveal", target)

        local unit = data.unit
        local owner = GetOwningPlayer(unit)
        -- dump("onTimerScan triggered")
        Dummy.applyDummyOrder(owner, target, CONFIG.scanRevealAbility, "faeriefire")
        Dummy.applyDummyOrder(owner, unit, CONFIG.scanBuffSpeedAbility, "bloodlust")
        Dummy.applyDummyOrder(owner, unit, CONFIG.scanBuffDamageAbility, "innerfire")
        -- ? phase + ? issue order attack

        ::continue::
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.scanToggleAbility,
            action = onTurnOn,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.scanRevealAbility,
            action = onReveal,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "unimmolation",
            action = onTurnOff,
        },
        {
            trigger = "AFTER_DAMAGE",
            filter = { source = FourCC(Ids.units.phalynx) },
            action = afterDamage,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = FourCC(Ids.units.phalynx) },
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
