local merge = require("data._merge").merge
local corpses = require("data.items.corpses")
local grabbed = require("data.items.grabbed")

local db = {}

merge(db, require("data.items.manual"), "data.items.manual", nil, "item")
merge(db, corpses.build(), "data.items.corpses", nil, "item")
merge(db, grabbed.build(), "data.items.grabbed", nil, "item")

return db
