local AbilityIds = require("lib.community.types.assets.AbilityIds")

---@class AbilityRow<T: AbilityDefinition>
---@field parent string
---@field name? string
---@field levels? integer
---@field buffs? string[]
---@field autocastRange? number
---@field options? integer
---@field buttonNormalX? integer
---@field buttonNormalY? integer
---@field apply? fun(a: T)

local function pack(parent, data)
    data = data or {}
    data.parent = parent
    return data
end

local function identity(fn)
    return fn
end

local callMt = {
    __call = function(self, data)
        return pack(self.parent, data)
    end,
}

local A = {}

---@class AbilityFactoryNeutralSpell
---@overload fun(data: AbilityRow<AbilityDefinitionNeutralSpell>?): AbilityRow<AbilityDefinitionNeutralSpell>
---@field apply fun(fn: fun(a: AbilityDefinitionNeutralSpell)): fun(a: AbilityDefinitionNeutralSpell)

---@type AbilityFactoryNeutralSpell
A.neutralSpell = setmetatable({
    parent = AbilityIds.neutralSpell,
    apply = identity,
}, callMt)

---@class AbilityFactoryAuraCommandCreep
---@overload fun(data: AbilityRow<AbilityDefinitionAuraCommandCreep>?): AbilityRow<AbilityDefinitionAuraCommandCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraCommandCreep)): fun(a: AbilityDefinitionAuraCommandCreep)

---@type AbilityFactoryAuraCommandCreep
A.auraCommandCreep = setmetatable({
    parent = AbilityIds.auraCommandCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryAnimateDead
---@overload fun(data: AbilityRow<AbilityDefinitionAnimateDeadcreep>?): AbilityRow<AbilityDefinitionAnimateDeadcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionAnimateDeadcreep)): fun(a: AbilityDefinitionAnimateDeadcreep)

---@type AbilityFactoryAnimateDead
A.animateDead = setmetatable({
    parent = AbilityIds.animateDead,
    apply = identity,
}, callMt)

---@class AbilityFactoryAntimagicShell
---@overload fun(data: AbilityRow<AbilityDefinitionAntimagicShieldcreep>?): AbilityRow<AbilityDefinitionAntimagicShieldcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionAntimagicShieldcreep)): fun(a: AbilityDefinitionAntimagicShieldcreep)

---@type AbilityFactoryAntimagicShell
A.antimagicShell = setmetatable({
    parent = AbilityIds.antimagicShell,
    apply = identity,
}, callMt)

---@class AbilityFactoryTrueshotAura
---@overload fun(data: AbilityRow<AbilityDefinitionAuraTrueshotCreep>?): AbilityRow<AbilityDefinitionAuraTrueshotCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraTrueshotCreep)): fun(a: AbilityDefinitionAuraTrueshotCreep)

---@type AbilityFactoryTrueshotAura
A.trueshotAura = setmetatable({
    parent = AbilityIds.trueshotAura,
    apply = identity,
}, callMt)

---@class AbilityFactoryDevotionAura1
---@overload fun(data: AbilityRow<AbilityDefinitionAuraDevotionCreep>?): AbilityRow<AbilityDefinitionAuraDevotionCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraDevotionCreep)): fun(a: AbilityDefinitionAuraDevotionCreep)

---@type AbilityFactoryDevotionAura1
A.devotionAura1 = setmetatable({
    parent = AbilityIds.devotionAura1,
    apply = identity,
}, callMt)

---@class AbilityFactoryBrillianceAura1
---@overload fun(data: AbilityRow<AbilityDefinitionAuraBrilliancecreep>?): AbilityRow<AbilityDefinitionAuraBrilliancecreep>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraBrilliancecreep)): fun(a: AbilityDefinitionAuraBrilliancecreep)

---@type AbilityFactoryBrillianceAura1
A.brillianceAura1 = setmetatable({
    parent = AbilityIds.brillianceAura1,
    apply = identity,
}, callMt)

---@class AbilityFactoryBreathofFireCreep
---@overload fun(data: AbilityRow<AbilityDefinitionBreathofFireCreep>?): AbilityRow<AbilityDefinitionBreathofFireCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionBreathofFireCreep)): fun(a: AbilityDefinitionBreathofFireCreep)

---@type AbilityFactoryBreathofFireCreep
A.breathofFireCreep = setmetatable({
    parent = AbilityIds.breathofFireCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryBreathofFrostCreep
---@overload fun(data: AbilityRow<AbilityDefinitionBreathofFrostCreep>?): AbilityRow<AbilityDefinitionBreathofFrostCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionBreathofFrostCreep)): fun(a: AbilityDefinitionBreathofFrostCreep)

---@type AbilityFactoryBreathofFrostCreep
A.breathofFrostCreep = setmetatable({
    parent = AbilityIds.breathofFrostCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryBash1
---@overload fun(data: AbilityRow<AbilityDefinitionBashcreep>?): AbilityRow<AbilityDefinitionBashcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionBashcreep)): fun(a: AbilityDefinitionBashcreep)

---@type AbilityFactoryBash1
A.bash1 = setmetatable({
    parent = AbilityIds.bash1,
    apply = identity,
}, callMt)

---@class AbilityFactoryBloodlust
---@overload fun(data: AbilityRow<AbilityDefinitionBloodlustCreep>?): AbilityRow<AbilityDefinitionBloodlustCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionBloodlustCreep)): fun(a: AbilityDefinitionBloodlustCreep)

---@type AbilityFactoryBloodlust
A.bloodlust = setmetatable({
    parent = AbilityIds.bloodlust,
    apply = identity,
}, callMt)

---@class AbilityFactoryBlizzard1
---@overload fun(data: AbilityRow<AbilityDefinitionBlizzardcreep>?): AbilityRow<AbilityDefinitionBlizzardcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionBlizzardcreep)): fun(a: AbilityDefinitionBlizzardcreep)

---@type AbilityFactoryBlizzard1
A.blizzard1 = setmetatable({
    parent = AbilityIds.blizzard1,
    apply = identity,
}, callMt)

---@class AbilityFactoryCarrionSwarm
---@overload fun(data: AbilityRow<AbilityDefinitionCarrionSwarmcreep>?): AbilityRow<AbilityDefinitionCarrionSwarmcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionCarrionSwarmcreep)): fun(a: AbilityDefinitionCarrionSwarmcreep)

---@type AbilityFactoryCarrionSwarm
A.carrionSwarm = setmetatable({
    parent = AbilityIds.carrionSwarm,
    apply = identity,
}, callMt)

---@class AbilityFactoryFrostBolt
---@overload fun(data: AbilityRow<AbilityDefinitionFrostBolt>?): AbilityRow<AbilityDefinitionFrostBolt>
---@field apply fun(fn: fun(a: AbilityDefinitionFrostBolt)): fun(a: AbilityDefinitionFrostBolt)

---@type AbilityFactoryFrostBolt
A.frostBolt = setmetatable({
    parent = AbilityIds.frostBolt,
    apply = identity,
}, callMt)

---@class AbilityFactoryCharm
---@overload fun(data: AbilityRow<AbilityDefinitionCharm>?): AbilityRow<AbilityDefinitionCharm>
---@field apply fun(fn: fun(a: AbilityDefinitionCharm)): fun(a: AbilityDefinitionCharm)

---@type AbilityFactoryCharm
A.charm = setmetatable({
    parent = AbilityIds.charm,
    apply = identity,
}, callMt)

---@class AbilityFactoryChainLightning
---@overload fun(data: AbilityRow<AbilityDefinitionChainLightningcreep>?): AbilityRow<AbilityDefinitionChainLightningcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionChainLightningcreep)): fun(a: AbilityDefinitionChainLightningcreep)

---@type AbilityFactoryChainLightning
A.chainLightning = setmetatable({
    parent = AbilityIds.chainLightning,
    apply = identity,
}, callMt)

---@class AbilityFactoryCannibalizecreep
---@overload fun(data: AbilityRow<AbilityDefinitionCannibalizecreep>?): AbilityRow<AbilityDefinitionCannibalizecreep>
---@field apply fun(fn: fun(a: AbilityDefinitionCannibalizecreep)): fun(a: AbilityDefinitionCannibalizecreep)

---@type AbilityFactoryCannibalizecreep
A.cannibalizecreep = setmetatable({
    parent = AbilityIds.cannibalizecreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryCripplecreep
---@overload fun(data: AbilityRow<AbilityDefinitionCripplecreep>?): AbilityRow<AbilityDefinitionCripplecreep>
---@field apply fun(fn: fun(a: AbilityDefinitionCripplecreep)): fun(a: AbilityDefinitionCripplecreep)

---@type AbilityFactoryCripplecreep
A.cripplecreep = setmetatable({
    parent = AbilityIds.cripplecreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryCursecreep
---@overload fun(data: AbilityRow<AbilityDefinitionCursecreep>?): AbilityRow<AbilityDefinitionCursecreep>
---@field apply fun(fn: fun(a: AbilityDefinitionCursecreep)): fun(a: AbilityDefinitionCursecreep)

---@type AbilityFactoryCursecreep
A.cursecreep = setmetatable({
    parent = AbilityIds.cursecreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryCriticalStrike
---@overload fun(data: AbilityRow<AbilityDefinitionCriticalStrikecreep>?): AbilityRow<AbilityDefinitionCriticalStrikecreep>
---@field apply fun(fn: fun(a: AbilityDefinitionCriticalStrikecreep)): fun(a: AbilityDefinitionCriticalStrikecreep)

---@type AbilityFactoryCriticalStrike
A.criticalStrike = setmetatable({
    parent = AbilityIds.criticalStrike,
    apply = identity,
}, callMt)

---@class AbilityFactoryCrushingWave
---@overload fun(data: AbilityRow<AbilityDefinitionCrushingWave>?): AbilityRow<AbilityDefinitionCrushingWave>
---@field apply fun(fn: fun(a: AbilityDefinitionCrushingWave)): fun(a: AbilityDefinitionCrushingWave)

---@type AbilityFactoryCrushingWave
A.crushingWave = setmetatable({
    parent = AbilityIds.crushingWave,
    apply = identity,
}, callMt)

---@class AbilityFactoryColdArrows1
---@overload fun(data: AbilityRow<AbilityDefinitionColdArrowscreep>?): AbilityRow<AbilityDefinitionColdArrowscreep>
---@field apply fun(fn: fun(a: AbilityDefinitionColdArrowscreep)): fun(a: AbilityDefinitionColdArrowscreep)

---@type AbilityFactoryColdArrows1
A.coldArrows1 = setmetatable({
    parent = AbilityIds.coldArrows1,
    apply = identity,
}, callMt)

---@class AbilityFactoryCyclonecreep
---@overload fun(data: AbilityRow<AbilityDefinitionCyclonecreep>?): AbilityRow<AbilityDefinitionCyclonecreep>
---@field apply fun(fn: fun(a: AbilityDefinitionCyclonecreep)): fun(a: AbilityDefinitionCyclonecreep)

---@type AbilityFactoryCyclonecreep
A.cyclonecreep = setmetatable({
    parent = AbilityIds.cyclonecreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryDeathCoil
---@overload fun(data: AbilityRow<AbilityDefinitionDeathCoilcreep>?): AbilityRow<AbilityDefinitionDeathCoilcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionDeathCoilcreep)): fun(a: AbilityDefinitionDeathCoilcreep)

---@type AbilityFactoryDeathCoil
A.deathCoil = setmetatable({
    parent = AbilityIds.deathCoil,
    apply = identity,
}, callMt)

---@class AbilityFactoryDevourMagiccreep
---@overload fun(data: AbilityRow<AbilityDefinitionDevourMagiccreep>?): AbilityRow<AbilityDefinitionDevourMagiccreep>
---@field apply fun(fn: fun(a: AbilityDefinitionDevourMagiccreep)): fun(a: AbilityDefinitionDevourMagiccreep)

---@type AbilityFactoryDevourMagiccreep
A.devourMagiccreep = setmetatable({
    parent = AbilityIds.devourMagiccreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryAbolishMagicCreep
---@overload fun(data: AbilityRow<AbilityDefinitionAbolishMagicCreep>?): AbilityRow<AbilityDefinitionAbolishMagicCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionAbolishMagicCreep)): fun(a: AbilityDefinitionAbolishMagicCreep)

---@type AbilityFactoryAbolishMagicCreep
A.abolishMagicCreep = setmetatable({
    parent = AbilityIds.abolishMagicCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryDrainLifeCreep
---@overload fun(data: AbilityRow<AbilityDefinitionDrainLifeCreep>?): AbilityRow<AbilityDefinitionDrainLifeCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionDrainLifeCreep)): fun(a: AbilityDefinitionDrainLifeCreep)

---@type AbilityFactoryDrainLifeCreep
A.drainLifeCreep = setmetatable({
    parent = AbilityIds.drainLifeCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryDevour
---@overload fun(data: AbilityRow<AbilityDefinitionDevourCreep>?): AbilityRow<AbilityDefinitionDevourCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionDevourCreep)): fun(a: AbilityDefinitionDevourCreep)

---@type AbilityFactoryDevour
A.devour = setmetatable({
    parent = AbilityIds.devour,
    apply = identity,
}, callMt)

---@class AbilityFactoryEnsnare
---@overload fun(data: AbilityRow<AbilityDefinitionEnsnareCreep>?): AbilityRow<AbilityDefinitionEnsnareCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionEnsnareCreep)): fun(a: AbilityDefinitionEnsnareCreep)

---@type AbilityFactoryEnsnare
A.ensnare = setmetatable({
    parent = AbilityIds.ensnare,
    apply = identity,
}, callMt)

---@class AbilityFactoryEvasion1
---@overload fun(data: AbilityRow<AbilityDefinitionEvasioncreep100>?): AbilityRow<AbilityDefinitionEvasioncreep100>
---@field apply fun(fn: fun(a: AbilityDefinitionEvasioncreep100)): fun(a: AbilityDefinitionEvasioncreep100)

---@type AbilityFactoryEvasion1
A.evasion1 = setmetatable({
    parent = AbilityIds.evasion1,
    apply = identity,
}, callMt)

---@class AbilityFactoryEvasion
---@overload fun(data: AbilityRow<AbilityDefinitionEvasion>?): AbilityRow<AbilityDefinitionEvasion>
---@field apply fun(fn: fun(a: AbilityDefinitionEvasion)): fun(a: AbilityDefinitionEvasion)

---@type AbilityFactoryEvasion
A.evasion = setmetatable({
    parent = AbilityIds.evasion,
    apply = identity,
}, callMt)

---@class AbilityFactoryFrostArmor
---@overload fun(data: AbilityRow<AbilityDefinitionFrostArmorcreep>?): AbilityRow<AbilityDefinitionFrostArmorcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionFrostArmorcreep)): fun(a: AbilityDefinitionFrostArmorcreep)

---@type AbilityFactoryFrostArmor
A.frostArmor = setmetatable({
    parent = AbilityIds.frostArmor,
    apply = identity,
}, callMt)

---@class AbilityFactoryFirebolt1
---@overload fun(data: AbilityRow<AbilityDefinitionFireBoltcreep>?): AbilityRow<AbilityDefinitionFireBoltcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionFireBoltcreep)): fun(a: AbilityDefinitionFireBoltcreep)

---@type AbilityFactoryFirebolt1
A.firebolt1 = setmetatable({
    parent = AbilityIds.firebolt1,
    apply = identity,
}, callMt)

---@class AbilityFactoryFaerieFirecreep
---@overload fun(data: AbilityRow<AbilityDefinitionFaerieFirecreep>?): AbilityRow<AbilityDefinitionFaerieFirecreep>
---@field apply fun(fn: fun(a: AbilityDefinitionFaerieFirecreep)): fun(a: AbilityDefinitionFaerieFirecreep)

---@type AbilityFactoryFaerieFirecreep
A.faerieFirecreep = setmetatable({
    parent = AbilityIds.faerieFirecreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryFrostNova
---@overload fun(data: AbilityRow<AbilityDefinitionFrostNovacreep>?): AbilityRow<AbilityDefinitionFrostNovacreep>
---@field apply fun(fn: fun(a: AbilityDefinitionFrostNovacreep)): fun(a: AbilityDefinitionFrostNovacreep)

---@type AbilityFactoryFrostNova
A.frostNova = setmetatable({
    parent = AbilityIds.frostNova,
    apply = identity,
}, callMt)

---@class AbilityFactoryForceofNature
---@overload fun(data: AbilityRow<AbilityDefinitionForceofNaturecreep>?): AbilityRow<AbilityDefinitionForceofNaturecreep>
---@field apply fun(fn: fun(a: AbilityDefinitionForceofNaturecreep)): fun(a: AbilityDefinitionForceofNaturecreep)

---@type AbilityFactoryForceofNature
A.forceofNature = setmetatable({
    parent = AbilityIds.forceofNature,
    apply = identity,
}, callMt)

---@class AbilityFactoryFlameStrikeCreep
---@overload fun(data: AbilityRow<AbilityDefinitionFlameStrikeCreep>?): AbilityRow<AbilityDefinitionFlameStrikeCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionFlameStrikeCreep)): fun(a: AbilityDefinitionFlameStrikeCreep)

---@type AbilityFactoryFlameStrikeCreep
A.flameStrikeCreep = setmetatable({
    parent = AbilityIds.flameStrikeCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryHealingWaveCreep
---@overload fun(data: AbilityRow<AbilityDefinitionHealingWaveCreep>?): AbilityRow<AbilityDefinitionHealingWaveCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionHealingWaveCreep)): fun(a: AbilityDefinitionHealingWaveCreep)

---@type AbilityFactoryHealingWaveCreep
A.healingWaveCreep = setmetatable({
    parent = AbilityIds.healingWaveCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryHealingWard
---@overload fun(data: AbilityRow<AbilityDefinitionHealingWardcreep>?): AbilityRow<AbilityDefinitionHealingWardcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionHealingWardcreep)): fun(a: AbilityDefinitionHealingWardcreep)

---@type AbilityFactoryHealingWard
A.healingWard = setmetatable({
    parent = AbilityIds.healingWard,
    apply = identity,
}, callMt)

---@class AbilityFactoryHexCreep
---@overload fun(data: AbilityRow<AbilityDefinitionHexCreep>?): AbilityRow<AbilityDefinitionHexCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionHexCreep)): fun(a: AbilityDefinitionHexCreep)

---@type AbilityFactoryHexCreep
A.hexCreep = setmetatable({
    parent = AbilityIds.hexCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryInnerFireCreep
---@overload fun(data: AbilityRow<AbilityDefinitionInnerFireCreep>?): AbilityRow<AbilityDefinitionInnerFireCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionInnerFireCreep)): fun(a: AbilityDefinitionInnerFireCreep)

---@type AbilityFactoryInnerFireCreep
A.innerFireCreep = setmetatable({
    parent = AbilityIds.innerFireCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryImmolation
---@overload fun(data: AbilityRow<AbilityDefinitionImmolationcreep>?): AbilityRow<AbilityDefinitionImmolationcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionImmolationcreep)): fun(a: AbilityDefinitionImmolationcreep)

---@type AbilityFactoryImmolation
A.immolation = setmetatable({
    parent = AbilityIds.immolation,
    apply = identity,
}, callMt)

---@class AbilityFactoryLightningShieldcreep
---@overload fun(data: AbilityRow<AbilityDefinitionLightningShieldcreep>?): AbilityRow<AbilityDefinitionLightningShieldcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionLightningShieldcreep)): fun(a: AbilityDefinitionLightningShieldcreep)

---@type AbilityFactoryLightningShieldcreep
A.lightningShieldcreep = setmetatable({
    parent = AbilityIds.lightningShieldcreep,
    apply = identity,
}, callMt)

---@class AbilityFactorySpellImmunity
---@overload fun(data: AbilityRow<AbilityDefinitionMagicImmunityArchimonde>?): AbilityRow<AbilityDefinitionMagicImmunityArchimonde>
---@field apply fun(fn: fun(a: AbilityDefinitionMagicImmunityArchimonde)): fun(a: AbilityDefinitionMagicImmunityArchimonde)

---@type AbilityFactorySpellImmunity
A.spellImmunity = setmetatable({
    parent = AbilityIds.spellImmunity,
    apply = identity,
}, callMt)

---@class AbilityFactorySpellImmunity1
---@overload fun(data: AbilityRow<AbilityDefinitionMagicImmunityDragons>?): AbilityRow<AbilityDefinitionMagicImmunityDragons>
---@field apply fun(fn: fun(a: AbilityDefinitionMagicImmunityDragons)): fun(a: AbilityDefinitionMagicImmunityDragons)

---@type AbilityFactorySpellImmunity1
A.spellImmunity1 = setmetatable({
    parent = AbilityIds.spellImmunity1,
    apply = identity,
}, callMt)

---@class AbilityFactoryManaShieldCreep
---@overload fun(data: AbilityRow<AbilityDefinitionManaShieldCreep>?): AbilityRow<AbilityDefinitionManaShieldCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionManaShieldCreep)): fun(a: AbilityDefinitionManaShieldCreep)

---@type AbilityFactoryManaShieldCreep
A.manaShieldCreep = setmetatable({
    parent = AbilityIds.manaShieldCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryMagicImmunityCreep
---@overload fun(data: AbilityRow<AbilityDefinitionMagicImmunityCreep>?): AbilityRow<AbilityDefinitionMagicImmunityCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionMagicImmunityCreep)): fun(a: AbilityDefinitionMagicImmunityCreep)

---@type AbilityFactoryMagicImmunityCreep
A.magicImmunityCreep = setmetatable({
    parent = AbilityIds.magicImmunityCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryMonsooncreep
---@overload fun(data: AbilityRow<AbilityDefinitionMonsooncreep>?): AbilityRow<AbilityDefinitionMonsooncreep>
---@field apply fun(fn: fun(a: AbilityDefinitionMonsooncreep)): fun(a: AbilityDefinitionMonsooncreep)

---@type AbilityFactoryMonsooncreep
A.monsooncreep = setmetatable({
    parent = AbilityIds.monsooncreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryImpaleCreep
---@overload fun(data: AbilityRow<AbilityDefinitionImpaleCreep>?): AbilityRow<AbilityDefinitionImpaleCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionImpaleCreep)): fun(a: AbilityDefinitionImpaleCreep)

---@type AbilityFactoryImpaleCreep
A.impaleCreep = setmetatable({
    parent = AbilityIds.impaleCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryLifeRegenerationAura
---@overload fun(data: AbilityRow<AbilityDefinitionNeutralRegenhealthonly>?): AbilityRow<AbilityDefinitionNeutralRegenhealthonly>
---@field apply fun(fn: fun(a: AbilityDefinitionNeutralRegenhealthonly)): fun(a: AbilityDefinitionNeutralRegenhealthonly)

---@type AbilityFactoryLifeRegenerationAura
A.lifeRegenerationAura = setmetatable({
    parent = AbilityIds.lifeRegenerationAura,
    apply = identity,
}, callMt)

---@class AbilityFactoryPossessioncreep
---@overload fun(data: AbilityRow<AbilityDefinitionPossessioncreep>?): AbilityRow<AbilityDefinitionPossessioncreep>
---@field apply fun(fn: fun(a: AbilityDefinitionPossessioncreep)): fun(a: AbilityDefinitionPossessioncreep)

---@type AbilityFactoryPossessioncreep
A.possessioncreep = setmetatable({
    parent = AbilityIds.possessioncreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryPurgeCreep
---@overload fun(data: AbilityRow<AbilityDefinitionPurgeCreep>?): AbilityRow<AbilityDefinitionPurgeCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionPurgeCreep)): fun(a: AbilityDefinitionPurgeCreep)

---@type AbilityFactoryPurgeCreep
A.purgeCreep = setmetatable({
    parent = AbilityIds.purgeCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryPulverize1
---@overload fun(data: AbilityRow<AbilityDefinitionPulverizecreep>?): AbilityRow<AbilityDefinitionPulverizecreep>
---@field apply fun(fn: fun(a: AbilityDefinitionPulverizecreep)): fun(a: AbilityDefinitionPulverizecreep)

---@type AbilityFactoryPulverize1
A.pulverize1 = setmetatable({
    parent = AbilityIds.pulverize1,
    apply = identity,
}, callMt)

---@class AbilityFactoryPolymorphcreep
---@overload fun(data: AbilityRow<AbilityDefinitionPolymorphcreep>?): AbilityRow<AbilityDefinitionPolymorphcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionPolymorphcreep)): fun(a: AbilityDefinitionPolymorphcreep)

---@type AbilityFactoryPolymorphcreep
A.polymorphcreep = setmetatable({
    parent = AbilityIds.polymorphcreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryRoarcreepSkeletalOrc
---@overload fun(data: AbilityRow<AbilityDefinitionRoarcreepSkeletalOrc>?): AbilityRow<AbilityDefinitionRoarcreepSkeletalOrc>
---@field apply fun(fn: fun(a: AbilityDefinitionRoarcreepSkeletalOrc)): fun(a: AbilityDefinitionRoarcreepSkeletalOrc)

---@type AbilityFactoryRoarcreepSkeletalOrc
A.roarcreepSkeletalOrc = setmetatable({
    parent = AbilityIds.roarcreepSkeletalOrc,
    apply = identity,
}, callMt)

---@class AbilityFactoryRejuvenation
---@overload fun(data: AbilityRow<AbilityDefinitionRejuvinationFurbolg>?): AbilityRow<AbilityDefinitionRejuvinationFurbolg>
---@field apply fun(fn: fun(a: AbilityDefinitionRejuvinationFurbolg)): fun(a: AbilityDefinitionRejuvinationFurbolg)

---@type AbilityFactoryRejuvenation
A.rejuvenation = setmetatable({
    parent = AbilityIds.rejuvenation,
    apply = identity,
}, callMt)

---@class AbilityFactoryRaiseDeadCreep
---@overload fun(data: AbilityRow<AbilityDefinitionRaiseDeadCreep>?): AbilityRow<AbilityDefinitionRaiseDeadCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionRaiseDeadCreep)): fun(a: AbilityDefinitionRaiseDeadCreep)

---@type AbilityFactoryRaiseDeadCreep
A.raiseDeadCreep = setmetatable({
    parent = AbilityIds.raiseDeadCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryRainofFire1
---@overload fun(data: AbilityRow<AbilityDefinitionRainofFirecreep>?): AbilityRow<AbilityDefinitionRainofFirecreep>
---@field apply fun(fn: fun(a: AbilityDefinitionRainofFirecreep)): fun(a: AbilityDefinitionRainofFirecreep)

---@type AbilityFactoryRainofFire1
A.rainofFire1 = setmetatable({
    parent = AbilityIds.rainofFire1,
    apply = identity,
}, callMt)

---@class AbilityFactoryRejuvinationcreep
---@overload fun(data: AbilityRow<AbilityDefinitionRejuvinationcreep>?): AbilityRow<AbilityDefinitionRejuvinationcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionRejuvinationcreep)): fun(a: AbilityDefinitionRejuvinationcreep)

---@type AbilityFactoryRejuvinationcreep
A.rejuvinationcreep = setmetatable({
    parent = AbilityIds.rejuvinationcreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryReincarnation1
---@overload fun(data: AbilityRow<AbilityDefinitionReincarnationcreep>?): AbilityRow<AbilityDefinitionReincarnationcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionReincarnationcreep)): fun(a: AbilityDefinitionReincarnationcreep)

---@type AbilityFactoryReincarnation1
A.reincarnation1 = setmetatable({
    parent = AbilityIds.reincarnation1,
    apply = identity,
}, callMt)

---@class AbilityFactoryRoarcreep
---@overload fun(data: AbilityRow<AbilityDefinitionRoarcreep>?): AbilityRow<AbilityDefinitionRoarcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionRoarcreep)): fun(a: AbilityDefinitionRoarcreep)

---@type AbilityFactoryRoarcreep
A.roarcreep = setmetatable({
    parent = AbilityIds.roarcreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryFeralSpirit1
---@overload fun(data: AbilityRow<AbilityDefinitionSpiritPigcreep>?): AbilityRow<AbilityDefinitionSpiritPigcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionSpiritPigcreep)): fun(a: AbilityDefinitionSpiritPigcreep)

---@type AbilityFactoryFeralSpirit1
A.feralSpirit1 = setmetatable({
    parent = AbilityIds.feralSpirit1,
    apply = identity,
}, callMt)

---@class AbilityFactorySearingArrows
---@overload fun(data: AbilityRow<AbilityDefinitionSearingArrowscreep>?): AbilityRow<AbilityDefinitionSearingArrowscreep>
---@field apply fun(fn: fun(a: AbilityDefinitionSearingArrowscreep)): fun(a: AbilityDefinitionSearingArrowscreep)

---@type AbilityFactorySearingArrows
A.searingArrows = setmetatable({
    parent = AbilityIds.searingArrows,
    apply = identity,
}, callMt)

---@class AbilityFactoryFeralSpirit
---@overload fun(data: AbilityRow<AbilityDefinitionSpiritWolfcreep>?): AbilityRow<AbilityDefinitionSpiritWolfcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionSpiritWolfcreep)): fun(a: AbilityDefinitionSpiritWolfcreep)

---@type AbilityFactoryFeralSpirit
A.feralSpirit = setmetatable({
    parent = AbilityIds.feralSpirit,
    apply = identity,
}, callMt)

---@class AbilityFactoryShockwave
---@overload fun(data: AbilityRow<AbilityDefinitionShockwaveCreep>?): AbilityRow<AbilityDefinitionShockwaveCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionShockwaveCreep)): fun(a: AbilityDefinitionShockwaveCreep)

---@type AbilityFactoryShockwave
A.shockwave = setmetatable({
    parent = AbilityIds.shockwave,
    apply = identity,
}, callMt)

---@class AbilityFactorySilenceCreep
---@overload fun(data: AbilityRow<AbilityDefinitionSilenceCreep>?): AbilityRow<AbilityDefinitionSilenceCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionSilenceCreep)): fun(a: AbilityDefinitionSilenceCreep)

---@type AbilityFactorySilenceCreep
A.silenceCreep = setmetatable({
    parent = AbilityIds.silenceCreep,
    apply = identity,
}, callMt)

---@class AbilityFactorySleep1
---@overload fun(data: AbilityRow<AbilityDefinitionSleepcreep>?): AbilityRow<AbilityDefinitionSleepcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionSleepcreep)): fun(a: AbilityDefinitionSleepcreep)

---@type AbilityFactorySleep1
A.sleep1 = setmetatable({
    parent = AbilityIds.sleep1,
    apply = identity,
}, callMt)

---@class AbilityFactorySiphonManaCreep
---@overload fun(data: AbilityRow<AbilityDefinitionSiphonManaCreep>?): AbilityRow<AbilityDefinitionSiphonManaCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionSiphonManaCreep)): fun(a: AbilityDefinitionSiphonManaCreep)

---@type AbilityFactorySiphonManaCreep
A.siphonManaCreep = setmetatable({
    parent = AbilityIds.siphonManaCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryShadowStrikeCreep
---@overload fun(data: AbilityRow<AbilityDefinitionShadowStrikeCreep>?): AbilityRow<AbilityDefinitionShadowStrikeCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionShadowStrikeCreep)): fun(a: AbilityDefinitionShadowStrikeCreep)

---@type AbilityFactoryShadowStrikeCreep
A.shadowStrikeCreep = setmetatable({
    parent = AbilityIds.shadowStrikeCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryShockwave1
---@overload fun(data: AbilityRow<AbilityDefinitionShockwaveTrap>?): AbilityRow<AbilityDefinitionShockwaveTrap>
---@field apply fun(fn: fun(a: AbilityDefinitionShockwaveTrap)): fun(a: AbilityDefinitionShockwaveTrap)

---@type AbilityFactoryShockwave1
A.shockwave1 = setmetatable({
    parent = AbilityIds.shockwave1,
    apply = identity,
}, callMt)

---@class AbilityFactorySlow1
---@overload fun(data: AbilityRow<AbilityDefinitionSlowCreep>?): AbilityRow<AbilityDefinitionSlowCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionSlowCreep)): fun(a: AbilityDefinitionSlowCreep)

---@type AbilityFactorySlow1
A.slow1 = setmetatable({
    parent = AbilityIds.slow1,
    apply = identity,
}, callMt)

---@class AbilityFactorySlam1
---@overload fun(data: AbilityRow<AbilityDefinitionThunderClapThunderLizard>?): AbilityRow<AbilityDefinitionThunderClapThunderLizard>
---@field apply fun(fn: fun(a: AbilityDefinitionThunderClapThunderLizard)): fun(a: AbilityDefinitionThunderClapThunderLizard)

---@type AbilityFactorySlam1
A.slam1 = setmetatable({
    parent = AbilityIds.slam1,
    apply = identity,
}, callMt)

---@class AbilityFactoryHurlBoulder
---@overload fun(data: AbilityRow<AbilityDefinitionThunderBoltCreep>?): AbilityRow<AbilityDefinitionThunderBoltCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionThunderBoltCreep)): fun(a: AbilityDefinitionThunderBoltCreep)

---@type AbilityFactoryHurlBoulder
A.hurlBoulder = setmetatable({
    parent = AbilityIds.hurlBoulder,
    apply = identity,
}, callMt)

---@class AbilityFactorySlam
---@overload fun(data: AbilityRow<AbilityDefinitionThunderClapCreep>?): AbilityRow<AbilityDefinitionThunderClapCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionThunderClapCreep)): fun(a: AbilityDefinitionThunderClapCreep)

---@type AbilityFactorySlam
A.slam = setmetatable({
    parent = AbilityIds.slam,
    apply = identity,
}, callMt)

---@class AbilityFactorySerpentWardtentacleForgottenone
---@overload fun(data: AbilityRow<AbilityDefinitionSerpentWardtentacleForgottenone>?): AbilityRow<AbilityDefinitionSerpentWardtentacleForgottenone>
---@field apply fun(fn: fun(a: AbilityDefinitionSerpentWardtentacleForgottenone)): fun(a: AbilityDefinitionSerpentWardtentacleForgottenone)

---@type AbilityFactorySerpentWardtentacleForgottenone
A.serpentWardtentacleForgottenone = setmetatable({
    parent = AbilityIds.serpentWardtentacleForgottenone,
    apply = identity,
}, callMt)

---@class AbilityFactoryUnholyAura
---@overload fun(data: AbilityRow<AbilityDefinitionUnholyAuracreep>?): AbilityRow<AbilityDefinitionUnholyAuracreep>
---@field apply fun(fn: fun(a: AbilityDefinitionUnholyAuracreep)): fun(a: AbilityDefinitionUnholyAuracreep)

---@type AbilityFactoryUnholyAura
A.unholyAura = setmetatable({
    parent = AbilityIds.unholyAura,
    apply = identity,
}, callMt)

---@class AbilityFactoryUnholyFrenzycreep
---@overload fun(data: AbilityRow<AbilityDefinitionUnholyFrenzycreep>?): AbilityRow<AbilityDefinitionUnholyFrenzycreep>
---@field apply fun(fn: fun(a: AbilityDefinitionUnholyFrenzycreep)): fun(a: AbilityDefinitionUnholyFrenzycreep)

---@type AbilityFactoryUnholyFrenzycreep
A.unholyFrenzycreep = setmetatable({
    parent = AbilityIds.unholyFrenzycreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryVampiricAura
---@overload fun(data: AbilityRow<AbilityDefinitionVampiricAuracreep>?): AbilityRow<AbilityDefinitionVampiricAuracreep>
---@field apply fun(fn: fun(a: AbilityDefinitionVampiricAuracreep)): fun(a: AbilityDefinitionVampiricAuracreep)

---@type AbilityFactoryVampiricAura
A.vampiricAura = setmetatable({
    parent = AbilityIds.vampiricAura,
    apply = identity,
}, callMt)

---@class AbilityFactoryEnvenomedWeapons
---@overload fun(data: AbilityRow<AbilityDefinitionVenomSpearsCreep>?): AbilityRow<AbilityDefinitionVenomSpearsCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionVenomSpearsCreep)): fun(a: AbilityDefinitionVenomSpearsCreep)

---@type AbilityFactoryEnvenomedWeapons
A.envenomedWeapons = setmetatable({
    parent = AbilityIds.envenomedWeapons,
    apply = identity,
}, callMt)

---@class AbilityFactoryWebcreep
---@overload fun(data: AbilityRow<AbilityDefinitionWebcreep>?): AbilityRow<AbilityDefinitionWebcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionWebcreep)): fun(a: AbilityDefinitionWebcreep)

---@type AbilityFactoryWebcreep
A.webcreep = setmetatable({
    parent = AbilityIds.webcreep,
    apply = identity,
}, callMt)

---@class AbilityFactorySummonSeaElemental
---@overload fun(data: AbilityRow<AbilityDefinitionSummonSeaElemental>?): AbilityRow<AbilityDefinitionSummonSeaElemental>
---@field apply fun(fn: fun(a: AbilityDefinitionSummonSeaElemental)): fun(a: AbilityDefinitionSummonSeaElemental)

---@type AbilityFactorySummonSeaElemental
A.summonSeaElemental = setmetatable({
    parent = AbilityIds.summonSeaElemental,
    apply = identity,
}, callMt)

---@class AbilityFactoryMetamorphosis1
---@overload fun(data: AbilityRow<AbilityDefinitionIllidanMetamorphosis>?): AbilityRow<AbilityDefinitionIllidanMetamorphosis>
---@field apply fun(fn: fun(a: AbilityDefinitionIllidanMetamorphosis)): fun(a: AbilityDefinitionIllidanMetamorphosis)

---@type AbilityFactoryMetamorphosis1
A.metamorphosis1 = setmetatable({
    parent = AbilityIds.metamorphosis1,
    apply = identity,
}, callMt)

---@class AbilityFactoryThornsAura1
---@overload fun(data: AbilityRow<AbilityDefinitionKeeperoftheGroveThornsAura>?): AbilityRow<AbilityDefinitionKeeperoftheGroveThornsAura>
---@field apply fun(fn: fun(a: AbilityDefinitionKeeperoftheGroveThornsAura)): fun(a: AbilityDefinitionKeeperoftheGroveThornsAura)

---@type AbilityFactoryThornsAura1
A.thornsAura1 = setmetatable({
    parent = AbilityIds.thornsAura1,
    apply = identity,
}, callMt)

---@class AbilityFactoryTrueshotAura1
---@overload fun(data: AbilityRow<AbilityDefinitionMoonPriestessTrueshotAura>?): AbilityRow<AbilityDefinitionMoonPriestessTrueshotAura>
---@field apply fun(fn: fun(a: AbilityDefinitionMoonPriestessTrueshotAura)): fun(a: AbilityDefinitionMoonPriestessTrueshotAura)

---@type AbilityFactoryTrueshotAura1
A.trueshotAura1 = setmetatable({
    parent = AbilityIds.trueshotAura1,
    apply = identity,
}, callMt)

