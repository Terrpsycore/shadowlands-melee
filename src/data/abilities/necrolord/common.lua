local A = require("data.abilityPresets")

-- TODO
-- - ? diff buff for each ability level
-- MEMO
-- - passiveAura -> CONSTANT BUFF | abom part, stacking; 3 - max parts; 4th from "apply limb"
-- - toggle / Versatile -> BONUS ACTIVE | abom part from combo
-- - "effect" -> PASSIVE POWER CONSTRAINT
-- - [limb] -> TIMED BUFF | non-abom tmp buff (to show buff timer)
--
-- - limb -> abom?
-- - - yes -> level up aura / add advanced / limb timer + tmp effect lvl up if limb wasn't on
-- - - no -> limb timer + tmp aura lvl 1
-- - +always: revert prev "limb" effect before

return {
    stitchingBaseKyrian = A.passiveAura({
        name = "Survive Wish",
        buffs = { "stitchingBaseKyrian" },
        levels = 3,
    }),
    stitchingBaseNecrolord = A.passiveAura({
        name = "Survive Wish",
        buffs = { "stitchingBaseNecrolord" },
        levels = 3,
    }),
    stitchingBaseFae = A.passiveAura({
        name = "Survive Wish",
        buffs = { "stitchingBaseFae" },
        levels = 3,
    }),
    stitchingBaseVenthyr = A.passiveAura({
        name = "Survive Wish",
        buffs = { "stitchingBaseVenthyr" },
        levels = 3,
    }),
    stitchingBaseMawsworn = A.passiveAura({
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
    stitchingLimbKyrian = A.nonDispellableSelfBuffTimed({
        name = "Survive Wish",
        buffs = { "stitchingBaseKyrian" },
    }),
    stitchingLimbNecrolord = A.nonDispellableSelfBuffTimed({
        name = "Survive Wish",
        buffs = { "stitchingBaseNecrolord" },
    }),
    stitchingLimbFae = A.nonDispellableSelfBuffTimed({
        name = "Survive Wish",
        buffs = { "stitchingBaseFae" },
    }),
    stitchingLimbVenthyr = A.nonDispellableSelfBuffTimed({
        name = "Survive Wish",
        buffs = { "stitchingBaseVenthyr" },
    }),
    stitchingLimbMawsworn = A.nonDispellableSelfBuffTimed({
        name = "Survive Wish",
        buffs = { "stitchingBaseMawsworn" },
    }),
}
