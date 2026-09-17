local UnitIds = require("vendor.assets.UnitIds")

return {
    lich = {
        parent = UnitIds.lich,
        name = "Lich",
        heroAbilities = { "necroticEruption", "bindDeathwalker", "droughtSigil", "explodeCorpses" },
    },
    bonesmith = {
        parent = UnitIds.dreadlord,
        name = "Bonesmith",
        heroAbilities = { "moldWeakness", "serratedSpaulders", "ammunitionControl", "forgeboneReveries" },
    },
    gladiatorHero = {
        parent = UnitIds.deathknight,
        name = "Gladiator",
        heroAbilities = { "weaponTest", "opressiveBanner", "brutalCombo", "allOnOne" },
    },
}
