require("vendor.assets.objediting.core.enum")

local merge = require("data._merge").merge

local db = {}

local sources = {
    { path = "data.units.common" },
    { class = "hero", path = "data.units.kyrian.heroes" },
    { class = "unit", path = "data.units.kyrian.units" },
    { class = "building", path = "data.units.kyrian.buildings" },
    { class = "hero", path = "data.units.necrolord.heroes" },
    { class = "unit", path = "data.units.necrolord.units" },
    { class = "building", path = "data.units.necrolord.buildings" },
    { class = "hero", path = "data.units.fae.heroes" },
    { class = "unit", path = "data.units.fae.units" },
    { class = "building", path = "data.units.fae.buildings" },
    { class = "hero", path = "data.units.venthyr.heroes" },
    { class = "unit", path = "data.units.venthyr.units" },
    { class = "building", path = "data.units.venthyr.buildings" },
    { class = "hero", path = "data.units.mawsworn.heroes" },
    { class = "unit", path = "data.units.mawsworn.units" },
    { class = "building", path = "data.units.mawsworn.buildings" },
}

for _, source in ipairs(sources) do
    merge(db, require(source.path), source.path, source.class, "unit")
end

return db
