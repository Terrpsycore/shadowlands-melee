--[[
TODO:
-- abil effects
-- ! UI error on "no corpse"
-- ! remove limb on timer (should be done already)
-- initDefault in STORAGE instead of implementation
-- if unit is stunned & must apply limb buff -> add timed aura instead
-- maybe rewrite to aura with duration & remove limb buff when aura fades
-- maybe set timer to 1-2s + onBeforeDamage
-- hide "effect" ability on add with BlzUnitHideAbility
]]
local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local UnitMeta = require("lib.units")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.stitched")
local StorageTmpBuffs = require("scenario.storage.stitchedTmpBuffs")
local StorageTurnableStatus = require("scenario.storage.constructTurnableStatus")

-- stitchingBase
-- stitchingAdvanced
-- stitchingBase...Effect
-- stitchingLimb
local factionSlugs = { "kyrian", "necrolord", "fae", "venthyr", "mawsworn" }

local abilityRefs = {
    applyLimb = Ids.abilities.applyLimb,
    stitchingAdvancedVersatile = Ids.abilities.stitchingAdvancedVersatile,
    faeCreateIllusion = Ids.abilities.stitchingFaeCreateIllusion,
    mawswornReduceHp = Ids.abilities.stitchingMawswornReduceHp,
    mawswornReduceHpDebuff = Ids.abilities.stitchingMawswornReduceHpDebuff,
    mawswornIncreaseHp = Ids.abilities.stitchingMawswornIncreaseHp,
    mawswornIncreaseHpBuff = Ids.abilities.stitchingMawswornIncreaseHpBuff,
}
local buffRefs = {
    stitchingMawswornReduceHpDebuff = Ids.buffs.stitchingMawswornReduceHpDebuff,
    stitchingMawswornIncreaseHpBuff = Ids.buffs.stitchingMawswornIncreaseHpBuff,
}
local stitchRefs = {}
for _, factionSlug in ipairs(factionSlugs) do
    local slugCapitalized = factionSlug:sub(1, 1):upper() .. factionSlug:sub(2)
    abilityRefs["stitchingBase" .. slugCapitalized] = Ids.abilities["stitchingBase" .. slugCapitalized]
    abilityRefs["stitchingAura" .. slugCapitalized] = Ids.abilities["stitchingAura" .. slugCapitalized]
    abilityRefs["stitchingAdvanced" .. slugCapitalized] = Ids.abilities["stitchingAdvanced" .. slugCapitalized]
    abilityRefs["stitchingBase" .. slugCapitalized .. "Effect"] =
        Ids.abilities["stitchingBase" .. slugCapitalized .. "Effect"]
    abilityRefs["stitchingLimb" .. slugCapitalized] = Ids.abilities["stitchingLimb" .. slugCapitalized]
    buffRefs["stitchingBase" .. slugCapitalized] = Ids.buffs["stitchingBase" .. slugCapitalized]
    buffRefs["stitchingLimb" .. slugCapitalized] = Ids.buffs["stitchingLimb" .. slugCapitalized]
    buffRefs["stitchingAdvanced" .. slugCapitalized] = Ids.buffs["stitchingAdvanced" .. slugCapitalized]
    stitchRefs[factionSlug] = {}
    stitchRefs[factionSlug].base = FourCC(abilityRefs["stitchingBase" .. slugCapitalized])
    stitchRefs[factionSlug].aura = FourCC(abilityRefs["stitchingAura" .. slugCapitalized])
    stitchRefs[factionSlug].advanced = FourCC(abilityRefs["stitchingAdvanced" .. slugCapitalized])
    stitchRefs[factionSlug].effect = FourCC(abilityRefs["stitchingBase" .. slugCapitalized .. "Effect"])
    stitchRefs[factionSlug].limb = FourCC(abilityRefs["stitchingLimb" .. slugCapitalized])
    stitchRefs[factionSlug].baseBuff = FourCC(buffRefs["stitchingBase" .. slugCapitalized])
    stitchRefs[factionSlug].limbBuff = FourCC(buffRefs["stitchingLimb" .. slugCapitalized])
    stitchRefs[factionSlug].advancedBuff = FourCC(buffRefs["stitchingAdvanced" .. slugCapitalized])
end

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = abilityRefs,
        buffs = buffRefs,
        units = {
            construct = Ids.units.construct,
        },
        items = {
            main = Ids.items.dummyHeroItem,
        },
    },
    balance = {
        duration = 60,
        searchRadiusPoint = 600,
        tickSeconds = 0.5,
        effects = {
            kyrian = { base = { damagePerLevel = 5 } },
            fae = {
                base = {
                    chance = 0.20,
                },
            },
        },
    },
})

