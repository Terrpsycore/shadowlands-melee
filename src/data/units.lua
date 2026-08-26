local UnitIds = require("lib.community.types.assets.UnitIds")

local db = {
    dummy = {
        parent = UnitIds.footman,
        abilities = {},
        apply = function(u)
            u:setManaMaximum(1000)
            u:setManaInitialAmount(1000)
            u:setModelFile("")
        end,
    },
    dummyHero = {
        parent = UnitIds.paladin,
        name = "Name",
    },
    steward = {
        parent = UnitIds.peasant,
        name = "Steward",
    },
    aspirant = {
        parent = UnitIds.footman,
        name = "Aspirant",
        abilities = { "soulbind" },
    },
    praetor = {
        parent = UnitIds.grunt,
        name = "Praetor",
        abilities = { "defenceProtocol" },
    },
    larion = {
        parent = UnitIds.druidoftheclaw,
        name = "Larion",
        abilities = { "cannibalizeSearch", "pride" },
    },
    purity = {
        parent = UnitIds.priest,
        name = "Praetor",
    },
    wisdom = {
        parent = UnitIds.sorceress,
        name = "Praetor",
    },
    loyalty = {
        parent = UnitIds.spellbreaker,
        name = "Praetor",
    },
    phalynx = {
        parent = UnitIds.whitewolf,
        name = "Phalynx",
    },
    goliath = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
    colossus = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
    ascendedWarrior = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
    ascendedPurity = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
    ascendedWisdom = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
    ascendedLoyalty = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
}

return db
