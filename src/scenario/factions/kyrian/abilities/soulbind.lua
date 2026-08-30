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

local Ids = require("data.generated.ids")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local SoulbindStorage = require("scenario.store.soulbind")

local CONFIG = {
    radius = 600,

    tickSeconds = 1,

    secondsForLevel = 5,
    maxLevel = 3,

    soulbindAbilityId = FourCC(Ids.abilities.soulbind),

    levels = {
        [1] = {
            dummyAbilityId = FourCC(Ids.abilities.soulbindBuff),
            buffId = FourCC(Ids.buffs.soulbind),
            requiredUpgradeId = nil,
        },
        [2] = {
            dummyAbilityId = FourCC(Ids.abilities.soulbindBuff),
            buffId = FourCC(Ids.buffs.soulbind),
            requiredUpgradeId = nil,
        },
        [3] = {
            dummyAbilityId = FourCC(Ids.abilities.soulbindBuff),
            buffId = FourCC(Ids.buffs.soulbind),
            requiredUpgradeId = nil,
        },
    },
    validUnitTypes = Type.toSet({
        FourCC(Ids.units.aspirant),
        FourCC(Ids.units.larion),
    }),
}

local function hasCharge(unit)
    return GetUnitAbilityLevel(unit, CONFIG.soulbindAbilityId) > 0
end

local function consumeCharge(caster, target)
    local r1 = UnitRemoveAbility(caster, CONFIG.soulbindAbilityId)
    local r2 = UnitRemoveAbility(target, CONFIG.soulbindAbilityId)
    return r1 and r2
end

local function isSoulbindCarrier(unit)
    local t = GetUnitTypeId(unit)
    return Type.toBool(CONFIG.validUnitTypes[t])
end

local function isValidTarget(caster, target)
    if not Unit.isAlive(caster) or not Unit.isAlive(target) then
        return false
    end
    if caster == target then
        return false
    end
    if SoulbindStorage.getBondIdByUnit(caster) or SoulbindStorage.getBondIdByUnit(target) then
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
    for _, soulbindLevel in ipairs(CONFIG.levels) do
        UnitRemoveBuffBJ(soulbindLevel.buffId, unit)
    end
end

local function applySoulbindBuff(unit, level)
    local dummy = CreateUnit(GetOwningPlayer(unit), FourCC(Ids.units.dummy), GetUnitX(unit), GetUnitY(unit), 270)
    local abilityId = CONFIG.levels[level].dummyAbilityId
    UnitApplyTimedLife(dummy, FourCC("BTLF"), 10.00)
    UnitAddAbility(dummy, abilityId)
    SetUnitAbilityLevel(dummy, abilityId, level)
    -- dump("dummy ability level", GetUnitAbilityLevel(dummy, abilityId))
    -- removeSoulbindBuff(unit)
    IssueTargetOrder(dummy, "innerfire", unit)
end

local function onSoulbindCast()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()

    if not isValidTarget(caster, target) then
        return false
    end

    if not SoulbindStorage.create(SoulbindStorage.allocBondId(), caster, target) then
        error("Can't create soulbind")
    end
    consumeCharge(caster, target)
end

local function tickBond(bondId)
    local bond = SoulbindStorage.open(bondId)
    if not bond then
        return
    end

    local u1, u2 = bond.units[1], bond.units[2]
    if not Unit.isAlive(u1) or not Unit.isAlive(u2) then
        SoulbindStorage.destroy(bondId)
        return
    end

    local inRange = Unit.distance(u1, u2) <= CONFIG.radius
    -- dump("tick", { active = bond.active, level = bond.level, inRange = inRange })
    if not inRange then
        if bond.active then
            bond.active = false
            removeSoulbindBuff(u1)
            removeSoulbindBuff(u2)
        end
        return
    end

    -- update progress & level
    local leveledUp
    if bond.level < CONFIG.maxLevel then
        local progressDelta = (CONFIG.tickSeconds / CONFIG.secondsForLevel)
        bond.progress = math.min(bond.progress + progressDelta, 1)
        if bond.progress >= 1 and bond.level < CONFIG.maxLevel then
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
    SoulbindStorage.forEachActive(tickBond)
end

return {
    triggers = {
        -- EVENT_UNIT_RESEARCH_FINISH
        -- +? unit dies
        EVENT_PLAYER_UNIT_SPELL_EFFECT = {
            spellId = CONFIG.soulbindAbilityId,
            action = onSoulbindCast,
        },
        TIMER = {
            delta = CONFIG.tickSeconds,
            action = updateSoulbindStatus,
        },
    },
    config = CONFIG,
    tickBond = tickBond,
}