local function isConstruct(unit)
    return GetUnitTypeId(unit) == CONFIG.refs.units.construct
end

local function getFactionIndex(faction)
    for i, slug in ipairs(factionSlugs) do
        if slug == faction then
            return i
        end
    end
end

local function clearApplyLimbBuffCommon(unit)
    local faction = StorageTmpBuffs:get(unit, "faction")
    if not faction then
        error("error")
    end
    local faction = factionSlugs[faction]
    local stitchSkills = stitchRefs[faction]
    UnitRemoveAbility(unit, stitchSkills.effect)
    UnitRemoveBuffBJ(stitchSkills.limbBuff, unit)
    StorageTmpBuffs:drop(unit)
end

--- @param unit unit
--- @param faction string
local function addApplyLimbBuffCommon(unit, faction)
    StorageTmpBuffs:set(unit, "faction", getFactionIndex(faction))
    StorageTmpBuffs:set(unit, "expiresAt", GetElapsedGameTime() + CONFIG.balance.duration)
    if IsUnitType(unit, UNIT_TYPE_STUNNED) then
        UnitAddAbility(unit, stitchRefs[faction].base)
    else
        UnitAddAbility(unit, stitchRefs[faction].limb)
        IssueImmediateOrder(unit, "berserk")
        UnitRemoveAbility(unit, stitchRefs[faction].limb)
    end
    UnitAddAbility(unit, stitchRefs[faction].effect)
end

-- Adjust faction ability levels
--- @param unit unit
local function refreshConstruct(unit, faction, construct)
    local factionStitchN = construct[faction]
    dump("abilityRefs", abilityRefs)
    dump("stitchRefs", stitchRefs)
    dump("stitchRefs[faction]", stitchRefs[faction])
    if factionStitchN == 0 then
        UnitRemoveAbility(unit, stitchRefs[faction].base)
        UnitRemoveAbility(unit, stitchRefs[faction].aura)
        UnitRemoveAbility(unit, stitchRefs[faction].effect)
        return
    end
    if factionStitchN == 1 then
        UnitAddAbility(unit, stitchRefs[faction].base)
        UnitAddAbility(unit, stitchRefs[faction].aura)
        UnitAddAbility(unit, stitchRefs[faction].effect)
    end
    if factionStitchN == 2 then
        UnitAddAbility(unit, stitchRefs[faction].advanced)
    end
    SetUnitAbilityLevel(unit, stitchRefs[faction].base, math.min(3, factionStitchN))
    SetUnitAbilityLevel(unit, stitchRefs[faction].aura, math.min(3, factionStitchN))
    SetUnitAbilityLevel(unit, stitchRefs[faction].effect, factionStitchN)
end

local function clearApplyLimbBuffConstruct(unit, construct)
    local factionIndex = StorageTmpBuffs:get(unit, "faction")
    if not factionIndex then
        error("error")
    end
    local faction = factionSlugs[factionIndex]
    construct[faction] = construct[faction] - 1
    construct.total = construct.total - 1
    UnitRemoveBuffBJ(stitchRefs[faction].limbBuff, unit)

    refreshConstruct(unit, faction, construct)

    StorageTmpBuffs:drop(unit)
end

--- @param unit unit
local function upgradeConstruct(unit, faction, construct)
    -- upgrade aura (+ give advanced abil) or apply tmp buff
    construct[faction] = construct[faction] + 1
    construct.total = construct.total + 1
    if construct.total > 4 then
        error("Invalid stitch count")
    end

    refreshConstruct(unit, faction, construct)

    if construct.total == 3 and construct.max == 1 then
        UnitAddAbility(unit, CONFIG.refs.abilities.stitchingAdvancedVersatile)
    end

    -- Add timed buff
    if construct.total == 4 then
        StorageTmpBuffs:set(unit, "faction", getFactionIndex(faction))
        if not IsUnitType(unit, UNIT_TYPE_STUNNED) then
            UnitAddAbility(unit, stitchRefs[faction].limb)
            IssueImmediateOrder(unit, "berserk")
            UnitRemoveAbility(unit, stitchRefs[faction].limb)
        end
    end
end

local function onApplyLimb()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    -- find corpse, get faction
    -- Storage
    local corpse = Unit.getNearestCorpse(caster, CONFIG.balance.searchRadiusPoint)
    local faction = UnitMeta.factionOf(corpse)
    if not faction then
        return error("Unknown faction")
    end

    local hasBuff = StorageTmpBuffs:has(target)
    local construct = not isConstruct(target) or Storage:bind(target)
    if isConstruct(target) and (not construct or not construct[faction]) then
        return error("Broken construct data")
    end

    if isConstruct(target) then
        if hasBuff then
            clearApplyLimbBuffConstruct(target, construct)
        end
        upgradeConstruct(target, faction, construct)
    else
        if hasBuff then
            clearApplyLimbBuffCommon(target)
        end
        addApplyLimbBuffCommon(target, faction)
    end
