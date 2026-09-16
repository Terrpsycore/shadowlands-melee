local A = require("data.abilityPresets")

-- TODO
-- - ? diff buff for each ability level
-- MEMO
-- - base -> VISIBLE ICON (TODO: render level)
-- - passiveAura -> CONSTANT BUFF | abom part, stacking; 3 - max parts; 4th from "apply limb"; ability not visible
-- - toggle / Versatile -> BONUS ACTIVE | abom part from combo
-- - "effect" -> PASSIVE POWER CONSTRAINT
-- - [limb] -> TIMED BUFF | non-abom tmp buff (to show buff timer)
--
-- - limb -> abom?
-- - - yes -> level up aura / add advanced / limb timer + tmp effect lvl up if limb wasn't on
-- - - no -> limb timer + tmp aura lvl 1
-- - +always: revert prev "limb" effect before

return {
    stitchingBaseKyrian = A.passiveGeneric({
        name = "Survive Wish",
        levels = 3,
    }),
    stitchingBaseNecrolord = A.passiveGeneric({
        name = "Survive Wish",
        levels = 3,
    }),
    stitchingBaseFae = A.passiveGeneric({
        name = "Survive Wish",
        levels = 3,
    }),
    stitchingBaseVenthyr = A.passiveGeneric({
        name = "Survive Wish",
        levels = 3,
    }),
    stitchingBaseMawsworn = A.passiveGeneric({
        name = "Survive Wish",
        levels = 3,
    }),
    stitchingAuraKyrian = A.passiveAura({
        name = "Survive Wish",
        buffs = { "stitchingBaseKyrian" },
        levels = 3,
    }),
    stitchingAuraNecrolord = A.passiveAura({
        name = "Survive Wish",
        buffs = { "stitchingBaseNecrolord" },
        levels = 3,
    }),
    stitchingAuraFae = A.passiveAura({
        name = "Survive Wish",
        buffs = { "stitchingBaseFae" },
        levels = 3,
    }),
    stitchingAuraVenthyr = A.passiveAura({
        name = "Survive Wish",
        buffs = { "stitchingBaseVenthyr" },
        levels = 3,
    }),
    stitchingAuraMawsworn = A.passiveAura({
        name = "Survive Wish",
        buffs = { "stitchingBaseMawsworn" },
        levels = 3,
    }),
    stitchingAdvancedKyrian = A.immolationToggle({
        name = "Survive Wish",
        buffs = { "stitchingAdvancedKyrian" },
    }),
    stitchingAdvancedNecrolord = A.immolationToggle({
        name = "Survive Wish",
        buffs = { "stitchingAdvancedNecrolord" },
    }),
    stitchingAdvancedFae = A.immolationToggle({
        name = "Survive Wish",
        buffs = { "stitchingAdvancedFae" },
    }),
    stitchingAdvancedVenthyr = A.immolationToggle({
        name = "Survive Wish",
        buffs = { "stitchingAdvancedVenthyr" },
    }),
    stitchingAdvancedMawsworn = A.immolationToggle({
        name = "Survive Wish",
        buffs = { "stitchingAdvancedMawsworn" },
    }),
    stitchingAdvancedVersatile = A.passiveAura({
        name = "Survive Wish",
        buffs = { "stitchingAdvancedVersatile" },
    }),
    --
    stitchingBaseKyrianEffect = A.passiveGeneric({
        name = "Survive Wish",
        levels = 4,
    }),
    stitchingBaseNecrolordEffect = A.itemDamageBonus({
        name = "Survive Wish",
        levels = 4,
        apply = A.itemDamageBonus.apply(function(a)
            a:setItemAbility(false)
            for level = 1, 4 do
                a:setAttackBonus(level, 5 * level)
            end
        end),
    }),
    stitchingBaseFaeEffect = A.passiveGeneric({
        name = "Survive Wish",
        levels = 4,
    }),
    stitchingBaseVenthyrEffect = A.itemAttackSpeedBonus({
        name = "Survive Wish",
        levels = 4,
        apply = A.itemAttackSpeedBonus.apply(function(a)
            for level = 1, 4 do
                a:setAttackSpeedIncrease(level, 5 * level)
            end
        end),
    }),
    stitchingBaseMawswornEffect = A.passiveGeneric({
        name = "Survive Wish",
        levels = 4,
    }),
    --
    stitchingKyrianLifeRegen = A.itemLifeRegeneration({
        levels = 5, -- on % of life
        apply = A.itemLifeRegeneration.apply(function(a)
            for level = 1, 5 do
                a:setHitPointsRegeneratedPerSecond(level, level * 2)
            end
        end),
    }),
    stitchingNecrolordHaste = A.itemAttackSpeedBonus({
        levels = 5, -- on % of life
        apply = A.itemAttackSpeedBonus.apply(function(a)
            for level = 1, 5 do
                a:setAttackSpeedIncrease(level, level * 10)
            end
        end),
    }),
    stitchingNecrolordVictoryRush = A.healCreepHigh({
        apply = A.healCreepHigh.apply(function(a)
            a:setHitPointsGained(1, 100)
        end),
    }),
    stitchingFaeCreateIllusion = A.itemIllusions({
        apply = A.itemIllusions.apply(function(a)
            a:setOrderStringActivate("channel")
            a:setOrderStringUseTurnOn("channel")
        end),
    }),
    stitchingVenthyrLeech = A.itemLifeSteal({
        apply = A.itemLifeSteal.apply(function(a)
            a:setLifeStolenPerAttack(1, 50)
        end),
    }),
    stitchingVenthyrLeechFixed = A.healCreepHigh({
        apply = A.healCreepHigh.apply(function(a)
            a:setHitPointsGained(1, 5)
        end),
    }),
    stitchingMawswornReduceHp = A.itemLifeBonus({
        apply = A.itemLifeBonus.apply(function(a)
            a:setMaxLifeGained(1, -25)
            a:setMaxLifeGained(2, -50)
            a:setMaxLifeGained(3, -75)
            a:setMaxLifeGained(4, -100)
        end),
    }),
    stitchingMawswornReduceHpDebuff = A.curse({
        buffs = { "stitchingMawswornReduceHpDebuff" },
        levels = 4,
        apply = A.curse.apply(function(a)
            -- TODO: allow target enemy
            for level = 1, 4 do
                a:setChancetoMiss(level, 0)
            end
        end),
    }),
    stitchingMawswornIncreaseHp = A.itemLifeBonus({
        apply = A.itemLifeBonus.apply(function(a)
            a:setMaxLifeGained(1, 25)
            a:setMaxLifeGained(2, 50)
            a:setMaxLifeGained(3, 75)
            a:setMaxLifeGained(4, 100)
        end),
    }),
    stitchingMawswornIncreaseHpBuff = A.innerFire({
        buffs = { "stitchingMawswornIncreaseHpBuff" },
        levels = 4,
        apply = A.innerFire.apply(function(a)
            for level = 1, 4 do
                a:setDefenseIncrease(level, 0)
                a:setDamageIncrease(level, 0)
            end
        end),
    }),
    --
    stitchingLimbKyrian = A.nonDispellableSelfBuffTimed({
        name = "Survive Wish",
        buffs = { "stitchingLimbKyrian" },
    }),
    stitchingLimbNecrolord = A.nonDispellableSelfBuffTimed({
        name = "Survive Wish",
        buffs = { "stitchingLimbNecrolord" },
    }),
    stitchingLimbFae = A.nonDispellableSelfBuffTimed({
        name = "Survive Wish",
        buffs = { "stitchingLimbFae" },
    }),
    stitchingLimbVenthyr = A.nonDispellableSelfBuffTimed({
        name = "Survive Wish",
        buffs = { "stitchingLimbVenthyr" },
    }),
    stitchingLimbMawsworn = A.nonDispellableSelfBuffTimed({
        name = "Survive Wish",
        buffs = { "stitchingLimbMawsworn" },
    }),
}
