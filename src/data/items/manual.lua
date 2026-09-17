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
}
