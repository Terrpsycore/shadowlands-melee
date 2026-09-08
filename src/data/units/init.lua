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
}

for _, source in ipairs(sources) do
    merge(db, require(source.path), source.path, source.class)
end

return db