---@class AbilityFactoryWardenBlink
---@overload fun(data: AbilityRow<AbilityDefinitionWardenBlink>?): AbilityRow<AbilityDefinitionWardenBlink>
---@field apply fun(fn: fun(a: AbilityDefinitionWardenBlink)): fun(a: AbilityDefinitionWardenBlink)

---@type AbilityFactoryWardenBlink
A.wardenBlink = setmetatable({
    parent = AbilityIds.wardenBlink,
    apply = identity,
}, callMt)

---@class AbilityFactoryEntanglingRoots1
---@overload fun(data: AbilityRow<AbilityDefinitionKeeperoftheGroveEntanglingRoots>?): AbilityRow<AbilityDefinitionKeeperoftheGroveEntanglingRoots>
---@field apply fun(fn: fun(a: AbilityDefinitionKeeperoftheGroveEntanglingRoots)): fun(a: AbilityDefinitionKeeperoftheGroveEntanglingRoots)

---@type AbilityFactoryEntanglingRoots1
A.entanglingRoots1 = setmetatable({
    parent = AbilityIds.entanglingRoots1,
    apply = identity,
}, callMt)

---@class AbilityFactoryEvasion2
---@overload fun(data: AbilityRow<AbilityDefinitionDemonHunterEvasion>?): AbilityRow<AbilityDefinitionDemonHunterEvasion>
---@field apply fun(fn: fun(a: AbilityDefinitionDemonHunterEvasion)): fun(a: AbilityDefinitionDemonHunterEvasion)

---@type AbilityFactoryEvasion2
A.evasion2 = setmetatable({
    parent = AbilityIds.evasion2,
    apply = identity,
}, callMt)

---@class AbilityFactoryWardenFanofKnives
---@overload fun(data: AbilityRow<AbilityDefinitionWardenFanofKnives>?): AbilityRow<AbilityDefinitionWardenFanofKnives>
---@field apply fun(fn: fun(a: AbilityDefinitionWardenFanofKnives)): fun(a: AbilityDefinitionWardenFanofKnives)

---@type AbilityFactoryWardenFanofKnives
A.wardenFanofKnives = setmetatable({
    parent = AbilityIds.wardenFanofKnives,
    apply = identity,
}, callMt)

---@class AbilityFactoryForceofNature1
---@overload fun(data: AbilityRow<AbilityDefinitionKeeperoftheGroveForceofNature>?): AbilityRow<AbilityDefinitionKeeperoftheGroveForceofNature>
---@field apply fun(fn: fun(a: AbilityDefinitionKeeperoftheGroveForceofNature)): fun(a: AbilityDefinitionKeeperoftheGroveForceofNature)

---@type AbilityFactoryForceofNature1
A.forceofNature1 = setmetatable({
    parent = AbilityIds.forceofNature1,
    apply = identity,
}, callMt)

---@class AbilityFactoryImmolation1
---@overload fun(data: AbilityRow<AbilityDefinitionDemonHunterImmolation>?): AbilityRow<AbilityDefinitionDemonHunterImmolation>
---@field apply fun(fn: fun(a: AbilityDefinitionDemonHunterImmolation)): fun(a: AbilityDefinitionDemonHunterImmolation)

---@type AbilityFactoryImmolation1
A.immolation1 = setmetatable({
    parent = AbilityIds.immolation1,
    apply = identity,
}, callMt)

---@class AbilityFactoryManaBurn1
---@overload fun(data: AbilityRow<AbilityDefinitionDemonHunterManaBurn>?): AbilityRow<AbilityDefinitionDemonHunterManaBurn>
---@field apply fun(fn: fun(a: AbilityDefinitionDemonHunterManaBurn)): fun(a: AbilityDefinitionDemonHunterManaBurn)

---@type AbilityFactoryManaBurn1
A.manaBurn1 = setmetatable({
    parent = AbilityIds.manaBurn1,
    apply = identity,
}, callMt)

---@class AbilityFactoryMetamorphosis
---@overload fun(data: AbilityRow<AbilityDefinitionDemonHunterMetamorphosis>?): AbilityRow<AbilityDefinitionDemonHunterMetamorphosis>
---@field apply fun(fn: fun(a: AbilityDefinitionDemonHunterMetamorphosis)): fun(a: AbilityDefinitionDemonHunterMetamorphosis)

---@type AbilityFactoryMetamorphosis
A.metamorphosis = setmetatable({
    parent = AbilityIds.metamorphosis,
    apply = identity,
}, callMt)

---@class AbilityFactoryPoisonArrows
---@overload fun(data: AbilityRow<AbilityDefinitionPoisonArrows>?): AbilityRow<AbilityDefinitionPoisonArrows>
---@field apply fun(fn: fun(a: AbilityDefinitionPoisonArrows)): fun(a: AbilityDefinitionPoisonArrows)

---@type AbilityFactoryPoisonArrows
A.poisonArrows = setmetatable({
    parent = AbilityIds.poisonArrows,
    apply = identity,
}, callMt)

---@class AbilityFactoryStarfall1
---@overload fun(data: AbilityRow<AbilityDefinitionCenariusBeefyStarfall>?): AbilityRow<AbilityDefinitionCenariusBeefyStarfall>
---@field apply fun(fn: fun(a: AbilityDefinitionCenariusBeefyStarfall)): fun(a: AbilityDefinitionCenariusBeefyStarfall)

---@type AbilityFactoryStarfall1
A.starfall1 = setmetatable({
    parent = AbilityIds.starfall1,
    apply = identity,
}, callMt)

---@class AbilityFactoryStarfall
---@overload fun(data: AbilityRow<AbilityDefinitionMoonPriestessStarfall>?): AbilityRow<AbilityDefinitionMoonPriestessStarfall>
---@field apply fun(fn: fun(a: AbilityDefinitionMoonPriestessStarfall)): fun(a: AbilityDefinitionMoonPriestessStarfall)

---@type AbilityFactoryStarfall
A.starfall = setmetatable({
    parent = AbilityIds.starfall,
    apply = identity,
}, callMt)

---@class AbilityFactoryShadowStrike
---@overload fun(data: AbilityRow<AbilityDefinitionWardenShadowStrike>?): AbilityRow<AbilityDefinitionWardenShadowStrike>
---@field apply fun(fn: fun(a: AbilityDefinitionWardenShadowStrike)): fun(a: AbilityDefinitionWardenShadowStrike)

---@type AbilityFactoryShadowStrike
A.shadowStrike = setmetatable({
    parent = AbilityIds.shadowStrike,
    apply = identity,
}, callMt)

---@class AbilityFactoryScout
---@overload fun(data: AbilityRow<AbilityDefinitionMoonPriestessScout>?): AbilityRow<AbilityDefinitionMoonPriestessScout>
---@field apply fun(fn: fun(a: AbilityDefinitionMoonPriestessScout)): fun(a: AbilityDefinitionMoonPriestessScout)

---@type AbilityFactoryScout
A.scout = setmetatable({
    parent = AbilityIds.scout,
    apply = identity,
}, callMt)

---@class AbilityFactoryWardenSpiritofVengeance
---@overload fun(data: AbilityRow<AbilityDefinitionWardenSpiritofVengeance>?): AbilityRow<AbilityDefinitionWardenSpiritofVengeance>
---@field apply fun(fn: fun(a: AbilityDefinitionWardenSpiritofVengeance)): fun(a: AbilityDefinitionWardenSpiritofVengeance)

---@type AbilityFactoryWardenSpiritofVengeance
A.wardenSpiritofVengeance = setmetatable({
    parent = AbilityIds.wardenSpiritofVengeance,
    apply = identity,
}, callMt)

---@class AbilityFactoryTranquility
---@overload fun(data: AbilityRow<AbilityDefinitionKeeperoftheGroveTranquility>?): AbilityRow<AbilityDefinitionKeeperoftheGroveTranquility>
---@field apply fun(fn: fun(a: AbilityDefinitionKeeperoftheGroveTranquility)): fun(a: AbilityDefinitionKeeperoftheGroveTranquility)

---@type AbilityFactoryTranquility
A.tranquility = setmetatable({
    parent = AbilityIds.tranquility,
    apply = identity,
}, callMt)

---@class AbilityFactoryEvilIllidanMetamorphosis
---@overload fun(data: AbilityRow<AbilityDefinitionEvilIllidanMetamorphosis>?): AbilityRow<AbilityDefinitionEvilIllidanMetamorphosis>
---@field apply fun(fn: fun(a: AbilityDefinitionEvilIllidanMetamorphosis)): fun(a: AbilityDefinitionEvilIllidanMetamorphosis)

---@type AbilityFactoryEvilIllidanMetamorphosis
A.evilIllidanMetamorphosis = setmetatable({
    parent = AbilityIds.evilIllidanMetamorphosis,
    apply = identity,
}, callMt)

---@class AbilityFactoryBrillianceAura
---@overload fun(data: AbilityRow<AbilityDefinitionArchMageBrillianceAura>?): AbilityRow<AbilityDefinitionArchMageBrillianceAura>
---@field apply fun(fn: fun(a: AbilityDefinitionArchMageBrillianceAura)): fun(a: AbilityDefinitionArchMageBrillianceAura)

---@type AbilityFactoryBrillianceAura
A.brillianceAura = setmetatable({
    parent = AbilityIds.brillianceAura,
    apply = identity,
}, callMt)

---@class AbilityFactoryDevotionAura
---@overload fun(data: AbilityRow<AbilityDefinitionPaladinDevotionAura>?): AbilityRow<AbilityDefinitionPaladinDevotionAura>
---@field apply fun(fn: fun(a: AbilityDefinitionPaladinDevotionAura)): fun(a: AbilityDefinitionPaladinDevotionAura)

---@type AbilityFactoryDevotionAura
A.devotionAura = setmetatable({
    parent = AbilityIds.devotionAura,
    apply = identity,
}, callMt)

---@class AbilityFactoryAvatar
---@overload fun(data: AbilityRow<AbilityDefinitionMountainKingAvatar>?): AbilityRow<AbilityDefinitionMountainKingAvatar>
---@field apply fun(fn: fun(a: AbilityDefinitionMountainKingAvatar)): fun(a: AbilityDefinitionMountainKingAvatar)

---@type AbilityFactoryAvatar
A.avatar = setmetatable({
    parent = AbilityIds.avatar,
    apply = identity,
}, callMt)

---@class AbilityFactoryBash
---@overload fun(data: AbilityRow<AbilityDefinitionMountainKingBash>?): AbilityRow<AbilityDefinitionMountainKingBash>
---@field apply fun(fn: fun(a: AbilityDefinitionMountainKingBash)): fun(a: AbilityDefinitionMountainKingBash)

---@type AbilityFactoryBash
A.bash = setmetatable({
    parent = AbilityIds.bash,
    apply = identity,
}, callMt)

---@class AbilityFactoryBanish
---@overload fun(data: AbilityRow<AbilityDefinitionBloodMageBanish>?): AbilityRow<AbilityDefinitionBloodMageBanish>
---@field apply fun(fn: fun(a: AbilityDefinitionBloodMageBanish)): fun(a: AbilityDefinitionBloodMageBanish)

---@type AbilityFactoryBanish
A.banish = setmetatable({
    parent = AbilityIds.banish,
    apply = identity,
}, callMt)

---@class AbilityFactoryBlizzard
---@overload fun(data: AbilityRow<AbilityDefinitionArchMageBlizzard>?): AbilityRow<AbilityDefinitionArchMageBlizzard>
---@field apply fun(fn: fun(a: AbilityDefinitionArchMageBlizzard)): fun(a: AbilityDefinitionArchMageBlizzard)

---@type AbilityFactoryBlizzard
A.blizzard = setmetatable({
    parent = AbilityIds.blizzard,
    apply = identity,
}, callMt)

---@class AbilityFactoryColdArrows
---@overload fun(data: AbilityRow<AbilityDefinitionRangerColdArrows>?): AbilityRow<AbilityDefinitionRangerColdArrows>
---@field apply fun(fn: fun(a: AbilityDefinitionRangerColdArrows)): fun(a: AbilityDefinitionRangerColdArrows)

---@type AbilityFactoryColdArrows
A.coldArrows = setmetatable({
    parent = AbilityIds.coldArrows,
    apply = identity,
}, callMt)

---@class AbilityFactorySiphonMana
---@overload fun(data: AbilityRow<AbilityDefinitionBloodMageSiphonMana>?): AbilityRow<AbilityDefinitionBloodMageSiphonMana>
---@field apply fun(fn: fun(a: AbilityDefinitionBloodMageSiphonMana)): fun(a: AbilityDefinitionBloodMageSiphonMana)

---@type AbilityFactorySiphonMana
A.siphonMana = setmetatable({
    parent = AbilityIds.siphonMana,
    apply = identity,
}, callMt)

---@class AbilityFactoryDivineShield
---@overload fun(data: AbilityRow<AbilityDefinitionPaladinDivineShield>?): AbilityRow<AbilityDefinitionPaladinDivineShield>
---@field apply fun(fn: fun(a: AbilityDefinitionPaladinDivineShield)): fun(a: AbilityDefinitionPaladinDivineShield)

---@type AbilityFactoryDivineShield
A.divineShield = setmetatable({
    parent = AbilityIds.divineShield,
    apply = identity,
}, callMt)

---@class AbilityFactorySearingArrows1
---@overload fun(data: AbilityRow<AbilityDefinitionMoonPriestessSearingArrows>?): AbilityRow<AbilityDefinitionMoonPriestessSearingArrows>
---@field apply fun(fn: fun(a: AbilityDefinitionMoonPriestessSearingArrows)): fun(a: AbilityDefinitionMoonPriestessSearingArrows)

---@type AbilityFactorySearingArrows1
A.searingArrows1 = setmetatable({
    parent = AbilityIds.searingArrows1,
    apply = identity,
}, callMt)

---@class AbilityFactoryBloodMageFlameStrike
---@overload fun(data: AbilityRow<AbilityDefinitionBloodMageFlameStrike>?): AbilityRow<AbilityDefinitionBloodMageFlameStrike>
---@field apply fun(fn: fun(a: AbilityDefinitionBloodMageFlameStrike)): fun(a: AbilityDefinitionBloodMageFlameStrike)

---@type AbilityFactoryBloodMageFlameStrike
A.bloodMageFlameStrike = setmetatable({
    parent = AbilityIds.bloodMageFlameStrike,
    apply = identity,
}, callMt)

---@class AbilityFactoryHolyLight
---@overload fun(data: AbilityRow<AbilityDefinitionPaladinHolyLight>?): AbilityRow<AbilityDefinitionPaladinHolyLight>
---@field apply fun(fn: fun(a: AbilityDefinitionPaladinHolyLight)): fun(a: AbilityDefinitionPaladinHolyLight)

---@type AbilityFactoryHolyLight
A.holyLight = setmetatable({
    parent = AbilityIds.holyLight,
    apply = identity,
}, callMt)

---@class AbilityFactoryMassTeleport
---@overload fun(data: AbilityRow<AbilityDefinitionArchMageMassTeleport>?): AbilityRow<AbilityDefinitionArchMageMassTeleport>
---@field apply fun(fn: fun(a: AbilityDefinitionArchMageMassTeleport)): fun(a: AbilityDefinitionArchMageMassTeleport)

---@type AbilityFactoryMassTeleport
A.massTeleport = setmetatable({
    parent = AbilityIds.massTeleport,
    apply = identity,
}, callMt)

---@class AbilityFactoryPhoenix
---@overload fun(data: AbilityRow<AbilityDefinitionBloodMagePhoenix>?): AbilityRow<AbilityDefinitionBloodMagePhoenix>
---@field apply fun(fn: fun(a: AbilityDefinitionBloodMagePhoenix)): fun(a: AbilityDefinitionBloodMagePhoenix)

---@type AbilityFactoryPhoenix
A.phoenix = setmetatable({
    parent = AbilityIds.phoenix,
    apply = identity,
}, callMt)

---@class AbilityFactoryResurrection
---@overload fun(data: AbilityRow<AbilityDefinitionPaladinResurrection>?): AbilityRow<AbilityDefinitionPaladinResurrection>
---@field apply fun(fn: fun(a: AbilityDefinitionPaladinResurrection)): fun(a: AbilityDefinitionPaladinResurrection)

---@type AbilityFactoryResurrection
A.resurrection = setmetatable({
    parent = AbilityIds.resurrection,
    apply = identity,
}, callMt)

---@class AbilityFactoryStormBolt
---@overload fun(data: AbilityRow<AbilityDefinitionMountainKingThunderBolt>?): AbilityRow<AbilityDefinitionMountainKingThunderBolt>
---@field apply fun(fn: fun(a: AbilityDefinitionMountainKingThunderBolt)): fun(a: AbilityDefinitionMountainKingThunderBolt)

---@type AbilityFactoryStormBolt
A.stormBolt = setmetatable({
    parent = AbilityIds.stormBolt,
    apply = identity,
}, callMt)

---@class AbilityFactoryThunderClap
---@overload fun(data: AbilityRow<AbilityDefinitionMountainKingThunderClap>?): AbilityRow<AbilityDefinitionMountainKingThunderClap>
---@field apply fun(fn: fun(a: AbilityDefinitionMountainKingThunderClap)): fun(a: AbilityDefinitionMountainKingThunderClap)

---@type AbilityFactoryThunderClap
A.thunderClap = setmetatable({
    parent = AbilityIds.thunderClap,
    apply = identity,
}, callMt)

---@class AbilityFactorySummonWaterElemental
---@overload fun(data: AbilityRow<AbilityDefinitionArchMageSummonWaterElemental>?): AbilityRow<AbilityDefinitionArchMageSummonWaterElemental>
---@field apply fun(fn: fun(a: AbilityDefinitionArchMageSummonWaterElemental)): fun(a: AbilityDefinitionArchMageSummonWaterElemental)

---@type AbilityFactorySummonWaterElemental
A.summonWaterElemental = setmetatable({
    parent = AbilityIds.summonWaterElemental,
    apply = identity,
}, callMt)

---@class AbilityFactoryAgilityBonusPlus1
---@overload fun(data: AbilityRow<AbilityDefinitionAgilityBonusPlus1>?): AbilityRow<AbilityDefinitionAgilityBonusPlus1>
---@field apply fun(fn: fun(a: AbilityDefinitionAgilityBonusPlus1)): fun(a: AbilityDefinitionAgilityBonusPlus1)

---@type AbilityFactoryAgilityBonusPlus1
A.agilityBonusPlus1 = setmetatable({
    parent = AbilityIds.agilityBonusPlus1,
    apply = identity,
}, callMt)

---@class AbilityFactoryAgilityBonusPlus3
---@overload fun(data: AbilityRow<AbilityDefinitionAgilityBonusPlus3>?): AbilityRow<AbilityDefinitionAgilityBonusPlus3>
---@field apply fun(fn: fun(a: AbilityDefinitionAgilityBonusPlus3)): fun(a: AbilityDefinitionAgilityBonusPlus3)

---@type AbilityFactoryAgilityBonusPlus3
A.agilityBonusPlus3 = setmetatable({
    parent = AbilityIds.agilityBonusPlus3,
    apply = identity,
}, callMt)

---@class AbilityFactoryAgilityBonusPlus4
---@overload fun(data: AbilityRow<AbilityDefinitionAgilityBonusPlus4>?): AbilityRow<AbilityDefinitionAgilityBonusPlus4>
---@field apply fun(fn: fun(a: AbilityDefinitionAgilityBonusPlus4)): fun(a: AbilityDefinitionAgilityBonusPlus4)

---@type AbilityFactoryAgilityBonusPlus4
A.agilityBonusPlus4 = setmetatable({
    parent = AbilityIds.agilityBonusPlus4,
    apply = identity,
}, callMt)

---@class AbilityFactoryAgilityBonusPlus6
---@overload fun(data: AbilityRow<AbilityDefinitionAgilityBonusPlus6>?): AbilityRow<AbilityDefinitionAgilityBonusPlus6>
---@field apply fun(fn: fun(a: AbilityDefinitionAgilityBonusPlus6)): fun(a: AbilityDefinitionAgilityBonusPlus6)

---@type AbilityFactoryAgilityBonusPlus6
A.agilityBonusPlus6 = setmetatable({
    parent = AbilityIds.agilityBonusPlus6,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAttackDamageGain
---@overload fun(data: AbilityRow<AbilityDefinitionAttackMod>?): AbilityRow<AbilityDefinitionAttackMod>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackMod)): fun(a: AbilityDefinitionAttackMod)

