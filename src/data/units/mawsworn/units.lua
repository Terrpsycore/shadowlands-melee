local UnitIds = require("vendor.assets.UnitIds")

return {
    runesmith = { -- ensure unit can power build but can't start build
        parent = UnitIds.peasant,
        name = "Steward",
        abilities = { "humanBuild", "repairHuman", "stygianShield" },
    },
    shackler = {
        parent = UnitIds.footman,
        name = "Shackler",
        abilities = { "shackle", "disarm", "mawswornGrab", "mawswornInventory" },
    },
    arbalest = {
        parent = UnitIds.headhunter,
        name = "Arbalest",
        abilities = { "malignantBolt", "mawswornGrab", "mawswornInventory" },
    },
    vanguard = {
        parent = UnitIds.grunt,
        name = "Vanguard",
        abilities = { "accursedStrength", "disarm", "mawswornGrab", "mawswornInventory" },
    },
    myrmidonFlying = {
        parent = UnitIds.dragonhawk,
        name = "Myrmidon",
        abilities = { "fallenArmaments", "myrmidonFly", "mawswornGrab", "mawswornInventory" },
    },
    myrmidon = {
        parent = UnitIds.headhunter,
        name = "Myrmidon",
        abilities = { "fallenArmaments", "myrmidonFly", "mawswornGrab", "mawswornInventory" },
    },
    soulEater = {
        parent = UnitIds.wolfrider,
        name = "Soul Eater",
        abilities = { "soulFeast", "weaknessHunger", "foulBite", "soulEaterFly" },
    },
    soulEaterFlying = {
        parent = UnitIds.hippogryph,
        name = "Soul Eater",
        abilities = { "soulFeast", "weaknessHunger", "foulBite", "soulEaterFly" },
    },
    soulSeeker = {
        parent = UnitIds.trollbatrider,
        name = "Soul Seeker",
        abilities = { "glare", "sneakPeek" },
    },
    mawcasterFire = {
        parent = UnitIds.war2warlock,
        name = "Fire",
        abilities = { "blazingPurge", "infusion", "burnResidue" },
    },
    mawcasterFrost = {
        parent = UnitIds.revenantoftheseas,
        name = "Frost",
        abilities = { "freezeBlood", "vessel", "calcify" },
    },
    mawcasterDomination = {
        parent = UnitIds.acolyte,
        name = "Domination",
        abilities = { "fallenMorale", "forcedRestitution", "betrayalSeed" },
    },
    charredBehemoth = {
        parent = UnitIds.fleshgolem,
        name = "Charred Behemoth",
        abilities = { "threateningRoar", "overwhelming" },
    },
    mawChain = {
        parent = UnitIds.circleofpower,
        name = "Domination Chain",
        abilities = { "relink" },
    },
    -- == Special
    mawswornShade = {
        parent = UnitIds.shade,
        name = "Transformed",
    },
    -- == Dummy
    -- Soulforges
    soulforgeCloak = {
        parent = UnitIds.shade,
        button = { -1, -1 },
        name = "Forge Cloak",
        apply = function(u)
            u:setBuildTime(5)
        end,
    },
    soulforgeGauntlets = {
        parent = UnitIds.shade,
        name = "Forge Gauntlets",
        button = { -1, -1 },
        apply = function(u)
            u:setBuildTime(5)
        end,
    },
    soulforgeSpikedArmor = {
        parent = UnitIds.shade,
        name = "Forge Spiked Armor",
        button = { -1, -1 },
        apply = function(u)
            u:setBuildTime(5)
        end,
    },
    -- Cage
    mawswornCagePossess = {
        parent = UnitIds.banshee,
        name = "Possess",
        apply = function(u)
            u:setBuildTime(5)
        end,
    },
    mawswornCageTransmute = {
        parent = UnitIds.waterelemental1,
        name = "Transmute",
        apply = function(u)
            u:setBuildTime(5)
        end,
    },
    mawswornCageTransform = {
        parent = UnitIds.shade,
        name = "Transform",
        apply = function(u)
            u:setBuildTime(5)
        end,
    },
}
