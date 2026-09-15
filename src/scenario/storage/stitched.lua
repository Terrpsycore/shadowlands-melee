local Storage = require("lib.storage.storage")

local Stitched = Storage.unitFields("Stitched", {
    total = "int",
    max = "int",
    kyrian = "int",
    necrolord = "int",
    fae = "int",
    venthyr = "int",
    mawsworn = "int",
    -- common = "int"
})

return Stitched
