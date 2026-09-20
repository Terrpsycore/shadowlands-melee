local UnitIds = require("vendor.assets.UnitIds")
local Icons = require("vendor.assets.generated.Icons")

return {
    lich = {
        parent = UnitIds.lich,
        name = "Lich",
        heroAbilities = { "necroticEruption", "bindDeathwalker", "droughtSigil", "explodeCorpses" },
    },
    bonesmith = {
        parent = UnitIds.dreadlord,
        name = "Bonesmith",
        art = { icon = Icons.skeletonMage },
        heroAbilities = { "moldWeakness", "serratedSpaulders", "ammunitionControl", "forgeboneReveries" },
    },
    gladiatorHero = {
        parent = UnitIds.deathknight,
        name = "Gladiator",
        art = { icon = Icons.chaosWarlord },
        heroAbilities = { "weaponTest", "opressiveBanner", "brutalCombo", "allOnOne" },
        -- abilities = { "brutalComboCrit" },
    },
}
