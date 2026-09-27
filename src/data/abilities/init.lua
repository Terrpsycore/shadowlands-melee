local merge = require("data._merge").merge

local db = {}

local sources = {
    { class = "unit", path = "data.abilities.common" },
    { class = "unit", path = "data.abilities.kyrian.common" },
    { class = "hero", path = "data.abilities.kyrian.heroes" },
    { class = "unit", path = "data.abilities.kyrian.units" },
    { class = "unit", path = "data.abilities.necrolord.common" },
    { class = "hero", path = "data.abilities.necrolord.heroes" },
    { class = "unit", path = "data.abilities.necrolord.units" },
    { class = "unit", path = "data.abilities.fae.common" },
    { class = "hero", path = "data.abilities.fae.heroes" },
    { class = "unit", path = "data.abilities.fae.units" },
    { class = "unit", path = "data.abilities.venthyr.common" },
    { class = "hero", path = "data.abilities.venthyr.heroes" },
    { class = "unit", path = "data.abilities.venthyr.units" },
    { class = "unit", path = "data.abilities.mawsworn.buildings" },
    { class = "unit", path = "data.abilities.mawsworn.common" },
    { class = "hero", path = "data.abilities.mawsworn.heroes" },
    { class = "unit", path = "data.abilities.mawsworn.units" },
}

for _, source in ipairs(sources) do
    merge(db, require(source.path), source.path, source.class, "ability")
end

return db
