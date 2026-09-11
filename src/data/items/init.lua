local merge = require("data._merge").merge
local corpses = require("data.items.corpses")

local db = {}

merge(db, require("data.items.manual"), "data.items.manual", nil, "item")
merge(db, corpses.build(), "data.items.corpses", nil, "item")

return db
