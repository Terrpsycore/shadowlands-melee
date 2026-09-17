--[[
TODO:
-- creep stitch abilities (minor crit + minor evasion)
-- clean storages onDeath + etc.

-- manual test
-- illusion storage persistance (reinit ephemeral runtime objects on save/load)
-- ! UI error on "no corpse"
-- move initDefault into STORAGE instead of implementation file
-- ? rewrite to aura with duration & remove limb buff when aura fades
-- hide "effect" ability on add with BlzUnitHideAbility

-- + refactor
]]

-- === Requires ===
local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local UnitMeta = require("lib.units")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.stitched")
local StorageTmpBuffs = require("scenario.storage.stitchedTmpBuffs")
local StorageTurnableStatus = require("scenario.storage.constructTurnableStatus")
local StorageIllusions = require("scenario.storage.stitchedIllusions")

-- === Refs & CONFIG ===
local factionSlugs = { "kyrian", "necrolord", "fae", "venthyr", "mawsworn", "common" }

local function getFactionIndex(faction)
    for i, slug in ipairs(factionSlugs) do
        if slug == faction then
            return i
        end
    end
end

local indexes = {
    kyrian = getFactionIndex("kyrian"),
    necrolord = getFactionIndex("necrolord"),
    common = getFactionIndex("common"),
}

local abilityRefs = {
    applyLimb = Ids.abilities.applyLimb,
    stitchingAdvancedVersatile = Ids.abilities.stitchingAdvancedVersatile,
    kyrianLifeRegen = Ids.abilities.stitchingKyrianLifeRegen,
    necrolordHaste = Ids.abilities.stitchingNecrolordHaste,
    necrolordHeal = Ids.abilities.stitchingNecrolordVictoryRush,
    faeCreateIllusion = Ids.abilities.stitchingFaeCreateIllusion,
    venthyrLeech = Ids.abilities.stitchingVenthyrLeech,
    venthyrLeechFixed = Ids.abilities.stitchingVenthyrLeechFixed,
    mawswornReduceHp = Ids.abilities.stitchingMawswornReduceHp,
    mawswornReduceHpDebuff = Ids.abilities.stitchingMawswornReduceHpDebuff,
    mawswornIncreaseHp = Ids.abilities.stitchingMawswornIncreaseHp,
    mawswornIncreaseHpBuff = Ids.abilities.stitchingMawswornIncreaseHpBuff,
    commonEvasion = Ids.abilities.stitchingCommonEvasion,
}

local buffRefs = {
    stitchingMawswornReduceHpDebuff = Ids.buffs.stitchingMawswornReduceHpDebuff,
    stitchingMawswornIncreaseHpBuff = Ids.buffs.stitchingMawswornIncreaseHpBuff,
}
local stitchRefs = {}
local turnableRefs = {} -- faction: id
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
    turnableRefs[stitchRefs[factionSlug].advanced] = factionSlug
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

local sameDamageTypeMemory = {} -- todo: save/load persistence

local illusionMap = {}
local illusionQueue = {}

-- === Helpers ===
local function isConstruct(unit)
    return GetUnitTypeId(unit) == CONFIG.refs.units.construct
end

-- === Common limb buff ===
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

-- === Construct state ===
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

-- === Apply limb ===
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

local function onConstructCreate()
    local unit = GetEnteringUnit()
    Storage:set(unit, "total", 0)
    Storage:set(unit, "max", 0)
    Storage:set(unit, "kyrian", 0)
    Storage:set(unit, "necrolord", 0)
    Storage:set(unit, "fae", 0)
    Storage:set(unit, "venthyr", 0)
    Storage:set(unit, "mawsworn", 0)
    Storage:set(unit, "common", 0)
end

-- ISSUED_ORDER: specific immediate order (e.g. unimmolation for toggle-off).
-- API: GetTriggerUnit(), GetIssuedOrderId()
local function onIssuedOrder() end

-- === Faction base effects ===

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
    if illusionMap[source] and illusionMap[source].count then
        Dummy.applyDummyOrder(owner, source, CONFIG.refs.abilities.faeCreateIllusion, "channel", level) -- todo: check order string
        table.insert(illusionQueue, { source = source, target = target })
    end
end

local function baseEffectMawsworn(source, target, level)
    -- TODO: chain buff&debuff - if 1 dispelled 2 dispells too (partially at least)
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

local function onCreate()
    local illusion = GetEnteringUnit()
    if not IsUnitIllusion(illusion) then
        return
    end
    local source
    local target
    local currentDistance
    local sourceIndex
    for i, data in ipairs(illusionQueue) do
        local newD = Unit.distance(illusion, data.source)
        if not currentDistance or newD < currentDistance then
            source = data.source
            target = data.target
            currentDistance = newD
            sourceIndex = i
        end
    end
    if source then
        table.remove(illusionQueue, sourceIndex)
    end
    StorageIllusions:set(illusion, "original", source)
    illusionMap[source] = illusionMap[source] or {}
    illusionMap[source].count = illusionMap[source].count + 1

    if StorageTurnableStatus:get(source, "active") then
        IssueTargetOrder(target, "attack", illusion)
    end
    --
