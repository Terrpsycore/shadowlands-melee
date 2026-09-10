local Storage = require("lib.storage.storage")

local Corpses = Storage.unitFields("corpses", {
    -- unitType
    reviveAfter = "int",
    diedAt = "real",
})

return Corpses
