-- TODO:
-- - [1] - check storage layer
-- - check upgrades (GetPlayerTechCount, GetOwningPlayer)
-- - - probably update on trigger and store instead of polling each soulbind tick
-- - apply buffs with dummy
-- - object editor (upgrades, soulbind buffs, soulbind ability properties)
-- - invisible soulbind charge for Larion (can be targeted, can't cast)
-- - hashtables (save-load persistance)
-- - refactor (group bond methods)
-- - remove buff on bond destroy, apply buff on bond create, update buff on level up
-- QUESTIONS:
-- - prevent bond progress when next level upgrade is not done
-- - how to refactor to not make hashtable storage transition more difficult

local Ids = require("data.generated.ids")
local Type = require("utils.type")
local Unit = require("utils.unit")

local SoulbindStorage = require("scenario.abilities.store.soulbind")

local CONFIG = {
    radius = 600,

    tickSeconds = 1,

    secondsForLevel = 60,
    maxLevel = 3,

    levels = {
        [1] = {
            dummyAbilityId = Ids.abilities.soulbindBuff,
            requiredUpgradeId = nil,
        },
        [2] = {
            dummyAbilityId = Ids.abilities.soulbindBuff,
            requiredUpgradeId = nil,
        },
        [3] = {
            dummyAbilityId = Ids.abilities.soulbindBuff,
            requiredUpgradeId = nil,
        },
    },
    validUnitTypes = Type.toSet({
        FourCC(Ids.units.aspirant),
        FourCC(Ids.units.larion),
    }),
}

local soulbindAbilityId = Ids.abilities.soulbind

local function hasCharge(unit)
    return GetUnitAbilityLevel(unit, FourCC(soulbindAbilityId)) > 0
end

local function consumeCharge(caster, target)
    local r1 = UnitRemoveAbility(caster, FourCC(soulbindAbilityId))
    local r2 = UnitRemoveAbility(target, FourCC(soulbindAbilityId))
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

local function applySoulbindBuff(unit, level)
    return "NOT IMPLEMENTED"
end

local function removeSoulbindBuff(unit)
    return "NOT IMPLEMENTED"
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
    if not inRange then
        if bond.active then
            bond.active = false
            removeSoulbindBuff(u1)
            removeSoulbindBuff(u2)
        end
        return
    end

    -- update progress & level
    if bond.level < CONFIG.maxLevel then
        local progressDelta = (CONFIG.tickSeconds / CONFIG.secondsForLevel)
        bond.progress = math.min(bond.progress + progressDelta, 1)
        if bond.progress >= 1 and bond.level < CONFIG.maxLevel then
            bond.progress = 0
            bond.level = bond.level + 1
        end
    end
    if not bond.active then
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
            spellId = soulbindAbilityId,
            action = onSoulbindCast,
        },
        TIMER = {
            delta = CONFIG.tickSeconds,
            action = updateSoulbindStatus,
        },
    },
    config = CONFIG,
}