end

local function onConstructCreate(info)
    local unit = info.target
    Storage:set(unit, "total", 0)
    Storage:set(unit, "max", 0)
    Storage:set(unit, "kyrian", 0)
    Storage:set(unit, "necrolord", 0)
    Storage:set(unit, "fae", 0)
    Storage:set(unit, "venthyr", 0)
    Storage:set(unit, "mawsworn", 0)
end

-- ISSUED_ORDER: specific immediate order (e.g. unimmolation for toggle-off).
-- API: GetTriggerUnit(), GetIssuedOrderId()
local function onIssuedOrder() end

local function baseEffectKyrian(source, target, level)
    Damage.apply(
        source,
        target,
        CONFIG.balance.effects.kyrian.base.damagePerLevel * level,
        false,
        false,
        ATTACK_TYPE_MAGIC
    )
end

local function baseEffectFae(source, target, level)
    local owner = GetOwningPlayer(source)
    if GetRandomReal(0, 100) >= CONFIG.balance.effects.fae.base.chance then
        return
    end
    -- TODO:
    -- - check illusion cap storage
    -- - taunt if turnable on
    Dummy.applyDummyOrder(owner, source, CONFIG.refs.abilities.faeCreateIllusion, "channel", level) -- todo: check order string
end

local function baseEffectMawsworn(source, target, level)
    -- TODO: chain buff&debuff
    local owner = GetOwningPlayer(source)
    local debuffLevelBefore = GetUnitAbilityLevel(target, CONFIG.refs.abilities.mawswornReduceHp)
    local debuffLevelAfter = math.min(debuffLevelBefore + 1, level)

    local turnableStatus = StorageTurnableStatus:bind(source)
    local turnableActive = turnableStatus
        and turnableStatus.active
        and turnableStatus.faction == getFactionIndex(turnableStatus.faction)

    Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.mawswornReduceHpDebuff, "curse", level)
    if turnableActive and debuffLevelAfter > debuffLevelBefore then
        Dummy.applyDummyOrder(owner, source, CONFIG.refs.abilities.mawswornIncreaseHpBuff, "innerfire", level)
    end
end

local function onMawswornStealHp()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    local level = GetUnitAbilityLevel(caster, GetSpellAbilityId())

    local debuffLevelBefore = GetUnitAbilityLevel(target, CONFIG.refs.abilities.mawswornReduceHp)
    if debuffLevelBefore == 0 then
        UnitAddAbility(target, CONFIG.refs.abilities.mawswornReduceHp)
    end
    local debuffLevelAfter = math.min(debuffLevelBefore, level)
    if debuffLevelAfter > debuffLevelBefore then
        SetUnitAbilityLevel(target, CONFIG.refs.abilities.mawswornReduceHp, debuffLevelAfter)
    end
end

-- DAMAGE: on damage event. info: { source, target, damage, ... }
local function onDamage(info)
    local onAttack = {
        [stitchRefs.kyrian.effect] = baseEffectKyrian,
        [stitchRefs.fae.effect] = baseEffectFae,
        [stitchRefs.mawsworn.effect] = baseEffectMawsworn,
    }
    local onDamaged = {}

    for abilityCode, callback in pairs(onAttack) do
        local level = GetUnitAbilityLevel(info.source, abilityCode)
        if level > 0 then
            callback(info.source, info.target, level)
        end
    end
end

-- TIMER: periodic tick. Set delta in seconds.
local function onTimer()
    local dropQueue = {}
    StorageTmpBuffs:each(function(unit)
        local expiresAt = StorageTmpBuffs:get(unit, "expiresAt")
        if expiresAt and expiresAt <= GetElapsedGameTime() then
            table.insert(dropQueue, unit)
        end
    end)
    for _, unit in ipairs(dropQueue) do
        clearApplyLimbBuffCommon(unit)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.applyLimb,
            action = onApplyLimb,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "unimmolation",
            action = onIssuedOrder,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.mawswornReduceHpDebuff,
            action = onMawswornStealHp,
        },
        {
            trigger = "DAMAGE",
            filter = {
                source = CONFIG.refs.units.carrier,
                target = CONFIG.refs.units.protected,
            },
            action = onDamage,
        },
        {
            trigger = "CREATE",
            filter = {
                target = CONFIG.refs.units.construct,
            },
            action = onConstructCreate,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.tickSeconds,
            action = onTimer,
        },
    },
    config = CONFIG,
}
