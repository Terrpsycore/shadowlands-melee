local Ids = require("data.ids")

local A = require("data.abilityPresets")
local Icons = require("vendor.assets.generated.Icons")

return {
    surviveWish = A.passiveGeneric({
        name = "Survive Wish",
        buffs = { "surviveWish" },
        art = { icon = Icons.pasRegenerationAura },
    }),
    surviveWishActive = A.berserkerRage1({
        name = "Survive Wish",
        apply = A.berserkerRage1.apply(function(a)
            a:setAttackSpeedIncrease(1, 0.2)
            a:setMovementSpeedIncrease(1, 0.2)
            a:setDamageTakenIncrease(1, 0)
        end),
    }),
    combatExpertise = A.passiveGeneric({
        name = "Combat Expertise",
        art = { icon = Icons.pasShadeTrueSight },
    }),
    combatExpertiseDamage = A.itemDamageBonus({
        levels = 5,
        apply = A.itemDamageBonus.apply(function(a)
            for level = 1, 5 do
                a:setAttackBonus(level, 1 * level)
            end
        end),
    }),
    vanish = A.channelNoTarget({
        name = "Vanish",
        art = { icon = Icons.ambush },
    }),
    vanishDummy = A.invisibility({
        apply = A.invisibility.apply(function(a)
            a:setTransitionTimeseconds(1, 2)
        end),
    }),
    netAmmo = A.web({
        name = "Net Ammo",
        art = { icon = Icons.apprehend },
    }),
    animateDead = A.raiseDead({
        name = "Animate Dead",
        art = { icon = Icons.raiseDeadOn },
        hotkey = "Q",
    }),
    animateDeadResurrection = A.resurrection({
        apply = A.resurrection.apply(function(a)
            a:setNumberofCorpsesRaised(1, 1)
        end),
    }),
    maldraciteNullify = A.dispelMagic({
        name = "Maldracite Nullify",
        art = { icon = Icons.nerubiannecklace },
        hotkey = "W",
    }),
    sigilOfBinding = A.itemPlaceGoblinLandMine({
        name = "Sigil of Binding",
        art = { icon = Icons.antiMagicShell },
        apply = A.itemPlaceGoblinLandMine.apply(function(a)
            a:setCastRange(1, 500)
            a:setUnitType(1, Ids.units.sigilOfBinding)
        end),
        hotkey = "E",
    }),
    sigilOfBindingActivation = A.mineexploding({
        name = "Sigil of Binding",
        apply = A.mineexploding.apply(function(a, level)
            a:setActivationDelay(level, 1)
        end),
    }),
    sigilOfBindingSlow = A.slow({
        name = "Sigil of Binding",
        buffs = { "sigilOfBinding" },
        apply = A.slow.apply(function(a) end),
    }),
    sigilOfBindingRoot = A.entanglingRoots({
        buffs = { "sigilOfBinding" },
        name = "Sigil of Binding",
        apply = A.entanglingRoots.apply(function(a)
            a:setDamageperSecond(1, 0)
            a:setDurationNormal(1, 8)
            a:setDurationHero(1, 8)
            a:setTargetsAllowed(1, "allied,enemy,ground,organic,nonhero,player")
        end),
    }),
    sigilOfBindingStun = A.stormBolt({
        name = "Sigil of Binding",
        buffs = { "sigilOfBinding" },
        apply = A.stormBolt.apply(function(a)
            a:setDamage(1, 0)
            a:setDurationNormal(1, 3)
            a:setDurationHero(1, 3)
            a:setTargetsAllowed(1, "allied,enemy,ground,organic,nonhero,player")
        end),
    }),
    applyLimb = A.channelTarget({
        name = "Apply Limb",
        art = { icon = Icons.amuletOftheWild },
        hotkey = "Q",
        apply = A.channelTarget.apply(function(a)
            a:setBaseOrderID(1, "bloodlust")
            a:setOrderStringUseTurnOn("bloodlust")
        end),
    }),
    scissorSoul = A.channelTarget({
        name = "Scissor Soul",
        art = { icon = Icons.manaFlare },
        hotkey = "W",
        apply = A.channelTarget.apply(function(a)
            a:setBaseOrderID(1, "innerfire")
            a:setOrderStringUseTurnOn("innerfire")
        end),
    }),
    scissorSoulDummy = A.nonDispellableTargetDebuff({
        buffs = { "scissorSoul" },
        apply = A.nonDispellableTargetDebuff.apply(function(a) end),
    }),
    scissorSoulManaBurn = A.feedback({
        name = "Scissor Soul",
        apply = A.feedback.apply(function(a)
            a:setSummonedDamage(1, 200)
            a:setDamageRatioUnits(1, 0.5)
            a:setMaxManaDrainedHeros(1, 100)
            a:setMaxManaDrainedUnits(1, 400)
            a:setDamageRatioHeros(1, 0.5)
        end),
    }),
    betterBody = A.channelTarget({
        name = "Better Body",
        art = { icon = Icons.bloodfury },
        hotkey = "E",
        apply = A.channelTarget.apply(function(a)
            a:setBaseOrderID(1, "thunderbolt")
            a:setOrderStringUseTurnOn("thunderbolt")
        end),
    }),
    betterBodyPossession = A.possession({
        name = "Better Body",
        manaCost = 0,
        apply = A.possession.apply(function(a)
            a:setCastingTime(1, 0)
            a:setCastRange(1, 1000)
        end),
    }),
    healingSlime = A.rejuvenation1({
        name = "Healing Slime",
        buffs = { "healingSlime" },
        art = { icon = Icons.restorativebalm },
        button = { 0, 2 },
        apply = A.rejuvenation1.apply(function(a)
            -- ? TODO change to autocast heal with spec buff
            a:setHitPointsGained(1, 100)
            a:setDurationHero(1, 10)
            a:setDurationNormal(1, 10)
        end),
    }),
    corrosivePlague = A.curse({
        name = "Corrosive Plague",
        buffs = { "corrosivePlague" },
        button = { 1, 2 },
        apply = A.curse.apply(function(a)
            a:setChancetoMiss(1, 0)
        end),
        art = { icon = Icons.plagueCloud },
    }),
    concoctPotionExplosive = A.channelTarget({
        name = "Concoct Explosive Potion",
        hotkey = "Q",
        apply = A.channelNoTarget.apply(function(a)
            a:setBaseOrderID(1, "bloodlust")
            a:setOrderStringUseTurnOn("bloodlust")
        end),
    }),
    concoctPotionHealing = A.channelTarget({
        name = "Concoct Healing Potion",
        hotkey = "W",
        apply = A.channelNoTarget.apply(function(a)
            a:setBaseOrderID(1, "innerfire")
            a:setOrderStringUseTurnOn("innerfire")
        end),
    }),
    concoctPotionFrenzy = A.channelTarget({
        name = "Concoct Frenzy Potion",
        hotkey = "E",
        apply = A.channelNoTarget.apply(function(a)
            a:setBaseOrderID(1, "thunderbolt")
            a:setOrderStringUseTurnOn("thunderbolt")
        end),
    }),
    concoctedExplosionActive = A.channelNoTarget({
        apply = A.channelNoTarget.apply(function(a)
            -- a:setOrderStringActivate
        end),
    }),
    concoctedExplosionDummy = A.selfDestruct3ClockwerkGoblins({
        apply = A.selfDestruct3ClockwerkGoblins.apply(function(a)
            a:setTargetsAllowed(1, "self,allied,enemy,ground,air,organic,mechanical,hero,nonhero,player")
            -- order = selfdestruct
        end),
    }),
    concoctedHealingActive = A.channelNoTarget({
        apply = A.channelNoTarget.apply(function(a)
            -- a:setOrderStringActivate
        end),
    }),
    concoctedHealingStunDummy = A.stormBolt({
        buffs = { "concoctedHealingStun" },
        apply = A.stormBolt.apply(function(a)
            a:setDamage(1, 0)
            a:setDurationNormal(1, 8)
            a:setDurationHero(1, 8)
            a:setTargetsAllowed(1, "allied,enemy,ground,organic,nonhero,player")
        end),
    }),
    concoctedHealingRejuvDummy = A.rejuvenation1({
        buffs = { "concoctedHealingRejuv" },
        apply = A.rejuvenation1.apply(function(a)
            a:setHitPointsGained(1, 1500)
            a:setManaPointsGained(1, 0)
            a:setNoTargetRequired(1, false)
            a:setAllowWhenFull(1, 0)
            a:setDurationNormal(1, 16)
            a:setDurationHero(1, 16)
            a:setTargetsAllowed(1, "allied,ground,organic,nonhero,player")
        end),
    }),
    concoctedFrenzyActive = A.nonDispellableSelfBuffTimed({
        buffs = { "concoctedFrenzy" },
        apply = A.nonDispellableSelfBuffTimed.apply(function(a)
            a:setAttackSpeedIncrease(1, 0.75)
            a:setDurationNormal(1, 999)
            a:setDurationHero(1, 999)
        end),
    }),
    concoctedFrenzyPassiveDoom = A.itemLifeRegeneration({
        levels = 10,
        apply = A.itemLifeRegeneration.apply(function(a)
            for level = 1, 10 do
                a:setHitPointsRegeneratedPerSecond(level, -4 - level)
            end
        end),
    }),
    concoctPotion = A.spellBook({
        name = "Concoct Potion",
        button = { 2, 2 },
        hotkey = "E",
        apply = A.spellBook.apply(function(a)
            a:setSpellList(
                1,
                table.concat({
                    Ids.abilities.concoctPotionExplosive,
                    Ids.abilities.concoctPotionHealing,
                    Ids.abilities.concoctPotionFrenzy,
                }, ",")
            )
        end),
    }),
    corrosivePlagueSpread = A.auraPlagueAbomination({
        name = "Corrosive Plague",
        buffs = { "corrosivePlague" },
        apply = A.auraPlagueAbomination.apply(function(a)
            a:setAreaofEffect(1, 64)
            a:setTargetsAllowed(1, "allied,organic,player")
        end),
    }),
    corrosivePlagueArmorDebuff = A.itemArmorBonus({
        name = "Corrosive Plague",
        apply = A.itemArmorBonus.apply(function(a)
            a:setDefenseBonus(1, -2)
        end),
    }),
    collectCorpsesSearch = A.channelPoint({
        name = "Cannibalize",
        art = { icon = Icons.undeadload },
        button = { 0, 2 },
    }),
    collectCorpses = A.cannibalize({
        name = "Collect Corpses",
        art = { icon = Icons.undeadload },
        button = { 0, 2 },
    }),
    collectCorpsesToggle = A.heal({
        name = "Collect Corpses",
        apply = A.heal.apply(function(a)
            a:setManaCost(1, 0)
            a:setTargetsAllowed(1, "")
        end),
    }),
    dropCorpses = A.channelTarget({
        name = "Drop Corpses",
        art = { icon = Icons.undeadUnLoad },
    }),
    poisonBite = A.slowPoison({
        name = "Poison Bite",
        art = { icon = Icons.pasPoisonSting },
        apply = A.slowPoison.apply(function(a)
            a:setStackingType(1, 0)
        end),
    }),
    sporeCloud = A.channelNoTarget({
        name = "Spore Cloud",
        art = { icon = Icons.orbOfVenom },
    }),
    sporeCloudDummy = A.cloudofFog({
        name = "Spore Cloud",
        apply = A.cloudofFog.apply(function(a)
            a:setAreaofEffect(1, 200)
            a:setDurationNormal(1, 10)
            a:setAttacksPrevented(1, 0)
            a:setChanceToMiss(1, 20)
        end),
    }),
    sporeCloudDamage = A.auraPlagueAbomination({
        name = "Spore Cloud",
        apply = A.auraPlagueAbomination.apply(function(a)
            a:setAreaofEffect(1, 200)
        end),
    }),
    warBanner = A.sentryWard({
        name = "War Banner",
        art = { icon = Icons.undeadCaptureFlag },
        apply = A.sentryWard.apply(function(a)
            a:setWardUnitType(1, Ids.units.warBanner)
        end),
    }),
    warBannerAura = A.enduranceAura({
        name = "War Banner",
        apply = A.enduranceAura.apply(function(a)
            a:setMovementSpeedIncrease(1, 0.10)
            a:setAttackSpeedIncrease(1, 0.10)
            a:setAreaofEffect(1, 600)
            a:setTargetsAllowed(1, "allied,ground,air,organic,nonhero,player")
        end),
    }),
    deadlyWhirlwind = A.permanentInvisibility({
        name = "Deadly Whirlwind",
    }),
    slurp = A.deathPact({
        art = { icon = Icons.devourMagic },
        manaCost = 0,
        name = "Slurp",
    }),
    slurpCorpseDummy = A.deathCoil({
        name = "Slurp",
        apply = A.deathCoil.apply(function(a) end),
    }),
}
