require("vendor.assets.objediting.core.enum")

local function merge(into, part, source, class)
    for slug, row in pairs(part) do
        if into[slug] then
            error("duplicate unit slug '" .. slug .. "' in " .. source)
        end
        into[slug] = row

        if not row.class then
            row.class = class
        end
    end
end

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
    merge(db, require(source.path), source.path, source.class)
end

return db
