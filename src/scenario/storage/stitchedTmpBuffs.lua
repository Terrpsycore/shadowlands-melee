local Storage = require("lib.storage.storage")

local StitchedTmpBuffs = Storage.unitFields("StitchedTmpBuffs", {
    faction = "int", -- 1 - 5
    expiresAt = "real",
})

return StitchedTmpBuffs
