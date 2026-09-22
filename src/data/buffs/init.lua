local merge = require("data._merge").merge

local db = {}
local sources = require("data.buffs._sources")

for _, source in ipairs(sources) do
    merge(db, require(source.path), source.path, nil, "buff", source.faction)
end

return db
