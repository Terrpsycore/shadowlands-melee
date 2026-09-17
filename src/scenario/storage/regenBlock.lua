local Storage = require("lib.storage.storage")

local RegenBlock = Storage.unitFields("regenBlock", {
    type = "int", -- 1=health, 2=mana
    frozenAmount = "real",
})

return RegenBlock
