local Storage = require("lib.storage.storage")

local Corpses = Storage.unitFields("sporeCloud", {
    ticks = "int",
    beforeNextTick = "real",
})

return Corpses
