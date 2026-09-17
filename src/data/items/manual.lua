local ItemIds = require("vendor.assets.ItemIds")

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
        abilities = { "concoctedExplosionActive" },
    },
    healingPotion = {
        parent = ItemIds.potionInvisibility,
        abilities = { "concoctedHealingActive" },
    },
    frenzyPotion = {
        parent = ItemIds.potionInvisibility,
        abilities = { "concoctedFrenzyActive" },
    },
}
