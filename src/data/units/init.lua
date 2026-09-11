require("vendor.assets.objediting.core.enum")

local merge = require("data._merge").merge

local db = {}

local sources = {
    { path = "data.units.common" },
    { faction = "kyrian", class = "hero", path = "data.units.kyrian.heroes" },
    { faction = "kyrian", class = "unit", path = "data.units.kyrian.units" },
    { faction = "kyrian", class = "building", path = "data.units.kyrian.buildings" },
    { faction = "necrolord", class = "hero", path = "data.units.necrolord.heroes" },
    { faction = "necrolord", class = "unit", path = "data.units.necrolord.units" },
    { faction = "necrolord", class = "building", path = "data.units.necrolord.buildings" },
    { faction = "fae", class = "hero", path = "data.units.fae.heroes" },
    { faction = "fae", class = "unit", path = "data.units.fae.units" },
    { faction = "fae", class = "building", path = "data.units.fae.buildings" },
    { faction = "venthyr", class = "hero", path = "data.units.venthyr.heroes" },
    { faction = "venthyr", class = "unit", path = "data.units.venthyr.units" },
    { faction = "venthyr", class = "building", path = "data.units.venthyr.buildings" },
    { faction = "mawsworn", class = "hero", path = "data.units.mawsworn.heroes" },
    { faction = "mawsworn", class = "unit", path = "data.units.mawsworn.units" },
    { faction = "mawsworn", class = "building", path = "data.units.mawsworn.buildings" },
}

for _, source in ipairs(sources) do
    merge(db, require(source.path), source.path, source.class, "unit", source.faction)
end

return db
