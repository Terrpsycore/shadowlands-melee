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
        abilities = { "shackle", "disarm" },
    },
    arbalest = {
        parent = UnitIds.headhunter,
        name = "Arbalest",
        abilities = { "malignantBolt" },
    },
    vanguard = {
        parent = UnitIds.grunt,
        name = "Vanguard",
        abilities = { "accursedStrength", "disarm" },
    },
    myrmidonFlying = {
        parent = UnitIds.dragonhawk,
        name = "Myrmidon",
        abilities = { "fallenArmaments", "myrmidonFly" },
    },
    myrmidon = {
        parent = UnitIds.headhunter,
        name = "Myrmidon",
        abilities = { "fallenArmaments", "myrmidonFly" },
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
    -- == Dummy
    mawswornCagePossess = {
        parent = UnitIds.banshee,
        name = "Possess",
    },
    mawswornCageTransmute = {
        parent = UnitIds.waterelemental1,
        name = "Possess",
    },
    mawswornCageTransform = {
        parent = UnitIds.shade,
        name = "Possess",
    },
}
