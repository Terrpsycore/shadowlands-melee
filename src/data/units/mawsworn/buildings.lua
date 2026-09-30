local UnitIds = require("vendor.assets.UnitIds")

return {
    -- Basic --
    mawswornMain = {
        parent = UnitIds.townhall,
        name = "Main",
        unitsTrained = { "runesmith" },
        abilities = { "suppressingAura" },
        structuresBuilt = {
            "mawswornMain",
        },
    },
    mawswornAltar = {
        parent = UnitIds.altarofstorms,
        name = "Altar",
        unitsTrained = { "forswornHero", "mawcasterHero", "mournebladeHero" },
        revivesDeadHeros = true,
    },
    -- Resources --
    mawswornCage = {
        parent = UnitIds.farm,
        abilities = { "mawswornCageInventory" },
        unitsTrained = { "mawswornCagePossess", "mawswornCageTransmute", "mawswornCageTransform" },
    },
    -- Barracks --
    mawswornBarracks = {
        parent = UnitIds.crypt,
        name = "PLACEHOLDER",
        unitsTrained = { "shackler", "arbalest", "vanguard" },
    },
    mawswornBarracks2 = { -- too much barracks!!!
        parent = UnitIds.crypt,
        name = "PLACEHOLDER",
        unitsTrained = { "soulEater" },
    },
    mawswornMechBarracks = {
        parent = UnitIds.crypt,
        name = "PLACEHOLDER",
        unitsTrained = { "mawChain", "soulSeeker", "charredBehemoth" },
    },
    mawswornMageBarracks = {
        parent = UnitIds.crypt,
        name = "PLACEHOLDER",
        unitsTrained = { "mawcasterFire", "mawcasterFrost", "mawcasterDomination" },
    },
    coldheartSpire = {
        parent = UnitIds.crypt,
        name = "Coldheart Spire",
        unitsTrained = { "myrmidon" },
    },
    -- Misc --
    mawswornShop = {
        parent = UnitIds.marketplace,
        name = "Shop",
    },
}
