local UnitArt = require("vendor.assets.generated.UnitArt")
local UnitIds = require("vendor.assets.UnitIds")

return {
    runesmith = { -- ensure unit can power build but can't start build
        parent = UnitIds.peasant,
        name = "Runesmith",
        abilities = { "humanBuild", "repairHuman", "stygianShield" },
        mana = { max = 200, initial = 100 },
    },
    shackler = {
        parent = UnitIds.footman,
        name = "Shackler",
        abilities = { "shackle", "disarm", "mawswornGrab", "mawswornInventory" },
        mana = { max = 200, initial = 100 },
    },
    arbalest = {
        parent = UnitIds.headhunter,
        name = "Arbalest",
        abilities = { "malignantBolt", "mawswornGrab", "mawswornInventory" },
        mana = { max = 200, initial = 100 },
    },
    vanguard = {
        parent = UnitIds.grunt,
        name = "Vanguard",
        abilities = { "accursedStrength", "disarm", "mawswornGrab", "mawswornInventory" },
        mana = { max = 200, initial = 100 },
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
        abilities = { "glare", "piercingGaze" },
        art = {
            model = UnitArt[UnitIds.sentryward].model,
        },
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
        parent = UnitIds.demolisher,
        name = "Domination Chain",
        abilities = { "mawChainRelink" },
        attack1 = {
            targetsAllowed = "structure,debris",
        },
    },
    -- == Special
    mawcasterFirePurge = {
        parent = UnitIds.chaoswarlock,
        name = "Fire",
        abilities = { "blazingPurge", "infusion", "burnResidue" },
    },
    vessel = {
        parent = UnitIds.stasistraptotem,
        name = "War Banner",
        abilities = { "warBannerAura" },
        art = { model = UnitArt[UnitIds.shade].model },
    },
    mawswornShade = {
        parent = UnitIds.shade,
        name = "Transformed",
    },
    opressiveChain1 = {
        parent = UnitIds.stasistraptotem,
        name = "Opressive Chain",
        -- apply max hp
    },
    opressiveChain2 = {
        parent = UnitIds.stasistraptotem,
        name = "Opressive Chain",
        -- apply max hp
    },
    opressiveChain3 = {
        parent = UnitIds.stasistraptotem,
        name = "Opressive Chain",
        -- apply max hp
    },
    gorgoaSoul = {
        parent = UnitIds.owl,
        name = "Gorgoa Soul",
        art = { model = UnitArt[UnitIds.shade].model },
        abilities = { "locust" },
    },
    -- == Dummy Train
    -- Soulforges
    soulforgeCloak = {
        parent = UnitIds.shade,
        button = { 0, -11 },
        name = "Forge Cloak",
        apply = function(u)
            u:setBuildTime(5)
        end,
    },
    soulforgeGauntlets = {
        parent = UnitIds.shade,
        name = "Forge Gauntlets",
        button = { 0, -11 },
        apply = function(u)
            u:setBuildTime(5)
        end,
    },
    soulforgeSpikedArmor = {
        parent = UnitIds.shade,
        name = "Forge Spiked Armor",
        button = { 0, -11 },
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