---@type AbilityFactoryItemAttackDamageGain
A.itemAttackDamageGain = setmetatable({
    parent = AbilityIds.itemAttackDamageGain,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemHeroStatBonus
---@overload fun(data: AbilityRow<AbilityDefinitionAIab>?): AbilityRow<AbilityDefinitionAIab>
---@field apply fun(fn: fun(a: AbilityDefinitionAIab)): fun(a: AbilityDefinitionAIab)

---@type AbilityFactoryItemHeroStatBonus
A.itemHeroStatBonus = setmetatable({
    parent = AbilityIds.itemHeroStatBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAuraDevotion
---@overload fun(data: AbilityRow<AbilityDefinitionItemAuraDevotion>?): AbilityRow<AbilityDefinitionItemAuraDevotion>
---@field apply fun(fn: fun(a: AbilityDefinitionItemAuraDevotion)): fun(a: AbilityDefinitionItemAuraDevotion)

---@type AbilityFactoryItemAuraDevotion
A.itemAuraDevotion = setmetatable({
    parent = AbilityIds.itemAuraDevotion,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAuraEndurance
---@overload fun(data: AbilityRow<AbilityDefinitionItemAuraEndurance>?): AbilityRow<AbilityDefinitionItemAuraEndurance>
---@field apply fun(fn: fun(a: AbilityDefinitionItemAuraEndurance)): fun(a: AbilityDefinitionItemAuraEndurance)

---@type AbilityFactoryItemAuraEndurance
A.itemAuraEndurance = setmetatable({
    parent = AbilityIds.itemAuraEndurance,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAgilityGain
---@overload fun(data: AbilityRow<AbilityDefinitionAgilityMod>?): AbilityRow<AbilityDefinitionAgilityMod>
---@field apply fun(fn: fun(a: AbilityDefinitionAgilityMod)): fun(a: AbilityDefinitionAgilityMod)

---@type AbilityFactoryItemAgilityGain
A.itemAgilityGain = setmetatable({
    parent = AbilityIds.itemAgilityGain,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAnimateDead
---@overload fun(data: AbilityRow<AbilityDefinitionAnimateDead>?): AbilityRow<AbilityDefinitionAnimateDead>
---@field apply fun(fn: fun(a: AbilityDefinitionAnimateDead)): fun(a: AbilityDefinitionAnimateDead)

---@type AbilityFactoryItemAnimateDead
A.itemAnimateDead = setmetatable({
    parent = AbilityIds.itemAnimateDead,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAuraTrueshot
---@overload fun(data: AbilityRow<AbilityDefinitionItemAuraTrueshot>?): AbilityRow<AbilityDefinitionItemAuraTrueshot>
---@field apply fun(fn: fun(a: AbilityDefinitionItemAuraTrueshot)): fun(a: AbilityDefinitionItemAuraTrueshot)

---@type AbilityFactoryItemAuraTrueshot
A.itemAuraTrueshot = setmetatable({
    parent = AbilityIds.itemAuraTrueshot,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAttackSpeedBonus
---@overload fun(data: AbilityRow<AbilityDefinitionAIas>?): AbilityRow<AbilityDefinitionAIas>
---@field apply fun(fn: fun(a: AbilityDefinitionAIas)): fun(a: AbilityDefinitionAIas)

---@type AbilityFactoryItemAttackSpeedBonus
A.itemAttackSpeedBonus = setmetatable({
    parent = AbilityIds.itemAttackSpeedBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemDamageBonus
---@overload fun(data: AbilityRow<AbilityDefinitionAttackBonus>?): AbilityRow<AbilityDefinitionAttackBonus>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackBonus)): fun(a: AbilityDefinitionAttackBonus)

---@type AbilityFactoryItemDamageBonus
A.itemDamageBonus = setmetatable({
    parent = AbilityIds.itemDamageBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAuraUnholy
---@overload fun(data: AbilityRow<AbilityDefinitionItemAuraUnholy>?): AbilityRow<AbilityDefinitionItemAuraUnholy>
---@field apply fun(fn: fun(a: AbilityDefinitionItemAuraUnholy)): fun(a: AbilityDefinitionItemAuraUnholy)

---@type AbilityFactoryItemAuraUnholy
A.itemAuraUnholy = setmetatable({
    parent = AbilityIds.itemAuraUnholy,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAuraVampiric
---@overload fun(data: AbilityRow<AbilityDefinitionItemAuraVampiric>?): AbilityRow<AbilityDefinitionItemAuraVampiric>
---@field apply fun(fn: fun(a: AbilityDefinitionItemAuraVampiric)): fun(a: AbilityDefinitionItemAuraVampiric)

---@type AbilityFactoryItemAuraVampiric
A.itemAuraVampiric = setmetatable({
    parent = AbilityIds.itemAuraVampiric,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAuraBrilliance
---@overload fun(data: AbilityRow<AbilityDefinitionItemAuraBrilliance>?): AbilityRow<AbilityDefinitionItemAuraBrilliance>
---@field apply fun(fn: fun(a: AbilityDefinitionItemAuraBrilliance)): fun(a: AbilityDefinitionItemAuraBrilliance)

---@type AbilityFactoryItemAuraBrilliance
A.itemAuraBrilliance = setmetatable({
    parent = AbilityIds.itemAuraBrilliance,
    apply = identity,
}, callMt)

---@class AbilityFactoryBuildTinyGreatHall
---@overload fun(data: AbilityRow<AbilityDefinitionBuildTinyGreatHall>?): AbilityRow<AbilityDefinitionBuildTinyGreatHall>
---@field apply fun(fn: fun(a: AbilityDefinitionBuildTinyGreatHall)): fun(a: AbilityDefinitionBuildTinyGreatHall)

---@type AbilityFactoryBuildTinyGreatHall
A.buildTinyGreatHall = setmetatable({
    parent = AbilityIds.buildTinyGreatHall,
    apply = identity,
}, callMt)

---@class AbilityFactoryBuildTinyCastle
---@overload fun(data: AbilityRow<AbilityDefinitionBuildTinyCastle>?): AbilityRow<AbilityDefinitionBuildTinyCastle>
---@field apply fun(fn: fun(a: AbilityDefinitionBuildTinyCastle)): fun(a: AbilityDefinitionBuildTinyCastle)

---@type AbilityFactoryBuildTinyCastle
A.buildTinyCastle = setmetatable({
    parent = AbilityIds.buildTinyCastle,
    apply = identity,
}, callMt)

---@class AbilityFactoryMaxManaBonusMost
---@overload fun(data: AbilityRow<AbilityDefinitionMaxManaBonusMost>?): AbilityRow<AbilityDefinitionMaxManaBonusMost>
---@field apply fun(fn: fun(a: AbilityDefinitionMaxManaBonusMost)): fun(a: AbilityDefinitionMaxManaBonusMost)

---@type AbilityFactoryMaxManaBonusMost
A.maxManaBonusMost = setmetatable({
    parent = AbilityIds.maxManaBonusMost,
    apply = identity,
}, callMt)

---@class AbilityFactoryBuildTinyScoutTower
---@overload fun(data: AbilityRow<AbilityDefinitionBuildTinyScoutTower>?): AbilityRow<AbilityDefinitionBuildTinyScoutTower>
---@field apply fun(fn: fun(a: AbilityDefinitionBuildTinyScoutTower)): fun(a: AbilityDefinitionBuildTinyScoutTower)

---@type AbilityFactoryBuildTinyScoutTower
A.buildTinyScoutTower = setmetatable({
    parent = AbilityIds.buildTinyScoutTower,
    apply = identity,
}, callMt)

---@class AbilityFactoryBashitem
---@overload fun(data: AbilityRow<AbilityDefinitionBashitem>?): AbilityRow<AbilityDefinitionBashitem>
---@field apply fun(fn: fun(a: AbilityDefinitionBashitem)): fun(a: AbilityDefinitionBashitem)

---@type AbilityFactoryBashitem
A.bashitem = setmetatable({
    parent = AbilityIds.bashitem,
    apply = identity,
}, callMt)

---@class AbilityFactoryOrbofCorruption
---@overload fun(data: AbilityRow<AbilityDefinitionOrbofCorruption>?): AbilityRow<AbilityDefinitionOrbofCorruption>
---@field apply fun(fn: fun(a: AbilityDefinitionOrbofCorruption)): fun(a: AbilityDefinitionOrbofCorruption)

---@type AbilityFactoryOrbofCorruption
A.orbofCorruption = setmetatable({
    parent = AbilityIds.orbofCorruption,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAuraCommand
---@overload fun(data: AbilityRow<AbilityDefinitionItemAuraCommand>?): AbilityRow<AbilityDefinitionItemAuraCommand>
---@field apply fun(fn: fun(a: AbilityDefinitionItemAuraCommand)): fun(a: AbilityDefinitionItemAuraCommand)

---@type AbilityFactoryItemAuraCommand
A.itemAuraCommand = setmetatable({
    parent = AbilityIds.itemAuraCommand,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemImmolation
---@overload fun(data: AbilityRow<AbilityDefinitionItemCloakOfFlames>?): AbilityRow<AbilityDefinitionItemCloakOfFlames>
---@field apply fun(fn: fun(a: AbilityDefinitionItemCloakOfFlames)): fun(a: AbilityDefinitionItemCloakOfFlames)

---@type AbilityFactoryItemImmolation
A.itemImmolation = setmetatable({
    parent = AbilityIds.itemImmolation,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemCommand
---@overload fun(data: AbilityRow<AbilityDefinitionItemCommand>?): AbilityRow<AbilityDefinitionItemCommand>
---@field apply fun(fn: fun(a: AbilityDefinitionItemCommand)): fun(a: AbilityDefinitionItemCommand)

---@type AbilityFactoryItemCommand
A.itemCommand = setmetatable({
    parent = AbilityIds.itemCommand,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemChangeTOD
---@overload fun(data: AbilityRow<AbilityDefinitionItemChangeTOD>?): AbilityRow<AbilityDefinitionItemChangeTOD>
---@field apply fun(fn: fun(a: AbilityDefinitionItemChangeTOD)): fun(a: AbilityDefinitionItemChangeTOD)

---@type AbilityFactoryItemChangeTOD
A.itemChangeTOD = setmetatable({
    parent = AbilityIds.itemChangeTOD,
    apply = identity,
}, callMt)

---@class AbilityFactoryCycloneAIcy
---@overload fun(data: AbilityRow<AbilityDefinitionCycloneAIcy>?): AbilityRow<AbilityDefinitionCycloneAIcy>
---@field apply fun(fn: fun(a: AbilityDefinitionCycloneAIcy)): fun(a: AbilityDefinitionCycloneAIcy)

---@type AbilityFactoryCycloneAIcy
A.cycloneAIcy = setmetatable({
    parent = AbilityIds.cycloneAIcy,
    apply = identity,
}, callMt)

---@class AbilityFactoryDefenseBonusPlus1
---@overload fun(data: AbilityRow<AbilityDefinitionDefenseBonusPlus1>?): AbilityRow<AbilityDefinitionDefenseBonusPlus1>
---@field apply fun(fn: fun(a: AbilityDefinitionDefenseBonusPlus1)): fun(a: AbilityDefinitionDefenseBonusPlus1)

---@type AbilityFactoryDefenseBonusPlus1
A.defenseBonusPlus1 = setmetatable({
    parent = AbilityIds.defenseBonusPlus1,
    apply = identity,
}, callMt)

---@class AbilityFactoryDefenseBonusPlus2
---@overload fun(data: AbilityRow<AbilityDefinitionDefenseBonusPlus2>?): AbilityRow<AbilityDefinitionDefenseBonusPlus2>
---@field apply fun(fn: fun(a: AbilityDefinitionDefenseBonusPlus2)): fun(a: AbilityDefinitionDefenseBonusPlus2)

---@type AbilityFactoryDefenseBonusPlus2
A.defenseBonusPlus2 = setmetatable({
    parent = AbilityIds.defenseBonusPlus2,
    apply = identity,
}, callMt)

---@class AbilityFactoryDefenseBonusPlus3
---@overload fun(data: AbilityRow<AbilityDefinitionDefenseBonusPlus3>?): AbilityRow<AbilityDefinitionDefenseBonusPlus3>
---@field apply fun(fn: fun(a: AbilityDefinitionDefenseBonusPlus3)): fun(a: AbilityDefinitionDefenseBonusPlus3)

---@type AbilityFactoryDefenseBonusPlus3
A.defenseBonusPlus3 = setmetatable({
    parent = AbilityIds.defenseBonusPlus3,
    apply = identity,
}, callMt)

---@class AbilityFactoryDefenseBonusPlus4
---@overload fun(data: AbilityRow<AbilityDefinitionDefenseBonusPlus4>?): AbilityRow<AbilityDefinitionDefenseBonusPlus4>
---@field apply fun(fn: fun(a: AbilityDefinitionDefenseBonusPlus4)): fun(a: AbilityDefinitionDefenseBonusPlus4)

---@type AbilityFactoryDefenseBonusPlus4
A.defenseBonusPlus4 = setmetatable({
    parent = AbilityIds.defenseBonusPlus4,
    apply = identity,
}, callMt)

---@class AbilityFactoryDefenseBonusPlus5
---@overload fun(data: AbilityRow<AbilityDefinitionDefenseBonusPlus5>?): AbilityRow<AbilityDefinitionDefenseBonusPlus5>
---@field apply fun(fn: fun(a: AbilityDefinitionDefenseBonusPlus5)): fun(a: AbilityDefinitionDefenseBonusPlus5)

---@type AbilityFactoryDefenseBonusPlus5
A.defenseBonusPlus5 = setmetatable({
    parent = AbilityIds.defenseBonusPlus5,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemTemporaryAreaArmorBonus
---@overload fun(data: AbilityRow<AbilityDefinitionItemDefenseAoe>?): AbilityRow<AbilityDefinitionItemDefenseAoe>
---@field apply fun(fn: fun(a: AbilityDefinitionItemDefenseAoe)): fun(a: AbilityDefinitionItemDefenseAoe)

---@type AbilityFactoryItemTemporaryAreaArmorBonus
A.itemTemporaryAreaArmorBonus = setmetatable({
    parent = AbilityIds.itemTemporaryAreaArmorBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemDefenseAoePlusHealing
---@overload fun(data: AbilityRow<AbilityDefinitionItemDefenseAoePlusHealing>?): AbilityRow<AbilityDefinitionItemDefenseAoePlusHealing>
---@field apply fun(fn: fun(a: AbilityDefinitionItemDefenseAoePlusHealing)): fun(a: AbilityDefinitionItemDefenseAoePlusHealing)

---@type AbilityFactoryItemDefenseAoePlusHealing
A.itemDefenseAoePlusHealing = setmetatable({
    parent = AbilityIds.itemDefenseAoePlusHealing,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemDispelChain
---@overload fun(data: AbilityRow<AbilityDefinitionItemDispelChain>?): AbilityRow<AbilityDefinitionItemDispelChain>
---@field apply fun(fn: fun(a: AbilityDefinitionItemDispelChain)): fun(a: AbilityDefinitionItemDispelChain)

---@type AbilityFactoryItemDispelChain
A.itemDispelChain = setmetatable({
    parent = AbilityIds.itemDispelChain,
    apply = identity,
}, callMt)

---@class AbilityFactoryDefendItem
---@overload fun(data: AbilityRow<AbilityDefinitionDefendItem>?): AbilityRow<AbilityDefinitionDefendItem>
---@field apply fun(fn: fun(a: AbilityDefinitionDefendItem)): fun(a: AbilityDefinitionDefendItem)

---@type AbilityFactoryDefendItem
A.defendItem = setmetatable({
    parent = AbilityIds.defendItem,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemArmorBonus
---@overload fun(data: AbilityRow<AbilityDefinitionAIde>?): AbilityRow<AbilityDefinitionAIde>
---@field apply fun(fn: fun(a: AbilityDefinitionAIde)): fun(a: AbilityDefinitionAIde)

---@type AbilityFactoryItemArmorBonus
A.itemArmorBonus = setmetatable({
    parent = AbilityIds.itemArmorBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryOrbofDarkness
---@overload fun(data: AbilityRow<AbilityDefinitionOrbofDarkness>?): AbilityRow<AbilityDefinitionOrbofDarkness>
---@field apply fun(fn: fun(a: AbilityDefinitionOrbofDarkness)): fun(a: AbilityDefinitionOrbofDarkness)

---@type AbilityFactoryOrbofDarkness
A.orbofDarkness = setmetatable({
    parent = AbilityIds.orbofDarkness,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemDispel
---@overload fun(data: AbilityRow<AbilityDefinitionItemDispelAoe>?): AbilityRow<AbilityDefinitionItemDispelAoe>
---@field apply fun(fn: fun(a: AbilityDefinitionItemDispelAoe)): fun(a: AbilityDefinitionItemDispelAoe)

---@type AbilityFactoryItemDispel
A.itemDispel = setmetatable({
    parent = AbilityIds.itemDispel,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemDispelAoeWithCooldown
---@overload fun(data: AbilityRow<AbilityDefinitionItemDispelAoeWithCooldown>?): AbilityRow<AbilityDefinitionItemDispelAoeWithCooldown>
---@field apply fun(fn: fun(a: AbilityDefinitionItemDispelAoeWithCooldown)): fun(a: AbilityDefinitionItemDispelAoeWithCooldown)

---@type AbilityFactoryItemDispelAoeWithCooldown
A.itemDispelAoeWithCooldown = setmetatable({
    parent = AbilityIds.itemDispelAoeWithCooldown,
    apply = identity,
}, callMt)

---@class AbilityFactoryExperienceModgreater
---@overload fun(data: AbilityRow<AbilityDefinitionExperienceModgreater>?): AbilityRow<AbilityDefinitionExperienceModgreater>
---@field apply fun(fn: fun(a: AbilityDefinitionExperienceModgreater)): fun(a: AbilityDefinitionExperienceModgreater)

---@type AbilityFactoryExperienceModgreater
A.experienceModgreater = setmetatable({
    parent = AbilityIds.experienceModgreater,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemExperienceGain
---@overload fun(data: AbilityRow<AbilityDefinitionExperienceMod>?): AbilityRow<AbilityDefinitionExperienceMod>
---@field apply fun(fn: fun(a: AbilityDefinitionExperienceMod)): fun(a: AbilityDefinitionExperienceMod)

---@type AbilityFactoryItemExperienceGain
A.itemExperienceGain = setmetatable({
    parent = AbilityIds.itemExperienceGain,
    apply = identity,
}, callMt)

---@class AbilityFactoryEvasion3
---@overload fun(data: AbilityRow<AbilityDefinitionEvasioncreep>?): AbilityRow<AbilityDefinitionEvasioncreep>
---@field apply fun(fn: fun(a: AbilityDefinitionEvasioncreep)): fun(a: AbilityDefinitionEvasioncreep)

---@type AbilityFactoryEvasion3
A.evasion3 = setmetatable({
    parent = AbilityIds.evasion3,
    apply = identity,
}, callMt)

---@class AbilityFactoryFlareGun
---@overload fun(data: AbilityRow<AbilityDefinitionFlareGun>?): AbilityRow<AbilityDefinitionFlareGun>
---@field apply fun(fn: fun(a: AbilityDefinitionFlareGun)): fun(a: AbilityDefinitionFlareGun)

---@type AbilityFactoryFlareGun
A.flareGun = setmetatable({
    parent = AbilityIds.flareGun,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAttackFireBonus
---@overload fun(data: AbilityRow<AbilityDefinitionFireDamageBonus>?): AbilityRow<AbilityDefinitionFireDamageBonus>
---@field apply fun(fn: fun(a: AbilityDefinitionFireDamageBonus)): fun(a: AbilityDefinitionFireDamageBonus)

---@type AbilityFactoryItemAttackFireBonus
A.itemAttackFireBonus = setmetatable({
    parent = AbilityIds.itemAttackFireBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemRedDrakeSummon
---@overload fun(data: AbilityRow<AbilityDefinitionFigurineRedDrake>?): AbilityRow<AbilityDefinitionFigurineRedDrake>
---@field apply fun(fn: fun(a: AbilityDefinitionFigurineRedDrake)): fun(a: AbilityDefinitionFigurineRedDrake)

---@type AbilityFactoryItemRedDrakeSummon
A.itemRedDrakeSummon = setmetatable({
    parent = AbilityIds.itemRedDrakeSummon,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemFurbolgSummon
---@overload fun(data: AbilityRow<AbilityDefinitionFigurineFurbolg>?): AbilityRow<AbilityDefinitionFigurineFurbolg>
---@field apply fun(fn: fun(a: AbilityDefinitionFigurineFurbolg)): fun(a: AbilityDefinitionFigurineFurbolg)

---@type AbilityFactoryItemFurbolgSummon
A.itemFurbolgSummon = setmetatable({
    parent = AbilityIds.itemFurbolgSummon,
    apply = identity,
}, callMt)

---@class AbilityFactoryCloudofFogItem
---@overload fun(data: AbilityRow<AbilityDefinitionCloudofFogItem>?): AbilityRow<AbilityDefinitionCloudofFogItem>
---@field apply fun(fn: fun(a: AbilityDefinitionCloudofFogItem)): fun(a: AbilityDefinitionCloudofFogItem)

---@type AbilityFactoryCloudofFogItem
A.cloudofFogItem = setmetatable({
    parent = AbilityIds.cloudofFogItem,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemFelhoundSummon
---@overload fun(data: AbilityRow<AbilityDefinitionFigurineFelHound>?): AbilityRow<AbilityDefinitionFigurineFelHound>
---@field apply fun(fn: fun(a: AbilityDefinitionFigurineFelHound)): fun(a: AbilityDefinitionFigurineFelHound)

---@type AbilityFactoryItemFelhoundSummon
A.itemFelhoundSummon = setmetatable({
    parent = AbilityIds.itemFelhoundSummon,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemRockGolemSummon
---@overload fun(data: AbilityRow<AbilityDefinitionFigurineRockGolem>?): AbilityRow<AbilityDefinitionFigurineRockGolem>
---@field apply fun(fn: fun(a: AbilityDefinitionFigurineRockGolem)): fun(a: AbilityDefinitionFigurineRockGolem)

---@type AbilityFactoryItemRockGolemSummon
A.itemRockGolemSummon = setmetatable({
    parent = AbilityIds.itemRockGolemSummon,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemSkeletonSummon
---@overload fun(data: AbilityRow<AbilityDefinitionFigurineSkeleton>?): AbilityRow<AbilityDefinitionFigurineSkeleton>
---@field apply fun(fn: fun(a: AbilityDefinitionFigurineSkeleton)): fun(a: AbilityDefinitionFigurineSkeleton)

---@type AbilityFactoryItemSkeletonSummon
A.itemSkeletonSummon = setmetatable({
    parent = AbilityIds.itemSkeletonSummon,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemDoomGuardSummon
---@overload fun(data: AbilityRow<AbilityDefinitionFigurineDoomGuard>?): AbilityRow<AbilityDefinitionFigurineDoomGuard>
---@field apply fun(fn: fun(a: AbilityDefinitionFigurineDoomGuard)): fun(a: AbilityDefinitionFigurineDoomGuard)

---@type AbilityFactoryItemDoomGuardSummon
A.itemDoomGuardSummon = setmetatable({
    parent = AbilityIds.itemDoomGuardSummon,
    apply = identity,
}, callMt)

---@class AbilityFactoryFortificationGlyph
---@overload fun(data: AbilityRow<AbilityDefinitionFortificationGlyph>?): AbilityRow<AbilityDefinitionFortificationGlyph>
---@field apply fun(fn: fun(a: AbilityDefinitionFortificationGlyph)): fun(a: AbilityDefinitionFortificationGlyph)

---@type AbilityFactoryFortificationGlyph
A.fortificationGlyph = setmetatable({
    parent = AbilityIds.fortificationGlyph,
    apply = identity,
}, callMt)

---@class AbilityFactoryAgilityModPlus2
---@overload fun(data: AbilityRow<AbilityDefinitionAgilityModPlus2>?): AbilityRow<AbilityDefinitionAgilityModPlus2>
---@field apply fun(fn: fun(a: AbilityDefinitionAgilityModPlus2)): fun(a: AbilityDefinitionAgilityModPlus2)

---@type AbilityFactoryAgilityModPlus2
A.agilityModPlus2 = setmetatable({
    parent = AbilityIds.agilityModPlus2,
    apply = identity,
}, callMt)

---@class AbilityFactoryGiveGold
---@overload fun(data: AbilityRow<AbilityDefinitionGiveGold>?): AbilityRow<AbilityDefinitionGiveGold>
---@field apply fun(fn: fun(a: AbilityDefinitionGiveGold)): fun(a: AbilityDefinitionGiveGold)

---@type AbilityFactoryGiveGold
A.giveGold = setmetatable({
    parent = AbilityIds.giveGold,
    apply = identity,
}, callMt)

---@class AbilityFactoryUltraVisionGlyph
---@overload fun(data: AbilityRow<AbilityDefinitionUltraVisionGlyph>?): AbilityRow<AbilityDefinitionUltraVisionGlyph>
---@field apply fun(fn: fun(a: AbilityDefinitionUltraVisionGlyph)): fun(a: AbilityDefinitionUltraVisionGlyph)

---@type AbilityFactoryUltraVisionGlyph
A.ultraVisionGlyph = setmetatable({
    parent = AbilityIds.ultraVisionGlyph,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemHealLesser
---@overload fun(data: AbilityRow<AbilityDefinitionItemHealLesser>?): AbilityRow<AbilityDefinitionItemHealLesser>
---@field apply fun(fn: fun(a: AbilityDefinitionItemHealLesser)): fun(a: AbilityDefinitionItemHealLesser)

---@type AbilityFactoryItemHealLesser
A.itemHealLesser = setmetatable({
    parent = AbilityIds.itemHealLesser,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemHealGreater
---@overload fun(data: AbilityRow<AbilityDefinitionItemHealGreater>?): AbilityRow<AbilityDefinitionItemHealGreater>
---@field apply fun(fn: fun(a: AbilityDefinitionItemHealGreater)): fun(a: AbilityDefinitionItemHealGreater)

---@type AbilityFactoryItemHealGreater
A.itemHealGreater = setmetatable({
    parent = AbilityIds.itemHealGreater,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemHealLeast
---@overload fun(data: AbilityRow<AbilityDefinitionItemHealLeast>?): AbilityRow<AbilityDefinitionItemHealLeast>
---@field apply fun(fn: fun(a: AbilityDefinitionItemHealLeast)): fun(a: AbilityDefinitionItemHealLeast)

---@type AbilityFactoryItemHealLeast
A.itemHealLeast = setmetatable({
    parent = AbilityIds.itemHealLeast,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAreaHealing
---@overload fun(data: AbilityRow<AbilityDefinitionItemHealAoe>?): AbilityRow<AbilityDefinitionItemHealAoe>
---@field apply fun(fn: fun(a: AbilityDefinitionItemHealAoe)): fun(a: AbilityDefinitionItemHealAoe)

---@type AbilityFactoryItemAreaHealing
A.itemAreaHealing = setmetatable({
    parent = AbilityIds.itemAreaHealing,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemHealAoeGreater
---@overload fun(data: AbilityRow<AbilityDefinitionItemHealAoeGreater>?): AbilityRow<AbilityDefinitionItemHealAoeGreater>
---@field apply fun(fn: fun(a: AbilityDefinitionItemHealAoeGreater)): fun(a: AbilityDefinitionItemHealAoeGreater)

---@type AbilityFactoryItemHealAoeGreater
A.itemHealAoeGreater = setmetatable({
    parent = AbilityIds.itemHealAoeGreater,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemHealing
---@overload fun(data: AbilityRow<AbilityDefinitionAIhe>?): AbilityRow<AbilityDefinitionAIhe>
---@field apply fun(fn: fun(a: AbilityDefinitionAIhe)): fun(a: AbilityDefinitionAIhe)

---@type AbilityFactoryItemHealing
A.itemHealing = setmetatable({
    parent = AbilityIds.itemHealing,
    apply = identity,
}, callMt)

---@class AbilityFactoryHealingWardAIhw
---@overload fun(data: AbilityRow<AbilityDefinitionHealingWardAIhw>?): AbilityRow<AbilityDefinitionHealingWardAIhw>
---@field apply fun(fn: fun(a: AbilityDefinitionHealingWardAIhw)): fun(a: AbilityDefinitionHealingWardAIhw)

---@type AbilityFactoryHealingWardAIhw
A.healingWardAIhw = setmetatable({
    parent = AbilityIds.healingWardAIhw,
    apply = identity,
}, callMt)

---@class AbilityFactoryIntelligenceBonusPlus1
---@overload fun(data: AbilityRow<AbilityDefinitionIntelligenceBonusPlus1>?): AbilityRow<AbilityDefinitionIntelligenceBonusPlus1>
---@field apply fun(fn: fun(a: AbilityDefinitionIntelligenceBonusPlus1)): fun(a: AbilityDefinitionIntelligenceBonusPlus1)

---@type AbilityFactoryIntelligenceBonusPlus1
A.intelligenceBonusPlus1 = setmetatable({
    parent = AbilityIds.intelligenceBonusPlus1,
    apply = identity,
}, callMt)

---@class AbilityFactoryIntelligenceBonusPlus3
---@overload fun(data: AbilityRow<AbilityDefinitionIntelligenceBonusPlus3>?): AbilityRow<AbilityDefinitionIntelligenceBonusPlus3>
---@field apply fun(fn: fun(a: AbilityDefinitionIntelligenceBonusPlus3)): fun(a: AbilityDefinitionIntelligenceBonusPlus3)

---@type AbilityFactoryIntelligenceBonusPlus3
A.intelligenceBonusPlus3 = setmetatable({
    parent = AbilityIds.intelligenceBonusPlus3,
    apply = identity,
}, callMt)

---@class AbilityFactoryIntelligenceBonusPlus4
---@overload fun(data: AbilityRow<AbilityDefinitionIntelligenceBonusPlus4>?): AbilityRow<AbilityDefinitionIntelligenceBonusPlus4>
---@field apply fun(fn: fun(a: AbilityDefinitionIntelligenceBonusPlus4)): fun(a: AbilityDefinitionIntelligenceBonusPlus4)

---@type AbilityFactoryIntelligenceBonusPlus4
A.intelligenceBonusPlus4 = setmetatable({
    parent = AbilityIds.intelligenceBonusPlus4,
    apply = identity,
}, callMt)

---@class AbilityFactoryIntelligenceBonusPlus6
---@overload fun(data: AbilityRow<AbilityDefinitionIntelligenceBonusPlus6>?): AbilityRow<AbilityDefinitionIntelligenceBonusPlus6>
---@field apply fun(fn: fun(a: AbilityDefinitionIntelligenceBonusPlus6)): fun(a: AbilityDefinitionIntelligenceBonusPlus6)

---@type AbilityFactoryIntelligenceBonusPlus6
A.intelligenceBonusPlus6 = setmetatable({
    parent = AbilityIds.intelligenceBonusPlus6,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemIllusions
---@overload fun(data: AbilityRow<AbilityDefinitionItemIllusion>?): AbilityRow<AbilityDefinitionItemIllusion>
---@field apply fun(fn: fun(a: AbilityDefinitionItemIllusion)): fun(a: AbilityDefinitionItemIllusion)

---@type AbilityFactoryItemIllusions
A.itemIllusions = setmetatable({
    parent = AbilityIds.itemIllusions,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemIntelligenceGain
---@overload fun(data: AbilityRow<AbilityDefinitionIntelligenceMod>?): AbilityRow<AbilityDefinitionIntelligenceMod>
---@field apply fun(fn: fun(a: AbilityDefinitionIntelligenceMod)): fun(a: AbilityDefinitionIntelligenceMod)

---@type AbilityFactoryItemIntelligenceGain
A.itemIntelligenceGain = setmetatable({
    parent = AbilityIds.itemIntelligenceGain,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemInferno
---@overload fun(data: AbilityRow<AbilityDefinitionItemInferno>?): AbilityRow<AbilityDefinitionItemInferno>
---@field apply fun(fn: fun(a: AbilityDefinitionItemInferno)): fun(a: AbilityDefinitionItemInferno)

---@type AbilityFactoryItemInferno
A.itemInferno = setmetatable({
    parent = AbilityIds.itemInferno,
    apply = identity,
}, callMt)

---@class AbilityFactoryFigurineIceRevenant
---@overload fun(data: AbilityRow<AbilityDefinitionFigurineIceRevenant>?): AbilityRow<AbilityDefinitionFigurineIceRevenant>
---@field apply fun(fn: fun(a: AbilityDefinitionFigurineIceRevenant)): fun(a: AbilityDefinitionFigurineIceRevenant)

---@type AbilityFactoryFigurineIceRevenant
A.figurineIceRevenant = setmetatable({
    parent = AbilityIds.figurineIceRevenant,
    apply = identity,
}, callMt)

---@class AbilityFactoryMaxLifeBonusLesser
---@overload fun(data: AbilityRow<AbilityDefinitionMaxLifeBonusLesser>?): AbilityRow<AbilityDefinitionMaxLifeBonusLesser>
---@field apply fun(fn: fun(a: AbilityDefinitionMaxLifeBonusLesser)): fun(a: AbilityDefinitionMaxLifeBonusLesser)

---@type AbilityFactoryMaxLifeBonusLesser
A.maxLifeBonusLesser = setmetatable({
    parent = AbilityIds.maxLifeBonusLesser,
    apply = identity,
}, callMt)

---@class AbilityFactoryMaxLifeBonusGreater
---@overload fun(data: AbilityRow<AbilityDefinitionMaxLifeBonusGreater>?): AbilityRow<AbilityDefinitionMaxLifeBonusGreater>
---@field apply fun(fn: fun(a: AbilityDefinitionMaxLifeBonusGreater)): fun(a: AbilityDefinitionMaxLifeBonusGreater)

---@type AbilityFactoryMaxLifeBonusGreater
A.maxLifeBonusGreater = setmetatable({
    parent = AbilityIds.maxLifeBonusGreater,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAttackLightningBonus
---@overload fun(data: AbilityRow<AbilityDefinitionLightningDamageBonus>?): AbilityRow<AbilityDefinitionLightningDamageBonus>
---@field apply fun(fn: fun(a: AbilityDefinitionLightningDamageBonus)): fun(a: AbilityDefinitionLightningDamageBonus)

---@type AbilityFactoryItemAttackLightningBonus
A.itemAttackLightningBonus = setmetatable({
    parent = AbilityIds.itemAttackLightningBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryMaxLifeBonusLeast
---@overload fun(data: AbilityRow<AbilityDefinitionMaxLifeBonusLeast>?): AbilityRow<AbilityDefinitionMaxLifeBonusLeast>
---@field apply fun(fn: fun(a: AbilityDefinitionMaxLifeBonusLeast)): fun(a: AbilityDefinitionMaxLifeBonusLeast)

---@type AbilityFactoryMaxLifeBonusLeast
A.maxLifeBonusLeast = setmetatable({
    parent = AbilityIds.maxLifeBonusLeast,
    apply = identity,
}, callMt)

---@class AbilityFactoryOrbofLightning
---@overload fun(data: AbilityRow<AbilityDefinitionOrbofLightning>?): AbilityRow<AbilityDefinitionOrbofLightning>
---@field apply fun(fn: fun(a: AbilityDefinitionOrbofLightning)): fun(a: AbilityDefinitionOrbofLightning)

---@type AbilityFactoryOrbofLightning
A.orbofLightning = setmetatable({
    parent = AbilityIds.orbofLightning,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemLevelGain
---@overload fun(data: AbilityRow<AbilityDefinitionLevelMod>?): AbilityRow<AbilityDefinitionLevelMod>
---@field apply fun(fn: fun(a: AbilityDefinitionLevelMod)): fun(a: AbilityDefinitionLevelMod)

---@type AbilityFactoryItemLevelGain
A.itemLevelGain = setmetatable({
    parent = AbilityIds.itemLevelGain,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemPurge
---@overload fun(data: AbilityRow<AbilityDefinitionLightningPurge>?): AbilityRow<AbilityDefinitionLightningPurge>
---@field apply fun(fn: fun(a: AbilityDefinitionLightningPurge)): fun(a: AbilityDefinitionLightningPurge)

---@type AbilityFactoryItemPurge
A.itemPurge = setmetatable({
    parent = AbilityIds.itemPurge,
    apply = identity,
}, callMt)

---@class AbilityFactoryLightningShieldAIls
---@overload fun(data: AbilityRow<AbilityDefinitionLightningShieldAIls>?): AbilityRow<AbilityDefinitionLightningShieldAIls>
---@field apply fun(fn: fun(a: AbilityDefinitionLightningShieldAIls)): fun(a: AbilityDefinitionLightningShieldAIls)

---@type AbilityFactoryLightningShieldAIls
A.lightningShieldAIls = setmetatable({
    parent = AbilityIds.lightningShieldAIls,
    apply = identity,
}, callMt)

---@class AbilityFactoryGiveLumber
---@overload fun(data: AbilityRow<AbilityDefinitionGiveLumber>?): AbilityRow<AbilityDefinitionGiveLumber>
---@field apply fun(fn: fun(a: AbilityDefinitionGiveLumber)): fun(a: AbilityDefinitionGiveLumber)

---@type AbilityFactoryGiveLumber
A.giveLumber = setmetatable({
    parent = AbilityIds.giveLumber,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemManaRestoreLesser
---@overload fun(data: AbilityRow<AbilityDefinitionItemManaRestoreLesser>?): AbilityRow<AbilityDefinitionItemManaRestoreLesser>
---@field apply fun(fn: fun(a: AbilityDefinitionItemManaRestoreLesser)): fun(a: AbilityDefinitionItemManaRestoreLesser)

---@type AbilityFactoryItemManaRestoreLesser
A.itemManaRestoreLesser = setmetatable({
    parent = AbilityIds.itemManaRestoreLesser,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemManaRestoreGreater
---@overload fun(data: AbilityRow<AbilityDefinitionItemManaRestoreGreater>?): AbilityRow<AbilityDefinitionItemManaRestoreGreater>
---@field apply fun(fn: fun(a: AbilityDefinitionItemManaRestoreGreater)): fun(a: AbilityDefinitionItemManaRestoreGreater)

---@type AbilityFactoryItemManaRestoreGreater
A.itemManaRestoreGreater = setmetatable({
    parent = AbilityIds.itemManaRestoreGreater,
    apply = identity,
}, callMt)

---@class AbilityFactoryMaxManaBonusLeast
---@overload fun(data: AbilityRow<AbilityDefinitionMaxManaBonusLeast>?): AbilityRow<AbilityDefinitionMaxManaBonusLeast>
---@field apply fun(fn: fun(a: AbilityDefinitionMaxManaBonusLeast)): fun(a: AbilityDefinitionMaxManaBonusLeast)

---@type AbilityFactoryMaxManaBonusLeast
A.maxManaBonusLeast = setmetatable({
    parent = AbilityIds.maxManaBonusLeast,
    apply = identity,
}, callMt)

---@class AbilityFactoryPermanentHitpointBonusfromchargeditem
---@overload fun(data: AbilityRow<AbilityDefinitionPermanentHitpointBonusfromchargeditem>?): AbilityRow<AbilityDefinitionPermanentHitpointBonusfromchargeditem>
---@field apply fun(fn: fun(a: AbilityDefinitionPermanentHitpointBonusfromchargeditem)): fun(a: AbilityDefinitionPermanentHitpointBonusfromchargeditem)

---@type AbilityFactoryPermanentHitpointBonusfromchargeditem
A.permanentHitpointBonusfromchargeditem = setmetatable({
    parent = AbilityIds.permanentHitpointBonusfromchargeditem,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemLifeGain
---@overload fun(data: AbilityRow<AbilityDefinitionAImi>?): AbilityRow<AbilityDefinitionAImi>
---@field apply fun(fn: fun(a: AbilityDefinitionAImi)): fun(a: AbilityDefinitionAImi)

---@type AbilityFactoryItemLifeGain
A.itemLifeGain = setmetatable({
    parent = AbilityIds.itemLifeGain,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemLifeBonus
---@overload fun(data: AbilityRow<AbilityDefinitionAIml>?): AbilityRow<AbilityDefinitionAIml>
---@field apply fun(fn: fun(a: AbilityDefinitionAIml)): fun(a: AbilityDefinitionAIml)

---@type AbilityFactoryItemLifeBonus
A.itemLifeBonus = setmetatable({
    parent = AbilityIds.itemLifeBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemManaBonus
---@overload fun(data: AbilityRow<AbilityDefinitionAImm>?): AbilityRow<AbilityDefinitionAImm>
---@field apply fun(fn: fun(a: AbilityDefinitionAImm)): fun(a: AbilityDefinitionAImm)

---@type AbilityFactoryItemManaBonus
A.itemManaBonus = setmetatable({
    parent = AbilityIds.itemManaBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemMonsterLure
---@overload fun(data: AbilityRow<AbilityDefinitionItemMonsterLure>?): AbilityRow<AbilityDefinitionItemMonsterLure>
---@field apply fun(fn: fun(a: AbilityDefinitionItemMonsterLure)): fun(a: AbilityDefinitionItemMonsterLure)

---@type AbilityFactoryItemMonsterLure
A.itemMonsterLure = setmetatable({
    parent = AbilityIds.itemMonsterLure,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAreaManaRegain
---@overload fun(data: AbilityRow<AbilityDefinitionItemManaRestoreAoe>?): AbilityRow<AbilityDefinitionItemManaRestoreAoe>
---@field apply fun(fn: fun(a: AbilityDefinitionItemManaRestoreAoe)): fun(a: AbilityDefinitionItemManaRestoreAoe)

---@type AbilityFactoryItemAreaManaRegain
A.itemAreaManaRegain = setmetatable({
    parent = AbilityIds.itemAreaManaRegain,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemMoveSpeedBonus
---@overload fun(data: AbilityRow<AbilityDefinitionMoveSpeedBonus>?): AbilityRow<AbilityDefinitionMoveSpeedBonus>
---@field apply fun(fn: fun(a: AbilityDefinitionMoveSpeedBonus)): fun(a: AbilityDefinitionMoveSpeedBonus)

---@type AbilityFactoryItemMoveSpeedBonus
A.itemMoveSpeedBonus = setmetatable({
    parent = AbilityIds.itemMoveSpeedBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryStaffoTeleportation
---@overload fun(data: AbilityRow<AbilityDefinitionStaffoTeleportation>?): AbilityRow<AbilityDefinitionStaffoTeleportation>
---@field apply fun(fn: fun(a: AbilityDefinitionStaffoTeleportation)): fun(a: AbilityDefinitionStaffoTeleportation)

---@type AbilityFactoryStaffoTeleportation
A.staffoTeleportation = setmetatable({
    parent = AbilityIds.staffoTeleportation,
    apply = identity,
}, callMt)

---@class AbilityFactoryMagicImmunityAImx
---@overload fun(data: AbilityRow<AbilityDefinitionMagicImmunityAImx>?): AbilityRow<AbilityDefinitionMagicImmunityAImx>
---@field apply fun(fn: fun(a: AbilityDefinitionMagicImmunityAImx)): fun(a: AbilityDefinitionMagicImmunityAImx)

---@type AbilityFactoryMagicImmunityAImx
A.magicImmunityAImx = setmetatable({
    parent = AbilityIds.magicImmunityAImx,
    apply = identity,
}, callMt)

---@class AbilityFactoryAnimateDeaditemspecial
---@overload fun(data: AbilityRow<AbilityDefinitionAnimateDeaditemspecial>?): AbilityRow<AbilityDefinitionAnimateDeaditemspecial>
---@field apply fun(fn: fun(a: AbilityDefinitionAnimateDeaditemspecial)): fun(a: AbilityDefinitionAnimateDeaditemspecial)

---@type AbilityFactoryAnimateDeaditemspecial
A.animateDeaditemspecial = setmetatable({
    parent = AbilityIds.animateDeaditemspecial,
    apply = identity,
}, callMt)

---@class AbilityFactoryStrengthModPlus2
---@overload fun(data: AbilityRow<AbilityDefinitionStrengthModPlus2>?): AbilityRow<AbilityDefinitionStrengthModPlus2>
---@field apply fun(fn: fun(a: AbilityDefinitionStrengthModPlus2)): fun(a: AbilityDefinitionStrengthModPlus2)

---@type AbilityFactoryStrengthModPlus2
A.strengthModPlus2 = setmetatable({
    parent = AbilityIds.strengthModPlus2,
    apply = identity,
}, callMt)

---@class AbilityFactoryInventory
---@overload fun(data: AbilityRow<AbilityDefinitionInventory>?): AbilityRow<AbilityDefinitionInventory>
---@field apply fun(fn: fun(a: AbilityDefinitionInventory)): fun(a: AbilityDefinitionInventory)

---@type AbilityFactoryInventory
A.inventory = setmetatable({
    parent = AbilityIds.inventory,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAttackFrostBonus
---@overload fun(data: AbilityRow<AbilityDefinitionFrostDamageBonus>?): AbilityRow<AbilityDefinitionFrostDamageBonus>
---@field apply fun(fn: fun(a: AbilityDefinitionFrostDamageBonus)): fun(a: AbilityDefinitionFrostDamageBonus)

---@type AbilityFactoryItemAttackFrostBonus
A.itemAttackFrostBonus = setmetatable({
    parent = AbilityIds.itemAttackFrostBonus,
    apply = identity,
}, callMt)

---@class AbilityFactorySlowAIos
---@overload fun(data: AbilityRow<AbilityDefinitionSlowAIos>?): AbilityRow<AbilityDefinitionSlowAIos>
---@field apply fun(fn: fun(a: AbilityDefinitionSlowAIos)): fun(a: AbilityDefinitionSlowAIos)

---@type AbilityFactorySlowAIos
A.slowAIos = setmetatable({
    parent = AbilityIds.slowAIos,
    apply = identity,
}, callMt)

---@class AbilityFactoryPotionofRejuvI
---@overload fun(data: AbilityRow<AbilityDefinitionPotionofRejuvI>?): AbilityRow<AbilityDefinitionPotionofRejuvI>
---@field apply fun(fn: fun(a: AbilityDefinitionPotionofRejuvI)): fun(a: AbilityDefinitionPotionofRejuvI)

---@type AbilityFactoryPotionofRejuvI
A.potionofRejuvI = setmetatable({
    parent = AbilityIds.potionofRejuvI,
    apply = identity,
}, callMt)

---@class AbilityFactoryPotionofRejuvII
---@overload fun(data: AbilityRow<AbilityDefinitionPotionofRejuvII>?): AbilityRow<AbilityDefinitionPotionofRejuvII>
---@field apply fun(fn: fun(a: AbilityDefinitionPotionofRejuvII)): fun(a: AbilityDefinitionPotionofRejuvII)

---@type AbilityFactoryPotionofRejuvII
A.potionofRejuvII = setmetatable({
    parent = AbilityIds.potionofRejuvII,
    apply = identity,
}, callMt)

---@class AbilityFactoryPotionofRejuvIII
---@overload fun(data: AbilityRow<AbilityDefinitionPotionofRejuvIII>?): AbilityRow<AbilityDefinitionPotionofRejuvIII>
---@field apply fun(fn: fun(a: AbilityDefinitionPotionofRejuvIII)): fun(a: AbilityDefinitionPotionofRejuvIII)

---@type AbilityFactoryPotionofRejuvIII
A.potionofRejuvIII = setmetatable({
    parent = AbilityIds.potionofRejuvIII,
    apply = identity,
}, callMt)

---@class AbilityFactoryPotionofRejuvIV
---@overload fun(data: AbilityRow<AbilityDefinitionPotionofRejuvIV>?): AbilityRow<AbilityDefinitionPotionofRejuvIV>
---@field apply fun(fn: fun(a: AbilityDefinitionPotionofRejuvIV)): fun(a: AbilityDefinitionPotionofRejuvIV)

---@type AbilityFactoryPotionofRejuvIV
A.potionofRejuvIV = setmetatable({
    parent = AbilityIds.potionofRejuvIV,
    apply = identity,
}, callMt)

---@class AbilityFactoryScrollofRejuvI
---@overload fun(data: AbilityRow<AbilityDefinitionScrollofRejuvI>?): AbilityRow<AbilityDefinitionScrollofRejuvI>
---@field apply fun(fn: fun(a: AbilityDefinitionScrollofRejuvI)): fun(a: AbilityDefinitionScrollofRejuvI)

---@type AbilityFactoryScrollofRejuvI
A.scrollofRejuvI = setmetatable({
    parent = AbilityIds.scrollofRejuvI,
    apply = identity,
}, callMt)

---@class AbilityFactoryScrollofRejuvII
---@overload fun(data: AbilityRow<AbilityDefinitionScrollofRejuvII>?): AbilityRow<AbilityDefinitionScrollofRejuvII>
---@field apply fun(fn: fun(a: AbilityDefinitionScrollofRejuvII)): fun(a: AbilityDefinitionScrollofRejuvII)

---@type AbilityFactoryScrollofRejuvII
A.scrollofRejuvII = setmetatable({
    parent = AbilityIds.scrollofRejuvII,
    apply = identity,
}, callMt)

---@class AbilityFactoryOrbofVenom
---@overload fun(data: AbilityRow<AbilityDefinitionOrbofVenom>?): AbilityRow<AbilityDefinitionOrbofVenom>
---@field apply fun(fn: fun(a: AbilityDefinitionOrbofVenom)): fun(a: AbilityDefinitionOrbofVenom)

---@type AbilityFactoryOrbofVenom
A.orbofVenom = setmetatable({
    parent = AbilityIds.orbofVenom,
    apply = identity,
}, callMt)

---@class AbilityFactoryPurgeorb
---@overload fun(data: AbilityRow<AbilityDefinitionPurgeorb>?): AbilityRow<AbilityDefinitionPurgeorb>
---@field apply fun(fn: fun(a: AbilityDefinitionPurgeorb)): fun(a: AbilityDefinitionPurgeorb)

---@type AbilityFactoryPurgeorb
A.purgeorb = setmetatable({
    parent = AbilityIds.purgeorb,
    apply = identity,
}, callMt)

---@class AbilityFactoryPotionofManaRegenlesser
---@overload fun(data: AbilityRow<AbilityDefinitionPotionofManaRegenlesser>?): AbilityRow<AbilityDefinitionPotionofManaRegenlesser>
---@field apply fun(fn: fun(a: AbilityDefinitionPotionofManaRegenlesser)): fun(a: AbilityDefinitionPotionofManaRegenlesser)

---@type AbilityFactoryPotionofManaRegenlesser
A.potionofManaRegenlesser = setmetatable({
    parent = AbilityIds.potionofManaRegenlesser,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemPlaceGoblinLandMine
---@overload fun(data: AbilityRow<AbilityDefinitionItemPlaceMine>?): AbilityRow<AbilityDefinitionItemPlaceMine>
---@field apply fun(fn: fun(a: AbilityDefinitionItemPlaceMine)): fun(a: AbilityDefinitionItemPlaceMine)

---@type AbilityFactoryItemPlaceGoblinLandMine
A.itemPlaceGoblinLandMine = setmetatable({
    parent = AbilityIds.itemPlaceGoblinLandMine,
    apply = identity,
}, callMt)

---@class AbilityFactoryPotionofManaRegengreater
---@overload fun(data: AbilityRow<AbilityDefinitionPotionofManaRegengreater>?): AbilityRow<AbilityDefinitionPotionofManaRegengreater>
---@field apply fun(fn: fun(a: AbilityDefinitionPotionofManaRegengreater)): fun(a: AbilityDefinitionPotionofManaRegengreater)

---@type AbilityFactoryPotionofManaRegengreater
A.potionofManaRegengreater = setmetatable({
    parent = AbilityIds.potionofManaRegengreater,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemPotionVampirism
---@overload fun(data: AbilityRow<AbilityDefinitionItemPotionVampirism>?): AbilityRow<AbilityDefinitionItemPotionVampirism>
---@field apply fun(fn: fun(a: AbilityDefinitionItemPotionVampirism)): fun(a: AbilityDefinitionItemPotionVampirism)

---@type AbilityFactoryItemPotionVampirism
A.itemPotionVampirism = setmetatable({
    parent = AbilityIds.itemPotionVampirism,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAreaHealManaRegain
---@overload fun(data: AbilityRow<AbilityDefinitionItemRestoreAoe>?): AbilityRow<AbilityDefinitionItemRestoreAoe>
---@field apply fun(fn: fun(a: AbilityDefinitionItemRestoreAoe)): fun(a: AbilityDefinitionItemRestoreAoe)

---@type AbilityFactoryItemAreaHealManaRegain
A.itemAreaHealManaRegain = setmetatable({
    parent = AbilityIds.itemAreaHealManaRegain,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemReincarnation
---@overload fun(data: AbilityRow<AbilityDefinitionItemReincarnation>?): AbilityRow<AbilityDefinitionItemReincarnation>
---@field apply fun(fn: fun(a: AbilityDefinitionItemReincarnation)): fun(a: AbilityDefinitionItemReincarnation)

---@type AbilityFactoryItemReincarnation
A.itemReincarnation = setmetatable({
    parent = AbilityIds.itemReincarnation,
    apply = identity,
}, callMt)

---@class AbilityFactoryRaiseDeadItem
---@overload fun(data: AbilityRow<AbilityDefinitionRaiseDeadItem>?): AbilityRow<AbilityDefinitionRaiseDeadItem>
---@field apply fun(fn: fun(a: AbilityDefinitionRaiseDeadItem)): fun(a: AbilityDefinitionRaiseDeadItem)

---@type AbilityFactoryRaiseDeadItem
A.raiseDeadItem = setmetatable({
    parent = AbilityIds.raiseDeadItem,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemHealManaRegain
---@overload fun(data: AbilityRow<AbilityDefinitionItemRestore>?): AbilityRow<AbilityDefinitionItemRestore>
---@field apply fun(fn: fun(a: AbilityDefinitionItemRestore)): fun(a: AbilityDefinitionItemRestore)

---@type AbilityFactoryItemHealManaRegain
A.itemHealManaRegain = setmetatable({
    parent = AbilityIds.itemHealManaRegain,
    apply = identity,
}, callMt)

---@class AbilityFactoryPotionofLifeRegen
---@overload fun(data: AbilityRow<AbilityDefinitionPotionofLifeRegen>?): AbilityRow<AbilityDefinitionPotionofLifeRegen>
---@field apply fun(fn: fun(a: AbilityDefinitionPotionofLifeRegen)): fun(a: AbilityDefinitionPotionofLifeRegen)

---@type AbilityFactoryPotionofLifeRegen
A.potionofLifeRegen = setmetatable({
    parent = AbilityIds.potionofLifeRegen,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemManaRegeneration
---@overload fun(data: AbilityRow<AbilityDefinitionItemRegenMana>?): AbilityRow<AbilityDefinitionItemRegenMana>
---@field apply fun(fn: fun(a: AbilityDefinitionItemRegenMana)): fun(a: AbilityDefinitionItemRegenMana)

---@type AbilityFactoryItemManaRegeneration
A.itemManaRegeneration = setmetatable({
    parent = AbilityIds.itemManaRegeneration,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemRegenManalesser
---@overload fun(data: AbilityRow<AbilityDefinitionItemRegenManalesser>?): AbilityRow<AbilityDefinitionItemRegenManalesser>
---@field apply fun(fn: fun(a: AbilityDefinitionItemRegenManalesser)): fun(a: AbilityDefinitionItemRegenManalesser)

---@type AbilityFactoryItemRegenManalesser
A.itemRegenManalesser = setmetatable({
    parent = AbilityIds.itemRegenManalesser,
    apply = identity,
}, callMt)

---@class AbilityFactoryRoarAIrr
---@overload fun(data: AbilityRow<AbilityDefinitionRoarAIrr>?): AbilityRow<AbilityDefinitionRoarAIrr>
---@field apply fun(fn: fun(a: AbilityDefinitionRoarAIrr)): fun(a: AbilityDefinitionRoarAIrr)

---@type AbilityFactoryRoarAIrr
A.roarAIrr = setmetatable({
    parent = AbilityIds.roarAIrr,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemResurrection
---@overload fun(data: AbilityRow<AbilityDefinitionResurrection>?): AbilityRow<AbilityDefinitionResurrection>
---@field apply fun(fn: fun(a: AbilityDefinitionResurrection)): fun(a: AbilityDefinitionResurrection)

---@type AbilityFactoryItemResurrection
A.itemResurrection = setmetatable({
    parent = AbilityIds.itemResurrection,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemRecall
---@overload fun(data: AbilityRow<AbilityDefinitionItemRecall>?): AbilityRow<AbilityDefinitionItemRecall>
---@field apply fun(fn: fun(a: AbilityDefinitionItemRecall)): fun(a: AbilityDefinitionItemRecall)

---@type AbilityFactoryItemRecall
A.itemRecall = setmetatable({
    parent = AbilityIds.itemRecall,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemRevealMap
---@overload fun(data: AbilityRow<AbilityDefinitionItemRevealMap>?): AbilityRow<AbilityDefinitionItemRevealMap>
---@field apply fun(fn: fun(a: AbilityDefinitionItemRevealMap)): fun(a: AbilityDefinitionItemRevealMap)

---@type AbilityFactoryItemRevealMap
A.itemRevealMap = setmetatable({
    parent = AbilityIds.itemRevealMap,
    apply = identity,
}, callMt)

---@class AbilityFactoryStrengthBonusPlus1
---@overload fun(data: AbilityRow<AbilityDefinitionStrengthBonusPlus1>?): AbilityRow<AbilityDefinitionStrengthBonusPlus1>
---@field apply fun(fn: fun(a: AbilityDefinitionStrengthBonusPlus1)): fun(a: AbilityDefinitionStrengthBonusPlus1)

---@type AbilityFactoryStrengthBonusPlus1
A.strengthBonusPlus1 = setmetatable({
    parent = AbilityIds.strengthBonusPlus1,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackSpeedIncreaseGreater
---@overload fun(data: AbilityRow<AbilityDefinitionAttackSpeedIncreaseGreater>?): AbilityRow<AbilityDefinitionAttackSpeedIncreaseGreater>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackSpeedIncreaseGreater)): fun(a: AbilityDefinitionAttackSpeedIncreaseGreater)

---@type AbilityFactoryAttackSpeedIncreaseGreater
A.attackSpeedIncreaseGreater = setmetatable({
    parent = AbilityIds.attackSpeedIncreaseGreater,
    apply = identity,
}, callMt)

---@class AbilityFactoryStrengthBonusPlus3
---@overload fun(data: AbilityRow<AbilityDefinitionStrengthBonusPlus3>?): AbilityRow<AbilityDefinitionStrengthBonusPlus3>
---@field apply fun(fn: fun(a: AbilityDefinitionStrengthBonusPlus3)): fun(a: AbilityDefinitionStrengthBonusPlus3)

---@type AbilityFactoryStrengthBonusPlus3
A.strengthBonusPlus3 = setmetatable({
    parent = AbilityIds.strengthBonusPlus3,
    apply = identity,
}, callMt)

---@class AbilityFactoryStrengthBonusPlus4
---@overload fun(data: AbilityRow<AbilityDefinitionStrengthBonusPlus4>?): AbilityRow<AbilityDefinitionStrengthBonusPlus4>
---@field apply fun(fn: fun(a: AbilityDefinitionStrengthBonusPlus4)): fun(a: AbilityDefinitionStrengthBonusPlus4)

---@type AbilityFactoryStrengthBonusPlus4
A.strengthBonusPlus4 = setmetatable({
    parent = AbilityIds.strengthBonusPlus4,
    apply = identity,
}, callMt)

---@class AbilityFactoryStrengthBonusPlus6
---@overload fun(data: AbilityRow<AbilityDefinitionStrengthBonusPlus6>?): AbilityRow<AbilityDefinitionStrengthBonusPlus6>
---@field apply fun(fn: fun(a: AbilityDefinitionStrengthBonusPlus6)): fun(a: AbilityDefinitionStrengthBonusPlus6)

---@type AbilityFactoryStrengthBonusPlus6
A.strengthBonusPlus6 = setmetatable({
    parent = AbilityIds.strengthBonusPlus6,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemSpeedAoe
---@overload fun(data: AbilityRow<AbilityDefinitionItemSpeedAoe>?): AbilityRow<AbilityDefinitionItemSpeedAoe>
---@field apply fun(fn: fun(a: AbilityDefinitionItemSpeedAoe)): fun(a: AbilityDefinitionItemSpeedAoe)

---@type AbilityFactoryItemSpeedAoe
A.itemSpeedAoe = setmetatable({
    parent = AbilityIds.itemSpeedAoe,
    apply = identity,
}, callMt)

---@class AbilityFactoryOrbofSpells
---@overload fun(data: AbilityRow<AbilityDefinitionOrbofSpells>?): AbilityRow<AbilityDefinitionOrbofSpells>
---@field apply fun(fn: fun(a: AbilityDefinitionOrbofSpells)): fun(a: AbilityDefinitionOrbofSpells)

---@type AbilityFactoryOrbofSpells
A.orbofSpells = setmetatable({
    parent = AbilityIds.orbofSpells,
    apply = identity,
}, callMt)

---@class AbilityFactorySilenceItem
---@overload fun(data: AbilityRow<AbilityDefinitionSilenceItem>?): AbilityRow<AbilityDefinitionSilenceItem>
---@field apply fun(fn: fun(a: AbilityDefinitionSilenceItem)): fun(a: AbilityDefinitionSilenceItem)

---@type AbilityFactorySilenceItem
A.silenceItem = setmetatable({
    parent = AbilityIds.silenceItem,
    apply = identity,
}, callMt)

---@class AbilityFactorySummonHeadhunteritem
---@overload fun(data: AbilityRow<AbilityDefinitionSummonHeadhunteritem>?): AbilityRow<AbilityDefinitionSummonHeadhunteritem>
---@field apply fun(fn: fun(a: AbilityDefinitionSummonHeadhunteritem)): fun(a: AbilityDefinitionSummonHeadhunteritem)

---@type AbilityFactorySummonHeadhunteritem
A.summonHeadhunteritem = setmetatable({
    parent = AbilityIds.summonHeadhunteritem,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemSightRangeBonus
---@overload fun(data: AbilityRow<AbilityDefinitionSightBonus>?): AbilityRow<AbilityDefinitionSightBonus>
---@field apply fun(fn: fun(a: AbilityDefinitionSightBonus)): fun(a: AbilityDefinitionSightBonus)

---@type AbilityFactoryItemSightRangeBonus
A.itemSightRangeBonus = setmetatable({
    parent = AbilityIds.itemSightRangeBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryScrollofLifeRegen
---@overload fun(data: AbilityRow<AbilityDefinitionScrollofLifeRegen>?): AbilityRow<AbilityDefinitionScrollofLifeRegen>
---@field apply fun(fn: fun(a: AbilityDefinitionScrollofLifeRegen)): fun(a: AbilityDefinitionScrollofLifeRegen)

---@type AbilityFactoryScrollofLifeRegen
A.scrollofLifeRegen = setmetatable({
    parent = AbilityIds.scrollofLifeRegen,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemStrengthGain
---@overload fun(data: AbilityRow<AbilityDefinitionStrengthMod>?): AbilityRow<AbilityDefinitionStrengthMod>
---@field apply fun(fn: fun(a: AbilityDefinitionStrengthMod)): fun(a: AbilityDefinitionStrengthMod)

---@type AbilityFactoryItemStrengthGain
A.itemStrengthGain = setmetatable({
    parent = AbilityIds.itemStrengthGain,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemTemporarySpeedBonus
---@overload fun(data: AbilityRow<AbilityDefinitionItemSpeed>?): AbilityRow<AbilityDefinitionItemSpeed>
---@field apply fun(fn: fun(a: AbilityDefinitionItemSpeed)): fun(a: AbilityDefinitionItemSpeed)

---@type AbilityFactoryItemTemporarySpeedBonus
A.itemTemporarySpeedBonus = setmetatable({
    parent = AbilityIds.itemTemporarySpeedBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryRunedBracers
---@overload fun(data: AbilityRow<AbilityDefinitionRunedBracers>?): AbilityRow<AbilityDefinitionRunedBracers>
---@field apply fun(fn: fun(a: AbilityDefinitionRunedBracers)): fun(a: AbilityDefinitionRunedBracers)

---@type AbilityFactoryRunedBracers
A.runedBracers = setmetatable({
    parent = AbilityIds.runedBracers,
    apply = identity,
}, callMt)

---@class AbilityFactorySentryWardAIsw
---@overload fun(data: AbilityRow<AbilityDefinitionSentryWardAIsw>?): AbilityRow<AbilityDefinitionSentryWardAIsw>
---@field apply fun(fn: fun(a: AbilityDefinitionSentryWardAIsw)): fun(a: AbilityDefinitionSentryWardAIsw)

---@type AbilityFactorySentryWardAIsw
A.sentryWardAIsw = setmetatable({
    parent = AbilityIds.sentryWardAIsw,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackSpeedIncrease
---@overload fun(data: AbilityRow<AbilityDefinitionAttackSpeedIncrease>?): AbilityRow<AbilityDefinitionAttackSpeedIncrease>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackSpeedIncrease)): fun(a: AbilityDefinitionAttackSpeedIncrease)

---@type AbilityFactoryAttackSpeedIncrease
A.attackSpeedIncrease = setmetatable({
    parent = AbilityIds.attackSpeedIncrease,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackBonusAIt6
---@overload fun(data: AbilityRow<AbilityDefinitionAttackBonusAIt6>?): AbilityRow<AbilityDefinitionAttackBonusAIt6>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackBonusAIt6)): fun(a: AbilityDefinitionAttackBonusAIt6)

---@type AbilityFactoryAttackBonusAIt6
A.attackBonusAIt6 = setmetatable({
    parent = AbilityIds.attackBonusAIt6,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackBonusAIt9
---@overload fun(data: AbilityRow<AbilityDefinitionAttackBonusAIt9>?): AbilityRow<AbilityDefinitionAttackBonusAIt9>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackBonusAIt9)): fun(a: AbilityDefinitionAttackBonusAIt9)

---@type AbilityFactoryAttackBonusAIt9
A.attackBonusAIt9 = setmetatable({
    parent = AbilityIds.attackBonusAIt9,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemAreaDetection
---@overload fun(data: AbilityRow<AbilityDefinitionItemDetectAoe>?): AbilityRow<AbilityDefinitionItemDetectAoe>
---@field apply fun(fn: fun(a: AbilityDefinitionItemDetectAoe)): fun(a: AbilityDefinitionItemDetectAoe)

---@type AbilityFactoryItemAreaDetection
A.itemAreaDetection = setmetatable({
    parent = AbilityIds.itemAreaDetection,
    apply = identity,
}, callMt)

---@class AbilityFactoryDustofAppearance
---@overload fun(data: AbilityRow<AbilityDefinitionDustofAppearance>?): AbilityRow<AbilityDefinitionDustofAppearance>
---@field apply fun(fn: fun(a: AbilityDefinitionDustofAppearance)): fun(a: AbilityDefinitionDustofAppearance)

---@type AbilityFactoryDustofAppearance
A.dustofAppearance = setmetatable({
    parent = AbilityIds.dustofAppearance,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackBonusAItc
---@overload fun(data: AbilityRow<AbilityDefinitionAttackBonusAItc>?): AbilityRow<AbilityDefinitionAttackBonusAItc>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackBonusAItc)): fun(a: AbilityDefinitionAttackBonusAItc)

---@type AbilityFactoryAttackBonusAItc
A.attackBonusAItc = setmetatable({
    parent = AbilityIds.attackBonusAItc,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackBonusAItf
---@overload fun(data: AbilityRow<AbilityDefinitionAttackBonusAItf>?): AbilityRow<AbilityDefinitionAttackBonusAItf>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackBonusAItf)): fun(a: AbilityDefinitionAttackBonusAItf)

---@type AbilityFactoryAttackBonusAItf
A.attackBonusAItf = setmetatable({
    parent = AbilityIds.attackBonusAItf,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackBonusPlus1
---@overload fun(data: AbilityRow<AbilityDefinitionAttackBonusPlus1>?): AbilityRow<AbilityDefinitionAttackBonusPlus1>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackBonusPlus1)): fun(a: AbilityDefinitionAttackBonusPlus1)

---@type AbilityFactoryAttackBonusPlus1
A.attackBonusPlus1 = setmetatable({
    parent = AbilityIds.attackBonusPlus1,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackBonusPlus2
---@overload fun(data: AbilityRow<AbilityDefinitionAttackBonusPlus2>?): AbilityRow<AbilityDefinitionAttackBonusPlus2>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackBonusPlus2)): fun(a: AbilityDefinitionAttackBonusPlus2)

---@type AbilityFactoryAttackBonusPlus2
A.attackBonusPlus2 = setmetatable({
    parent = AbilityIds.attackBonusPlus2,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackBonusPlus4
---@overload fun(data: AbilityRow<AbilityDefinitionAttackBonusPlus4>?): AbilityRow<AbilityDefinitionAttackBonusPlus4>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackBonusPlus4)): fun(a: AbilityDefinitionAttackBonusPlus4)

---@type AbilityFactoryAttackBonusPlus4
A.attackBonusPlus4 = setmetatable({
    parent = AbilityIds.attackBonusPlus4,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackBonusPlus5
---@overload fun(data: AbilityRow<AbilityDefinitionAttackBonusPlus5>?): AbilityRow<AbilityDefinitionAttackBonusPlus5>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackBonusPlus5)): fun(a: AbilityDefinitionAttackBonusPlus5)

---@type AbilityFactoryAttackBonusPlus5
A.attackBonusPlus5 = setmetatable({
    parent = AbilityIds.attackBonusPlus5,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackBonusPlus7
---@overload fun(data: AbilityRow<AbilityDefinitionAttackBonusPlus7>?): AbilityRow<AbilityDefinitionAttackBonusPlus7>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackBonusPlus7)): fun(a: AbilityDefinitionAttackBonusPlus7)

---@type AbilityFactoryAttackBonusPlus7
A.attackBonusPlus7 = setmetatable({
    parent = AbilityIds.attackBonusPlus7,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackBonusPlus8
---@overload fun(data: AbilityRow<AbilityDefinitionAttackBonusPlus8>?): AbilityRow<AbilityDefinitionAttackBonusPlus8>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackBonusPlus8)): fun(a: AbilityDefinitionAttackBonusPlus8)

---@type AbilityFactoryAttackBonusPlus8
A.attackBonusPlus8 = setmetatable({
    parent = AbilityIds.attackBonusPlus8,
    apply = identity,
}, callMt)

---@class AbilityFactoryIntelligenceModPlus2
---@overload fun(data: AbilityRow<AbilityDefinitionIntelligenceModPlus2>?): AbilityRow<AbilityDefinitionIntelligenceModPlus2>
---@field apply fun(fn: fun(a: AbilityDefinitionIntelligenceModPlus2)): fun(a: AbilityDefinitionIntelligenceModPlus2)

---@type AbilityFactoryIntelligenceModPlus2
A.intelligenceModPlus2 = setmetatable({
    parent = AbilityIds.intelligenceModPlus2,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttackBonusPlus10
---@overload fun(data: AbilityRow<AbilityDefinitionAttackBonusPlus10>?): AbilityRow<AbilityDefinitionAttackBonusPlus10>
---@field apply fun(fn: fun(a: AbilityDefinitionAttackBonusPlus10)): fun(a: AbilityDefinitionAttackBonusPlus10)

---@type AbilityFactoryAttackBonusPlus10
A.attackBonusPlus10 = setmetatable({
    parent = AbilityIds.attackBonusPlus10,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemTownPortal
---@overload fun(data: AbilityRow<AbilityDefinitionItemTownPortal>?): AbilityRow<AbilityDefinitionItemTownPortal>
---@field apply fun(fn: fun(a: AbilityDefinitionItemTownPortal)): fun(a: AbilityDefinitionItemTownPortal)

---@type AbilityFactoryItemTownPortal
A.itemTownPortal = setmetatable({
    parent = AbilityIds.itemTownPortal,
    apply = identity,
}, callMt)

---@class AbilityFactoryFigurineUrsaWarrior
---@overload fun(data: AbilityRow<AbilityDefinitionFigurineUrsaWarrior>?): AbilityRow<AbilityDefinitionFigurineUrsaWarrior>
---@field apply fun(fn: fun(a: AbilityDefinitionFigurineUrsaWarrior)): fun(a: AbilityDefinitionFigurineUrsaWarrior)

---@type AbilityFactoryFigurineUrsaWarrior
A.figurineUrsaWarrior = setmetatable({
    parent = AbilityIds.figurineUrsaWarrior,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemLifeSteal
---@overload fun(data: AbilityRow<AbilityDefinitionVampiricattackAIva>?): AbilityRow<AbilityDefinitionVampiricattackAIva>
---@field apply fun(fn: fun(a: AbilityDefinitionVampiricattackAIva)): fun(a: AbilityDefinitionVampiricattackAIva)

---@type AbilityFactoryItemLifeSteal
A.itemLifeSteal = setmetatable({
    parent = AbilityIds.itemLifeSteal,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemWeb
---@overload fun(data: AbilityRow<AbilityDefinitionItemWeb>?): AbilityRow<AbilityDefinitionItemWeb>
---@field apply fun(fn: fun(a: AbilityDefinitionItemWeb)): fun(a: AbilityDefinitionItemWeb)

---@type AbilityFactoryItemWeb
A.itemWeb = setmetatable({
    parent = AbilityIds.itemWeb,
    apply = identity,
}, callMt)

---@class AbilityFactoryAllPlus1
---@overload fun(data: AbilityRow<AbilityDefinitionAllPlus1>?): AbilityRow<AbilityDefinitionAllPlus1>
---@field apply fun(fn: fun(a: AbilityDefinitionAllPlus1)): fun(a: AbilityDefinitionAllPlus1)

---@type AbilityFactoryAllPlus1
A.allPlus1 = setmetatable({
    parent = AbilityIds.allPlus1,
    apply = identity,
}, callMt)

---@class AbilityFactoryAllPlus2
---@overload fun(data: AbilityRow<AbilityDefinitionAllPlus2>?): AbilityRow<AbilityDefinitionAllPlus2>
---@field apply fun(fn: fun(a: AbilityDefinitionAllPlus2)): fun(a: AbilityDefinitionAllPlus2)

---@type AbilityFactoryAllPlus2
A.allPlus2 = setmetatable({
    parent = AbilityIds.allPlus2,
    apply = identity,
}, callMt)

---@class AbilityFactoryAllPlus3
---@overload fun(data: AbilityRow<AbilityDefinitionAllPlus3>?): AbilityRow<AbilityDefinitionAllPlus3>
---@field apply fun(fn: fun(a: AbilityDefinitionAllPlus3)): fun(a: AbilityDefinitionAllPlus3)

---@type AbilityFactoryAllPlus3
A.allPlus3 = setmetatable({
    parent = AbilityIds.allPlus3,
    apply = identity,
}, callMt)

---@class AbilityFactoryCrownofKingsAllPlus5
---@overload fun(data: AbilityRow<AbilityDefinitionCrownofKingsAllPlus5>?): AbilityRow<AbilityDefinitionCrownofKingsAllPlus5>
---@field apply fun(fn: fun(a: AbilityDefinitionCrownofKingsAllPlus5)): fun(a: AbilityDefinitionCrownofKingsAllPlus5)

---@type AbilityFactoryCrownofKingsAllPlus5
A.crownofKingsAllPlus5 = setmetatable({
    parent = AbilityIds.crownofKingsAllPlus5,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemIntAgiStrgain
---@overload fun(data: AbilityRow<AbilityDefinitionPermanentAllPlus1>?): AbilityRow<AbilityDefinitionPermanentAllPlus1>
---@field apply fun(fn: fun(a: AbilityDefinitionPermanentAllPlus1)): fun(a: AbilityDefinitionPermanentAllPlus1)

---@type AbilityFactoryItemIntAgiStrgain
A.itemIntAgiStrgain = setmetatable({
    parent = AbilityIds.itemIntAgiStrgain,
    apply = identity,
}, callMt)

---@class AbilityFactoryAntimagicShieldAIxs
---@overload fun(data: AbilityRow<AbilityDefinitionAntimagicShieldAIxs>?): AbilityRow<AbilityDefinitionAntimagicShieldAIxs>
---@field apply fun(fn: fun(a: AbilityDefinitionAntimagicShieldAIxs)): fun(a: AbilityDefinitionAntimagicShieldAIxs)

---@type AbilityFactoryAntimagicShieldAIxs
A.antimagicShieldAIxs = setmetatable({
    parent = AbilityIds.antimagicShieldAIxs,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemFreezeDamageBonus
---@overload fun(data: AbilityRow<AbilityDefinitionFreezeDamageBonus>?): AbilityRow<AbilityDefinitionFreezeDamageBonus>
---@field apply fun(fn: fun(a: AbilityDefinitionFreezeDamageBonus)): fun(a: AbilityDefinitionFreezeDamageBonus)

---@type AbilityFactoryItemFreezeDamageBonus
A.itemFreezeDamageBonus = setmetatable({
    parent = AbilityIds.itemFreezeDamageBonus,
    apply = identity,
}, callMt)

---@class AbilityFactoryAcidBomb
---@overload fun(data: AbilityRow<AbilityDefinitionAlchemistAcidBomb>?): AbilityRow<AbilityDefinitionAlchemistAcidBomb>
---@field apply fun(fn: fun(a: AbilityDefinitionAlchemistAcidBomb)): fun(a: AbilityDefinitionAlchemistAcidBomb)

---@type AbilityFactoryAcidBomb
A.acidBomb = setmetatable({
    parent = AbilityIds.acidBomb,
    apply = identity,
}, callMt)

---@class AbilityFactoryBashmaulSPBearlevel3
---@overload fun(data: AbilityRow<AbilityDefinitionBashmaulSPBearlevel3>?): AbilityRow<AbilityDefinitionBashmaulSPBearlevel3>
---@field apply fun(fn: fun(a: AbilityDefinitionBashmaulSPBearlevel3)): fun(a: AbilityDefinitionBashmaulSPBearlevel3)

---@type AbilityFactoryBashmaulSPBearlevel3
A.bashmaulSPBearlevel3 = setmetatable({
    parent = AbilityIds.bashmaulSPBearlevel3,
    apply = identity,
}, callMt)

---@class AbilityFactoryDarkRangerBlackArrow
---@overload fun(data: AbilityRow<AbilityDefinitionDarkRangerBlackArrow>?): AbilityRow<AbilityDefinitionDarkRangerBlackArrow>
---@field apply fun(fn: fun(a: AbilityDefinitionDarkRangerBlackArrow)): fun(a: AbilityDefinitionDarkRangerBlackArrow)

---@type AbilityFactoryDarkRangerBlackArrow
A.darkRangerBlackArrow = setmetatable({
    parent = AbilityIds.darkRangerBlackArrow,
    apply = identity,
}, callMt)

---@class AbilityFactoryBrewmasterBreathofFire
---@overload fun(data: AbilityRow<AbilityDefinitionBrewmasterBreathofFire>?): AbilityRow<AbilityDefinitionBrewmasterBreathofFire>
---@field apply fun(fn: fun(a: AbilityDefinitionBrewmasterBreathofFire)): fun(a: AbilityDefinitionBrewmasterBreathofFire)

---@type AbilityFactoryBrewmasterBreathofFire
A.brewmasterBreathofFire = setmetatable({
    parent = AbilityIds.brewmasterBreathofFire,
    apply = identity,
}, callMt)

---@class AbilityFactoryBashBeastmasterBear
---@overload fun(data: AbilityRow<AbilityDefinitionBashBeastmasterBear>?): AbilityRow<AbilityDefinitionBashBeastmasterBear>
---@field apply fun(fn: fun(a: AbilityDefinitionBashBeastmasterBear)): fun(a: AbilityDefinitionBashBeastmasterBear)

---@type AbilityFactoryBashBeastmasterBear
A.bashBeastmasterBear = setmetatable({
    parent = AbilityIds.bashBeastmasterBear,
    apply = identity,
}, callMt)

---@class AbilityFactoryBattleRoar
---@overload fun(data: AbilityRow<AbilityDefinitionBattleRoar>?): AbilityRow<AbilityDefinitionBattleRoar>
---@field apply fun(fn: fun(a: AbilityDefinitionBattleRoar)): fun(a: AbilityDefinitionBattleRoar)

---@type AbilityFactoryBattleRoar
A.battleRoar = setmetatable({
    parent = AbilityIds.battleRoar,
    apply = identity,
}, callMt)

---@class AbilityFactoryOrbofDarknessBlackArrow
---@overload fun(data: AbilityRow<AbilityDefinitionOrbofDarknessBlackArrow>?): AbilityRow<AbilityDefinitionOrbofDarknessBlackArrow>
---@field apply fun(fn: fun(a: AbilityDefinitionOrbofDarknessBlackArrow)): fun(a: AbilityDefinitionOrbofDarknessBlackArrow)

---@type AbilityFactoryOrbofDarknessBlackArrow
A.orbofDarknessBlackArrow = setmetatable({
    parent = AbilityIds.orbofDarknessBlackArrow,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererClusterRocketsLevel1
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererClusterRocketsLevel1>?): AbilityRow<AbilityDefinitionTinkererClusterRocketsLevel1>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererClusterRocketsLevel1)): fun(a: AbilityDefinitionTinkererClusterRocketsLevel1)

---@type AbilityFactoryTinkererClusterRocketsLevel1
A.tinkererClusterRocketsLevel1 = setmetatable({
    parent = AbilityIds.tinkererClusterRocketsLevel1,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererClusterRocketsLevel2
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererClusterRocketsLevel2>?): AbilityRow<AbilityDefinitionTinkererClusterRocketsLevel2>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererClusterRocketsLevel2)): fun(a: AbilityDefinitionTinkererClusterRocketsLevel2)

---@type AbilityFactoryTinkererClusterRocketsLevel2
A.tinkererClusterRocketsLevel2 = setmetatable({
    parent = AbilityIds.tinkererClusterRocketsLevel2,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererClusterRocketsLevel3
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererClusterRocketsLevel3>?): AbilityRow<AbilityDefinitionTinkererClusterRocketsLevel3>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererClusterRocketsLevel3)): fun(a: AbilityDefinitionTinkererClusterRocketsLevel3)

---@type AbilityFactoryTinkererClusterRocketsLevel3
A.tinkererClusterRocketsLevel3 = setmetatable({
    parent = AbilityIds.tinkererClusterRocketsLevel3,
    apply = identity,
}, callMt)

---@class AbilityFactoryPitLordCleavingAttack
---@overload fun(data: AbilityRow<AbilityDefinitionPitLordCleavingAttack>?): AbilityRow<AbilityDefinitionPitLordCleavingAttack>
---@field apply fun(fn: fun(a: AbilityDefinitionPitLordCleavingAttack)): fun(a: AbilityDefinitionPitLordCleavingAttack)

---@type AbilityFactoryPitLordCleavingAttack
A.pitLordCleavingAttack = setmetatable({
    parent = AbilityIds.pitLordCleavingAttack,
    apply = identity,
}, callMt)

---@class AbilityFactoryDarkRangerCharm
---@overload fun(data: AbilityRow<AbilityDefinitionDarkRangerCharm>?): AbilityRow<AbilityDefinitionDarkRangerCharm>
---@field apply fun(fn: fun(a: AbilityDefinitionDarkRangerCharm)): fun(a: AbilityDefinitionDarkRangerCharm)

---@type AbilityFactoryDarkRangerCharm
A.darkRangerCharm = setmetatable({
    parent = AbilityIds.darkRangerCharm,
    apply = identity,
}, callMt)

---@class AbilityFactoryChannel
---@overload fun(data: AbilityRow<AbilityDefinitionIllidanChannel>?): AbilityRow<AbilityDefinitionIllidanChannel>
---@field apply fun(fn: fun(a: AbilityDefinitionIllidanChannel)): fun(a: AbilityDefinitionIllidanChannel)

---@type AbilityFactoryChannel
A.channel = setmetatable({
    parent = AbilityIds.channel,
    apply = identity,
}, callMt)

---@class AbilityFactoryAlchemistChemicalRage
---@overload fun(data: AbilityRow<AbilityDefinitionAlchemistChemicalRage>?): AbilityRow<AbilityDefinitionAlchemistChemicalRage>
---@field apply fun(fn: fun(a: AbilityDefinitionAlchemistChemicalRage)): fun(a: AbilityDefinitionAlchemistChemicalRage)

---@type AbilityFactoryAlchemistChemicalRage
A.alchemistChemicalRage = setmetatable({
    parent = AbilityIds.alchemistChemicalRage,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererClusterRocketsLevel0
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererClusterRocketsLevel0>?): AbilityRow<AbilityDefinitionTinkererClusterRocketsLevel0>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererClusterRocketsLevel0)): fun(a: AbilityDefinitionTinkererClusterRocketsLevel0)

---@type AbilityFactoryTinkererClusterRocketsLevel0
A.tinkererClusterRocketsLevel0 = setmetatable({
    parent = AbilityIds.tinkererClusterRocketsLevel0,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererDemolishLevel1
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererDemolishLevel1>?): AbilityRow<AbilityDefinitionTinkererDemolishLevel1>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererDemolishLevel1)): fun(a: AbilityDefinitionTinkererDemolishLevel1)

---@type AbilityFactoryTinkererDemolishLevel1
A.tinkererDemolishLevel1 = setmetatable({
    parent = AbilityIds.tinkererDemolishLevel1,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererDemolishLevel2
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererDemolishLevel2>?): AbilityRow<AbilityDefinitionTinkererDemolishLevel2>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererDemolishLevel2)): fun(a: AbilityDefinitionTinkererDemolishLevel2)

---@type AbilityFactoryTinkererDemolishLevel2
A.tinkererDemolishLevel2 = setmetatable({
    parent = AbilityIds.tinkererDemolishLevel2,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererDemolishLevel3
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererDemolishLevel3>?): AbilityRow<AbilityDefinitionTinkererDemolishLevel3>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererDemolishLevel3)): fun(a: AbilityDefinitionTinkererDemolishLevel3)

---@type AbilityFactoryTinkererDemolishLevel3
A.tinkererDemolishLevel3 = setmetatable({
    parent = AbilityIds.tinkererDemolishLevel3,
    apply = identity,
}, callMt)

---@class AbilityFactoryBrewmasterDrunkenBrawler
---@overload fun(data: AbilityRow<AbilityDefinitionBrewmasterDrunkenBrawler>?): AbilityRow<AbilityDefinitionBrewmasterDrunkenBrawler>
---@field apply fun(fn: fun(a: AbilityDefinitionBrewmasterDrunkenBrawler)): fun(a: AbilityDefinitionBrewmasterDrunkenBrawler)

---@type AbilityFactoryBrewmasterDrunkenBrawler
A.brewmasterDrunkenBrawler = setmetatable({
    parent = AbilityIds.brewmasterDrunkenBrawler,
    apply = identity,
}, callMt)

---@class AbilityFactoryDarkConversion
---@overload fun(data: AbilityRow<AbilityDefinitionMalganisDarkConversion>?): AbilityRow<AbilityDefinitionMalganisDarkConversion>
---@field apply fun(fn: fun(a: AbilityDefinitionMalganisDarkConversion)): fun(a: AbilityDefinitionMalganisDarkConversion)

---@type AbilityFactoryDarkConversion
A.darkConversion = setmetatable({
    parent = AbilityIds.darkConversion,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererDemolishLevel0
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererDemolishLevel0>?): AbilityRow<AbilityDefinitionTinkererDemolishLevel0>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererDemolishLevel0)): fun(a: AbilityDefinitionTinkererDemolishLevel0)

---@type AbilityFactoryTinkererDemolishLevel0
A.tinkererDemolishLevel0 = setmetatable({
    parent = AbilityIds.tinkererDemolishLevel0,
    apply = identity,
}, callMt)

---@class AbilityFactoryBrewmasterDrunkenHaze
---@overload fun(data: AbilityRow<AbilityDefinitionBrewmasterDrunkenHaze>?): AbilityRow<AbilityDefinitionBrewmasterDrunkenHaze>
---@field apply fun(fn: fun(a: AbilityDefinitionBrewmasterDrunkenHaze)): fun(a: AbilityDefinitionBrewmasterDrunkenHaze)

---@type AbilityFactoryBrewmasterDrunkenHaze
A.brewmasterDrunkenHaze = setmetatable({
    parent = AbilityIds.brewmasterDrunkenHaze,
    apply = identity,
}, callMt)

---@class AbilityFactoryPitLordDoom
---@overload fun(data: AbilityRow<AbilityDefinitionPitLordDoom>?): AbilityRow<AbilityDefinitionPitLordDoom>
---@field apply fun(fn: fun(a: AbilityDefinitionPitLordDoom)): fun(a: AbilityDefinitionPitLordDoom)

---@type AbilityFactoryPitLordDoom
A.pitLordDoom = setmetatable({
    parent = AbilityIds.pitLordDoom,
    apply = identity,
}, callMt)

---@class AbilityFactoryDarkPortal
---@overload fun(data: AbilityRow<AbilityDefinitionDarkPortal>?): AbilityRow<AbilityDefinitionDarkPortal>
---@field apply fun(fn: fun(a: AbilityDefinitionDarkPortal)): fun(a: AbilityDefinitionDarkPortal)

---@type AbilityFactoryDarkPortal
A.darkPortal = setmetatable({
    parent = AbilityIds.darkPortal,
    apply = identity,
}, callMt)

---@class AbilityFactoryDarkRangerDrain
---@overload fun(data: AbilityRow<AbilityDefinitionDarkRangerDrain>?): AbilityRow<AbilityDefinitionDarkRangerDrain>
---@field apply fun(fn: fun(a: AbilityDefinitionDarkRangerDrain)): fun(a: AbilityDefinitionDarkRangerDrain)

---@type AbilityFactoryDarkRangerDrain
A.darkRangerDrain = setmetatable({
    parent = AbilityIds.darkRangerDrain,
    apply = identity,
}, callMt)

---@class AbilityFactoryBrewmasterStormEarthandFire
---@overload fun(data: AbilityRow<AbilityDefinitionBrewmasterStormEarthandFire>?): AbilityRow<AbilityDefinitionBrewmasterStormEarthandFire>
---@field apply fun(fn: fun(a: AbilityDefinitionBrewmasterStormEarthandFire)): fun(a: AbilityDefinitionBrewmasterStormEarthandFire)

---@type AbilityFactoryBrewmasterStormEarthandFire
A.brewmasterStormEarthandFire = setmetatable({
    parent = AbilityIds.brewmasterStormEarthandFire,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererEngineeringUpgrade
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererEngineeringUpgrade>?): AbilityRow<AbilityDefinitionTinkererEngineeringUpgrade>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererEngineeringUpgrade)): fun(a: AbilityDefinitionTinkererEngineeringUpgrade)

---@type AbilityFactoryTinkererEngineeringUpgrade
A.tinkererEngineeringUpgrade = setmetatable({
    parent = AbilityIds.tinkererEngineeringUpgrade,
    apply = identity,
}, callMt)

---@class AbilityFactorySeaWitchFrostArrows
---@overload fun(data: AbilityRow<AbilityDefinitionSeaWitchFrostArrows>?): AbilityRow<AbilityDefinitionSeaWitchFrostArrows>
---@field apply fun(fn: fun(a: AbilityDefinitionSeaWitchFrostArrows)): fun(a: AbilityDefinitionSeaWitchFrostArrows)

---@type AbilityFactorySeaWitchFrostArrows
A.seaWitchFrostArrows = setmetatable({
    parent = AbilityIds.seaWitchFrostArrows,
    apply = identity,
}, callMt)

---@class AbilityFactoryFirebolt
---@overload fun(data: AbilityRow<AbilityDefinitionFireBolt>?): AbilityRow<AbilityDefinitionFireBolt>
---@field apply fun(fn: fun(a: AbilityDefinitionFireBolt)): fun(a: AbilityDefinitionFireBolt)

---@type AbilityFactoryFirebolt
A.firebolt = setmetatable({
    parent = AbilityIds.firebolt,
    apply = identity,
}, callMt)

---@class AbilityFactoryFingerofDeath
---@overload fun(data: AbilityRow<AbilityDefinitionFingerofDeath>?): AbilityRow<AbilityDefinitionFingerofDeath>
---@field apply fun(fn: fun(a: AbilityDefinitionFingerofDeath)): fun(a: AbilityDefinitionFingerofDeath)

---@type AbilityFactoryFingerofDeath
A.fingerofDeath = setmetatable({
    parent = AbilityIds.fingerofDeath,
    apply = identity,
}, callMt)

---@class AbilityFactorySeaWitchForkedLightning
---@overload fun(data: AbilityRow<AbilityDefinitionSeaWitchForkedLightning>?): AbilityRow<AbilityDefinitionSeaWitchForkedLightning>
---@field apply fun(fn: fun(a: AbilityDefinitionSeaWitchForkedLightning)): fun(a: AbilityDefinitionSeaWitchForkedLightning)

---@type AbilityFactorySeaWitchForkedLightning
A.seaWitchForkedLightning = setmetatable({
    parent = AbilityIds.seaWitchForkedLightning,
    apply = identity,
}, callMt)

---@class AbilityFactoryFactory
---@overload fun(data: AbilityRow<AbilityDefinitionFactory>?): AbilityRow<AbilityDefinitionFactory>
---@field apply fun(fn: fun(a: AbilityDefinitionFactory)): fun(a: AbilityDefinitionFactory)

---@type AbilityFactoryFactory
A.factory = setmetatable({
    parent = AbilityIds.factory,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererRoboGoblinLevel1
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererRoboGoblinLevel1>?): AbilityRow<AbilityDefinitionTinkererRoboGoblinLevel1>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererRoboGoblinLevel1)): fun(a: AbilityDefinitionTinkererRoboGoblinLevel1)

---@type AbilityFactoryTinkererRoboGoblinLevel1
A.tinkererRoboGoblinLevel1 = setmetatable({
    parent = AbilityIds.tinkererRoboGoblinLevel1,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererRoboGoblinLevel2
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererRoboGoblinLevel2>?): AbilityRow<AbilityDefinitionTinkererRoboGoblinLevel2>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererRoboGoblinLevel2)): fun(a: AbilityDefinitionTinkererRoboGoblinLevel2)

---@type AbilityFactoryTinkererRoboGoblinLevel2
A.tinkererRoboGoblinLevel2 = setmetatable({
    parent = AbilityIds.tinkererRoboGoblinLevel2,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererRoboGoblinLevel3
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererRoboGoblinLevel3>?): AbilityRow<AbilityDefinitionTinkererRoboGoblinLevel3>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererRoboGoblinLevel3)): fun(a: AbilityDefinitionTinkererRoboGoblinLevel3)

---@type AbilityFactoryTinkererRoboGoblinLevel3
A.tinkererRoboGoblinLevel3 = setmetatable({
    parent = AbilityIds.tinkererRoboGoblinLevel3,
    apply = identity,
}, callMt)

---@class AbilityFactoryAlchemistHealingSpray
---@overload fun(data: AbilityRow<AbilityDefinitionAlchemistHealingSpray>?): AbilityRow<AbilityDefinitionAlchemistHealingSpray>
---@field apply fun(fn: fun(a: AbilityDefinitionAlchemistHealingSpray)): fun(a: AbilityDefinitionAlchemistHealingSpray)

---@type AbilityFactoryAlchemistHealingSpray
A.alchemistHealingSpray = setmetatable({
    parent = AbilityIds.alchemistHealingSpray,
    apply = identity,
}, callMt)

---@class AbilityFactoryPitLordHowlofTerror
---@overload fun(data: AbilityRow<AbilityDefinitionPitLordHowlofTerror>?): AbilityRow<AbilityDefinitionPitLordHowlofTerror>
---@field apply fun(fn: fun(a: AbilityDefinitionPitLordHowlofTerror)): fun(a: AbilityDefinitionPitLordHowlofTerror)

---@type AbilityFactoryPitLordHowlofTerror
A.pitLordHowlofTerror = setmetatable({
    parent = AbilityIds.pitLordHowlofTerror,
    apply = identity,
}, callMt)

---@class AbilityFactoryFirelordIncinerate
---@overload fun(data: AbilityRow<AbilityDefinitionFirelordIncinerate>?): AbilityRow<AbilityDefinitionFirelordIncinerate>
---@field apply fun(fn: fun(a: AbilityDefinitionFirelordIncinerate)): fun(a: AbilityDefinitionFirelordIncinerate)

---@type AbilityFactoryFirelordIncinerate
A.firelordIncinerate = setmetatable({
    parent = AbilityIds.firelordIncinerate,
    apply = identity,
}, callMt)

---@class AbilityFactoryInferno1
---@overload fun(data: AbilityRow<AbilityDefinitionInferno>?): AbilityRow<AbilityDefinitionInferno>
---@field apply fun(fn: fun(a: AbilityDefinitionInferno)): fun(a: AbilityDefinitionInferno)

---@type AbilityFactoryInferno1
A.inferno1 = setmetatable({
    parent = AbilityIds.inferno1,
    apply = identity,
}, callMt)

---@class AbilityFactorySummonLavaSpawn
---@overload fun(data: AbilityRow<AbilityDefinitionFirelordSummonLavaSpawn>?): AbilityRow<AbilityDefinitionFirelordSummonLavaSpawn>
---@field apply fun(fn: fun(a: AbilityDefinitionFirelordSummonLavaSpawn)): fun(a: AbilityDefinitionFirelordSummonLavaSpawn)

---@type AbilityFactorySummonLavaSpawn
A.summonLavaSpawn = setmetatable({
    parent = AbilityIds.summonLavaSpawn,
    apply = identity,
}, callMt)

---@class AbilityFactoryMonsoon
---@overload fun(data: AbilityRow<AbilityDefinitionMonsoon>?): AbilityRow<AbilityDefinitionMonsoon>
---@field apply fun(fn: fun(a: AbilityDefinitionMonsoon)): fun(a: AbilityDefinitionMonsoon)

---@type AbilityFactoryMonsoon
A.monsoon = setmetatable({
    parent = AbilityIds.monsoon,
    apply = identity,
}, callMt)

---@class AbilityFactoryMindRot
---@overload fun(data: AbilityRow<AbilityDefinitionMindRot>?): AbilityRow<AbilityDefinitionMindRot>
---@field apply fun(fn: fun(a: AbilityDefinitionMindRot)): fun(a: AbilityDefinitionMindRot)

---@type AbilityFactoryMindRot
A.mindRot = setmetatable({
    parent = AbilityIds.mindRot,
    apply = identity,
}, callMt)

---@class AbilityFactorySeaWitchManaShield
---@overload fun(data: AbilityRow<AbilityDefinitionSeaWitchManaShield>?): AbilityRow<AbilityDefinitionSeaWitchManaShield>
---@field apply fun(fn: fun(a: AbilityDefinitionSeaWitchManaShield)): fun(a: AbilityDefinitionSeaWitchManaShield)

---@type AbilityFactorySeaWitchManaShield
A.seaWitchManaShield = setmetatable({
    parent = AbilityIds.seaWitchManaShield,
    apply = identity,
}, callMt)

---@class AbilityFactoryParasite
---@overload fun(data: AbilityRow<AbilityDefinitionParasite>?): AbilityRow<AbilityDefinitionParasite>
---@field apply fun(fn: fun(a: AbilityDefinitionParasite)): fun(a: AbilityDefinitionParasite)

---@type AbilityFactoryParasite
A.parasite = setmetatable({
    parent = AbilityIds.parasite,
    apply = identity,
}, callMt)

---@class AbilityFactoryPermanentImmolation
---@overload fun(data: AbilityRow<AbilityDefinitionPermanentImmolation>?): AbilityRow<AbilityDefinitionPermanentImmolation>
---@field apply fun(fn: fun(a: AbilityDefinitionPermanentImmolation)): fun(a: AbilityDefinitionPermanentImmolation)

---@type AbilityFactoryPermanentImmolation
A.permanentImmolation = setmetatable({
    parent = AbilityIds.permanentImmolation,
    apply = identity,
}, callMt)

---@class AbilityFactoryPreservation
---@overload fun(data: AbilityRow<AbilityDefinitionPreservation>?): AbilityRow<AbilityDefinitionPreservation>
---@field apply fun(fn: fun(a: AbilityDefinitionPreservation)): fun(a: AbilityDefinitionPreservation)

---@type AbilityFactoryPreservation
A.preservation = setmetatable({
    parent = AbilityIds.preservation,
    apply = identity,
}, callMt)

---@class AbilityFactoryRainofChaos
---@overload fun(data: AbilityRow<AbilityDefinitionRainofChaos>?): AbilityRow<AbilityDefinitionRainofChaos>
---@field apply fun(fn: fun(a: AbilityDefinitionRainofChaos)): fun(a: AbilityDefinitionRainofChaos)

---@type AbilityFactoryRainofChaos
A.rainofChaos = setmetatable({
    parent = AbilityIds.rainofChaos,
    apply = identity,
}, callMt)

---@class AbilityFactoryManaRegeneration
---@overload fun(data: AbilityRow<AbilityDefinitionNeutralRegenmanaonly>?): AbilityRow<AbilityDefinitionNeutralRegenmanaonly>
---@field apply fun(fn: fun(a: AbilityDefinitionNeutralRegenmanaonly)): fun(a: AbilityDefinitionNeutralRegenmanaonly)

---@type AbilityFactoryManaRegeneration
A.manaRegeneration = setmetatable({
    parent = AbilityIds.manaRegeneration,
    apply = identity,
}, callMt)

---@class AbilityFactoryRainofFire
---@overload fun(data: AbilityRow<AbilityDefinitionRainofFire>?): AbilityRow<AbilityDefinitionRainofFire>
---@field apply fun(fn: fun(a: AbilityDefinitionRainofFire)): fun(a: AbilityDefinitionRainofFire)

---@type AbilityFactoryRainofFire
A.rainofFire = setmetatable({
    parent = AbilityIds.rainofFire,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererRoboGoblinLevel0
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererRoboGoblinLevel0>?): AbilityRow<AbilityDefinitionTinkererRoboGoblinLevel0>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererRoboGoblinLevel0)): fun(a: AbilityDefinitionTinkererRoboGoblinLevel0)

---@type AbilityFactoryTinkererRoboGoblinLevel0
A.tinkererRoboGoblinLevel0 = setmetatable({
    parent = AbilityIds.tinkererRoboGoblinLevel0,
    apply = identity,
}, callMt)

---@class AbilityFactoryReincarnation
---@overload fun(data: AbilityRow<AbilityDefinitionMannorothReincarnation>?): AbilityRow<AbilityDefinitionMannorothReincarnation>
---@field apply fun(fn: fun(a: AbilityDefinitionMannorothReincarnation)): fun(a: AbilityDefinitionMannorothReincarnation)

---@type AbilityFactoryReincarnation
A.reincarnation = setmetatable({
    parent = AbilityIds.reincarnation,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererSummonFactoryLevel1
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererSummonFactoryLevel1>?): AbilityRow<AbilityDefinitionTinkererSummonFactoryLevel1>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererSummonFactoryLevel1)): fun(a: AbilityDefinitionTinkererSummonFactoryLevel1)

---@type AbilityFactoryTinkererSummonFactoryLevel1
A.tinkererSummonFactoryLevel1 = setmetatable({
    parent = AbilityIds.tinkererSummonFactoryLevel1,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererSummonFactoryLevel2
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererSummonFactoryLevel2>?): AbilityRow<AbilityDefinitionTinkererSummonFactoryLevel2>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererSummonFactoryLevel2)): fun(a: AbilityDefinitionTinkererSummonFactoryLevel2)

---@type AbilityFactoryTinkererSummonFactoryLevel2
A.tinkererSummonFactoryLevel2 = setmetatable({
    parent = AbilityIds.tinkererSummonFactoryLevel2,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererSummonFactoryLevel3
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererSummonFactoryLevel3>?): AbilityRow<AbilityDefinitionTinkererSummonFactoryLevel3>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererSummonFactoryLevel3)): fun(a: AbilityDefinitionTinkererSummonFactoryLevel3)

---@type AbilityFactoryTinkererSummonFactoryLevel3
A.tinkererSummonFactoryLevel3 = setmetatable({
    parent = AbilityIds.tinkererSummonFactoryLevel3,
    apply = identity,
}, callMt)

---@class AbilityFactorySanctuary
---@overload fun(data: AbilityRow<AbilityDefinitionSanctuary>?): AbilityRow<AbilityDefinitionSanctuary>
---@field apply fun(fn: fun(a: AbilityDefinitionSanctuary)): fun(a: AbilityDefinitionSanctuary)

---@type AbilityFactorySanctuary
A.sanctuary = setmetatable({
    parent = AbilityIds.sanctuary,
    apply = identity,
}, callMt)

---@class AbilityFactorySpellShieldAOE
---@overload fun(data: AbilityRow<AbilityDefinitionSpellShieldAOE>?): AbilityRow<AbilityDefinitionSpellShieldAOE>
---@field apply fun(fn: fun(a: AbilityDefinitionSpellShieldAOE)): fun(a: AbilityDefinitionSpellShieldAOE)

---@type AbilityFactorySpellShieldAOE
A.spellShieldAOE = setmetatable({
    parent = AbilityIds.spellShieldAOE,
    apply = identity,
}, callMt)

---@class AbilityFactoryBeastMasterSummonBear
---@overload fun(data: AbilityRow<AbilityDefinitionBeastMasterSummonBear>?): AbilityRow<AbilityDefinitionBeastMasterSummonBear>
---@field apply fun(fn: fun(a: AbilityDefinitionBeastMasterSummonBear)): fun(a: AbilityDefinitionBeastMasterSummonBear)

---@type AbilityFactoryBeastMasterSummonBear
A.beastMasterSummonBear = setmetatable({
    parent = AbilityIds.beastMasterSummonBear,
    apply = identity,
}, callMt)

---@class AbilityFactorySilence
---@overload fun(data: AbilityRow<AbilityDefinitionDarkRangerSilence>?): AbilityRow<AbilityDefinitionDarkRangerSilence>
---@field apply fun(fn: fun(a: AbilityDefinitionDarkRangerSilence)): fun(a: AbilityDefinitionDarkRangerSilence)

---@type AbilityFactorySilence
A.silence = setmetatable({
    parent = AbilityIds.silence,
    apply = identity,
}, callMt)

---@class AbilityFactorySoulPreservation
---@overload fun(data: AbilityRow<AbilityDefinitionMalganisSoulPreservation>?): AbilityRow<AbilityDefinitionMalganisSoulPreservation>
---@field apply fun(fn: fun(a: AbilityDefinitionMalganisSoulPreservation)): fun(a: AbilityDefinitionMalganisSoulPreservation)

---@type AbilityFactorySoulPreservation
A.soulPreservation = setmetatable({
    parent = AbilityIds.soulPreservation,
    apply = identity,
}, callMt)

---@class AbilityFactorySoulBurn
---@overload fun(data: AbilityRow<AbilityDefinitionFirelordSoulBurn>?): AbilityRow<AbilityDefinitionFirelordSoulBurn>
---@field apply fun(fn: fun(a: AbilityDefinitionFirelordSoulBurn)): fun(a: AbilityDefinitionFirelordSoulBurn)

---@type AbilityFactorySoulBurn
A.soulBurn = setmetatable({
    parent = AbilityIds.soulBurn,
    apply = identity,
}, callMt)

---@class AbilityFactoryBeastMasterSummonQuilbeast
---@overload fun(data: AbilityRow<AbilityDefinitionBeastMasterSummonQuilbeast>?): AbilityRow<AbilityDefinitionBeastMasterSummonQuilbeast>
---@field apply fun(fn: fun(a: AbilityDefinitionBeastMasterSummonQuilbeast)): fun(a: AbilityDefinitionBeastMasterSummonQuilbeast)

---@type AbilityFactoryBeastMasterSummonQuilbeast
A.beastMasterSummonQuilbeast = setmetatable({
    parent = AbilityIds.beastMasterSummonQuilbeast,
    apply = identity,
}, callMt)

---@class AbilityFactoryBeastMasterStampede
---@overload fun(data: AbilityRow<AbilityDefinitionBeastMasterStampede>?): AbilityRow<AbilityDefinitionBeastMasterStampede>
---@field apply fun(fn: fun(a: AbilityDefinitionBeastMasterStampede)): fun(a: AbilityDefinitionBeastMasterStampede)

---@type AbilityFactoryBeastMasterStampede
A.beastMasterStampede = setmetatable({
    parent = AbilityIds.beastMasterStampede,
    apply = identity,
}, callMt)

---@class AbilityFactoryBeastMasterSummonHawk
---@overload fun(data: AbilityRow<AbilityDefinitionBeastMasterSummonHawk>?): AbilityRow<AbilityDefinitionBeastMasterSummonHawk>
---@field apply fun(fn: fun(a: AbilityDefinitionBeastMasterSummonHawk)): fun(a: AbilityDefinitionBeastMasterSummonHawk)

---@type AbilityFactoryBeastMasterSummonHawk
A.beastMasterSummonHawk = setmetatable({
    parent = AbilityIds.beastMasterSummonHawk,
    apply = identity,
}, callMt)

---@class AbilityFactoryTinkererSummonFactoryLevel0
---@overload fun(data: AbilityRow<AbilityDefinitionTinkererSummonFactoryLevel0>?): AbilityRow<AbilityDefinitionTinkererSummonFactoryLevel0>
---@field apply fun(fn: fun(a: AbilityDefinitionTinkererSummonFactoryLevel0)): fun(a: AbilityDefinitionTinkererSummonFactoryLevel0)

---@type AbilityFactoryTinkererSummonFactoryLevel0
A.tinkererSummonFactoryLevel0 = setmetatable({
    parent = AbilityIds.tinkererSummonFactoryLevel0,
    apply = identity,
}, callMt)

---@class AbilityFactoryTaunt1
---@overload fun(data: AbilityRow<AbilityDefinitionTauntCreep>?): AbilityRow<AbilityDefinitionTauntCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionTauntCreep)): fun(a: AbilityDefinitionTauntCreep)

---@type AbilityFactoryTaunt1
A.taunt1 = setmetatable({
    parent = AbilityIds.taunt1,
    apply = identity,
}, callMt)

---@class AbilityFactoryThornyShieldCreep
---@overload fun(data: AbilityRow<AbilityDefinitionThornyShieldCreep>?): AbilityRow<AbilityDefinitionThornyShieldCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionThornyShieldCreep)): fun(a: AbilityDefinitionThornyShieldCreep)

---@type AbilityFactoryThornyShieldCreep
A.thornyShieldCreep = setmetatable({
    parent = AbilityIds.thornyShieldCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryTransmute
---@overload fun(data: AbilityRow<AbilityDefinitionAlchemistTransmute>?): AbilityRow<AbilityDefinitionAlchemistTransmute>
---@field apply fun(fn: fun(a: AbilityDefinitionAlchemistTransmute)): fun(a: AbilityDefinitionAlchemistTransmute)

---@type AbilityFactoryTransmute
A.transmute = setmetatable({
    parent = AbilityIds.transmute,
    apply = identity,
}, callMt)

---@class AbilityFactoryTornado
---@overload fun(data: AbilityRow<AbilityDefinitionSeaWitchTornado>?): AbilityRow<AbilityDefinitionSeaWitchTornado>
---@field apply fun(fn: fun(a: AbilityDefinitionSeaWitchTornado)): fun(a: AbilityDefinitionSeaWitchTornado)

---@type AbilityFactoryTornado
A.tornado = setmetatable({
    parent = AbilityIds.tornado,
    apply = identity,
}, callMt)

---@class AbilityFactoryVolcano
---@overload fun(data: AbilityRow<AbilityDefinitionFirelordVolcano>?): AbilityRow<AbilityDefinitionFirelordVolcano>
---@field apply fun(fn: fun(a: AbilityDefinitionFirelordVolcano)): fun(a: AbilityDefinitionFirelordVolcano)

---@type AbilityFactoryVolcano
A.volcano = setmetatable({
    parent = AbilityIds.volcano,
    apply = identity,
}, callMt)

---@class AbilityFactoryWindWalk1
---@overload fun(data: AbilityRow<AbilityDefinitionWindWalk>?): AbilityRow<AbilityDefinitionWindWalk>
---@field apply fun(fn: fun(a: AbilityDefinitionWindWalk)): fun(a: AbilityDefinitionWindWalk)

---@type AbilityFactoryWindWalk1
A.windWalk1 = setmetatable({
    parent = AbilityIds.windWalk1,
    apply = identity,
}, callMt)

---@class AbilityFactoryWateryMinion
---@overload fun(data: AbilityRow<AbilityDefinitionWateryMinion>?): AbilityRow<AbilityDefinitionWateryMinion>
---@field apply fun(fn: fun(a: AbilityDefinitionWateryMinion)): fun(a: AbilityDefinitionWateryMinion)

---@type AbilityFactoryWateryMinion
A.wateryMinion = setmetatable({
    parent = AbilityIds.wateryMinion,
    apply = identity,
}, callMt)

---@class AbilityFactoryEnduranceAura1
---@overload fun(data: AbilityRow<AbilityDefinitionTaurenChieftainEnduranceAura>?): AbilityRow<AbilityDefinitionTaurenChieftainEnduranceAura>
---@field apply fun(fn: fun(a: AbilityDefinitionTaurenChieftainEnduranceAura)): fun(a: AbilityDefinitionTaurenChieftainEnduranceAura)

---@type AbilityFactoryEnduranceAura1
A.enduranceAura1 = setmetatable({
    parent = AbilityIds.enduranceAura1,
    apply = identity,
}, callMt)

---@class AbilityFactoryChainLightning1
---@overload fun(data: AbilityRow<AbilityDefinitionFarseerChainLightning>?): AbilityRow<AbilityDefinitionFarseerChainLightning>
---@field apply fun(fn: fun(a: AbilityDefinitionFarseerChainLightning)): fun(a: AbilityDefinitionFarseerChainLightning)

---@type AbilityFactoryChainLightning1
A.chainLightning1 = setmetatable({
    parent = AbilityIds.chainLightning1,
    apply = identity,
}, callMt)

---@class AbilityFactoryCriticalStrike1
---@overload fun(data: AbilityRow<AbilityDefinitionBladeMasterCriticalStrike>?): AbilityRow<AbilityDefinitionBladeMasterCriticalStrike>
---@field apply fun(fn: fun(a: AbilityDefinitionBladeMasterCriticalStrike)): fun(a: AbilityDefinitionBladeMasterCriticalStrike)

---@type AbilityFactoryCriticalStrike1
A.criticalStrike1 = setmetatable({
    parent = AbilityIds.criticalStrike1,
    apply = identity,
}, callMt)

---@class AbilityFactoryEarthquake1
---@overload fun(data: AbilityRow<AbilityDefinitionFarseerEarthquake>?): AbilityRow<AbilityDefinitionFarseerEarthquake>
---@field apply fun(fn: fun(a: AbilityDefinitionFarseerEarthquake)): fun(a: AbilityDefinitionFarseerEarthquake)

---@type AbilityFactoryEarthquake1
A.earthquake1 = setmetatable({
    parent = AbilityIds.earthquake1,
    apply = identity,
}, callMt)

---@class AbilityFactoryFarSight
---@overload fun(data: AbilityRow<AbilityDefinitionFarseerFarSight>?): AbilityRow<AbilityDefinitionFarseerFarSight>
---@field apply fun(fn: fun(a: AbilityDefinitionFarseerFarSight)): fun(a: AbilityDefinitionFarseerFarSight)

---@type AbilityFactoryFarSight
A.farSight = setmetatable({
    parent = AbilityIds.farSight,
    apply = identity,
}, callMt)

---@class AbilityFactoryShadowHunterHealingWave
---@overload fun(data: AbilityRow<AbilityDefinitionShadowHunterHealingWave>?): AbilityRow<AbilityDefinitionShadowHunterHealingWave>
---@field apply fun(fn: fun(a: AbilityDefinitionShadowHunterHealingWave)): fun(a: AbilityDefinitionShadowHunterHealingWave)

---@type AbilityFactoryShadowHunterHealingWave
A.shadowHunterHealingWave = setmetatable({
    parent = AbilityIds.shadowHunterHealingWave,
    apply = identity,
}, callMt)

---@class AbilityFactoryShadowHunterHex
---@overload fun(data: AbilityRow<AbilityDefinitionShadowHunterHex>?): AbilityRow<AbilityDefinitionShadowHunterHex>
---@field apply fun(fn: fun(a: AbilityDefinitionShadowHunterHex)): fun(a: AbilityDefinitionShadowHunterHex)

---@type AbilityFactoryShadowHunterHex
A.shadowHunterHex = setmetatable({
    parent = AbilityIds.shadowHunterHex,
    apply = identity,
}, callMt)

---@class AbilityFactoryMirrorImage
---@overload fun(data: AbilityRow<AbilityDefinitionBladeMasterMirrorImage>?): AbilityRow<AbilityDefinitionBladeMasterMirrorImage>
---@field apply fun(fn: fun(a: AbilityDefinitionBladeMasterMirrorImage)): fun(a: AbilityDefinitionBladeMasterMirrorImage)

---@type AbilityFactoryMirrorImage
A.mirrorImage = setmetatable({
    parent = AbilityIds.mirrorImage,
    apply = identity,
}, callMt)

---@class AbilityFactoryReincarnation2
---@overload fun(data: AbilityRow<AbilityDefinitionTaurenChieftainReincarnation>?): AbilityRow<AbilityDefinitionTaurenChieftainReincarnation>
---@field apply fun(fn: fun(a: AbilityDefinitionTaurenChieftainReincarnation)): fun(a: AbilityDefinitionTaurenChieftainReincarnation)

---@type AbilityFactoryReincarnation2
A.reincarnation2 = setmetatable({
    parent = AbilityIds.reincarnation2,
    apply = identity,
}, callMt)

---@class AbilityFactoryFeralSpirit2
---@overload fun(data: AbilityRow<AbilityDefinitionFarseerSpiritWolf>?): AbilityRow<AbilityDefinitionFarseerSpiritWolf>
---@field apply fun(fn: fun(a: AbilityDefinitionFarseerSpiritWolf)): fun(a: AbilityDefinitionFarseerSpiritWolf)

---@type AbilityFactoryFeralSpirit2
A.feralSpirit2 = setmetatable({
    parent = AbilityIds.feralSpirit2,
    apply = identity,
}, callMt)

---@class AbilityFactoryShockwave2
---@overload fun(data: AbilityRow<AbilityDefinitionTaurenChieftainShockWave>?): AbilityRow<AbilityDefinitionTaurenChieftainShockWave>
---@field apply fun(fn: fun(a: AbilityDefinitionTaurenChieftainShockWave)): fun(a: AbilityDefinitionTaurenChieftainShockWave)

---@type AbilityFactoryShockwave2
A.shockwave2 = setmetatable({
    parent = AbilityIds.shockwave2,
    apply = identity,
}, callMt)

---@class AbilityFactoryShadowHunterSerpentWard
---@overload fun(data: AbilityRow<AbilityDefinitionShadowHunterSerpentWard>?): AbilityRow<AbilityDefinitionShadowHunterSerpentWard>
---@field apply fun(fn: fun(a: AbilityDefinitionShadowHunterSerpentWard)): fun(a: AbilityDefinitionShadowHunterSerpentWard)

---@type AbilityFactoryShadowHunterSerpentWard
A.shadowHunterSerpentWard = setmetatable({
    parent = AbilityIds.shadowHunterSerpentWard,
    apply = identity,
}, callMt)

---@class AbilityFactoryWindWalk
---@overload fun(data: AbilityRow<AbilityDefinitionBladeMasterWindWalk>?): AbilityRow<AbilityDefinitionBladeMasterWindWalk>
---@field apply fun(fn: fun(a: AbilityDefinitionBladeMasterWindWalk)): fun(a: AbilityDefinitionBladeMasterWindWalk)

---@type AbilityFactoryWindWalk
A.windWalk = setmetatable({
    parent = AbilityIds.windWalk,
    apply = identity,
}, callMt)

---@class AbilityFactoryWarStomp1
---@overload fun(data: AbilityRow<AbilityDefinitionTaurenChieftainWarStomp>?): AbilityRow<AbilityDefinitionTaurenChieftainWarStomp>
---@field apply fun(fn: fun(a: AbilityDefinitionTaurenChieftainWarStomp)): fun(a: AbilityDefinitionTaurenChieftainWarStomp)

---@type AbilityFactoryWarStomp1
A.warStomp1 = setmetatable({
    parent = AbilityIds.warStomp1,
    apply = identity,
}, callMt)

---@class AbilityFactoryBladestorm
---@overload fun(data: AbilityRow<AbilityDefinitionBladeMasterBladestorm>?): AbilityRow<AbilityDefinitionBladeMasterBladestorm>
---@field apply fun(fn: fun(a: AbilityDefinitionBladeMasterBladestorm)): fun(a: AbilityDefinitionBladeMasterBladestorm)

---@type AbilityFactoryBladestorm
A.bladestorm = setmetatable({
    parent = AbilityIds.bladestorm,
    apply = identity,
}, callMt)

---@class AbilityFactoryRuneofLesserResurrection
---@overload fun(data: AbilityRow<AbilityDefinitionRuneofLesserResurrection>?): AbilityRow<AbilityDefinitionRuneofLesserResurrection>
---@field apply fun(fn: fun(a: AbilityDefinitionRuneofLesserResurrection)): fun(a: AbilityDefinitionRuneofLesserResurrection)

---@type AbilityFactoryRuneofLesserResurrection
A.runeofLesserResurrection = setmetatable({
    parent = AbilityIds.runeofLesserResurrection,
    apply = identity,
}, callMt)

---@class AbilityFactoryRuneofGreaterResurrection
---@overload fun(data: AbilityRow<AbilityDefinitionRuneofGreaterResurrection>?): AbilityRow<AbilityDefinitionRuneofGreaterResurrection>
---@field apply fun(fn: fun(a: AbilityDefinitionRuneofGreaterResurrection)): fun(a: AbilityDefinitionRuneofGreaterResurrection)

---@type AbilityFactoryRuneofGreaterResurrection
A.runeofGreaterResurrection = setmetatable({
    parent = AbilityIds.runeofGreaterResurrection,
    apply = identity,
}, callMt)

---@class AbilityFactoryAnimateDead1
---@overload fun(data: AbilityRow<AbilityDefinitionDeathKnightAnimateDead>?): AbilityRow<AbilityDefinitionDeathKnightAnimateDead>
---@field apply fun(fn: fun(a: AbilityDefinitionDeathKnightAnimateDead)): fun(a: AbilityDefinitionDeathKnightAnimateDead)

---@type AbilityFactoryAnimateDead1
A.animateDead1 = setmetatable({
    parent = AbilityIds.animateDead1,
    apply = identity,
}, callMt)

---@class AbilityFactoryUnholyAura1
---@overload fun(data: AbilityRow<AbilityDefinitionDeathKnightUnholyAura>?): AbilityRow<AbilityDefinitionDeathKnightUnholyAura>
---@field apply fun(fn: fun(a: AbilityDefinitionDeathKnightUnholyAura)): fun(a: AbilityDefinitionDeathKnightUnholyAura)

---@type AbilityFactoryUnholyAura1
A.unholyAura1 = setmetatable({
    parent = AbilityIds.unholyAura1,
    apply = identity,
}, callMt)

---@class AbilityFactoryVampiricAura1
---@overload fun(data: AbilityRow<AbilityDefinitionDreadlordVampiricAura>?): AbilityRow<AbilityDefinitionDreadlordVampiricAura>
---@field apply fun(fn: fun(a: AbilityDefinitionDreadlordVampiricAura)): fun(a: AbilityDefinitionDreadlordVampiricAura)

---@type AbilityFactoryVampiricAura1
A.vampiricAura1 = setmetatable({
    parent = AbilityIds.vampiricAura1,
    apply = identity,
}, callMt)

---@class AbilityFactoryCryptLordCarrionScarabs
---@overload fun(data: AbilityRow<AbilityDefinitionCryptLordCarrionScarabs>?): AbilityRow<AbilityDefinitionCryptLordCarrionScarabs>
---@field apply fun(fn: fun(a: AbilityDefinitionCryptLordCarrionScarabs)): fun(a: AbilityDefinitionCryptLordCarrionScarabs)

---@type AbilityFactoryCryptLordCarrionScarabs
A.cryptLordCarrionScarabs = setmetatable({
    parent = AbilityIds.cryptLordCarrionScarabs,
    apply = identity,
}, callMt)

---@class AbilityFactoryCarrionSwarm1
---@overload fun(data: AbilityRow<AbilityDefinitionDreadlordCarrionSwarm>?): AbilityRow<AbilityDefinitionDreadlordCarrionSwarm>
---@field apply fun(fn: fun(a: AbilityDefinitionDreadlordCarrionSwarm)): fun(a: AbilityDefinitionDreadlordCarrionSwarm)

---@type AbilityFactoryCarrionSwarm1
A.carrionSwarm1 = setmetatable({
    parent = AbilityIds.carrionSwarm1,
    apply = identity,
}, callMt)

---@class AbilityFactoryDeathCoil1
---@overload fun(data: AbilityRow<AbilityDefinitionDeathKnightDeathCoil>?): AbilityRow<AbilityDefinitionDeathKnightDeathCoil>
---@field apply fun(fn: fun(a: AbilityDefinitionDeathKnightDeathCoil)): fun(a: AbilityDefinitionDeathKnightDeathCoil)

---@type AbilityFactoryDeathCoil1
A.deathCoil1 = setmetatable({
    parent = AbilityIds.deathCoil1,
    apply = identity,
}, callMt)

---@class AbilityFactoryDeathAndDecay1
---@overload fun(data: AbilityRow<AbilityDefinitionLichDeathandDecay>?): AbilityRow<AbilityDefinitionLichDeathandDecay>
---@field apply fun(fn: fun(a: AbilityDefinitionLichDeathandDecay)): fun(a: AbilityDefinitionLichDeathandDecay)

---@type AbilityFactoryDeathAndDecay1
A.deathAndDecay1 = setmetatable({
    parent = AbilityIds.deathAndDecay1,
    apply = identity,
}, callMt)

---@class AbilityFactoryDeathPact
---@overload fun(data: AbilityRow<AbilityDefinitionDeathKnightDeathPact>?): AbilityRow<AbilityDefinitionDeathKnightDeathPact>
---@field apply fun(fn: fun(a: AbilityDefinitionDeathKnightDeathPact)): fun(a: AbilityDefinitionDeathKnightDeathPact)

---@type AbilityFactoryDeathPact
A.deathPact = setmetatable({
    parent = AbilityIds.deathPact,
    apply = identity,
}, callMt)

---@class AbilityFactoryDarkRitual
---@overload fun(data: AbilityRow<AbilityDefinitionLichDarkRitual>?): AbilityRow<AbilityDefinitionLichDarkRitual>
---@field apply fun(fn: fun(a: AbilityDefinitionLichDarkRitual)): fun(a: AbilityDefinitionLichDarkRitual)

---@type AbilityFactoryDarkRitual
A.darkRitual = setmetatable({
    parent = AbilityIds.darkRitual,
    apply = identity,
}, callMt)

---@class AbilityFactoryDarkSummoning1
---@overload fun(data: AbilityRow<AbilityDefinitionTichondriusDarkSummoning>?): AbilityRow<AbilityDefinitionTichondriusDarkSummoning>
---@field apply fun(fn: fun(a: AbilityDefinitionTichondriusDarkSummoning)): fun(a: AbilityDefinitionTichondriusDarkSummoning)

---@type AbilityFactoryDarkSummoning1
A.darkSummoning1 = setmetatable({
    parent = AbilityIds.darkSummoning1,
    apply = identity,
}, callMt)

---@class AbilityFactoryFrostArmor1
---@overload fun(data: AbilityRow<AbilityDefinitionLichFrostArmor>?): AbilityRow<AbilityDefinitionLichFrostArmor>
---@field apply fun(fn: fun(a: AbilityDefinitionLichFrostArmor)): fun(a: AbilityDefinitionLichFrostArmor)

---@type AbilityFactoryFrostArmor1
A.frostArmor1 = setmetatable({
    parent = AbilityIds.frostArmor1,
    apply = identity,
}, callMt)

---@class AbilityFactoryFrostNova1
---@overload fun(data: AbilityRow<AbilityDefinitionLichFrostNova>?): AbilityRow<AbilityDefinitionLichFrostNova>
---@field apply fun(fn: fun(a: AbilityDefinitionLichFrostNova)): fun(a: AbilityDefinitionLichFrostNova)

---@type AbilityFactoryFrostNova1
A.frostNova1 = setmetatable({
    parent = AbilityIds.frostNova1,
    apply = identity,
}, callMt)

---@class AbilityFactoryLichFrostArmorAutocast
---@overload fun(data: AbilityRow<AbilityDefinitionLichFrostArmorAutocast>?): AbilityRow<AbilityDefinitionLichFrostArmorAutocast>
---@field apply fun(fn: fun(a: AbilityDefinitionLichFrostArmorAutocast)): fun(a: AbilityDefinitionLichFrostArmorAutocast)

---@type AbilityFactoryLichFrostArmorAutocast
A.lichFrostArmorAutocast = setmetatable({
    parent = AbilityIds.lichFrostArmorAutocast,
    apply = identity,
}, callMt)

---@class AbilityFactoryCryptLordImpale
---@overload fun(data: AbilityRow<AbilityDefinitionCryptLordImpale>?): AbilityRow<AbilityDefinitionCryptLordImpale>
---@field apply fun(fn: fun(a: AbilityDefinitionCryptLordImpale)): fun(a: AbilityDefinitionCryptLordImpale)

---@type AbilityFactoryCryptLordImpale
A.cryptLordImpale = setmetatable({
    parent = AbilityIds.cryptLordImpale,
    apply = identity,
}, callMt)

---@class AbilityFactoryInferno2
---@overload fun(data: AbilityRow<AbilityDefinitionDreadlordInferno>?): AbilityRow<AbilityDefinitionDreadlordInferno>
---@field apply fun(fn: fun(a: AbilityDefinitionDreadlordInferno)): fun(a: AbilityDefinitionDreadlordInferno)

---@type AbilityFactoryInferno2
A.inferno2 = setmetatable({
    parent = AbilityIds.inferno2,
    apply = identity,
}, callMt)

---@class AbilityFactoryCryptLordLocustSwarm
---@overload fun(data: AbilityRow<AbilityDefinitionCryptLordLocustSwarm>?): AbilityRow<AbilityDefinitionCryptLordLocustSwarm>
---@field apply fun(fn: fun(a: AbilityDefinitionCryptLordLocustSwarm)): fun(a: AbilityDefinitionCryptLordLocustSwarm)

---@type AbilityFactoryCryptLordLocustSwarm
A.cryptLordLocustSwarm = setmetatable({
    parent = AbilityIds.cryptLordLocustSwarm,
    apply = identity,
}, callMt)

---@class AbilityFactorySleep2
---@overload fun(data: AbilityRow<AbilityDefinitionDreadlordSleep>?): AbilityRow<AbilityDefinitionDreadlordSleep>
---@field apply fun(fn: fun(a: AbilityDefinitionDreadlordSleep)): fun(a: AbilityDefinitionDreadlordSleep)

---@type AbilityFactorySleep2
A.sleep2 = setmetatable({
    parent = AbilityIds.sleep2,
    apply = identity,
}, callMt)

---@class AbilityFactoryCryptLordSpikedCarapace
---@overload fun(data: AbilityRow<AbilityDefinitionCryptLordSpikedCarapace>?): AbilityRow<AbilityDefinitionCryptLordSpikedCarapace>
---@field apply fun(fn: fun(a: AbilityDefinitionCryptLordSpikedCarapace)): fun(a: AbilityDefinitionCryptLordSpikedCarapace)

---@type AbilityFactoryCryptLordSpikedCarapace
A.cryptLordSpikedCarapace = setmetatable({
    parent = AbilityIds.cryptLordSpikedCarapace,
    apply = identity,
}, callMt)

---@class AbilityFactoryAuraRegenerationStatue
---@overload fun(data: AbilityRow<AbilityDefinitionAuraRegenerationStatue>?): AbilityRow<AbilityDefinitionAuraRegenerationStatue>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraRegenerationStatue)): fun(a: AbilityDefinitionAuraRegenerationStatue)

---@type AbilityFactoryAuraRegenerationStatue
A.auraRegenerationStatue = setmetatable({
    parent = AbilityIds.auraRegenerationStatue,
    apply = identity,
}, callMt)

---@class AbilityFactoryAbsorbMana
---@overload fun(data: AbilityRow<AbilityDefinitionAbsorbMana>?): AbilityRow<AbilityDefinitionAbsorbMana>
---@field apply fun(fn: fun(a: AbilityDefinitionAbsorbMana)): fun(a: AbilityDefinitionAbsorbMana)

---@type AbilityFactoryAbsorbMana
A.absorbMana = setmetatable({
    parent = AbilityIds.absorbMana,
    apply = identity,
}, callMt)

---@class AbilityFactoryAbolishMagic
---@overload fun(data: AbilityRow<AbilityDefinitionAbolishMagic>?): AbilityRow<AbilityDefinitionAbolishMagic>
---@field apply fun(fn: fun(a: AbilityDefinitionAbolishMagic)): fun(a: AbilityDefinitionAbolishMagic)

---@type AbilityFactoryAbolishMagic
A.abolishMagic = setmetatable({
    parent = AbilityIds.abolishMagic,
    apply = identity,
}, callMt)

---@class AbilityFactoryWarDrums
---@overload fun(data: AbilityRow<AbilityDefinitionAuraWarDrumsKodobeast>?): AbilityRow<AbilityDefinitionAuraWarDrumsKodobeast>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraWarDrumsKodobeast)): fun(a: AbilityDefinitionAuraWarDrumsKodobeast)

---@type AbilityFactoryWarDrums
A.warDrums = setmetatable({
    parent = AbilityIds.warDrums,
    apply = identity,
}, callMt)

---@class AbilityFactoryAlliedBuilding
---@overload fun(data: AbilityRow<AbilityDefinitionAlliedBuilding>?): AbilityRow<AbilityDefinitionAlliedBuilding>
---@field apply fun(fn: fun(a: AbilityDefinitionAlliedBuilding)): fun(a: AbilityDefinitionAlliedBuilding)

---@type AbilityFactoryAlliedBuilding
A.alliedBuilding = setmetatable({
    parent = AbilityIds.alliedBuilding,
    apply = identity,
}, callMt)

---@class AbilityFactoryShopSharingAlliedBldg
---@overload fun(data: AbilityRow<AbilityDefinitionAlliedBuilding>?): AbilityRow<AbilityDefinitionAlliedBuilding>
---@field apply fun(fn: fun(a: AbilityDefinitionAlliedBuilding)): fun(a: AbilityDefinitionAlliedBuilding)

---@type AbilityFactoryShopSharingAlliedBldg
A.shopSharingAlliedBldg = setmetatable({
    parent = AbilityIds.shopSharingAlliedBldg,
    apply = identity,
}, callMt)

---@class AbilityFactoryAntimagicShieldMatrix
---@overload fun(data: AbilityRow<AbilityDefinitionAntimagicShieldMatrix>?): AbilityRow<AbilityDefinitionAntimagicShieldMatrix>
---@field apply fun(fn: fun(a: AbilityDefinitionAntimagicShieldMatrix)): fun(a: AbilityDefinitionAntimagicShieldMatrix)

---@type AbilityFactoryAntimagicShieldMatrix
A.antimagicShieldMatrix = setmetatable({
    parent = AbilityIds.antimagicShieldMatrix,
    apply = identity,
}, callMt)

---@class AbilityFactoryAttributeModifierSkill
---@overload fun(data: AbilityRow<AbilityDefinitionAttributeModifierSkill>?): AbilityRow<AbilityDefinitionAttributeModifierSkill>
---@field apply fun(fn: fun(a: AbilityDefinitionAttributeModifierSkill)): fun(a: AbilityDefinitionAttributeModifierSkill)

---@type AbilityFactoryAttributeModifierSkill
A.attributeModifierSkill = setmetatable({
    parent = AbilityIds.attributeModifierSkill,
    apply = identity,
}, callMt)

---@class AbilityFactoryAntimagicShell1
---@overload fun(data: AbilityRow<AbilityDefinitionAntimagicShield>?): AbilityRow<AbilityDefinitionAntimagicShield>
---@field apply fun(fn: fun(a: AbilityDefinitionAntimagicShield)): fun(a: AbilityDefinitionAntimagicShield)

---@type AbilityFactoryAntimagicShell1
A.antimagicShell1 = setmetatable({
    parent = AbilityIds.antimagicShell1,
    apply = identity,
}, callMt)

---@class AbilityFactoryAuraPlagueAbomination
---@overload fun(data: AbilityRow<AbilityDefinitionAuraPlagueAbomination>?): AbilityRow<AbilityDefinitionAuraPlagueAbomination>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraPlagueAbomination)): fun(a: AbilityDefinitionAuraPlagueAbomination)

---@type AbilityFactoryAuraPlagueAbomination
A.auraPlagueAbomination = setmetatable({
    parent = AbilityIds.auraPlagueAbomination,
    apply = identity,
}, callMt)

---@class AbilityFactoryDiseaseCloud
---@overload fun(data: AbilityRow<AbilityDefinitionAuraPlaguePlagueWard>?): AbilityRow<AbilityDefinitionAuraPlaguePlagueWard>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraPlaguePlagueWard)): fun(a: AbilityDefinitionAuraPlaguePlagueWard)

---@type AbilityFactoryDiseaseCloud
A.diseaseCloud = setmetatable({
    parent = AbilityIds.diseaseCloud,
    apply = identity,
}, callMt)

---@class AbilityFactoryAuraPlagueCreep
---@overload fun(data: AbilityRow<AbilityDefinitionAuraPlagueCreep>?): AbilityRow<AbilityDefinitionAuraPlagueCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraPlagueCreep)): fun(a: AbilityDefinitionAuraPlagueCreep)

---@type AbilityFactoryAuraPlagueCreep
A.auraPlagueCreep = setmetatable({
    parent = AbilityIds.auraPlagueCreep,
    apply = identity,
}, callMt)

---@class AbilityFactoryAuraPlagueCreepnodamage
---@overload fun(data: AbilityRow<AbilityDefinitionAuraPlagueCreepnodamage>?): AbilityRow<AbilityDefinitionAuraPlagueCreepnodamage>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraPlagueCreepnodamage)): fun(a: AbilityDefinitionAuraPlagueCreepnodamage)

---@type AbilityFactoryAuraPlagueCreepnodamage
A.auraPlagueCreepnodamage = setmetatable({
    parent = AbilityIds.auraPlagueCreepnodamage,
    apply = identity,
}, callMt)

---@class AbilityFactoryDiseaseCloud1
---@overload fun(data: AbilityRow<AbilityDefinitionAapl>?): AbilityRow<AbilityDefinitionAapl>
---@field apply fun(fn: fun(a: AbilityDefinitionAapl)): fun(a: AbilityDefinitionAapl)

---@type AbilityFactoryDiseaseCloud1
A.diseaseCloud1 = setmetatable({
    parent = AbilityIds.diseaseCloud1,
    apply = identity,
}, callMt)

---@class AbilityFactoryManaRegenerationAura
---@overload fun(data: AbilityRow<AbilityDefinitionAarm>?): AbilityRow<AbilityDefinitionAarm>
---@field apply fun(fn: fun(a: AbilityDefinitionAarm)): fun(a: AbilityDefinitionAarm)

---@type AbilityFactoryManaRegenerationAura
A.manaRegenerationAura = setmetatable({
    parent = AbilityIds.manaRegenerationAura,
    apply = identity,
}, callMt)

---@class AbilityFactorySlowAura
---@overload fun(data: AbilityRow<AbilityDefinitionAuraSlow>?): AbilityRow<AbilityDefinitionAuraSlow>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraSlow)): fun(a: AbilityDefinitionAuraSlow)

---@type AbilityFactorySlowAura
A.slowAura = setmetatable({
    parent = AbilityIds.slowAura,
    apply = identity,
}, callMt)

---@class AbilityFactoryAncestralSpirit
---@overload fun(data: AbilityRow<AbilityDefinitionAncestralSpirit>?): AbilityRow<AbilityDefinitionAncestralSpirit>
---@field apply fun(fn: fun(a: AbilityDefinitionAncestralSpirit)): fun(a: AbilityDefinitionAncestralSpirit)

---@type AbilityFactoryAncestralSpirit
A.ancestralSpirit = setmetatable({
    parent = AbilityIds.ancestralSpirit,
    apply = identity,
}, callMt)

---@class AbilityFactoryAvengerForm
---@overload fun(data: AbilityRow<AbilityDefinitionAvengerForm>?): AbilityRow<AbilityDefinitionAvengerForm>
---@field apply fun(fn: fun(a: AbilityDefinitionAvengerForm)): fun(a: AbilityDefinitionAvengerForm)

---@type AbilityFactoryAvengerForm
A.avengerForm = setmetatable({
    parent = AbilityIds.avengerForm,
    apply = identity,
}, callMt)

---@class AbilityFactoryBlightDispelLarge
---@overload fun(data: AbilityRow<AbilityDefinitionBlightDispelLarge>?): AbilityRow<AbilityDefinitionBlightDispelLarge>
---@field apply fun(fn: fun(a: AbilityDefinitionBlightDispelLarge)): fun(a: AbilityDefinitionBlightDispelLarge)

---@type AbilityFactoryBlightDispelLarge
A.blightDispelLarge = setmetatable({
    parent = AbilityIds.blightDispelLarge,
    apply = identity,
}, callMt)

---@class AbilityFactoryBlightDispelSmall
---@overload fun(data: AbilityRow<AbilityDefinitionBlightDispelSmall>?): AbilityRow<AbilityDefinitionBlightDispelSmall>
---@field apply fun(fn: fun(a: AbilityDefinitionBlightDispelSmall)): fun(a: AbilityDefinitionBlightDispelSmall)

---@type AbilityFactoryBlightDispelSmall
A.blightDispelSmall = setmetatable({
    parent = AbilityIds.blightDispelSmall,
    apply = identity,
}, callMt)

---@class AbilityFactoryBurrowDetectionFlyers
---@overload fun(data: AbilityRow<AbilityDefinitionBurrowDetectionFlyers>?): AbilityRow<AbilityDefinitionBurrowDetectionFlyers>
---@field apply fun(fn: fun(a: AbilityDefinitionBurrowDetectionFlyers)): fun(a: AbilityDefinitionBurrowDetectionFlyers)

---@type AbilityFactoryBurrowDetectionFlyers
A.burrowDetectionFlyers = setmetatable({
    parent = AbilityIds.burrowDetectionFlyers,
    apply = identity,
}, callMt)

---@class AbilityFactoryBlightGrowthLarge
---@overload fun(data: AbilityRow<AbilityDefinitionBlightGrowthLarge>?): AbilityRow<AbilityDefinitionBlightGrowthLarge>
---@field apply fun(fn: fun(a: AbilityDefinitionBlightGrowthLarge)): fun(a: AbilityDefinitionBlightGrowthLarge)

---@type AbilityFactoryBlightGrowthLarge
A.blightGrowthLarge = setmetatable({
    parent = AbilityIds.blightGrowthLarge,
    apply = identity,
}, callMt)

---@class AbilityFactoryBlightedGoldMineAbility
---@overload fun(data: AbilityRow<AbilityDefinitionBlightedGoldmine>?): AbilityRow<AbilityDefinitionBlightedGoldmine>
---@field apply fun(fn: fun(a: AbilityDefinitionBlightedGoldmine)): fun(a: AbilityDefinitionBlightedGoldmine)

---@type AbilityFactoryBlightedGoldMineAbility
A.blightedGoldMineAbility = setmetatable({
    parent = AbilityIds.blightedGoldMineAbility,
    apply = identity,
}, callMt)

---@class AbilityFactoryBlightGrowthSmall
---@overload fun(data: AbilityRow<AbilityDefinitionBlightGrowthSmall>?): AbilityRow<AbilityDefinitionBlightGrowthSmall>
---@field apply fun(fn: fun(a: AbilityDefinitionBlightGrowthSmall)): fun(a: AbilityDefinitionBlightGrowthSmall)

---@type AbilityFactoryBlightGrowthSmall
A.blightGrowthSmall = setmetatable({
    parent = AbilityIds.blightGrowthSmall,
    apply = identity,
}, callMt)

---@class AbilityFactoryBloodlust1
---@overload fun(data: AbilityRow<AbilityDefinitionBloodlust>?): AbilityRow<AbilityDefinitionBloodlust>
---@field apply fun(fn: fun(a: AbilityDefinitionBloodlust)): fun(a: AbilityDefinitionBloodlust)

---@type AbilityFactoryBloodlust1
A.bloodlust1 = setmetatable({
    parent = AbilityIds.bloodlust1,
    apply = identity,
}, callMt)

---@class AbilityFactoryBlightPlacement
---@overload fun(data: AbilityRow<AbilityDefinitionBlightPlacement>?): AbilityRow<AbilityDefinitionBlightPlacement>
---@field apply fun(fn: fun(a: AbilityDefinitionBlightPlacement)): fun(a: AbilityDefinitionBlightPlacement)

---@type AbilityFactoryBlightPlacement
A.blightPlacement = setmetatable({
    parent = AbilityIds.blightPlacement,
    apply = identity,
}, callMt)

---@class AbilityFactoryBallsofFire
---@overload fun(data: AbilityRow<AbilityDefinitionBallsofFire>?): AbilityRow<AbilityDefinitionBallsofFire>
---@field apply fun(fn: fun(a: AbilityDefinitionBallsofFire)): fun(a: AbilityDefinitionBallsofFire)

---@type AbilityFactoryBallsofFire
A.ballsofFire = setmetatable({
    parent = AbilityIds.ballsofFire,
    apply = identity,
}, callMt)

---@class AbilityFactoryBearForm
---@overload fun(data: AbilityRow<AbilityDefinitionBearform>?): AbilityRow<AbilityDefinitionBearform>
---@field apply fun(fn: fun(a: AbilityDefinitionBearform)): fun(a: AbilityDefinitionBearform)

---@type AbilityFactoryBearForm
A.bearForm = setmetatable({
    parent = AbilityIds.bearForm,
    apply = identity,
}, callMt)

---@class AbilityFactoryBerserkerRage1
---@overload fun(data: AbilityRow<AbilityDefinitionBeserk>?): AbilityRow<AbilityDefinitionBeserk>
---@field apply fun(fn: fun(a: AbilityDefinitionBeserk)): fun(a: AbilityDefinitionBeserk)

---@type AbilityFactoryBerserkerRage1
A.berserkerRage1 = setmetatable({
    parent = AbilityIds.berserkerRage1,
    apply = identity,
}, callMt)

---@class AbilityFactoryBattleStations
---@overload fun(data: AbilityRow<AbilityDefinitionBattlestations>?): AbilityRow<AbilityDefinitionBattlestations>
---@field apply fun(fn: fun(a: AbilityDefinitionBattlestations)): fun(a: AbilityDefinitionBattlestations)

---@type AbilityFactoryBattleStations
A.battleStations = setmetatable({
    parent = AbilityIds.battleStations,
    apply = identity,
}, callMt)

---@class AbilityFactoryBurrowscarablvl2
---@overload fun(data: AbilityRow<AbilityDefinitionBurrowscarablvl2>?): AbilityRow<AbilityDefinitionBurrowscarablvl2>
---@field apply fun(fn: fun(a: AbilityDefinitionBurrowscarablvl2)): fun(a: AbilityDefinitionBurrowscarablvl2)

---@type AbilityFactoryBurrowscarablvl2
A.burrowscarablvl2 = setmetatable({
    parent = AbilityIds.burrowscarablvl2,
    apply = identity,
}, callMt)

---@class AbilityFactoryBurrowscarablvl3
---@overload fun(data: AbilityRow<AbilityDefinitionBurrowscarablvl3>?): AbilityRow<AbilityDefinitionBurrowscarablvl3>
---@field apply fun(fn: fun(a: AbilityDefinitionBurrowscarablvl3)): fun(a: AbilityDefinitionBurrowscarablvl3)

---@type AbilityFactoryBurrowscarablvl3
A.burrowscarablvl3 = setmetatable({
    parent = AbilityIds.burrowscarablvl3,
    apply = identity,
}, callMt)

---@class AbilityFactoryCargoHold
---@overload fun(data: AbilityRow<AbilityDefinitionCargoHoldBurrow>?): AbilityRow<AbilityDefinitionCargoHoldBurrow>
---@field apply fun(fn: fun(a: AbilityDefinitionCargoHoldBurrow)): fun(a: AbilityDefinitionCargoHoldBurrow)

---@type AbilityFactoryCargoHold
A.cargoHold = setmetatable({
    parent = AbilityIds.cargoHold,
    apply = identity,
}, callMt)

---@class AbilityFactoryBurrow
---@overload fun(data: AbilityRow<AbilityDefinitionBurrow>?): AbilityRow<AbilityDefinitionBurrow>
---@field apply fun(fn: fun(a: AbilityDefinitionBurrow)): fun(a: AbilityDefinitionBurrow)

---@type AbilityFactoryBurrow
A.burrow = setmetatable({
    parent = AbilityIds.burrow,
    apply = identity,
}, callMt)

---@class AbilityFactoryCannibalize
---@overload fun(data: AbilityRow<AbilityDefinitionCannibalize>?): AbilityRow<AbilityDefinitionCannibalize>
---@field apply fun(fn: fun(a: AbilityDefinitionCannibalize)): fun(a: AbilityDefinitionCannibalize)

---@type AbilityFactoryCannibalize
A.cannibalize = setmetatable({
    parent = AbilityIds.cannibalize,
    apply = identity,
}, callMt)

---@class AbilityFactoryChaos
---@overload fun(data: AbilityRow<AbilityDefinitionAcha>?): AbilityRow<AbilityDefinitionAcha>
---@field apply fun(fn: fun(a: AbilityDefinitionAcha)): fun(a: AbilityDefinitionAcha)

---@type AbilityFactoryChaos
A.chaos = setmetatable({
    parent = AbilityIds.chaos,
    apply = identity,
}, callMt)

---@class AbilityFactoryCargoHoldDeath
---@overload fun(data: AbilityRow<AbilityDefinitionCargoHoldDeath>?): AbilityRow<AbilityDefinitionCargoHoldDeath>
---@field apply fun(fn: fun(a: AbilityDefinitionCargoHoldDeath)): fun(a: AbilityDefinitionCargoHoldDeath)

---@type AbilityFactoryCargoHoldDeath
A.cargoHoldDeath = setmetatable({
    parent = AbilityIds.cargoHoldDeath,
    apply = identity,
}, callMt)

---@class AbilityFactoryChaosCargoLoad
---@overload fun(data: AbilityRow<AbilityDefinitionChaosCargoLoad>?): AbilityRow<AbilityDefinitionChaosCargoLoad>
---@field apply fun(fn: fun(a: AbilityDefinitionChaosCargoLoad)): fun(a: AbilityDefinitionChaosCargoLoad)

---@type AbilityFactoryChaosCargoLoad
A.chaosCargoLoad = setmetatable({
    parent = AbilityIds.chaosCargoLoad,
    apply = identity,
}, callMt)

---@class AbilityFactoryCloudofFog
---@overload fun(data: AbilityRow<AbilityDefinitionCloudofFog>?): AbilityRow<AbilityDefinitionCloudofFog>
---@field apply fun(fn: fun(a: AbilityDefinitionCloudofFog)): fun(a: AbilityDefinitionCloudofFog)

---@type AbilityFactoryCloudofFog
A.cloudofFog = setmetatable({
    parent = AbilityIds.cloudofFog,
    apply = identity,
}, callMt)

---@class AbilityFactoryControlMagic
---@overload fun(data: AbilityRow<AbilityDefinitionControlMagic>?): AbilityRow<AbilityDefinitionControlMagic>
---@field apply fun(fn: fun(a: AbilityDefinitionControlMagic)): fun(a: AbilityDefinitionControlMagic)

---@type AbilityFactoryControlMagic
A.controlMagic = setmetatable({
    parent = AbilityIds.controlMagic,
    apply = identity,
}, callMt)

---@class AbilityFactoryCoupleInstantArcher
---@overload fun(data: AbilityRow<AbilityDefinitionCoupleInstantArcher>?): AbilityRow<AbilityDefinitionCoupleInstantArcher>
---@field apply fun(fn: fun(a: AbilityDefinitionCoupleInstantArcher)): fun(a: AbilityDefinitionCoupleInstantArcher)

---@type AbilityFactoryCoupleInstantArcher
A.coupleInstantArcher = setmetatable({
    parent = AbilityIds.coupleInstantArcher,
    apply = identity,
}, callMt)

---@class AbilityFactoryCoupleInstantHippogryph
---@overload fun(data: AbilityRow<AbilityDefinitionCoupleInstantHippogryph>?): AbilityRow<AbilityDefinitionCoupleInstantHippogryph>
---@field apply fun(fn: fun(a: AbilityDefinitionCoupleInstantHippogryph)): fun(a: AbilityDefinitionCoupleInstantHippogryph)

---@type AbilityFactoryCoupleInstantHippogryph
A.coupleInstantHippogryph = setmetatable({
    parent = AbilityIds.coupleInstantHippogryph,
    apply = identity,
}, callMt)

---@class AbilityFactoryMountHippogryph
---@overload fun(data: AbilityRow<AbilityDefinitionCoupleArcher>?): AbilityRow<AbilityDefinitionCoupleArcher>
---@field apply fun(fn: fun(a: AbilityDefinitionCoupleArcher)): fun(a: AbilityDefinitionCoupleArcher)

---@type AbilityFactoryMountHippogryph
A.mountHippogryph = setmetatable({
    parent = AbilityIds.mountHippogryph,
    apply = identity,
}, callMt)

---@class AbilityFactoryPickupArcher
---@overload fun(data: AbilityRow<AbilityDefinitionCoupleHippogryph>?): AbilityRow<AbilityDefinitionCoupleHippogryph>
---@field apply fun(fn: fun(a: AbilityDefinitionCoupleHippogryph)): fun(a: AbilityDefinitionCoupleHippogryph)

---@type AbilityFactoryPickupArcher
A.pickupArcher = setmetatable({
    parent = AbilityIds.pickupArcher,
    apply = identity,
}, callMt)

---@class AbilityFactoryCorrosiveBreath
---@overload fun(data: AbilityRow<AbilityDefinitionCorrosiveBreath>?): AbilityRow<AbilityDefinitionCorrosiveBreath>
---@field apply fun(fn: fun(a: AbilityDefinitionCorrosiveBreath)): fun(a: AbilityDefinitionCorrosiveBreath)

---@type AbilityFactoryCorrosiveBreath
A.corrosiveBreath = setmetatable({
    parent = AbilityIds.corrosiveBreath,
    apply = identity,
}, callMt)

---@class AbilityFactoryCorporealForm
---@overload fun(data: AbilityRow<AbilityDefinitionCorporealForm>?): AbilityRow<AbilityDefinitionCorporealForm>
---@field apply fun(fn: fun(a: AbilityDefinitionCorporealForm)): fun(a: AbilityDefinitionCorporealForm)

---@type AbilityFactoryCorporealForm
A.corporealForm = setmetatable({
    parent = AbilityIds.corporealForm,
    apply = identity,
}, callMt)

---@class AbilityFactoryCripple
---@overload fun(data: AbilityRow<AbilityDefinitionCripple>?): AbilityRow<AbilityDefinitionCripple>
---@field apply fun(fn: fun(a: AbilityDefinitionCripple)): fun(a: AbilityDefinitionCripple)

---@type AbilityFactoryCripple
A.cripple = setmetatable({
    parent = AbilityIds.cripple,
    apply = identity,
}, callMt)

---@class AbilityFactoryCurse
---@overload fun(data: AbilityRow<AbilityDefinitionCurse>?): AbilityRow<AbilityDefinitionCurse>
---@field apply fun(fn: fun(a: AbilityDefinitionCurse)): fun(a: AbilityDefinitionCurse)

---@type AbilityFactoryCurse
A.curse = setmetatable({
    parent = AbilityIds.curse,
    apply = identity,
}, callMt)

---@class AbilityFactoryCyclone1
---@overload fun(data: AbilityRow<AbilityDefinitionCyclone>?): AbilityRow<AbilityDefinitionCyclone>
---@field apply fun(fn: fun(a: AbilityDefinitionCyclone)): fun(a: AbilityDefinitionCyclone)

---@type AbilityFactoryCyclone1
A.cyclone1 = setmetatable({
    parent = AbilityIds.cyclone1,
    apply = identity,
}, callMt)

---@class AbilityFactoryDisenchantold
---@overload fun(data: AbilityRow<AbilityDefinitionDisenchantold>?): AbilityRow<AbilityDefinitionDisenchantold>
---@field apply fun(fn: fun(a: AbilityDefinitionDisenchantold)): fun(a: AbilityDefinitionDisenchantold)

---@type AbilityFactoryDisenchantold
A.disenchantold = setmetatable({
    parent = AbilityIds.disenchantold,
    apply = identity,
}, callMt)

---@class AbilityFactoryAOEdamageupondeath
---@overload fun(data: AbilityRow<AbilityDefinitionDeathDamageAOEsapper>?): AbilityRow<AbilityDefinitionDeathDamageAOEsapper>
---@field apply fun(fn: fun(a: AbilityDefinitionDeathDamageAOEsapper)): fun(a: AbilityDefinitionDeathDamageAOEsapper)

---@type AbilityFactoryAOEdamageupondeath
A.aOEdamageupondeath = setmetatable({
    parent = AbilityIds.aOEdamageupondeath,
    apply = identity,
}, callMt)

---@class AbilityFactoryDecouple
---@overload fun(data: AbilityRow<AbilityDefinitionDecouple>?): AbilityRow<AbilityDefinitionDecouple>
---@field apply fun(fn: fun(a: AbilityDefinitionDecouple)): fun(a: AbilityDefinitionDecouple)

---@type AbilityFactoryDecouple
A.decouple = setmetatable({
    parent = AbilityIds.decouple,
    apply = identity,
}, callMt)

---@class AbilityFactoryDefend
---@overload fun(data: AbilityRow<AbilityDefinitionDefend>?): AbilityRow<AbilityDefinitionDefend>
---@field apply fun(fn: fun(a: AbilityDefinitionDefend)): fun(a: AbilityDefinitionDefend)

---@type AbilityFactoryDefend
A.defend = setmetatable({
    parent = AbilityIds.defend,
    apply = identity,
}, callMt)

---@class AbilityFactoryDetector
---@overload fun(data: AbilityRow<AbilityDefinitionAdet>?): AbilityRow<AbilityDefinitionAdet>
---@field apply fun(fn: fun(a: AbilityDefinitionAdet)): fun(a: AbilityDefinitionAdet)

---@type AbilityFactoryDetector
A.detector = setmetatable({
    parent = AbilityIds.detector,
    apply = identity,
}, callMt)

---@class AbilityFactoryDevour1
---@overload fun(data: AbilityRow<AbilityDefinitionDevour>?): AbilityRow<AbilityDefinitionDevour>
---@field apply fun(fn: fun(a: AbilityDefinitionDevour)): fun(a: AbilityDefinitionDevour)

---@type AbilityFactoryDevour1
A.devour1 = setmetatable({
    parent = AbilityIds.devour1,
    apply = identity,
}, callMt)

---@class AbilityFactoryDispelMagic
---@overload fun(data: AbilityRow<AbilityDefinitionDispelMagic>?): AbilityRow<AbilityDefinitionDispelMagic>
---@field apply fun(fn: fun(a: AbilityDefinitionDispelMagic)): fun(a: AbilityDefinitionDispelMagic)

---@type AbilityFactoryDispelMagic
A.dispelMagic = setmetatable({
    parent = AbilityIds.dispelMagic,
    apply = identity,
}, callMt)

---@class AbilityFactoryDispelMagic1
---@overload fun(data: AbilityRow<AbilityDefinitionDispelMagiccreep>?): AbilityRow<AbilityDefinitionDispelMagiccreep>
---@field apply fun(fn: fun(a: AbilityDefinitionDispelMagiccreep)): fun(a: AbilityDefinitionDispelMagiccreep)

---@type AbilityFactoryDispelMagic1
A.dispelMagic1 = setmetatable({
    parent = AbilityIds.dispelMagic1,
    apply = identity,
}, callMt)

---@class AbilityFactoryDetectSentryWard
---@overload fun(data: AbilityRow<AbilityDefinitionDetectSentryWard>?): AbilityRow<AbilityDefinitionDetectSentryWard>
---@field apply fun(fn: fun(a: AbilityDefinitionDetectSentryWard)): fun(a: AbilityDefinitionDetectSentryWard)

---@type AbilityFactoryDetectSentryWard
A.detectSentryWard = setmetatable({
    parent = AbilityIds.detectSentryWard,
    apply = identity,
}, callMt)

---@class AbilityFactoryTrueSight1
---@overload fun(data: AbilityRow<AbilityDefinitionDetectgeneral>?): AbilityRow<AbilityDefinitionDetectgeneral>
---@field apply fun(fn: fun(a: AbilityDefinitionDetectgeneral)): fun(a: AbilityDefinitionDetectgeneral)

---@type AbilityFactoryTrueSight1
A.trueSight1 = setmetatable({
    parent = AbilityIds.trueSight1,
    apply = identity,
}, callMt)

---@class AbilityFactoryDetonate
---@overload fun(data: AbilityRow<AbilityDefinitionDetonate>?): AbilityRow<AbilityDefinitionDetonate>
---@field apply fun(fn: fun(a: AbilityDefinitionDetonate)): fun(a: AbilityDefinitionDetonate)

---@type AbilityFactoryDetonate
A.detonate = setmetatable({
    parent = AbilityIds.detonate,
    apply = identity,
}, callMt)

---@class AbilityFactoryMagicSentry
---@overload fun(data: AbilityRow<AbilityDefinitionDetectMagicSentinel>?): AbilityRow<AbilityDefinitionDetectMagicSentinel>
---@field apply fun(fn: fun(a: AbilityDefinitionDetectMagicSentinel)): fun(a: AbilityDefinitionDetectMagicSentinel)

---@type AbilityFactoryMagicSentry
A.magicSentry = setmetatable({
    parent = AbilityIds.magicSentry,
    apply = identity,
}, callMt)

---@class AbilityFactoryDevourCargo
---@overload fun(data: AbilityRow<AbilityDefinitionCargoHoldDevour>?): AbilityRow<AbilityDefinitionCargoHoldDevour>
---@field apply fun(fn: fun(a: AbilityDefinitionCargoHoldDevour)): fun(a: AbilityDefinitionCargoHoldDevour)

---@type AbilityFactoryDevourCargo
A.devourCargo = setmetatable({
    parent = AbilityIds.devourCargo,
    apply = identity,
}, callMt)

---@class AbilityFactoryDevourMagic
---@overload fun(data: AbilityRow<AbilityDefinitionDevourMagic>?): AbilityRow<AbilityDefinitionDevourMagic>
---@field apply fun(fn: fun(a: AbilityDefinitionDevourMagic)): fun(a: AbilityDefinitionDevourMagic)

---@type AbilityFactoryDevourMagic
A.devourMagic = setmetatable({
    parent = AbilityIds.devourMagic,
    apply = identity,
}, callMt)

---@class AbilityFactoryEatTree
---@overload fun(data: AbilityRow<AbilityDefinitionEatTree>?): AbilityRow<AbilityDefinitionEatTree>
---@field apply fun(fn: fun(a: AbilityDefinitionEatTree)): fun(a: AbilityDefinitionEatTree)

---@type AbilityFactoryEatTree
A.eatTree = setmetatable({
    parent = AbilityIds.eatTree,
    apply = identity,
}, callMt)

---@class AbilityFactoryEntangledGoldMineAbility
---@overload fun(data: AbilityRow<AbilityDefinitionEntangledGoldMine>?): AbilityRow<AbilityDefinitionEntangledGoldMine>
---@field apply fun(fn: fun(a: AbilityDefinitionEntangledGoldMine)): fun(a: AbilityDefinitionEntangledGoldMine)

---@type AbilityFactoryEntangledGoldMineAbility
A.entangledGoldMineAbility = setmetatable({
    parent = AbilityIds.entangledGoldMineAbility,
    apply = identity,
}, callMt)

---@class AbilityFactoryElunesGrace
---@overload fun(data: AbilityRow<AbilityDefinitionElunesGrace>?): AbilityRow<AbilityDefinitionElunesGrace>
---@field apply fun(fn: fun(a: AbilityDefinitionElunesGrace)): fun(a: AbilityDefinitionElunesGrace)

---@type AbilityFactoryElunesGrace
A.elunesGrace = setmetatable({
    parent = AbilityIds.elunesGrace,
    apply = identity,
}, callMt)

---@class AbilityFactoryLoad1
---@overload fun(data: AbilityRow<AbilityDefinitionCargoHoldEntangledGoldMine>?): AbilityRow<AbilityDefinitionCargoHoldEntangledGoldMine>
---@field apply fun(fn: fun(a: AbilityDefinitionCargoHoldEntangledGoldMine)): fun(a: AbilityDefinitionCargoHoldEntangledGoldMine)

---@type AbilityFactoryLoad1
A.load1 = setmetatable({
    parent = AbilityIds.load1,
    apply = identity,
}, callMt)

---@class AbilityFactoryEntanglingRoots
---@overload fun(data: AbilityRow<AbilityDefinitionEntanglingRootscreep>?): AbilityRow<AbilityDefinitionEntanglingRootscreep>
---@field apply fun(fn: fun(a: AbilityDefinitionEntanglingRootscreep)): fun(a: AbilityDefinitionEntanglingRootscreep)

---@type AbilityFactoryEntanglingRoots
A.entanglingRoots = setmetatable({
    parent = AbilityIds.entanglingRoots,
    apply = identity,
}, callMt)

---@class AbilityFactoryEnsnare1
---@overload fun(data: AbilityRow<AbilityDefinitionEnsnare>?): AbilityRow<AbilityDefinitionEnsnare>
---@field apply fun(fn: fun(a: AbilityDefinitionEnsnare)): fun(a: AbilityDefinitionEnsnare)

---@type AbilityFactoryEnsnare1
A.ensnare1 = setmetatable({
    parent = AbilityIds.ensnare1,
    apply = identity,
}, callMt)

---@class AbilityFactoryEntangleGoldMine
---@overload fun(data: AbilityRow<AbilityDefinitionEntangle>?): AbilityRow<AbilityDefinitionEntangle>
---@field apply fun(fn: fun(a: AbilityDefinitionEntangle)): fun(a: AbilityDefinitionEntangle)

---@type AbilityFactoryEntangleGoldMine
A.entangleGoldMine = setmetatable({
    parent = AbilityIds.entangleGoldMine,
    apply = identity,
}, callMt)

---@class AbilityFactoryEntanglingSeaweed
---@overload fun(data: AbilityRow<AbilityDefinitionEntanglingSeaweed>?): AbilityRow<AbilityDefinitionEntanglingSeaweed>
---@field apply fun(fn: fun(a: AbilityDefinitionEntanglingSeaweed)): fun(a: AbilityDefinitionEntanglingSeaweed)

---@type AbilityFactoryEntanglingSeaweed
A.entanglingSeaweed = setmetatable({
    parent = AbilityIds.entanglingSeaweed,
    apply = identity,
}, callMt)

---@class AbilityFactorySentinel
---@overload fun(data: AbilityRow<AbilityDefinitionSentinel>?): AbilityRow<AbilityDefinitionSentinel>
---@field apply fun(fn: fun(a: AbilityDefinitionSentinel)): fun(a: AbilityDefinitionSentinel)

---@type AbilityFactorySentinel
A.sentinel = setmetatable({
    parent = AbilityIds.sentinel,
    apply = identity,
}, callMt)

---@class AbilityFactoryEtherealForm
---@overload fun(data: AbilityRow<AbilityDefinitionEtherealForm>?): AbilityRow<AbilityDefinitionEtherealForm>
---@field apply fun(fn: fun(a: AbilityDefinitionEtherealForm)): fun(a: AbilityDefinitionEtherealForm)

---@type AbilityFactoryEtherealForm
A.etherealForm = setmetatable({
    parent = AbilityIds.etherealForm,
    apply = identity,
}, callMt)

---@class AbilityFactoryGhostVisible
---@overload fun(data: AbilityRow<AbilityDefinitionGhostVisible>?): AbilityRow<AbilityDefinitionGhostVisible>
---@field apply fun(fn: fun(a: AbilityDefinitionGhostVisible)): fun(a: AbilityDefinitionGhostVisible)

---@type AbilityFactoryGhostVisible
A.ghostVisible = setmetatable({
    parent = AbilityIds.ghostVisible,
    apply = identity,
}, callMt)

---@class AbilityFactoryExhume
---@overload fun(data: AbilityRow<AbilityDefinitionExhume>?): AbilityRow<AbilityDefinitionExhume>
---@field apply fun(fn: fun(a: AbilityDefinitionExhume)): fun(a: AbilityDefinitionExhume)

---@type AbilityFactoryExhume
A.exhume = setmetatable({
    parent = AbilityIds.exhume,
    apply = identity,
}, callMt)

---@class AbilityFactorySentryWard
---@overload fun(data: AbilityRow<AbilityDefinitionSentryWard>?): AbilityRow<AbilityDefinitionSentryWard>
---@field apply fun(fn: fun(a: AbilityDefinitionSentryWard)): fun(a: AbilityDefinitionSentryWard)

---@type AbilityFactorySentryWard
A.sentryWard = setmetatable({
    parent = AbilityIds.sentryWard,
    apply = identity,
}, callMt)

---@class AbilityFactoryFaerieFireAfa2
---@overload fun(data: AbilityRow<AbilityDefinitionFaerieFireAfa2>?): AbilityRow<AbilityDefinitionFaerieFireAfa2>
---@field apply fun(fn: fun(a: AbilityDefinitionFaerieFireAfa2)): fun(a: AbilityDefinitionFaerieFireAfa2)

---@type AbilityFactoryFaerieFireAfa2
A.faerieFireAfa2 = setmetatable({
    parent = AbilityIds.faerieFireAfa2,
    apply = identity,
}, callMt)

---@class AbilityFactoryFaerieFire
---@overload fun(data: AbilityRow<AbilityDefinitionFaerieFire>?): AbilityRow<AbilityDefinitionFaerieFire>
---@field apply fun(fn: fun(a: AbilityDefinitionFaerieFire)): fun(a: AbilityDefinitionFaerieFire)

---@type AbilityFactoryFaerieFire
A.faerieFire = setmetatable({
    parent = AbilityIds.faerieFire,
    apply = identity,
}, callMt)

---@class AbilityFactoryOrbofAnnihilation
---@overload fun(data: AbilityRow<AbilityDefinitionOrbofAnnihilation>?): AbilityRow<AbilityDefinitionOrbofAnnihilation>
---@field apply fun(fn: fun(a: AbilityDefinitionOrbofAnnihilation)): fun(a: AbilityDefinitionOrbofAnnihilation)

---@type AbilityFactoryOrbofAnnihilation
A.orbofAnnihilation = setmetatable({
    parent = AbilityIds.orbofAnnihilation,
    apply = identity,
}, callMt)

---@class AbilityFactoryFeedbackSpiritBeast
---@overload fun(data: AbilityRow<AbilityDefinitionFeedbackSpiritBeast>?): AbilityRow<AbilityDefinitionFeedbackSpiritBeast>
---@field apply fun(fn: fun(a: AbilityDefinitionFeedbackSpiritBeast)): fun(a: AbilityDefinitionFeedbackSpiritBeast)

---@type AbilityFactoryFeedbackSpiritBeast
A.feedbackSpiritBeast = setmetatable({
    parent = AbilityIds.feedbackSpiritBeast,
    apply = identity,
}, callMt)

---@class AbilityFactoryFeedback
---@overload fun(data: AbilityRow<AbilityDefinitionFeedback>?): AbilityRow<AbilityDefinitionFeedback>
---@field apply fun(fn: fun(a: AbilityDefinitionFeedback)): fun(a: AbilityDefinitionFeedback)

---@type AbilityFactoryFeedback
A.feedback = setmetatable({
    parent = AbilityIds.feedback,
    apply = identity,
}, callMt)

---@class AbilityFactoryFeedbackArcaneTower
---@overload fun(data: AbilityRow<AbilityDefinitionFeedbackArcaneTower>?): AbilityRow<AbilityDefinitionFeedbackArcaneTower>
---@field apply fun(fn: fun(a: AbilityDefinitionFeedbackArcaneTower)): fun(a: AbilityDefinitionFeedbackArcaneTower)

---@type AbilityFactoryFeedbackArcaneTower
A.feedbackArcaneTower = setmetatable({
    parent = AbilityIds.feedbackArcaneTower,
    apply = identity,
}, callMt)

---@class AbilityFactoryFlare
---@overload fun(data: AbilityRow<AbilityDefinitionFlare>?): AbilityRow<AbilityDefinitionFlare>
---@field apply fun(fn: fun(a: AbilityDefinitionFlare)): fun(a: AbilityDefinitionFlare)

---@type AbilityFactoryFlare
A.flare = setmetatable({
    parent = AbilityIds.flare,
    apply = identity,
}, callMt)

---@class AbilityFactoryFlakCannon
---@overload fun(data: AbilityRow<AbilityDefinitionFlakCannon>?): AbilityRow<AbilityDefinitionFlakCannon>
---@field apply fun(fn: fun(a: AbilityDefinitionFlakCannon)): fun(a: AbilityDefinitionFlakCannon)

---@type AbilityFactoryFlakCannon
A.flakCannon = setmetatable({
    parent = AbilityIds.flakCannon,
    apply = identity,
}, callMt)

---@class AbilityFactoryFreezingBreath
---@overload fun(data: AbilityRow<AbilityDefinitionFreezingBreath>?): AbilityRow<AbilityDefinitionFreezingBreath>
---@field apply fun(fn: fun(a: AbilityDefinitionFreezingBreath)): fun(a: AbilityDefinitionFreezingBreath)

---@type AbilityFactoryFreezingBreath
A.freezingBreath = setmetatable({
    parent = AbilityIds.freezingBreath,
    apply = identity,
}, callMt)

---@class AbilityFactoryFragShards
---@overload fun(data: AbilityRow<AbilityDefinitionFragShards>?): AbilityRow<AbilityDefinitionFragShards>
---@field apply fun(fn: fun(a: AbilityDefinitionFragShards)): fun(a: AbilityDefinitionFragShards)

---@type AbilityFactoryFragShards
A.fragShards = setmetatable({
    parent = AbilityIds.fragShards,
    apply = identity,
}, callMt)

---@class AbilityFactoryFrenzy
---@overload fun(data: AbilityRow<AbilityDefinitionFrenzy>?): AbilityRow<AbilityDefinitionFrenzy>
---@field apply fun(fn: fun(a: AbilityDefinitionFrenzy)): fun(a: AbilityDefinitionFrenzy)

---@type AbilityFactoryFrenzy
A.frenzy = setmetatable({
    parent = AbilityIds.frenzy,
    apply = identity,
}, callMt)

---@class AbilityFactoryGhost
---@overload fun(data: AbilityRow<AbilityDefinitionGhost>?): AbilityRow<AbilityDefinitionGhost>
---@field apply fun(fn: fun(a: AbilityDefinitionGhost)): fun(a: AbilityDefinitionGhost)

---@type AbilityFactoryGhost
A.ghost = setmetatable({
    parent = AbilityIds.ghost,
    apply = identity,
}, callMt)

---@class AbilityFactoryGoldMineability
---@overload fun(data: AbilityRow<AbilityDefinitionGoldMine>?): AbilityRow<AbilityDefinitionGoldMine>
---@field apply fun(fn: fun(a: AbilityDefinitionGoldMine)): fun(a: AbilityDefinitionGoldMine)

---@type AbilityFactoryGoldMineability
A.goldMineability = setmetatable({
    parent = AbilityIds.goldMineability,
    apply = identity,
}, callMt)

---@class AbilityFactoryGrabTree
---@overload fun(data: AbilityRow<AbilityDefinitionGrabTree>?): AbilityRow<AbilityDefinitionGrabTree>
---@field apply fun(fn: fun(a: AbilityDefinitionGrabTree)): fun(a: AbilityDefinitionGrabTree)

---@type AbilityFactoryGrabTree
A.grabTree = setmetatable({
    parent = AbilityIds.grabTree,
    apply = identity,
}, callMt)

---@class AbilityFactoryCreateCorpse
---@overload fun(data: AbilityRow<AbilityDefinitionGraveyard>?): AbilityRow<AbilityDefinitionGraveyard>
---@field apply fun(fn: fun(a: AbilityDefinitionGraveyard)): fun(a: AbilityDefinitionGraveyard)

---@type AbilityFactoryCreateCorpse
A.createCorpse = setmetatable({
    parent = AbilityIds.createCorpse,
    apply = identity,
}, callMt)

---@class AbilityFactoryTrueSight
---@overload fun(data: AbilityRow<AbilityDefinitionDetectGyrocopter>?): AbilityRow<AbilityDefinitionDetectGyrocopter>
---@field apply fun(fn: fun(a: AbilityDefinitionDetectGyrocopter)): fun(a: AbilityDefinitionDetectGyrocopter)

---@type AbilityFactoryTrueSight
A.trueSight = setmetatable({
    parent = AbilityIds.trueSight,
    apply = identity,
}, callMt)

---@class AbilityFactoryHarvest
---@overload fun(data: AbilityRow<AbilityDefinitionHarvest>?): AbilityRow<AbilityDefinitionHarvest>
---@field apply fun(fn: fun(a: AbilityDefinitionHarvest)): fun(a: AbilityDefinitionHarvest)

---@type AbilityFactoryHarvest
A.harvest = setmetatable({
    parent = AbilityIds.harvest,
    apply = identity,
}, callMt)

---@class AbilityFactoryHeal
---@overload fun(data: AbilityRow<AbilityDefinitionHeal>?): AbilityRow<AbilityDefinitionHeal>
---@field apply fun(fn: fun(a: AbilityDefinitionHeal)): fun(a: AbilityDefinitionHeal)

---@type AbilityFactoryHeal
A.heal = setmetatable({
    parent = AbilityIds.heal,
    apply = identity,
}, callMt)

---@class AbilityFactoryShadowMeldAkama
---@overload fun(data: AbilityRow<AbilityDefinitionShadowMeldAkama>?): AbilityRow<AbilityDefinitionShadowMeldAkama>
---@field apply fun(fn: fun(a: AbilityDefinitionShadowMeldAkama)): fun(a: AbilityDefinitionShadowMeldAkama)

---@type AbilityFactoryShadowMeldAkama
A.shadowMeldAkama = setmetatable({
    parent = AbilityIds.shadowMeldAkama,
    apply = identity,
}, callMt)

---@class AbilityFactoryNullroarsummoner
---@overload fun(data: AbilityRow<AbilityDefinitionnullroarsummoner>?): AbilityRow<AbilityDefinitionnullroarsummoner>
---@field apply fun(fn: fun(a: AbilityDefinitionnullroarsummoner)): fun(a: AbilityDefinitionnullroarsummoner)

---@type AbilityFactoryNullroarsummoner
A.nullroarsummoner = setmetatable({
    parent = AbilityIds.nullroarsummoner,
    apply = identity,
}, callMt)

---@class AbilityFactoryHarvestLumberArchimondeghouls
---@overload fun(data: AbilityRow<AbilityDefinitionHarvestLumberArchimondeghouls>?): AbilityRow<AbilityDefinitionHarvestLumberArchimondeghouls>
---@field apply fun(fn: fun(a: AbilityDefinitionHarvestLumberArchimondeghouls)): fun(a: AbilityDefinitionHarvestLumberArchimondeghouls)

---@type AbilityFactoryHarvestLumberArchimondeghouls
A.harvestLumberArchimondeghouls = setmetatable({
    parent = AbilityIds.harvestLumberArchimondeghouls,
    apply = identity,
}, callMt)

---@class AbilityFactoryHarvest2
---@overload fun(data: AbilityRow<AbilityDefinitionHarvestLumbershredder>?): AbilityRow<AbilityDefinitionHarvestLumbershredder>
---@field apply fun(fn: fun(a: AbilityDefinitionHarvestLumbershredder)): fun(a: AbilityDefinitionHarvestLumbershredder)

---@type AbilityFactoryHarvest2
A.harvest2 = setmetatable({
    parent = AbilityIds.harvest2,
    apply = identity,
}, callMt)

---@class AbilityFactoryHarvest1
---@overload fun(data: AbilityRow<AbilityDefinitionHarvestLumber>?): AbilityRow<AbilityDefinitionHarvestLumber>
---@field apply fun(fn: fun(a: AbilityDefinitionHarvestLumber)): fun(a: AbilityDefinitionHarvestLumber)

---@type AbilityFactoryHarvest1
A.harvest1 = setmetatable({
    parent = AbilityIds.harvest1,
    apply = identity,
}, callMt)

---@class AbilityFactoryRepairHuman
---@overload fun(data: AbilityRow<AbilityDefinitionRepairHuman>?): AbilityRow<AbilityDefinitionRepairHuman>
---@field apply fun(fn: fun(a: AbilityDefinitionRepairHuman)): fun(a: AbilityDefinitionRepairHuman)

---@type AbilityFactoryRepairHuman
A.repairHuman = setmetatable({
    parent = AbilityIds.repairHuman,
    apply = identity,
}, callMt)

---@class AbilityFactoryAhrs
---@overload fun(data: AbilityRow<AbilityDefinitionAhrs>?): AbilityRow<AbilityDefinitionAhrs>
---@field apply fun(fn: fun(a: AbilityDefinitionAhrs)): fun(a: AbilityDefinitionAhrs)

---@type AbilityFactoryAhrs
A.ahrs = setmetatable({
    parent = AbilityIds.ahrs,
    apply = identity,
}, callMt)

---@class AbilityFactorySunderingBlades
---@overload fun(data: AbilityRow<AbilityDefinitionSunderingBlades>?): AbilityRow<AbilityDefinitionSunderingBlades>
---@field apply fun(fn: fun(a: AbilityDefinitionSunderingBlades)): fun(a: AbilityDefinitionSunderingBlades)

---@type AbilityFactorySunderingBlades
A.sunderingBlades = setmetatable({
    parent = AbilityIds.sunderingBlades,
    apply = identity,
}, callMt)

---@class AbilityFactoryHealingWard1
---@overload fun(data: AbilityRow<AbilityDefinitionHealingWard>?): AbilityRow<AbilityDefinitionHealingWard>
---@field apply fun(fn: fun(a: AbilityDefinitionHealingWard)): fun(a: AbilityDefinitionHealingWard)

---@type AbilityFactoryHealingWard1
A.healingWard1 = setmetatable({
    parent = AbilityIds.healingWard1,
    apply = identity,
}, callMt)

---@class AbilityFactoryInnerFire
---@overload fun(data: AbilityRow<AbilityDefinitionInnerFire>?): AbilityRow<AbilityDefinitionInnerFire>
---@field apply fun(fn: fun(a: AbilityDefinitionInnerFire)): fun(a: AbilityDefinitionInnerFire)

---@type AbilityFactoryInnerFire
A.innerFire = setmetatable({
    parent = AbilityIds.innerFire,
    apply = identity,
}, callMt)

---@class AbilityFactoryInventory2slotunitUndead
---@overload fun(data: AbilityRow<AbilityDefinitionInventory2slotunitUndead>?): AbilityRow<AbilityDefinitionInventory2slotunitUndead>
---@field apply fun(fn: fun(a: AbilityDefinitionInventory2slotunitUndead)): fun(a: AbilityDefinitionInventory2slotunitUndead)

---@type AbilityFactoryInventory2slotunitUndead
A.inventory2slotunitUndead = setmetatable({
    parent = AbilityIds.inventory2slotunitUndead,
    apply = identity,
}, callMt)

---@class AbilityFactoryInvisibility
---@overload fun(data: AbilityRow<AbilityDefinitionInvisibility>?): AbilityRow<AbilityDefinitionInvisibility>
---@field apply fun(fn: fun(a: AbilityDefinitionInvisibility)): fun(a: AbilityDefinitionInvisibility)

---@type AbilityFactoryInvisibility
A.invisibility = setmetatable({
    parent = AbilityIds.invisibility,
    apply = identity,
}, callMt)

---@class AbilityFactoryLiquidFire
---@overload fun(data: AbilityRow<AbilityDefinitionLiquidFire>?): AbilityRow<AbilityDefinitionLiquidFire>
---@field apply fun(fn: fun(a: AbilityDefinitionLiquidFire)): fun(a: AbilityDefinitionLiquidFire)

---@type AbilityFactoryLiquidFire
A.liquidFire = setmetatable({
    parent = AbilityIds.liquidFire,
    apply = identity,
}, callMt)

---@class AbilityFactoryLightningAttack
---@overload fun(data: AbilityRow<AbilityDefinitionLightningAttack>?): AbilityRow<AbilityDefinitionLightningAttack>
---@field apply fun(fn: fun(a: AbilityDefinitionLightningAttack)): fun(a: AbilityDefinitionLightningAttack)

---@type AbilityFactoryLightningAttack
A.lightningAttack = setmetatable({
    parent = AbilityIds.lightningAttack,
    apply = identity,
}, callMt)

---@class AbilityFactoryLoad
---@overload fun(data: AbilityRow<AbilityDefinitionLoad>?): AbilityRow<AbilityDefinitionLoad>
---@field apply fun(fn: fun(a: AbilityDefinitionLoad)): fun(a: AbilityDefinitionLoad)

---@type AbilityFactoryLoad
A.load = setmetatable({
    parent = AbilityIds.load,
    apply = identity,
}, callMt)

---@class AbilityFactoryLightningShield
---@overload fun(data: AbilityRow<AbilityDefinitionLightningShield>?): AbilityRow<AbilityDefinitionLightningShield>
---@field apply fun(fn: fun(a: AbilityDefinitionLightningShield)): fun(a: AbilityDefinitionLightningShield)

---@type AbilityFactoryLightningShield
A.lightningShield = setmetatable({
    parent = AbilityIds.lightningShield,
    apply = identity,
}, callMt)

---@class AbilityFactoryManaBatteryObsidianStatue
---@overload fun(data: AbilityRow<AbilityDefinitionManaBatteryObsidianStatue>?): AbilityRow<AbilityDefinitionManaBatteryObsidianStatue>
---@field apply fun(fn: fun(a: AbilityDefinitionManaBatteryObsidianStatue)): fun(a: AbilityDefinitionManaBatteryObsidianStatue)

---@type AbilityFactoryManaBatteryObsidianStatue
A.manaBatteryObsidianStatue = setmetatable({
    parent = AbilityIds.manaBatteryObsidianStatue,
    apply = identity,
}, callMt)

---@class AbilityFactoryManaBurn
---@overload fun(data: AbilityRow<AbilityDefinitionManaBurndemonAmbd>?): AbilityRow<AbilityDefinitionManaBurndemonAmbd>
---@field apply fun(fn: fun(a: AbilityDefinitionManaBurndemonAmbd)): fun(a: AbilityDefinitionManaBurndemonAmbd)

---@type AbilityFactoryManaBurn
A.manaBurn = setmetatable({
    parent = AbilityIds.manaBurn,
    apply = identity,
}, callMt)

---@class AbilityFactoryReplenishManaandLife
---@overload fun(data: AbilityRow<AbilityDefinitionManaBattery>?): AbilityRow<AbilityDefinitionManaBattery>
---@field apply fun(fn: fun(a: AbilityDefinitionManaBattery)): fun(a: AbilityDefinitionManaBattery)

---@type AbilityFactoryReplenishManaandLife
A.replenishManaandLife = setmetatable({
    parent = AbilityIds.replenishManaandLife,
    apply = identity,
}, callMt)

---@class AbilityFactoryMagicDefense
---@overload fun(data: AbilityRow<AbilityDefinitionMagicDefense>?): AbilityRow<AbilityDefinitionMagicDefense>
---@field apply fun(fn: fun(a: AbilityDefinitionMagicDefense)): fun(a: AbilityDefinitionMagicDefense)

---@type AbilityFactoryMagicDefense
A.magicDefense = setmetatable({
    parent = AbilityIds.magicDefense,
    apply = identity,
}, callMt)

---@class AbilityFactoryMechanicalCritter
---@overload fun(data: AbilityRow<AbilityDefinitionMechanicalCritter>?): AbilityRow<AbilityDefinitionMechanicalCritter>
---@field apply fun(fn: fun(a: AbilityDefinitionMechanicalCritter)): fun(a: AbilityDefinitionMechanicalCritter)

---@type AbilityFactoryMechanicalCritter
A.mechanicalCritter = setmetatable({
    parent = AbilityIds.mechanicalCritter,
    apply = identity,
}, callMt)

---@class AbilityFactoryManaFlare
---@overload fun(data: AbilityRow<AbilityDefinitionManaFlare>?): AbilityRow<AbilityDefinitionManaFlare>
---@field apply fun(fn: fun(a: AbilityDefinitionManaFlare)): fun(a: AbilityDefinitionManaFlare)

---@type AbilityFactoryManaFlare
A.manaFlare = setmetatable({
    parent = AbilityIds.manaFlare,
    apply = identity,
}, callMt)

---@class AbilityFactoryCalltoArms
---@overload fun(data: AbilityRow<AbilityDefinitionMilitia>?): AbilityRow<AbilityDefinitionMilitia>
---@field apply fun(fn: fun(a: AbilityDefinitionMilitia)): fun(a: AbilityDefinitionMilitia)

---@type AbilityFactoryCalltoArms
A.calltoArms = setmetatable({
    parent = AbilityIds.calltoArms,
    apply = identity,
}, callMt)

---@class AbilityFactorySpellImmunity2
---@overload fun(data: AbilityRow<AbilityDefinitionMagicImmunity>?): AbilityRow<AbilityDefinitionMagicImmunity>
---@field apply fun(fn: fun(a: AbilityDefinitionMagicImmunity)): fun(a: AbilityDefinitionMagicImmunity)

---@type AbilityFactorySpellImmunity2
A.spellImmunity2 = setmetatable({
    parent = AbilityIds.spellImmunity2,
    apply = identity,
}, callMt)

---@class AbilityFactoryMineexploding
---@overload fun(data: AbilityRow<AbilityDefinitionMine>?): AbilityRow<AbilityDefinitionMine>
---@field apply fun(fn: fun(a: AbilityDefinitionMine)): fun(a: AbilityDefinitionMine)

---@type AbilityFactoryMineexploding
A.mineexploding = setmetatable({
    parent = AbilityIds.mineexploding,
    apply = identity,
}, callMt)

---@class AbilityFactoryAerialShackles
---@overload fun(data: AbilityRow<AbilityDefinitionAerialShackles>?): AbilityRow<AbilityDefinitionAerialShackles>
---@field apply fun(fn: fun(a: AbilityDefinitionAerialShackles)): fun(a: AbilityDefinitionAerialShackles)

---@type AbilityFactoryAerialShackles
A.aerialShackles = setmetatable({
    parent = AbilityIds.aerialShackles,
    apply = identity,
}, callMt)

---@class AbilityFactoryManaBurndemon
---@overload fun(data: AbilityRow<AbilityDefinitionManaBurndemon>?): AbilityRow<AbilityDefinitionManaBurndemon>
---@field apply fun(fn: fun(a: AbilityDefinitionManaBurndemon)): fun(a: AbilityDefinitionManaBurndemon)

---@type AbilityFactoryManaBurndemon
A.manaBurndemon = setmetatable({
    parent = AbilityIds.manaBurndemon,
    apply = identity,
}, callMt)

---@class AbilityFactoryDeathDamageAOEmine
---@overload fun(data: AbilityRow<AbilityDefinitionDeathDamageAOEmine>?): AbilityRow<AbilityDefinitionDeathDamageAOEmine>
---@field apply fun(fn: fun(a: AbilityDefinitionDeathDamageAOEmine)): fun(a: AbilityDefinitionDeathDamageAOEmine)

---@type AbilityFactoryDeathDamageAOEmine
A.deathDamageAOEmine = setmetatable({
    parent = AbilityIds.deathDamageAOEmine,
    apply = identity,
}, callMt)

---@class AbilityFactoryDeathDamageAOEmineBIG
---@overload fun(data: AbilityRow<AbilityDefinitionDeathDamageAOEmineBIG>?): AbilityRow<AbilityDefinitionDeathDamageAOEmineBIG>
---@field apply fun(fn: fun(a: AbilityDefinitionDeathDamageAOEmineBIG)): fun(a: AbilityDefinitionDeathDamageAOEmineBIG)

---@type AbilityFactoryDeathDamageAOEmineBIG
A.deathDamageAOEmineBIG = setmetatable({
    parent = AbilityIds.deathDamageAOEmineBIG,
    apply = identity,
}, callMt)

---@class AbilityFactoryCrowForm
---@overload fun(data: AbilityRow<AbilityDefinitionRavenFormMedivh>?): AbilityRow<AbilityDefinitionRavenFormMedivh>
---@field apply fun(fn: fun(a: AbilityDefinitionRavenFormMedivh)): fun(a: AbilityDefinitionRavenFormMedivh)

---@type AbilityFactoryCrowForm
A.crowForm = setmetatable({
    parent = AbilityIds.crowForm,
    apply = identity,
}, callMt)

---@class AbilityFactoryReveal1
---@overload fun(data: AbilityRow<AbilityDefinitionNeutralDetectionRevealability>?): AbilityRow<AbilityDefinitionNeutralDetectionRevealability>
---@field apply fun(fn: fun(a: AbilityDefinitionNeutralDetectionRevealability)): fun(a: AbilityDefinitionNeutralDetectionRevealability)

---@type AbilityFactoryReveal1
A.reveal1 = setmetatable({
    parent = AbilityIds.reveal1,
    apply = identity,
}, callMt)

---@class AbilityFactoryNeutralBuildinganyunit
---@overload fun(data: AbilityRow<AbilityDefinitionNeutralBuildinganyunit>?): AbilityRow<AbilityDefinitionNeutralBuildinganyunit>
---@field apply fun(fn: fun(a: AbilityDefinitionNeutralBuildinganyunit)): fun(a: AbilityDefinitionNeutralBuildinganyunit)

---@type AbilityFactoryNeutralBuildinganyunit
A.neutralBuildinganyunit = setmetatable({
    parent = AbilityIds.neutralBuildinganyunit,
    apply = identity,
}, callMt)

---@class AbilityFactorySelectHero
---@overload fun(data: AbilityRow<AbilityDefinitionNeutralBuilding>?): AbilityRow<AbilityDefinitionNeutralBuilding>
---@field apply fun(fn: fun(a: AbilityDefinitionNeutralBuilding)): fun(a: AbilityDefinitionNeutralBuilding)

---@type AbilityFactorySelectHero
A.selectHero = setmetatable({
    parent = AbilityIds.selectHero,
    apply = identity,
}, callMt)

---@class AbilityFactoryHealCreepNormal
---@overload fun(data: AbilityRow<AbilityDefinitionHealCreepNormal>?): AbilityRow<AbilityDefinitionHealCreepNormal>
---@field apply fun(fn: fun(a: AbilityDefinitionHealCreepNormal)): fun(a: AbilityDefinitionHealCreepNormal)

---@type AbilityFactoryHealCreepNormal
A.healCreepNormal = setmetatable({
    parent = AbilityIds.healCreepNormal,
    apply = identity,
}, callMt)

---@class AbilityFactoryHealCreepHigh
---@overload fun(data: AbilityRow<AbilityDefinitionHealCreepHigh>?): AbilityRow<AbilityDefinitionHealCreepHigh>
---@field apply fun(fn: fun(a: AbilityDefinitionHealCreepHigh)): fun(a: AbilityDefinitionHealCreepHigh)

---@type AbilityFactoryHealCreepHigh
A.healCreepHigh = setmetatable({
    parent = AbilityIds.healCreepHigh,
    apply = identity,
}, callMt)

---@class AbilityFactoryHeal1
---@overload fun(data: AbilityRow<AbilityDefinitionHealCreepNormalAnhe>?): AbilityRow<AbilityDefinitionHealCreepNormalAnhe>
---@field apply fun(fn: fun(a: AbilityDefinitionHealCreepNormalAnhe)): fun(a: AbilityDefinitionHealCreepNormalAnhe)

---@type AbilityFactoryHeal1
A.heal1 = setmetatable({
    parent = AbilityIds.heal1,
    apply = identity,
}, callMt)

---@class AbilityFactoryNeutralSpies
---@overload fun(data: AbilityRow<AbilityDefinitionNeutralSpies>?): AbilityRow<AbilityDefinitionNeutralSpies>
---@field apply fun(fn: fun(a: AbilityDefinitionNeutralSpies)): fun(a: AbilityDefinitionNeutralSpies)

---@type AbilityFactoryNeutralSpies
A.neutralSpies = setmetatable({
    parent = AbilityIds.neutralSpies,
    apply = identity,
}, callMt)

---@class AbilityFactoryAnwm
---@overload fun(data: AbilityRow<AbilityDefinitionAnwm>?): AbilityRow<AbilityDefinitionAnwm>
---@field apply fun(fn: fun(a: AbilityDefinitionAnwm)): fun(a: AbilityDefinitionAnwm)

---@type AbilityFactoryAnwm
A.anwm = setmetatable({
    parent = AbilityIds.anwm,
    apply = identity,
}, callMt)

---@class AbilityFactoryHealingWardAura
---@overload fun(data: AbilityRow<AbilityDefinitionAuraRegenerationHealingWard>?): AbilityRow<AbilityDefinitionAuraRegenerationHealingWard>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraRegenerationHealingWard)): fun(a: AbilityDefinitionAuraRegenerationHealingWard)

---@type AbilityFactoryHealingWardAura
A.healingWardAura = setmetatable({
    parent = AbilityIds.healingWardAura,
    apply = identity,
}, callMt)

---@class AbilityFactoryInventoryPackMule
---@overload fun(data: AbilityRow<AbilityDefinitionInventoryPackMule>?): AbilityRow<AbilityDefinitionInventoryPackMule>
---@field apply fun(fn: fun(a: AbilityDefinitionInventoryPackMule)): fun(a: AbilityDefinitionInventoryPackMule)

---@type AbilityFactoryInventoryPackMule
A.inventoryPackMule = setmetatable({
    parent = AbilityIds.inventoryPackMule,
    apply = identity,
}, callMt)

---@class AbilityFactoryPurgeApg2
---@overload fun(data: AbilityRow<AbilityDefinitionPurgeApg2>?): AbilityRow<AbilityDefinitionPurgeApg2>
---@field apply fun(fn: fun(a: AbilityDefinitionPurgeApg2)): fun(a: AbilityDefinitionPurgeApg2)

---@type AbilityFactoryPurgeApg2
A.purgeApg2 = setmetatable({
    parent = AbilityIds.purgeApg2,
    apply = identity,
}, callMt)

---@class AbilityFactoryPhoenix2
---@overload fun(data: AbilityRow<AbilityDefinitionPhoenix>?): AbilityRow<AbilityDefinitionPhoenix>
---@field apply fun(fn: fun(a: AbilityDefinitionPhoenix)): fun(a: AbilityDefinitionPhoenix)

---@type AbilityFactoryPhoenix2
A.phoenix2 = setmetatable({
    parent = AbilityIds.phoenix2,
    apply = identity,
}, callMt)

---@class AbilityFactoryPermanentImmolationgraphic
---@overload fun(data: AbilityRow<AbilityDefinitionPermanentImmolationgraphic>?): AbilityRow<AbilityDefinitionPermanentImmolationgraphic>
---@field apply fun(fn: fun(a: AbilityDefinitionPermanentImmolationgraphic)): fun(a: AbilityDefinitionPermanentImmolationgraphic)

---@type AbilityFactoryPermanentImmolationgraphic
A.permanentImmolationgraphic = setmetatable({
    parent = AbilityIds.permanentImmolationgraphic,
    apply = identity,
}, callMt)

---@class AbilityFactoryPermanentInvisibility
---@overload fun(data: AbilityRow<AbilityDefinitionPermanentInvisibility>?): AbilityRow<AbilityDefinitionPermanentInvisibility>
---@field apply fun(fn: fun(a: AbilityDefinitionPermanentInvisibility)): fun(a: AbilityDefinitionPermanentInvisibility)

---@type AbilityFactoryPermanentInvisibility
A.permanentInvisibility = setmetatable({
    parent = AbilityIds.permanentInvisibility,
    apply = identity,
}, callMt)

---@class AbilityFactoryPolymorph
---@overload fun(data: AbilityRow<AbilityDefinitionPolymorph>?): AbilityRow<AbilityDefinitionPolymorph>
---@field apply fun(fn: fun(a: AbilityDefinitionPolymorph)): fun(a: AbilityDefinitionPolymorph)

---@type AbilityFactoryPolymorph
A.polymorph = setmetatable({
    parent = AbilityIds.polymorph,
    apply = identity,
}, callMt)

---@class AbilityFactoryPermanentImmolationflying
---@overload fun(data: AbilityRow<AbilityDefinitionPermanentImmolationflying>?): AbilityRow<AbilityDefinitionPermanentImmolationflying>
---@field apply fun(fn: fun(a: AbilityDefinitionPermanentImmolationflying)): fun(a: AbilityDefinitionPermanentImmolationflying)

---@type AbilityFactoryPermanentImmolationflying
A.permanentImmolationflying = setmetatable({
    parent = AbilityIds.permanentImmolationflying,
    apply = identity,
}, callMt)

---@class AbilityFactoryOrbofVenomPoisonAttack
---@overload fun(data: AbilityRow<AbilityDefinitionOrbofVenomPoisonAttack>?): AbilityRow<AbilityDefinitionOrbofVenomPoisonAttack>
---@field apply fun(fn: fun(a: AbilityDefinitionOrbofVenomPoisonAttack)): fun(a: AbilityDefinitionOrbofVenomPoisonAttack)

---@type AbilityFactoryOrbofVenomPoisonAttack
A.orbofVenomPoisonAttack = setmetatable({
    parent = AbilityIds.orbofVenomPoisonAttack,
    apply = identity,
}, callMt)

---@class AbilityFactoryPoisonSting
---@overload fun(data: AbilityRow<AbilityDefinitionPoisonAttack>?): AbilityRow<AbilityDefinitionPoisonAttack>
---@field apply fun(fn: fun(a: AbilityDefinitionPoisonAttack)): fun(a: AbilityDefinitionPoisonAttack)

---@type AbilityFactoryPoisonSting
A.poisonSting = setmetatable({
    parent = AbilityIds.poisonSting,
    apply = identity,
}, callMt)

---@class AbilityFactoryPossession
---@overload fun(data: AbilityRow<AbilityDefinitionPossession>?): AbilityRow<AbilityDefinitionPossession>
---@field apply fun(fn: fun(a: AbilityDefinitionPossession)): fun(a: AbilityDefinitionPossession)

---@type AbilityFactoryPossession
A.possession = setmetatable({
    parent = AbilityIds.possession,
    apply = identity,
}, callMt)

---@class AbilityFactoryPurge
---@overload fun(data: AbilityRow<AbilityDefinitionPurge>?): AbilityRow<AbilityDefinitionPurge>
---@field apply fun(fn: fun(a: AbilityDefinitionPurge)): fun(a: AbilityDefinitionPurge)

---@type AbilityFactoryPurge
A.purge = setmetatable({
    parent = AbilityIds.purge,
    apply = identity,
}, callMt)

---@class AbilityFactoryPossessionChanneling
---@overload fun(data: AbilityRow<AbilityDefinitionPossessionChanneling>?): AbilityRow<AbilityDefinitionPossessionChanneling>
---@field apply fun(fn: fun(a: AbilityDefinitionPossessionChanneling)): fun(a: AbilityDefinitionPossessionChanneling)

---@type AbilityFactoryPossessionChanneling
A.possessionChanneling = setmetatable({
    parent = AbilityIds.possessionChanneling,
    apply = identity,
}, callMt)

---@class AbilityFactoryPhaseShift
---@overload fun(data: AbilityRow<AbilityDefinitionPhaseShift>?): AbilityRow<AbilityDefinitionPhaseShift>
---@field apply fun(fn: fun(a: AbilityDefinitionPhaseShift)): fun(a: AbilityDefinitionPhaseShift)

---@type AbilityFactoryPhaseShift
A.phaseShift = setmetatable({
    parent = AbilityIds.phaseShift,
    apply = identity,
}, callMt)

---@class AbilityFactoryDiseaseCloud2
---@overload fun(data: AbilityRow<AbilityDefinitionPlagueToss>?): AbilityRow<AbilityDefinitionPlagueToss>
---@field apply fun(fn: fun(a: AbilityDefinitionPlagueToss)): fun(a: AbilityDefinitionPlagueToss)

---@type AbilityFactoryDiseaseCloud2
A.diseaseCloud2 = setmetatable({
    parent = AbilityIds.diseaseCloud2,
    apply = identity,
}, callMt)

---@class AbilityFactoryPhoenixFire
---@overload fun(data: AbilityRow<AbilityDefinitionPhoenixFire>?): AbilityRow<AbilityDefinitionPhoenixFire>
---@field apply fun(fn: fun(a: AbilityDefinitionPhoenixFire)): fun(a: AbilityDefinitionPhoenixFire)

---@type AbilityFactoryPhoenixFire
A.phoenixFire = setmetatable({
    parent = AbilityIds.phoenixFire,
    apply = identity,
}, callMt)

---@class AbilityFactoryRoarAra2
---@overload fun(data: AbilityRow<AbilityDefinitionRoarAra2>?): AbilityRow<AbilityDefinitionRoarAra2>
---@field apply fun(fn: fun(a: AbilityDefinitionRoarAra2)): fun(a: AbilityDefinitionRoarAra2)

---@type AbilityFactoryRoarAra2
A.roarAra2 = setmetatable({
    parent = AbilityIds.roarAra2,
    apply = identity,
}, callMt)

---@class AbilityFactoryRaiseDead
---@overload fun(data: AbilityRow<AbilityDefinitionRaiseDead>?): AbilityRow<AbilityDefinitionRaiseDead>
---@field apply fun(fn: fun(a: AbilityDefinitionRaiseDead)): fun(a: AbilityDefinitionRaiseDead)

---@type AbilityFactoryRaiseDead
A.raiseDead = setmetatable({
    parent = AbilityIds.raiseDead,
    apply = identity,
}, callMt)

---@class AbilityFactoryStormCrowForm
---@overload fun(data: AbilityRow<AbilityDefinitionRavenFormDruidoftheTalon>?): AbilityRow<AbilityDefinitionRavenFormDruidoftheTalon>
---@field apply fun(fn: fun(a: AbilityDefinitionRavenFormDruidoftheTalon)): fun(a: AbilityDefinitionRavenFormDruidoftheTalon)

---@type AbilityFactoryStormCrowForm
A.stormCrowForm = setmetatable({
    parent = AbilityIds.stormCrowForm,
    apply = identity,
}, callMt)

---@class AbilityFactoryRejuvenation1
---@overload fun(data: AbilityRow<AbilityDefinitionRejuvination>?): AbilityRow<AbilityDefinitionRejuvination>
---@field apply fun(fn: fun(a: AbilityDefinitionRejuvination)): fun(a: AbilityDefinitionRejuvination)

---@type AbilityFactoryRejuvenation1
A.rejuvenation1 = setmetatable({
    parent = AbilityIds.rejuvenation1,
    apply = identity,
}, callMt)

---@class AbilityFactoryItemLifeRegeneration
---@overload fun(data: AbilityRow<AbilityDefinitionRegenLife>?): AbilityRow<AbilityDefinitionRegenLife>
---@field apply fun(fn: fun(a: AbilityDefinitionRegenLife)): fun(a: AbilityDefinitionRegenLife)

---@type AbilityFactoryItemLifeRegeneration
A.itemLifeRegeneration = setmetatable({
    parent = AbilityIds.itemLifeRegeneration,
    apply = identity,
}, callMt)

---@class AbilityFactoryRenew
---@overload fun(data: AbilityRow<AbilityDefinitionRenew>?): AbilityRow<AbilityDefinitionRenew>
---@field apply fun(fn: fun(a: AbilityDefinitionRenew)): fun(a: AbilityDefinitionRenew)

---@type AbilityFactoryRenew
A.renew = setmetatable({
    parent = AbilityIds.renew,
    apply = identity,
}, callMt)

---@class AbilityFactoryRepair
---@overload fun(data: AbilityRow<AbilityDefinitionRepairOrc>?): AbilityRow<AbilityDefinitionRepairOrc>
---@field apply fun(fn: fun(a: AbilityDefinitionRepairOrc)): fun(a: AbilityDefinitionRepairOrc)

---@type AbilityFactoryRepair
A.repair = setmetatable({
    parent = AbilityIds.repair,
    apply = identity,
}, callMt)

---@class AbilityFactoryReturnGold
---@overload fun(data: AbilityRow<AbilityDefinitionReturnGold>?): AbilityRow<AbilityDefinitionReturnGold>
---@field apply fun(fn: fun(a: AbilityDefinitionReturnGold)): fun(a: AbilityDefinitionReturnGold)

---@type AbilityFactoryReturnGold
A.returnGold = setmetatable({
    parent = AbilityIds.returnGold,
    apply = identity,
}, callMt)

---@class AbilityFactoryReturnGoldLumber
---@overload fun(data: AbilityRow<AbilityDefinitionReturnGoldLumber>?): AbilityRow<AbilityDefinitionReturnGoldLumber>
---@field apply fun(fn: fun(a: AbilityDefinitionReturnGoldLumber)): fun(a: AbilityDefinitionReturnGoldLumber)

---@type AbilityFactoryReturnGoldLumber
A.returnGoldLumber = setmetatable({
    parent = AbilityIds.returnGoldLumber,
    apply = identity,
}, callMt)

---@class AbilityFactoryRegenLifeArll
---@overload fun(data: AbilityRow<AbilityDefinitionRegenLifeArll>?): AbilityRow<AbilityDefinitionRegenLifeArll>
---@field apply fun(fn: fun(a: AbilityDefinitionRegenLifeArll)): fun(a: AbilityDefinitionRegenLifeArll)

---@type AbilityFactoryRegenLifeArll
A.regenLifeArll = setmetatable({
    parent = AbilityIds.regenLifeArll,
    apply = identity,
}, callMt)

---@class AbilityFactoryReturnLumber
---@overload fun(data: AbilityRow<AbilityDefinitionReturnLumber>?): AbilityRow<AbilityDefinitionReturnLumber>
---@field apply fun(fn: fun(a: AbilityDefinitionReturnLumber)): fun(a: AbilityDefinitionReturnLumber)

---@type AbilityFactoryReturnLumber
A.returnLumber = setmetatable({
    parent = AbilityIds.returnLumber,
    apply = identity,
}, callMt)

---@class AbilityFactoryRootAncients
---@overload fun(data: AbilityRow<AbilityDefinitionRootAncients>?): AbilityRow<AbilityDefinitionRootAncients>
---@field apply fun(fn: fun(a: AbilityDefinitionRootAncients)): fun(a: AbilityDefinitionRootAncients)

---@type AbilityFactoryRootAncients
A.rootAncients = setmetatable({
    parent = AbilityIds.rootAncients,
    apply = identity,
}, callMt)

---@class AbilityFactoryRootAncientProtector
---@overload fun(data: AbilityRow<AbilityDefinitionRootAncientProtector>?): AbilityRow<AbilityDefinitionRootAncientProtector>
---@field apply fun(fn: fun(a: AbilityDefinitionRootAncientProtector)): fun(a: AbilityDefinitionRootAncientProtector)

---@type AbilityFactoryRootAncientProtector
A.rootAncientProtector = setmetatable({
    parent = AbilityIds.rootAncientProtector,
    apply = identity,
}, callMt)

---@class AbilityFactoryRoar
---@overload fun(data: AbilityRow<AbilityDefinitionRoar>?): AbilityRow<AbilityDefinitionRoar>
---@field apply fun(fn: fun(a: AbilityDefinitionRoar)): fun(a: AbilityDefinitionRoar)

---@type AbilityFactoryRoar
A.roar = setmetatable({
    parent = AbilityIds.roar,
    apply = identity,
}, callMt)

---@class AbilityFactoryRocketAttack
---@overload fun(data: AbilityRow<AbilityDefinitionRocketAttack>?): AbilityRow<AbilityDefinitionRocketAttack>
---@field apply fun(fn: fun(a: AbilityDefinitionRocketAttack)): fun(a: AbilityDefinitionRocketAttack)

---@type AbilityFactoryRocketAttack
A.rocketAttack = setmetatable({
    parent = AbilityIds.rocketAttack,
    apply = identity,
}, callMt)

---@class AbilityFactoryRoot
---@overload fun(data: AbilityRow<AbilityDefinitionAroo>?): AbilityRow<AbilityDefinitionAroo>
---@field apply fun(fn: fun(a: AbilityDefinitionAroo)): fun(a: AbilityDefinitionAroo)

---@type AbilityFactoryRoot
A.root = setmetatable({
    parent = AbilityIds.root,
    apply = identity,
}, callMt)

---@class AbilityFactoryReplenishLifeMana
---@overload fun(data: AbilityRow<AbilityDefinitionReplenishLifeMana>?): AbilityRow<AbilityDefinitionReplenishLifeMana>
---@field apply fun(fn: fun(a: AbilityDefinitionReplenishLifeMana)): fun(a: AbilityDefinitionReplenishLifeMana)

---@type AbilityFactoryReplenishLifeMana
A.replenishLifeMana = setmetatable({
    parent = AbilityIds.replenishLifeMana,
    apply = identity,
}, callMt)

---@class AbilityFactoryReplenishLife
---@overload fun(data: AbilityRow<AbilityDefinitionReplenishLife>?): AbilityRow<AbilityDefinitionReplenishLife>
---@field apply fun(fn: fun(a: AbilityDefinitionReplenishLife)): fun(a: AbilityDefinitionReplenishLife)

---@type AbilityFactoryReplenishLife
A.replenishLife = setmetatable({
    parent = AbilityIds.replenishLife,
    apply = identity,
}, callMt)

---@class AbilityFactoryReplenishMana
---@overload fun(data: AbilityRow<AbilityDefinitionReplenishMana>?): AbilityRow<AbilityDefinitionReplenishMana>
---@field apply fun(fn: fun(a: AbilityDefinitionReplenishMana)): fun(a: AbilityDefinitionReplenishMana)

---@type AbilityFactoryReplenishMana
A.replenishMana = setmetatable({
    parent = AbilityIds.replenishMana,
    apply = identity,
}, callMt)

---@class AbilityFactoryRestore
---@overload fun(data: AbilityRow<AbilityDefinitionRestoration>?): AbilityRow<AbilityDefinitionRestoration>
---@field apply fun(fn: fun(a: AbilityDefinitionRestoration)): fun(a: AbilityDefinitionRestoration)

---@type AbilityFactoryRestore
A.restore = setmetatable({
    parent = AbilityIds.restore,
    apply = identity,
}, callMt)

---@class AbilityFactoryReturn111
---@overload fun(data: AbilityRow<AbilityDefinitionArtn>?): AbilityRow<AbilityDefinitionArtn>
---@field apply fun(fn: fun(a: AbilityDefinitionArtn)): fun(a: AbilityDefinitionArtn)

---@type AbilityFactoryReturn111
A.return111 = setmetatable({
    parent = AbilityIds.return111,
    apply = identity,
}, callMt)

---@class AbilityFactoryPillage
---@overload fun(data: AbilityRow<AbilityDefinitionPillage>?): AbilityRow<AbilityDefinitionPillage>
---@field apply fun(fn: fun(a: AbilityDefinitionPillage)): fun(a: AbilityDefinitionPillage)

---@type AbilityFactoryPillage
A.pillage = setmetatable({
    parent = AbilityIds.pillage,
    apply = identity,
}, callMt)

---@class AbilityFactorySubmergeMyrmidon
---@overload fun(data: AbilityRow<AbilityDefinitionSubmergeMyrmidon>?): AbilityRow<AbilityDefinitionSubmergeMyrmidon>
---@field apply fun(fn: fun(a: AbilityDefinitionSubmergeMyrmidon)): fun(a: AbilityDefinitionSubmergeMyrmidon)

---@type AbilityFactorySubmergeMyrmidon
A.submergeMyrmidon = setmetatable({
    parent = AbilityIds.submergeMyrmidon,
    apply = identity,
}, callMt)

---@class AbilityFactorySubmergeRoyalGuard
---@overload fun(data: AbilityRow<AbilityDefinitionSubmergeRoyalGuard>?): AbilityRow<AbilityDefinitionSubmergeRoyalGuard>
---@field apply fun(fn: fun(a: AbilityDefinitionSubmergeRoyalGuard)): fun(a: AbilityDefinitionSubmergeRoyalGuard)

---@type AbilityFactorySubmergeRoyalGuard
A.submergeRoyalGuard = setmetatable({
    parent = AbilityIds.submergeRoyalGuard,
    apply = identity,
}, callMt)

---@class AbilityFactorySubmergeSnapDragon
---@overload fun(data: AbilityRow<AbilityDefinitionSubmergeSnapDragon>?): AbilityRow<AbilityDefinitionSubmergeSnapDragon>
---@field apply fun(fn: fun(a: AbilityDefinitionSubmergeSnapDragon)): fun(a: AbilityDefinitionSubmergeSnapDragon)

---@type AbilityFactorySubmergeSnapDragon
A.submergeSnapDragon = setmetatable({
    parent = AbilityIds.submergeSnapDragon,
    apply = identity,
}, callMt)

---@class AbilityFactorySelfDestruct2ClockwerkGoblins
---@overload fun(data: AbilityRow<AbilityDefinitionSelfDestruct2ClockwerkGoblins>?): AbilityRow<AbilityDefinitionSelfDestruct2ClockwerkGoblins>
---@field apply fun(fn: fun(a: AbilityDefinitionSelfDestruct2ClockwerkGoblins)): fun(a: AbilityDefinitionSelfDestruct2ClockwerkGoblins)

---@type AbilityFactorySelfDestruct2ClockwerkGoblins
A.selfDestruct2ClockwerkGoblins = setmetatable({
    parent = AbilityIds.selfDestruct2ClockwerkGoblins,
    apply = identity,
}, callMt)

---@class AbilityFactorySelfDestruct3ClockwerkGoblins
---@overload fun(data: AbilityRow<AbilityDefinitionSelfDestruct3ClockwerkGoblins>?): AbilityRow<AbilityDefinitionSelfDestruct3ClockwerkGoblins>
---@field apply fun(fn: fun(a: AbilityDefinitionSelfDestruct3ClockwerkGoblins)): fun(a: AbilityDefinitionSelfDestruct3ClockwerkGoblins)

---@type AbilityFactorySelfDestruct3ClockwerkGoblins
A.selfDestruct3ClockwerkGoblins = setmetatable({
    parent = AbilityIds.selfDestruct3ClockwerkGoblins,
    apply = identity,
}, callMt)

---@class AbilityFactorySelfDestructClockwerkGoblins
---@overload fun(data: AbilityRow<AbilityDefinitionSelfDestructClockwerkGoblins>?): AbilityRow<AbilityDefinitionSelfDestructClockwerkGoblins>
---@field apply fun(fn: fun(a: AbilityDefinitionSelfDestructClockwerkGoblins)): fun(a: AbilityDefinitionSelfDestructClockwerkGoblins)

---@type AbilityFactorySelfDestructClockwerkGoblins
A.selfDestructClockwerkGoblins = setmetatable({
    parent = AbilityIds.selfDestructClockwerkGoblins,
    apply = identity,
}, callMt)

---@class AbilityFactoryKaboom
---@overload fun(data: AbilityRow<AbilityDefinitionSelfDestruct>?): AbilityRow<AbilityDefinitionSelfDestruct>
---@field apply fun(fn: fun(a: AbilityDefinitionSelfDestruct)): fun(a: AbilityDefinitionSelfDestruct)

---@type AbilityFactoryKaboom
A.kaboom = setmetatable({
    parent = AbilityIds.kaboom,
    apply = identity,
}, callMt)

---@class AbilityFactoryShadowMeld
---@overload fun(data: AbilityRow<AbilityDefinitionShadowMeld>?): AbilityRow<AbilityDefinitionShadowMeld>
---@field apply fun(fn: fun(a: AbilityDefinitionShadowMeld)): fun(a: AbilityDefinitionShadowMeld)

---@type AbilityFactoryShadowMeld
A.shadowMeld = setmetatable({
    parent = AbilityIds.shadowMeld,
    apply = identity,
}, callMt)

---@class AbilityFactorySleepAlways
---@overload fun(data: AbilityRow<AbilityDefinitionSleepAlways>?): AbilityRow<AbilityDefinitionSleepAlways>
---@field apply fun(fn: fun(a: AbilityDefinitionSleepAlways)): fun(a: AbilityDefinitionSleepAlways)

---@type AbilityFactorySleepAlways
A.sleepAlways = setmetatable({
    parent = AbilityIds.sleepAlways,
    apply = identity,
}, callMt)

---@class AbilityFactorySlow
---@overload fun(data: AbilityRow<AbilityDefinitionSlow>?): AbilityRow<AbilityDefinitionSlow>
---@field apply fun(fn: fun(a: AbilityDefinitionSlow)): fun(a: AbilityDefinitionSlow)

---@type AbilityFactorySlow
A.slow = setmetatable({
    parent = AbilityIds.slow,
    apply = identity,
}, callMt)

---@class AbilityFactorySpawnOnDeathskeleton
---@overload fun(data: AbilityRow<AbilityDefinitionSpawnOnDeathskeleton>?): AbilityRow<AbilityDefinitionSpawnOnDeathskeleton>
---@field apply fun(fn: fun(a: AbilityDefinitionSpawnOnDeathskeleton)): fun(a: AbilityDefinitionSpawnOnDeathskeleton)

---@type AbilityFactorySpawnOnDeathskeleton
A.spawnOnDeathskeleton = setmetatable({
    parent = AbilityIds.spawnOnDeathskeleton,
    apply = identity,
}, callMt)

---@class AbilityFactorySpiderAttack
---@overload fun(data: AbilityRow<AbilityDefinitionSpiderAttack>?): AbilityRow<AbilityDefinitionSpiderAttack>
---@field apply fun(fn: fun(a: AbilityDefinitionSpiderAttack)): fun(a: AbilityDefinitionSpiderAttack)

---@type AbilityFactorySpiderAttack
A.spiderAttack = setmetatable({
    parent = AbilityIds.spiderAttack,
    apply = identity,
}, callMt)

---@class AbilityFactorySpellBook
---@overload fun(data: AbilityRow<AbilityDefinitionSpellBook>?): AbilityRow<AbilityDefinitionSpellBook>
---@field apply fun(fn: fun(a: AbilityDefinitionSpellBook)): fun(a: AbilityDefinitionSpellBook)

---@type AbilityFactorySpellBook
A.spellBook = setmetatable({
    parent = AbilityIds.spellBook,
    apply = identity,
}, callMt)

---@class AbilityFactorySpawnSpiders
---@overload fun(data: AbilityRow<AbilityDefinitionSpawnSpiderOnDeath>?): AbilityRow<AbilityDefinitionSpawnSpiderOnDeath>
---@field apply fun(fn: fun(a: AbilityDefinitionSpawnSpiderOnDeath)): fun(a: AbilityDefinitionSpawnSpiderOnDeath)

---@type AbilityFactorySpawnSpiders
A.spawnSpiders = setmetatable({
    parent = AbilityIds.spawnSpiders,
    apply = identity,
}, callMt)

---@class AbilityFactorySpiritLink
---@overload fun(data: AbilityRow<AbilityDefinitionSpiritLink>?): AbilityRow<AbilityDefinitionSpiritLink>
---@field apply fun(fn: fun(a: AbilityDefinitionSpiritLink)): fun(a: AbilityDefinitionSpiritLink)

---@type AbilityFactorySpiritLink
A.spiritLink = setmetatable({
    parent = AbilityIds.spiritLink,
    apply = identity,
}, callMt)

---@class AbilityFactorySlowPoison
---@overload fun(data: AbilityRow<AbilityDefinitionSlowPoison>?): AbilityRow<AbilityDefinitionSlowPoison>
---@field apply fun(fn: fun(a: AbilityDefinitionSlowPoison)): fun(a: AbilityDefinitionSlowPoison)

---@type AbilityFactorySlowPoison
A.slowPoison = setmetatable({
    parent = AbilityIds.slowPoison,
    apply = identity,
}, callMt)

---@class AbilityFactoryRuneofSpiritLink
---@overload fun(data: AbilityRow<AbilityDefinitionRuneofSpiritLink>?): AbilityRow<AbilityDefinitionRuneofSpiritLink>
---@field apply fun(fn: fun(a: AbilityDefinitionRuneofSpiritLink)): fun(a: AbilityDefinitionRuneofSpiritLink)

---@type AbilityFactoryRuneofSpiritLink
A.runeofSpiritLink = setmetatable({
    parent = AbilityIds.runeofSpiritLink,
    apply = identity,
}, callMt)

---@class AbilityFactorySpawnHydraHatchling
---@overload fun(data: AbilityRow<AbilityDefinitionSpawnHydraHatchling>?): AbilityRow<AbilityDefinitionSpawnHydraHatchling>
---@field apply fun(fn: fun(a: AbilityDefinitionSpawnHydraHatchling)): fun(a: AbilityDefinitionSpawnHydraHatchling)

---@type AbilityFactorySpawnHydraHatchling
A.spawnHydraHatchling = setmetatable({
    parent = AbilityIds.spawnHydraHatchling,
    apply = identity,
}, callMt)

---@class AbilityFactoryAspx
---@overload fun(data: AbilityRow<AbilityDefinitionAspx>?): AbilityRow<AbilityDefinitionAspx>
---@field apply fun(fn: fun(a: AbilityDefinitionAspx)): fun(a: AbilityDefinitionAspx)

---@type AbilityFactoryAspx
A.aspx = setmetatable({
    parent = AbilityIds.aspx,
    apply = identity,
}, callMt)

---@class AbilityFactorySpawnHydra
---@overload fun(data: AbilityRow<AbilityDefinitionSpawnHydra>?): AbilityRow<AbilityDefinitionSpawnHydra>
---@field apply fun(fn: fun(a: AbilityDefinitionSpawnHydra)): fun(a: AbilityDefinitionSpawnHydra)

---@type AbilityFactorySpawnHydra
A.spawnHydra = setmetatable({
    parent = AbilityIds.spawnHydra,
    apply = identity,
}, callMt)

---@class AbilityFactoryHardenedSkin
---@overload fun(data: AbilityRow<AbilityDefinitionHardenedSkin>?): AbilityRow<AbilityDefinitionHardenedSkin>
---@field apply fun(fn: fun(a: AbilityDefinitionHardenedSkin)): fun(a: AbilityDefinitionHardenedSkin)

---@type AbilityFactoryHardenedSkin
A.hardenedSkin = setmetatable({
    parent = AbilityIds.hardenedSkin,
    apply = identity,
}, callMt)

---@class AbilityFactorySpawnSpiderlings
---@overload fun(data: AbilityRow<AbilityDefinitionSpawnSpiderlingOnDeath>?): AbilityRow<AbilityDefinitionSpawnSpiderlingOnDeath>
---@field apply fun(fn: fun(a: AbilityDefinitionSpawnSpiderlingOnDeath)): fun(a: AbilityDefinitionSpawnSpiderlingOnDeath)

---@type AbilityFactorySpawnSpiderlings
A.spawnSpiderlings = setmetatable({
    parent = AbilityIds.spawnSpiderlings,
    apply = identity,
}, callMt)

---@class AbilityFactoryStasisTrap
---@overload fun(data: AbilityRow<AbilityDefinitionStasisTrap>?): AbilityRow<AbilityDefinitionStasisTrap>
---@field apply fun(fn: fun(a: AbilityDefinitionStasisTrap)): fun(a: AbilityDefinitionStasisTrap)

---@type AbilityFactoryStasisTrap
A.stasisTrap = setmetatable({
    parent = AbilityIds.stasisTrap,
    apply = identity,
}, callMt)

---@class AbilityFactoryManaSteal
---@overload fun(data: AbilityRow<AbilityDefinitionManaSteal>?): AbilityRow<AbilityDefinitionManaSteal>
---@field apply fun(fn: fun(a: AbilityDefinitionManaSteal)): fun(a: AbilityDefinitionManaSteal)

---@type AbilityFactoryManaSteal
A.manaSteal = setmetatable({
    parent = AbilityIds.manaSteal,
    apply = identity,
}, callMt)

---@class AbilityFactoryStoneForm
---@overload fun(data: AbilityRow<AbilityDefinitionStoneForm>?): AbilityRow<AbilityDefinitionStoneForm>
---@field apply fun(fn: fun(a: AbilityDefinitionStoneForm)): fun(a: AbilityDefinitionStoneForm)

---@type AbilityFactoryStoneForm
A.stoneForm = setmetatable({
    parent = AbilityIds.stoneForm,
    apply = identity,
}, callMt)

---@class AbilityFactoryTaunt
---@overload fun(data: AbilityRow<AbilityDefinitionTaunt>?): AbilityRow<AbilityDefinitionTaunt>
---@field apply fun(fn: fun(a: AbilityDefinitionTaunt)): fun(a: AbilityDefinitionTaunt)

---@type AbilityFactoryTaunt
A.taunt = setmetatable({
    parent = AbilityIds.taunt,
    apply = identity,
}, callMt)

---@class AbilityFactoryTornadoDamage
---@overload fun(data: AbilityRow<AbilityDefinitionTornadoDamage>?): AbilityRow<AbilityDefinitionTornadoDamage>
---@field apply fun(fn: fun(a: AbilityDefinitionTornadoDamage)): fun(a: AbilityDefinitionTornadoDamage)

---@type AbilityFactoryTornadoDamage
A.tornadoDamage = setmetatable({
    parent = AbilityIds.tornadoDamage,
    apply = identity,
}, callMt)

---@class AbilityFactoryTrueSight2
---@overload fun(data: AbilityRow<AbilityDefinitionDetectShade>?): AbilityRow<AbilityDefinitionDetectShade>
---@field apply fun(fn: fun(a: AbilityDefinitionDetectShade)): fun(a: AbilityDefinitionDetectShade)

---@type AbilityFactoryTrueSight2
A.trueSight2 = setmetatable({
    parent = AbilityIds.trueSight2,
    apply = identity,
}, callMt)

---@class AbilityFactoryTornadoSpin
---@overload fun(data: AbilityRow<AbilityDefinitionTornadoSpin>?): AbilityRow<AbilityDefinitionTornadoSpin>
---@field apply fun(fn: fun(a: AbilityDefinitionTornadoSpin)): fun(a: AbilityDefinitionTornadoSpin)

---@type AbilityFactoryTornadoSpin
A.tornadoSpin = setmetatable({
    parent = AbilityIds.tornadoSpin,
    apply = identity,
}, callMt)

---@class AbilityFactoryUnstableConcoction
---@overload fun(data: AbilityRow<AbilityDefinitionUnstableConcoction>?): AbilityRow<AbilityDefinitionUnstableConcoction>
---@field apply fun(fn: fun(a: AbilityDefinitionUnstableConcoction)): fun(a: AbilityDefinitionUnstableConcoction)

---@type AbilityFactoryUnstableConcoction
A.unstableConcoction = setmetatable({
    parent = AbilityIds.unstableConcoction,
    apply = identity,
}, callMt)

---@class AbilityFactoryUnholyFrenzy
---@overload fun(data: AbilityRow<AbilityDefinitionUnholyFrenzy>?): AbilityRow<AbilityDefinitionUnholyFrenzy>
---@field apply fun(fn: fun(a: AbilityDefinitionUnholyFrenzy)): fun(a: AbilityDefinitionUnholyFrenzy)

---@type AbilityFactoryUnholyFrenzy
A.unholyFrenzy = setmetatable({
    parent = AbilityIds.unholyFrenzy,
    apply = identity,
}, callMt)

---@class AbilityFactoryUnsummonBuilding
---@overload fun(data: AbilityRow<AbilityDefinitionUnsummon>?): AbilityRow<AbilityDefinitionUnsummon>
---@field apply fun(fn: fun(a: AbilityDefinitionUnsummon)): fun(a: AbilityDefinitionUnsummon)

---@type AbilityFactoryUnsummonBuilding
A.unsummonBuilding = setmetatable({
    parent = AbilityIds.unsummonBuilding,
    apply = identity,
}, callMt)

---@class AbilityFactoryEnvenomedSpears
---@overload fun(data: AbilityRow<AbilityDefinitionVenomSpears>?): AbilityRow<AbilityDefinitionVenomSpears>
---@field apply fun(fn: fun(a: AbilityDefinitionVenomSpears)): fun(a: AbilityDefinitionVenomSpears)

---@type AbilityFactoryEnvenomedSpears
A.envenomedSpears = setmetatable({
    parent = AbilityIds.envenomedSpears,
    apply = identity,
}, callMt)

---@class AbilityFactoryVengeance
---@overload fun(data: AbilityRow<AbilityDefinitionVengeance>?): AbilityRow<AbilityDefinitionVengeance>
---@field apply fun(fn: fun(a: AbilityDefinitionVengeance)): fun(a: AbilityDefinitionVengeance)

---@type AbilityFactoryVengeance
A.vengeance = setmetatable({
    parent = AbilityIds.vengeance,
    apply = identity,
}, callMt)

---@class AbilityFactoryPulverize
---@overload fun(data: AbilityRow<AbilityDefinitionPulverize>?): AbilityRow<AbilityDefinitionPulverize>
---@field apply fun(fn: fun(a: AbilityDefinitionPulverize)): fun(a: AbilityDefinitionPulverize)

---@type AbilityFactoryPulverize
A.pulverize = setmetatable({
    parent = AbilityIds.pulverize,
    apply = identity,
}, callMt)

---@class AbilityFactoryWeb
---@overload fun(data: AbilityRow<AbilityDefinitionWeb>?): AbilityRow<AbilityDefinitionWeb>
---@field apply fun(fn: fun(a: AbilityDefinitionWeb)): fun(a: AbilityDefinitionWeb)

---@type AbilityFactoryWeb
A.web = setmetatable({
    parent = AbilityIds.web,
    apply = identity,
}, callMt)

---@class AbilityFactoryFirebolt2
---@overload fun(data: AbilityRow<AbilityDefinitionFireBoltwarlock>?): AbilityRow<AbilityDefinitionFireBoltwarlock>
---@field apply fun(fn: fun(a: AbilityDefinitionFireBoltwarlock)): fun(a: AbilityDefinitionFireBoltwarlock)

---@type AbilityFactoryFirebolt2
A.firebolt2 = setmetatable({
    parent = AbilityIds.firebolt2,
    apply = identity,
}, callMt)

---@class AbilityFactoryGather1
---@overload fun(data: AbilityRow<AbilityDefinitionWispHarvestInvulnerable>?): AbilityRow<AbilityDefinitionWispHarvestInvulnerable>
---@field apply fun(fn: fun(a: AbilityDefinitionWispHarvestInvulnerable)): fun(a: AbilityDefinitionWispHarvestInvulnerable)

---@type AbilityFactoryGather1
A.gather1 = setmetatable({
    parent = AbilityIds.gather1,
    apply = identity,
}, callMt)

---@class AbilityFactoryGather
---@overload fun(data: AbilityRow<AbilityDefinitionWispHarvest>?): AbilityRow<AbilityDefinitionWispHarvest>
---@field apply fun(fn: fun(a: AbilityDefinitionWispHarvest)): fun(a: AbilityDefinitionWispHarvest)

---@type AbilityFactoryGather
A.gather = setmetatable({
    parent = AbilityIds.gather,
    apply = identity,
}, callMt)

---@class AbilityFactoryWarStompseagiant
---@overload fun(data: AbilityRow<AbilityDefinitionWarStompseagiant>?): AbilityRow<AbilityDefinitionWarStompseagiant>
---@field apply fun(fn: fun(a: AbilityDefinitionWarStompseagiant)): fun(a: AbilityDefinitionWarStompseagiant)

---@type AbilityFactoryWarStompseagiant
A.warStompseagiant = setmetatable({
    parent = AbilityIds.warStompseagiant,
    apply = identity,
}, callMt)

---@class AbilityFactoryWarStomphydra
---@overload fun(data: AbilityRow<AbilityDefinitionWarStomphydra>?): AbilityRow<AbilityDefinitionWarStomphydra>
---@field apply fun(fn: fun(a: AbilityDefinitionWarStomphydra)): fun(a: AbilityDefinitionWarStomphydra)

---@type AbilityFactoryWarStomphydra
A.warStomphydra = setmetatable({
    parent = AbilityIds.warStomphydra,
    apply = identity,
}, callMt)

---@class AbilityFactoryWaygateability
---@overload fun(data: AbilityRow<AbilityDefinitionWarp>?): AbilityRow<AbilityDefinitionWarp>
---@field apply fun(fn: fun(a: AbilityDefinitionWarp)): fun(a: AbilityDefinitionWarp)

---@type AbilityFactoryWaygateability
A.waygateability = setmetatable({
    parent = AbilityIds.waygateability,
    apply = identity,
}, callMt)

---@class AbilityFactoryWarStomp
---@overload fun(data: AbilityRow<AbilityDefinitionWarStompcreep>?): AbilityRow<AbilityDefinitionWarStompcreep>
---@field apply fun(fn: fun(a: AbilityDefinitionWarStompcreep)): fun(a: AbilityDefinitionWarStompcreep)

---@type AbilityFactoryWarStomp
A.warStomp = setmetatable({
    parent = AbilityIds.warStomp,
    apply = identity,
}, callMt)

---@class AbilityFactoryEnduranceAura
---@overload fun(data: AbilityRow<AbilityDefinitionAuraEnduranceCreep>?): AbilityRow<AbilityDefinitionAuraEnduranceCreep>
---@field apply fun(fn: fun(a: AbilityDefinitionAuraEnduranceCreep)): fun(a: AbilityDefinitionAuraEnduranceCreep)

---@type AbilityFactoryEnduranceAura
A.enduranceAura = setmetatable({
    parent = AbilityIds.enduranceAura,
    apply = identity,
}, callMt)

---@class AbilityFactoryCyclone
---@overload fun(data: AbilityRow<AbilityDefinitionCycloneCenarius>?): AbilityRow<AbilityDefinitionCycloneCenarius>
---@field apply fun(fn: fun(a: AbilityDefinitionCycloneCenarius)): fun(a: AbilityDefinitionCycloneCenarius)

---@type AbilityFactoryCyclone
A.cyclone = setmetatable({
    parent = AbilityIds.cyclone,
    apply = identity,
}, callMt)

---@class AbilityFactoryVampiricattack
---@overload fun(data: AbilityRow<AbilityDefinitionVampiricattack>?): AbilityRow<AbilityDefinitionVampiricattack>
---@field apply fun(fn: fun(a: AbilityDefinitionVampiricattack)): fun(a: AbilityDefinitionVampiricattack)

---@type AbilityFactoryVampiricattack
A.vampiricattack = setmetatable({
    parent = AbilityIds.vampiricattack,
    apply = identity,
}, callMt)

---@class AbilityFactoryDarkConversionFast
---@overload fun(data: AbilityRow<AbilityDefinitionDarkConversionFast>?): AbilityRow<AbilityDefinitionDarkConversionFast>
---@field apply fun(fn: fun(a: AbilityDefinitionDarkConversionFast)): fun(a: AbilityDefinitionDarkConversionFast)

---@type AbilityFactoryDarkConversionFast
A.darkConversionFast = setmetatable({
    parent = AbilityIds.darkConversionFast,
    apply = identity,
}, callMt)

---@class AbilityFactoryDeathAndDecay
---@overload fun(data: AbilityRow<AbilityDefinitionSuperDeathandDecay>?): AbilityRow<AbilityDefinitionSuperDeathandDecay>
---@field apply fun(fn: fun(a: AbilityDefinitionSuperDeathandDecay)): fun(a: AbilityDefinitionSuperDeathandDecay)

---@type AbilityFactoryDeathAndDecay
A.deathAndDecay = setmetatable({
    parent = AbilityIds.deathAndDecay,
    apply = identity,
}, callMt)

---@class AbilityFactoryEarthquake
---@overload fun(data: AbilityRow<AbilityDefinitionSuperEarthquake>?): AbilityRow<AbilityDefinitionSuperEarthquake>
---@field apply fun(fn: fun(a: AbilityDefinitionSuperEarthquake)): fun(a: AbilityDefinitionSuperEarthquake)

---@type AbilityFactoryEarthquake
A.earthquake = setmetatable({
    parent = AbilityIds.earthquake,
    apply = identity,
}, callMt)

---@class AbilityFactoryInferno
---@overload fun(data: AbilityRow<AbilityDefinitionTichondriusInferno>?): AbilityRow<AbilityDefinitionTichondriusInferno>
---@field apply fun(fn: fun(a: AbilityDefinitionTichondriusInferno)): fun(a: AbilityDefinitionTichondriusInferno)

---@type AbilityFactoryInferno
A.inferno = setmetatable({
    parent = AbilityIds.inferno,
    apply = identity,
}, callMt)

---@class AbilityFactoryBerserkerUpgrade
---@overload fun(data: AbilityRow<AbilityDefinitionBerserkerUpgrade>?): AbilityRow<AbilityDefinitionBerserkerUpgrade>
---@field apply fun(fn: fun(a: AbilityDefinitionBerserkerUpgrade)): fun(a: AbilityDefinitionBerserkerUpgrade)

---@type AbilityFactoryBerserkerUpgrade
A.berserkerUpgrade = setmetatable({
    parent = AbilityIds.berserkerUpgrade,
    apply = identity,
}, callMt)

---@class AbilityFactoryBattlestationsChaos
---@overload fun(data: AbilityRow<AbilityDefinitionBattlestationsChaos>?): AbilityRow<AbilityDefinitionBattlestationsChaos>
---@field apply fun(fn: fun(a: AbilityDefinitionBattlestationsChaos)): fun(a: AbilityDefinitionBattlestationsChaos)

---@type AbilityFactoryBattlestationsChaos
A.battlestationsChaos = setmetatable({
    parent = AbilityIds.battlestationsChaos,
    apply = identity,
}, callMt)

---@class AbilityFactoryChaosGrunt
---@overload fun(data: AbilityRow<AbilityDefinitionChaosGrunt>?): AbilityRow<AbilityDefinitionChaosGrunt>
---@field apply fun(fn: fun(a: AbilityDefinitionChaosGrunt)): fun(a: AbilityDefinitionChaosGrunt)

---@type AbilityFactoryChaosGrunt
A.chaosGrunt = setmetatable({
    parent = AbilityIds.chaosGrunt,
    apply = identity,
}, callMt)

---@class AbilityFactoryChaosRaider
---@overload fun(data: AbilityRow<AbilityDefinitionChaosRaider>?): AbilityRow<AbilityDefinitionChaosRaider>
---@field apply fun(fn: fun(a: AbilityDefinitionChaosRaider)): fun(a: AbilityDefinitionChaosRaider)

---@type AbilityFactoryChaosRaider
A.chaosRaider = setmetatable({
    parent = AbilityIds.chaosRaider,
    apply = identity,
}, callMt)

---@class AbilityFactoryChaosShaman
---@overload fun(data: AbilityRow<AbilityDefinitionChaosShaman>?): AbilityRow<AbilityDefinitionChaosShaman>
---@field apply fun(fn: fun(a: AbilityDefinitionChaosShaman)): fun(a: AbilityDefinitionChaosShaman)

---@type AbilityFactoryChaosShaman
A.chaosShaman = setmetatable({
    parent = AbilityIds.chaosShaman,
    apply = identity,
}, callMt)

---@class AbilityFactoryChaosKodo
---@overload fun(data: AbilityRow<AbilityDefinitionChaosKodo>?): AbilityRow<AbilityDefinitionChaosKodo>
---@field apply fun(fn: fun(a: AbilityDefinitionChaosKodo)): fun(a: AbilityDefinitionChaosKodo)

---@type AbilityFactoryChaosKodo
A.chaosKodo = setmetatable({
    parent = AbilityIds.chaosKodo,
    apply = identity,
}, callMt)

---@class AbilityFactoryChaosPeon
---@overload fun(data: AbilityRow<AbilityDefinitionChaosPeon>?): AbilityRow<AbilityDefinitionChaosPeon>
---@field apply fun(fn: fun(a: AbilityDefinitionChaosPeon)): fun(a: AbilityDefinitionChaosPeon)

---@type AbilityFactoryChaosPeon
A.chaosPeon = setmetatable({
    parent = AbilityIds.chaosPeon,
    apply = identity,
}, callMt)

---@class AbilityFactoryChaosGrom
---@overload fun(data: AbilityRow<AbilityDefinitionChaosGrom>?): AbilityRow<AbilityDefinitionChaosGrom>
---@field apply fun(fn: fun(a: AbilityDefinitionChaosGrom)): fun(a: AbilityDefinitionChaosGrom)

---@type AbilityFactoryChaosGrom
A.chaosGrom = setmetatable({
    parent = AbilityIds.chaosGrom,
    apply = identity,
}, callMt)

---@class AbilityFactoryCargoHoldMeatWagon
---@overload fun(data: AbilityRow<AbilityDefinitionCargoHoldMeatWagon>?): AbilityRow<AbilityDefinitionCargoHoldMeatWagon>
---@field apply fun(fn: fun(a: AbilityDefinitionCargoHoldMeatWagon)): fun(a: AbilityDefinitionCargoHoldMeatWagon)

---@type AbilityFactoryCargoHoldMeatWagon
A.cargoHoldMeatWagon = setmetatable({
    parent = AbilityIds.cargoHoldMeatWagon,
    apply = identity,
}, callMt)

---@class AbilityFactoryCargoHoldTransport
---@overload fun(data: AbilityRow<AbilityDefinitionCargoHoldTransport>?): AbilityRow<AbilityDefinitionCargoHoldTransport>
---@field apply fun(fn: fun(a: AbilityDefinitionCargoHoldTransport)): fun(a: AbilityDefinitionCargoHoldTransport)

---@type AbilityFactoryCargoHoldTransport
A.cargoHoldTransport = setmetatable({
    parent = AbilityIds.cargoHoldTransport,
    apply = identity,
}, callMt)

---@class AbilityFactoryCargoHoldTank
---@overload fun(data: AbilityRow<AbilityDefinitionCargoHoldTank>?): AbilityRow<AbilityDefinitionCargoHoldTank>
---@field apply fun(fn: fun(a: AbilityDefinitionCargoHoldTank)): fun(a: AbilityDefinitionCargoHoldTank)

---@type AbilityFactoryCargoHoldTank
A.cargoHoldTank = setmetatable({
    parent = AbilityIds.cargoHoldTank,
    apply = identity,
}, callMt)

---@class AbilityFactoryCargoHoldShip
---@overload fun(data: AbilityRow<AbilityDefinitionCargoHoldShip>?): AbilityRow<AbilityDefinitionCargoHoldShip>
---@field apply fun(fn: fun(a: AbilityDefinitionCargoHoldShip)): fun(a: AbilityDefinitionCargoHoldShip)

---@type AbilityFactoryCargoHoldShip
A.cargoHoldShip = setmetatable({
    parent = AbilityIds.cargoHoldShip,
    apply = identity,
}, callMt)

---@class AbilityFactoryCripple1
---@overload fun(data: AbilityRow<AbilityDefinitionCrippleWarlock>?): AbilityRow<AbilityDefinitionCrippleWarlock>
---@field apply fun(fn: fun(a: AbilityDefinitionCrippleWarlock)): fun(a: AbilityDefinitionCrippleWarlock)

---@type AbilityFactoryCripple1
A.cripple1 = setmetatable({
    parent = AbilityIds.cripple1,
    apply = identity,
}, callMt)

---@class AbilityFactoryLoadWisp
---@overload fun(data: AbilityRow<AbilityDefinitionLoadEntangledGoldMine>?): AbilityRow<AbilityDefinitionLoadEntangledGoldMine>
---@field apply fun(fn: fun(a: AbilityDefinitionLoadEntangledGoldMine)): fun(a: AbilityDefinitionLoadEntangledGoldMine)

---@type AbilityFactoryLoadWisp
A.loadWisp = setmetatable({
    parent = AbilityIds.loadWisp,
    apply = identity,
}, callMt)

---@class AbilityFactoryLoadNavies
---@overload fun(data: AbilityRow<AbilityDefinitionLoadNavies>?): AbilityRow<AbilityDefinitionLoadNavies>
---@field apply fun(fn: fun(a: AbilityDefinitionLoadNavies)): fun(a: AbilityDefinitionLoadNavies)

---@type AbilityFactoryLoadNavies
A.loadNavies = setmetatable({
    parent = AbilityIds.loadNavies,
    apply = identity,
}, callMt)

---@class AbilityFactoryLoadBurrow
---@overload fun(data: AbilityRow<AbilityDefinitionLoadBurrow>?): AbilityRow<AbilityDefinitionLoadBurrow>
---@field apply fun(fn: fun(a: AbilityDefinitionLoadBurrow)): fun(a: AbilityDefinitionLoadBurrow)

---@type AbilityFactoryLoadBurrow
A.loadBurrow = setmetatable({
    parent = AbilityIds.loadBurrow,
    apply = identity,
}, callMt)

---@class AbilityFactoryTankUpgrade
---@overload fun(data: AbilityRow<AbilityDefinitionTankUpgrade>?): AbilityRow<AbilityDefinitionTankUpgrade>
---@field apply fun(fn: fun(a: AbilityDefinitionTankUpgrade)): fun(a: AbilityDefinitionTankUpgrade)

---@type AbilityFactoryTankUpgrade
A.tankUpgrade = setmetatable({
    parent = AbilityIds.tankUpgrade,
    apply = identity,
}, callMt)

---@class AbilityFactoryShadowMeldInstant
---@overload fun(data: AbilityRow<AbilityDefinitionShadowMeldInstant>?): AbilityRow<AbilityDefinitionShadowMeldInstant>
---@field apply fun(fn: fun(a: AbilityDefinitionShadowMeldInstant)): fun(a: AbilityDefinitionShadowMeldInstant)

---@type AbilityFactoryShadowMeldInstant
A.shadowMeldInstant = setmetatable({
    parent = AbilityIds.shadowMeldInstant,
    apply = identity,
}, callMt)

---@class AbilityFactoryPilotTankMortarTeam
---@overload fun(data: AbilityRow<AbilityDefinitionPilotTankMortarTeam>?): AbilityRow<AbilityDefinitionPilotTankMortarTeam>
---@field apply fun(fn: fun(a: AbilityDefinitionPilotTankMortarTeam)): fun(a: AbilityDefinitionPilotTankMortarTeam)

---@type AbilityFactoryPilotTankMortarTeam
A.pilotTankMortarTeam = setmetatable({
    parent = AbilityIds.pilotTankMortarTeam,
    apply = identity,
}, callMt)

---@class AbilityFactoryPIlotTankRifleman
---@overload fun(data: AbilityRow<AbilityDefinitionPIlotTankRifleman>?): AbilityRow<AbilityDefinitionPIlotTankRifleman>
---@field apply fun(fn: fun(a: AbilityDefinitionPIlotTankRifleman)): fun(a: AbilityDefinitionPIlotTankRifleman)

---@type AbilityFactoryPIlotTankRifleman
A.pIlotTankRifleman = setmetatable({
    parent = AbilityIds.pIlotTankRifleman,
    apply = identity,
}, callMt)

---@class AbilityFactoryUnholyFrenzy1
---@overload fun(data: AbilityRow<AbilityDefinitionUnholyFrenzyWarlock>?): AbilityRow<AbilityDefinitionUnholyFrenzyWarlock>
---@field apply fun(fn: fun(a: AbilityDefinitionUnholyFrenzyWarlock)): fun(a: AbilityDefinitionUnholyFrenzyWarlock)

---@type AbilityFactoryUnholyFrenzy1
A.unholyFrenzy1 = setmetatable({
    parent = AbilityIds.unholyFrenzy1,
    apply = identity,
}, callMt)

return A
