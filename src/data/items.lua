local ItemIds = require("lib.community.types.assets.ItemIds")

local db = {
    dummyUnitItem = {
        parent = ItemIds.ringProtection1,
        unit = true,
    },
    dummyHeroItem = {
        parent = ItemIds.ringProtection1,
    },
}

return db
