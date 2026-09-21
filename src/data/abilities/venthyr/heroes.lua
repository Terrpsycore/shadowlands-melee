local Ids = require("data.ids")

local A = require("data.abilityPresets")

return {
    --- FENCER ---
    freeWalk = A.beastMasterSummonBear({
        name = "Free Walk",
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        hotkey = "Q",
    }),
    bladeThirst = A.channelNoTarget({
        name = "Blade Thirst",
        levels = 3,
        manaCost = 100,
        button = { 1, 2 },
        hotkey = "W",
    }),
    carnage = A.passiveGeneric({
        name = "Carnage",
        levels = 3,
        button = { 2, 2 },
        hotkey = "E",
    }),
    phaseShift = A.channelNoTarget({
        name = "Phase Shift",
        levels = 1,
        manaCost = 100,
        button = { 3, 2 },
        hotkey = "R",
    }),
    ---
    fissure = A.channelPoint({
        name = "Fissure",
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        hotkey = "Q",
    }),
    stoneBarrier = A.nonDispellableSelfBuffTimed({
        name = "Stone Barrier",
        buffs = { "soldiersOath" },
        levels = 3,
        manaCost = 100,
        button = { 1, 2 },
        hotkey = "W",
    }),
    soldiersOath = A.passiveGeneric({
        name = "Soldier's Oath",
        levels = 3,
        button = { 2, 2 },
        hotkey = "E",
    }),
    crushingStone = A.nonDispellableSelfBuffTimed({
        name = "Crushing Stone",
        levels = 1,
        manaCost = 100,
        button = { 3, 2 },
        hotkey = "R",
    }),
    ---
    inquisitorMark = A.nonDispellableTargetDebuff({
        name = "Inquisitor Mark",
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        hotkey = "Q",
    }),
    deepInquiry = A.channelTarget({
        name = "Deep Inquiry",
        levels = 3,
        manaCost = 100,
        button = { 1, 2 },
        hotkey = "W",
    }),
    condemnPride = A.dispellableTargetDebuff({ -- undispellable on 3rd level?
        name = "Condemn Pride",
        levels = 3,
        button = { 2, 2 },
        hotkey = "E",
    }),
    condemnGreed = A.nonDispellableTargetDebuff({
        name = "Condemn Greed",
        levels = 1,
        manaCost = 100,
        button = { 3, 2 },
        hotkey = "R",
    }),
    ---
    sentientBladeReturn = A.channelNoTarget({
        name = "Deep Inquiry",
    }),
    stoneBarrierBuff = A.nonDispellableTargetDebuff({ -- "positive"
        name = "Stone Barrier",
        buffs = { "soldiersOath" },
    }),
    soldiersOathBuff = A.bloodlust({
        name = "Soldier's Oath",
        class = "unit",
        buffs = { "soldiersOath" },
    }),
    deepInquirySummon = A.feralSpirit2({
        name = "Deep Inquiry",
    }),
}
