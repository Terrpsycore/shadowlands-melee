local Ids = require("data.ids")
local Icons = require("vendor.assets.generated.Icons")

local A = require("data.abilityPresets")

return {
    --- FENCER ---
    freeWalk = A.beastMasterSummonBear({
        name = "Free Walk",
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        art = { icon = Icons.glovesofultimatevampirism },
        hotkey = "Q",
    }),
    bladeThirst = A.channelNoTarget({
        name = "Blade Thirst",
        levels = 3,
        manaCost = 100,
        button = { 1, 2 },
        art = { icon = Icons.potionOfVampirism },
        hotkey = "W",
    }),
    carnage = A.passiveGeneric({
        name = "Carnage",
        levels = 3,
        button = { 2, 2 },
        art = { icon = Icons.pasBloodthirst },
        hotkey = "E",
    }),
    phaseShift = A.channelNoTarget({
        name = "Phase Shift",
        levels = 1,
        manaCost = 100,
        button = { 3, 2 },
        art = { icon = Icons.blink },
        hotkey = "R",
    }),
    ---
    fissure = A.channelPoint({
        name = "Fissure",
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        art = { icon = Icons.earthquake },
        hotkey = "Q",
    }),
    stoneBarrier = A.nonDispellableSelfBuffTimed({
        name = "Stone Barrier",
        buffs = { "soldiersOath" },
        levels = 3,
        manaCost = 100,
        button = { 1, 2 },
        art = { icon = Icons.shoulderBash },
        hotkey = "W",
    }),
    soldiersOath = A.passiveGeneric({
        name = "Soldier's Oath",
        levels = 3,
        button = { 2, 2 },
        art = { icon = Icons.pasHandofjustice },
        hotkey = "E",
    }),
    crushingStone = A.nonDispellableSelfBuffTimed({
        name = "Crushing Stone",
        levels = 1,
        manaCost = 100,
        button = { 3, 2 },
        art = { icon = Icons.improvedcreaturecarapace },
        hotkey = "R",
    }),
    ---
    inquisitorMark = A.nonDispellableTargetDebuff({
        name = "Inquisitor Mark",
        levels = 3,
        manaCost = 100,
        button = { 0, 2 },
        art = { icon = Icons.signetofblood },
        hotkey = "Q",
    }),
    deepInquiry = A.channelTarget({
        name = "Deep Inquiry",
        levels = 3,
        manaCost = 100,
        button = { 1, 2 },
        art = { icon = Icons.lavaSpawn },
        hotkey = "W",
    }),
    condemnPride = A.dispellableTargetDebuff({ -- undispellable on 3rd level?
        name = "Condemn Pride",
        levels = 3,
        button = { 2, 2 },
        art = { icon = Icons.giftofpride },
        hotkey = "E",
    }),
    condemnGreed = A.nonDispellableTargetDebuff({
        name = "Condemn Greed",
        levels = 1,
        manaCost = 100,
        button = { 3, 2 },
        art = { icon = Icons.giftofgreed },
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
