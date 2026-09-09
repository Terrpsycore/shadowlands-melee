local Storage = require("lib.storage.storage")

local CombatExpertise = Storage.unitFields("combatExpertise", {
    buffLevel = "int",
    frags = "int",
})

return CombatExpertise
