local merge = require("data._merge").merge

local db = {}
local sources = require("data.abilities._sources")

for _, source in ipairs(sources) do
    merge(db, require(source.path), source.path, source.class, "ability")
end

return db
