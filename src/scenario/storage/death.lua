local Storage = require("lib.storage.storage")

local Death = Storage.unitFields("Death", {
    originalOwner = "int",
    -- faction = "string",
    reviveAfter = "int",
    unit = "unit",
    isPeon = "bool",
    diedAt = "real",
})

return Death
