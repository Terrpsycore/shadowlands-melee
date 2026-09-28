local Ids = require("data.ids")

local A = require("data.abilityPresets")

return {
    -- template
    xxx = A.channelNoTarget({
        name = "xxx",
    }),
    -- == UI
    -- Grovetender
    joinHunt = A.bearForm({
        name = "Join Hunt",
        -- apply one-direction transform
    }),
    faeUnsummonBuilding = A.unsummonBuilding({
        name = "Cut Nutrition",
    }),
    -- Tirnenn (worker)
    awaken = A.bearForm({
        name = "Awaken",
        -- apply one-direction transform
    }),
    regrowForest = A.channelArea({
        name = "Regrow Forest",
    }),
    -- Defender
    -- Trapper
    trap = A.channelNoTarget({
        name = "Trap",
    }),
    exposedShot = A.passiveGeneric({
        name = "Exposed Shot",
    }),
    -- Vorkai
    weakspotAim = A.passiveGeneric({
        name = "Weakspot Aim",
    }),
    -- Fairy
    chooseInstrument = A.spellBook({
        name = "Choose Instrument",
        button = { 1, 1 },
        hotkey = "D",
        apply = A.spellBook.apply(function(a)
            a:setSpellList(
                1,
                table.concat({
                    Ids.abilities.chooseInstrumentHarp,
                    Ids.abilities.chooseInstrumentDrum,
                    Ids.abilities.chooseInstrumentFlute,
                }, ",")
            )
        end),
    }),
    chooseInstrumentHarp = A.channelNoTarget({
        name = "Choose Instrument (Harp)",
        button = { 0, 0 },
        hotkey = "Q",
    }),
    chooseInstrumentDrum = A.channelNoTarget({
        name = "Choose Instrument (Drum)",
        button = { 1, 0 },
        hotkey = "W",
    }),
    chooseInstrumentFlute = A.channelNoTarget({
        name = "Choose Instrument (Flute)",
        button = { 2, 0 },
        hotkey = "E",
    }),
    noteHarp = A.innerFire({
        name = "Play Note (Harp)",
        buffs = { "noteHarp" },
        button = { 0, 2 },
        hotkey = "Q",
    }),
    noteDrum = A.bloodlust({
        name = "Play Note (Drum)",
        buffs = { "noteDrum" },
        button = { 0, 2 },
        hotkey = "Q",
    }),
    noteFlute = A.innerFire({
        name = "Play Note (Flute)",
        buffs = { "noteFlute" },
        button = { 0, 2 },
        hotkey = "Q",
    }),
    windBells = A.sentinel({
        name = "Windbells",
        button = { 1, 2 },
        hotkey = "W",
        -- apply number of owls = 0
    }),
    dance = A.tinkererClusterRocketsLevel0({
        name = "Dance!",
        buffs = { "dance" },
        button = { 2, 2 },
        hotkey = "E",
    }),
    -- Trickster
    dontGoOffRoad = A.dispellableTargetDebuff({
        name = "Don't go off road",
        buffs = { "dontGoOffRoad" },
    }),
    disguise = A.channelTarget({
        name = "Disguise",
    }),
    kidnap = A.channelTarget({
        name = "Kidnap",
    }),
    -- Gorm
    burrow = A.phaseShift({
        name = "Burrow",
        -- apply cast time
    }),
    hungerFrenzy = A.passiveGeneric({
        name = "Hunger Frenzy",
    }),
    -- Flying Gorm
    paraliticSting = A.slowPoison({
        name = "Paralitic Sting",
        buffs = { "paraliticStingSlow" },
        -- apply slow stacks, no damage
    }),
    -- Ardenmoth
    shimmerdustPoof = A.channelArea({
        name = "Shimmerdust Poof",
    }),
    -- Wilderling
    blockMagic = A.abolishMagic({
        name = "Block Magic",
    }),
    -- Ancient
    rake = A.passiveGeneric({
        name = "Rake",
    }),
    rebirthJoy = A.lifeRegenerationAura({
        name = "Rebirth Joy",
        buffs = { "rebirthJoy" },
    }),
    -- Tirnenn
    growForest = A.channelArea({
        name = "Grow Forest",
    }),
    safeCrown = A.channelArea({
        name = "Safe Crown",
    }),
    longRoots = A.sentinel({
        name = "Long Roots",
        -- apply number of owls = 0
    }),
    -- == Dummy
    -- Grovetender
    joinHuntHeal = A.healCreepHigh({
        name = "Join Hunt",
    }),
    -- Tirnenn (worker)
    -- Defender
    -- Trapper
    trapPlace = A.itemPlaceGoblinLandMine({
        name = "Trap",
        apply = A.itemPlaceGoblinLandMine.apply(function(a)
            a:setUnitType(1, Ids.units.hunterTrap)
        end),
    }),
    trapActivate = A.mineexploding({
        name = "Trap",
        apply = A.mineexploding.apply(function(a, level)
            a:setActivationDelay(level, 1)
        end),
    }),
    -- Vorkai
    -- Fairy
    harmonicNoteHarp = A.rejuvenation({ -- conflicts?
        name = "Harmonic Note (Harp)",
        buffs = { "harmonicNoteHarp" },
    }),
    harmonicNoteDrum = A.bloodlust({ -- conflicts?
        name = "Harmonic Note (Drum)",
        buffs = { "harmonicNoteDrum" },
    }),
    harmonicNoteFlute = A.innerFire({ -- conflicts?
        name = "Harmonic Note (Flute)",
        buffs = { "harmonicNoteFlute" },
    }),
    windBellsReveal = A.trueSight({
        name = "Windbells",
    }),
    -- Trickster
    dontGoOffRoadEffect = A.itemSightRangeBonus({
        name = "Don't go off road",
        -- apply negative
    }),
    -- Gorm
    burrowDamage = A.earthquake({
        name = "Burrow",
        buffs = { "burrowDamage" },
    }),
    hungerFrenzyBuff = A.bloodlust({
        name = "Hunger Frenzy",
        buffs = { "hungerFrenzyBuff" },
    }),
    -- Flying Gorm
    paraliticStingStun = A.stormBolt({
        name = "Paralitic Sting",
        buffs = { "paraliticStingStun" },
    }),
    -- Ardenmoth
    shimmerdustPoofBuff = A.invisibility({
        name = "Shimmerdust Poof",
        buffs = { "shimmerdustPoof" },
    }),
    -- Wilderling
    blockMagicSilence = A.silence({
        name = "Block Magic",
        buffs = { "blockMagic" },
    }),
    -- Ancient
    rakeDamage = A.nonDispellableTargetDebuff({
        name = "Rake",
    }),
    -- Tirnenn
    longRootsDisable = A.channelTarget({ -- replace with missile/lightning spell // root should be triggered
        name = "Long Roots",
        buffs = { "longRoots" },
    }),
}
