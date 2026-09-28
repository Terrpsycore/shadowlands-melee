local Ids = require("data.ids")

local A = require("data.abilityPresets")

return {
    -- == UI
    -- Hunter
    calledShot = A.shadowStrike({
        name = "Called Shot",
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        hotkey = "Q",
    }),
    huntingHorn = A.roar({
        name = "Hunting Horn",
        buffs = { "huntingHornStrike" },
        manaCost = 100,
        levels = 3,
        button = { 1, 2 },
        hotkey = "W",
        -- apply no bonuses in OE. remove buff on AA
    }),
    ambush = A.passiveGeneric({ -- mb add non-dispellable debuff for 60-sec target cd visuals
        name = "Ambush",
        levels = 3,
        button = { 2, 2 },
        hotkey = "E",
    }),
    huntMark = A.nonDispellableTargetDebuff({
        name = "Hunt Mark",
        buffs = { "huntMark" },
        manaCost = 100,
        levels = 1,
        button = { 3, 2 },
        hotkey = "R",
    }),
    -- Partymaker
    impossibleRhyme = A.channelNoTarget({
        name = "Impossible Rhyme",
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        hotkey = "Q",
        buffs = { "impossibleRhyme" },
    }),
    guessingGame = A.mirrorImage({ -- triggered AoE damage
        name = "Guessing Game",
        manaCost = 100,
        levels = 3,
        button = { 1, 2 },
        hotkey = "W",
    }),
    liftSpirits = A.dispellableTargetDebuff({
        name = "Lift Spirits",
        buffs = { "liftSpirits" },
        manaCost = 100,
        levels = 3,
        button = { 2, 2 },
        hotkey = "E",
    }),
    fireworks = A.tinkererClusterRocketsLevel0({
        name = "Fireworks",
        manaCost = 100,
        levels = 1,
        button = { 3, 2 },
        hotkey = "R",
    }),
    -- Spirit
    defendersWrath = A.nonDispellableSelfBuffTimed({
        name = "Defender's Wrath",
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        hotkey = "Q",
    }),
    faeBlink = A.phaseShift({
        name = "Blink",
        manaCost = 100,
        levels = 3,
        button = { 1, 2 },
        hotkey = "W",
    }),
    maul = A.exhumeBased({
        name = "Maul",
        levels = 3,
        button = { 2, 2 },
        hotkey = "E",
    }),
    mortalRage = A.immolationToggle({
        name = "Mortal Rage",
        manaCost = 100,
        levels = 1,
        button = { 3, 2 },
        hotkey = "R",
    }),
    -- == Dummy
    -- Hunter
    huntingHornSpeed = A.enduranceAura({ -- quickly add/remove
        name = "Hunting Horn",
        buffs = { "huntingHorn" },
        levels = 3,
        -- apply duration
    }),
    ambushBuff = A.nonDispellableSelfBuffTimed({
        name = "Ambush",
        buffs = { "ambush" },
        levels = 3,
    }),
    huntMarkEffect = A.vampiricAura({
        name = "Hunt Mark",
        buffs = { "hunterMark" },
        levels = 3,
    }),
    -- Partymaker
    impossibleRhymeSilence = A.silence({
        name = "Impossible Rhyme",
        buffs = { "impossibleRhymeSilence" },
        levels = 3,
    }),
    impossibleRhymeFeedback = A.manaBurn({
        name = "Impossible Rhyme",
        levels = 3,
    }),
    liftSpiritsStun = A.stormBolt({
        name = "Lift Spirits",
        buffs = { "liftSpiritsStun" },
        levels = 3,
    }),
    liftSpiritsFeedback = A.manaBurn({
        name = "Lift Spirits",
        levels = 3,
    }),
    -- Spirit
    defendersWrathThorns = A.cryptLordSpikedCarapace({
        name = "Defender's Wrath",
        levels = 3,
    }),
    defendersWrathDamage = A.thunderClap({
        name = "Defender's Wrath",
        buffs = {},
        levels = 3,
        -- apply no slow
    }),
    faeBlinkSpeed = A.nonDispellableSelfBuffTimed({
        name = "Blink",
        levels = 3,
        button = { 0, 2 },
    }),
    maulCleave = A.pitLordCleavingAttack({
        name = "Maul",
        levels = 3,
    }),
    mortalRageSpeed = A.itemAttackSpeedBonus({
        name = "Mortal Rage",
    }),
}
