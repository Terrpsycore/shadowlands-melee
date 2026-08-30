local Storage = require("lib.storage.storage")

return Storage.record("soulbind", {
    existsField = "level",
    fields = {
        level = { type = "int", default = 1, child = 1 },
        progress = { type = "real", default = 0, child = 2 },
        active = { type = "bool", default = false, child = 3 },
        unit_a = { type = "unit", child = 4 },
        unit_b = { type = "unit", child = 5 },
    },
    indexes = {
        byUnit = { "unit_a", "unit_b" },
    },
})