end

local function updateAdvancedActiveAbilities(unit)
    if not StorageTurnableStatus:get(unit, "active") then
        return
    end
    local faction = StorageTurnableStatus:get(unit, "faction")
    if not indexes[faction] then
        return
    end

    local hpPercent = GetUnitStatePercent(unit, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE)
    local level = math.min(5, math.ceil((101 - hpPercent) / 20))
    local ability
    if faction == indexes.kyrian then
        ability = CONFIG.refs.abilities.kyrianLifeRegen
    elseif faction == indexes.necrolord then
        ability = CONFIG.refs.abilities.necrolordHaste
    elseif faction == indexes.common then
        ability = CONFIG.refs.abilities.commonEvasion
    end

    if ability then
        if GetUnitAbilityLevel(unit, ability) == 0 then
            UnitAddAbility(unit, ability)
        end
    end
end

local function onTurnOn()
    local unit = GetTriggerUnit()
    local spell = GetSpellAbilityId()
    local faction = turnableRefs[spell]
    if not faction then
        error("Invalid faction config")
    end
    StorageTurnableStatus:set(unit, "active", true)
    StorageTurnableStatus:set(unit, "faction", getFactionIndex(faction))

    updateAdvancedActiveAbilities(unit)
end

local function onDeath()
    local unit = GetDyingUnit()
    if not StorageIllusions:has(unit) then
        return
    end
    local source = StorageIllusions:get(unit, "original")
    illusionMap[source].count = illusionMap[source].count - 1
    StorageIllusions:drop(unit)
end

--- @param info damageInfo
local function onDamage(info)
    if info.isSpell then
        return
    end

    local source = info.source
    local target = info.target

    if
        not isConstruct(source)
        and not isConstruct(target)
        and not StorageTurnableStatus:has(source)
        and not StorageTurnableStatus:has(target)
    then
        return
    end

    local onAttack = {
        [stitchRefs.kyrian.effect] = baseEffectKyrian,
        [stitchRefs.fae.effect] = baseEffectFae,
        [stitchRefs.mawsworn.effect] = baseEffectMawsworn,
    }

    if
        StorageTurnableStatus:get(target, "active")
        and GetUnitAbilityLevel(target, CONFIG.refs.abilities.stitchingAdvancedVersatile) > 0
    then
        local lastAttackType = sameDamageTypeMemory[target]
        if lastAttackType == info.weaponType then
            info.damage = info.damage / 2
            sameDamageTypeMemory[target] = info.weaponType
        end
    end

    for abilityCode, callback in pairs(onAttack) do
        local level = GetUnitAbilityLevel(source, abilityCode)
        if level > 0 then
            callback(source, target, level)
        end
    end

    if GetUnitAbilityLevel(source, CONFIG.refs.abilities.venthyrLeech) > 0 then
        Dummy.applyDummyOrder(GetOwningPlayer(source), source, CONFIG.refs.abilities.venthyrLeechFixed, "heal")
    end
end

local function onLethalDamage(info)
    local status = StorageTurnableStatus:bind(info.source)
    if status then
        if not status.active then
            return
        end
        if status.faction == getFactionIndex("necrolord") then
            Dummy.applyDummyOrder(
                GetOwningPlayer(info.source),
                info.source,
                CONFIG.refs.abilities.necrolordHeal,
                "heal"
            )
        end
    end
end

local function onOneTimeCast()
    local dummyCaster = GetTriggerUnit()
    RemoveUnit(dummyCaster)
end

-- === Timer & export ===
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

local function onTurnableTimer()
    StorageTurnableStatus:each(function(unit)
        updateAdvancedActiveAbilities(unit)
    end)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.applyLimb,
            action = onApplyLimb,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = {
                stitchRefs.kyrian.advanced,
                stitchRefs.necrolord.advanced,
                stitchRefs.fae.advanced,
                stitchRefs.venthyr.advanced,
                stitchRefs.mawsworn.advanced,
                stitchRefs.common.advanced,
            },
            action = onTurnOn,
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
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = { CONFIG.refs.abilities.necrolordHeal, CONFIG.refs.abilities.venthyrLeechFixed },
            action = onOneTimeCast,
        },
        {
            trigger = "DAMAGE",
            action = onDamage,
        },
        {
            trigger = "LETHAL_DAMAGE",
            filter = {
                source = CONFIG.refs.units.carrier,
                target = CONFIG.refs.units.protected,
            },
            action = onLethalDamage,
        },
        {
            trigger = "CREATE",
            filter = {
                target = CONFIG.refs.units.construct,
            },
            action = onConstructCreate,
        },
        {
            trigger = "CREATE",
            action = onCreate,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            action = onDeath,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.tickSeconds,
            action = onTimer,
        },
        {
            trigger = "TIMER",
            delta = 1,
            action = onTurnableTimer,
        },
    },
    config = CONFIG,
}
