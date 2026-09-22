local merge = require("data._merge").merge

local db = {}
local sources = require("data.upgrades._sources")

merge(db, require("data.upgrades.template"), "data.upgrades.template", nil, "upgrade")

for _, source in ipairs(sources) do
    merge(db, require(source.path), source.path, nil, "upgrade", source.faction)
end

return db
