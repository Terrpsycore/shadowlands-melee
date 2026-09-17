local Storage = require("lib.storage.storage")

local Corpses = Storage.unitFields("corrosivePlague", {
    owner = "int", -- int
})

return Corpses
