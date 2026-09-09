-- TODO:
-- - CHECK: soulbind charge + bond level & buff constistency on morphing
-- - BUG: soulbind abil charge reappears after morph
-- - BUG: dispellability. Try replacing dummy buff with item abilities (3 separate abilities instead of leveled one or so)
--
-- - [1] - check save-load
-- - check upgrades (GetPlayerTechCount, GetOwningPlayer)
-- - - probably update on trigger and store instead of polling each soulbind tick
-- - object editor (upgrades, soulbind buffs, duration, soulbind ability properties)
-- - invisible soulbind charge for Larion (can be targeted, can't cast)
-- - hashtables (save-load persistance)
-- - refactor (group bond methods)
-- QUESTIONS:
-- - prevent bond progress when next level upgrade is not done
-- - autocheck object ability levels VS script ability levels

local Ids = require("data.ids")
local AbilityConfig = require("scenario.config")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local SoulbindStorage = require("scenario.storage.soulbind")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.soulbind,
            buff = Ids.abilities.soulbindBuff,
        },
        buffs = {
            main = Ids.buffs.soulbind,
        },
        units = {
            dummy = Ids.units.dummy,
            carriers = { Ids.units.aspirant, Ids.units.larion },
        },
    },
    balance = {
        radius = 600,
        tickSeconds = 1,
        secondsForLevel = 5,
        maxLevel = 3,
        levels = {
            [1] = { requiredUpgradeId = nil },
            [2] = { requiredUpgradeId = nil },
            [3] = { requiredUpgradeId = nil },
        },
    },
})

local carrierTypeSet = Type.toSet(CONFIG.refs.units.carriers)

local function hasCharge(unit)
    return GetUnitAbilityLevel(unit, CONFIG.refs.abilities.main) > 0
end

local function consumeCharge(caster, target)
    local r1 = UnitRemoveAbility(caster, CONFIG.refs.abilities.main)
    local r2 = UnitRemoveAbility(target, CONFIG.refs.abilities.main)
    return r1 and r2
end

local function isSoulbindCarrier(unit)
    local t = GetUnitTypeId(unit)
    return Type.toBool(carrierTypeSet[t])
end

local function isValidTarget(caster, target)
    if not Unit.isAlive(caster) or not Unit.isAlive(target) then
        return false
    end
    if caster == target then
        return false
    end
    if SoulbindStorage:getByUnit(caster) or SoulbindStorage:getByUnit(target) then
        return false
    end
    if not isSoulbindCarrier(target) then
        return false
    end
    if not hasCharge(caster) or not hasCharge(target) then
        return false
    end
    return true
end

local function removeSoulbindBuff(unit)
    UnitRemoveBuffBJ(CONFIG.refs.buffs.main, unit)
end

local function applySoulbindBuff(unit, level)
    local dummy = CreateUnit(
        GetOwningPlayer(unit),
        AbilityConfig.unitId(CONFIG.refs.units.dummy),
        GetUnitX(unit),
        GetUnitY(unit),
        270
    )
    local abilityId = CONFIG.refs.abilities.buff
    UnitApplyTimedLife(dummy, FourCC("BTLF"), 10.00)
    UnitAddAbility(dummy, abilityId)
    SetUnitAbilityLevel(dummy, abilityId, level)
    IssueTargetOrder(dummy, "innerfire", unit)
end

local function onSoulbindCast()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()

    if not isValidTarget(caster, target) then
        return false
    end

    if not SoulbindStorage:create(SoulbindStorage:alloc(), { unit_a = caster, unit_b = target }) then
        error("Can't create soulbind")
    end
    consumeCharge(caster, target)
end

local function tickBond(bondId)
    local bond = SoulbindStorage:open(bondId)
    if not bond then
        return
    end

    local u1, u2 = bond.unit_a, bond.unit_b
    if not Unit.isAlive(u1) or not Unit.isAlive(u2) then
        SoulbindStorage:destroy(bondId)
        return
    end

    local inRange = Unit.distance(u1, u2) <= CONFIG.balance.radius
    if not inRange then
        if bond.active then
            bond.active = false
            removeSoulbindBuff(u1)
            removeSoulbindBuff(u2)
        end
        return
    end

    local leveledUp
    if bond.level < CONFIG.balance.maxLevel then
        local progressDelta = (CONFIG.balance.tickSeconds / CONFIG.balance.secondsForLevel)
        bond.progress = math.min(bond.progress + progressDelta, 1)
        if bond.progress >= 1 and bond.level < CONFIG.balance.maxLevel then
            bond.progress = 0
            bond.level = bond.level + 1
            leveledUp = true
        else
            leveledUp = false
        end
    end
    if not bond.active or leveledUp then
        bond.active = true
        applySoulbindBuff(u1, bond.level)
        applySoulbindBuff(u2, bond.level)
    end
end

local function updateSoulbindStatus()
    SoulbindStorage:forEachActive(tickBond)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSoulbindCast,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.tickSeconds,
            action = updateSoulbindStatus,
        },
    },
    config = CONFIG,
    tickBond = tickBond,
}
