local UnitIds = require("vendor.assets.UnitIds")
local UnitArt = require("vendor.assets.generated.UnitArt")
local Icons = require("vendor.assets.generated.Icons")

return {
    dredger = {
        parent = UnitIds.peon,
        name = "Dredger",
        abilities = {
            "motivation",
        },
        art = {
            model = UnitArt[UnitIds.mountaingiant].model,
            scale = 0.3,
            icon = Icons.mountainGiant,
        },
        structuresBuilt = {
            -- "shop",
        },
    },
    duelist = {
        parent = UnitIds.footman,
        name = "Duelist",
        abilities = {
            "duel",
            -- "riposte"
        },
    },
    hopebreaker = {
        parent = UnitIds.archer,
        name = "Hopebreaker",
        abilities = { "dreadTrack", "hopebreakerThrill" },
    },
    stoneborn = {
        parent = UnitIds.granitegolem,
        name = "Stoneborn",
        abilities = { "breakTheRanks" },
    },
    gargon = {
        parent = UnitIds.whitedirewolf,
        name = "Gargon",
        abilities = { "fearsomePresence" },
    },
    gargoyle = {
        parent = UnitIds.gargoyle,
        name = "Gargoyle",
        abilities = { "screech" },
    },
    courier = {
        parent = UnitIds.gargoyle,
        name = "Courier",
        abilities = { "provoke" },
    },
    --
    infuser = {
        parent = UnitIds.druidofthetalon,
        name = "Infuser",
        abilities = { "infuseWeapon", "harvestAcceleration", "feast" },
    },
    tormentor = {
        parent = UnitIds.roguewizard,
        name = "Tormentor",
        abilities = { "castigate", "sharedSuffering", "secondBreath" },
    },
    inquisitor = {
        parent = UnitIds.spellbreaker,
        name = "Inquisitor",
        abilities = { "condemnWrath", "devourSins", "contain" },
    },
    dredgerBrute = {
        parent = UnitIds.ogre1,
        name = "Dredger Brute",
        abilities = { "stampede" },
    },
    sinstoneGolem = {
        parent = UnitIds.mountaingiant,
        name = "Sinstone Golem",
        abilities = { "siphonAnima", "pullSins" },
    },
}
