local Ids = require("data.ids")

local A = require("data.ability")

return {
    judgingGaze = A.seaWitchFrostArrows({
        name = "Judging Gaze",
        levels = 3,
        buffs = { "judgingGazeEvent" },
        apply = A.seaWitchFrostArrows.apply(function(a)
            a:setExtraDamage(1, 0)
            a:setAttackSpeedFactor(1, 0)
            a:setMovementSpeedFactor(1, 0)
        end),
    }),
    judgingGazeMissDebuff = A.curse({
        name = "",
        apply = A.curse.apply(function(a)
            --
        end),
    }),
    judgingGazeArmorDebuff = A.acidBomb({
        name = "",
        apply = A.acidBomb.apply(function(a)
            a:setDamageInterval(1, 1)
            a:setPrimaryDamage(1, 0)
            a:setMovementSpeedReduction(1, 0)
            a:setArmorPenalty(1, 2)
            a:setSecondaryDamage(1, 0)
            a:setAttackSpeedReduction(1, 0)
        end),
    }),
    -- judgingGazeDummy
}
