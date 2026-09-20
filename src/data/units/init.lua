require("vendor.assets.objediting.core.enum")

local merge = require("data._merge").merge

local db = {}
local sources = require("data.units._sources")

for _, source in ipairs(sources) do
    merge(db, require(source.path), source.path, source.class, "unit", source.faction)
end

return db
