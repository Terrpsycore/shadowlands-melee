local ItemIds = require("vendor.assets.ItemIds")
local Icons = require("vendor.assets.generated.Icons")

return {
    dummyUnitItem = {
        parent = ItemIds.ringProtection1,
        unit = true,
    },
    dummyHeroItem = {
        parent = ItemIds.ringProtection1,
    },
    -- Necrolords
    explosivePotion = {
        parent = ItemIds.potionInvisibility,
        name = "Explosive Potion",
        art = {
            icon = Icons.liquidfire,
        },
        abilities = { "concoctedExplosionActive" },
    },
    healingPotion = {
        parent = ItemIds.potionInvisibility,
        name = "Healing Potion",
        art = {
            icon = Icons.potionofrestoration,
        },
        abilities = { "concoctedHealingActive" },
    },
    frenzyPotion = {
        parent = ItemIds.potionInvisibility,
        name = "Frenzy Potion",
        art = {
            icon = Icons.potionpurple,
        },
        abilities = { "concoctedFrenzyActive" },
    },
    -- Mawsworn
    soul = {
        parent = ItemIds.moonKey,
        name = "Soul",
        -- apply type "not-unique"
    },
    soulkeeper0 = {
        parent = ItemIds.kelenDaggerEscape,
        name = "Soulkeeper (0/3)",
        art = { icon = Icons["3m1"] },
        abilities = { "soulkeeper" },
    },
    soulkeeper1 = {
        parent = ItemIds.kelenDaggerEscape,
        name = "Soulkeeper (1/3)",
        art = { icon = Icons["3m1"] },
        abilities = { "soulkeeper" },
    },
    soulkeeper2 = {
        parent = ItemIds.kelenDaggerEscape,
        name = "Soulkeeper (2/3)",
        art = { icon = Icons["3m2"] },
        abilities = { "soulkeeper" },
    },
    soulkeeper3 = {
        parent = ItemIds.kelenDaggerEscape,
        name = "Soulkeeper (3/3)",
        art = { icon = Icons["3m3"] },
        abilities = { "soulkeeper" },
    },
    ---
    soulforgedCloak = {
        parent = ItemIds.kelenDaggerEscape,
        name = "Soulfourged Cloak",
        -- art = { icon = Icons["3m3"] },
        abilities = { "soulforgedCloak" },
    },
    soulforgedGauntlets = {
        parent = ItemIds.moonKey,
        name = "Soulfourged Gauntlets",
        -- art = { icon = Icons["3m3"] },
        abilities = {},
    },
    soulforgedSpikedArmor = {
        parent = ItemIds.kelenDaggerEscape,
        name = "Soulfourged Spiked Armor",
        -- art = { icon = Icons["3m3"] },
        abilities = { "soulforgedSpikedArmor", "soulforgedSpikedArmorNegativeRegen" },
    },
}
