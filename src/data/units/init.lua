local function merge(into, part, source)
    for slug, row in pairs(part) do
        if into[slug] then
            error("duplicate unit slug '" .. slug .. "' in " .. source)
        end
        into[slug] = row
    end
end

local db = {}

local sources = {
    "data.units.common",
    "data.units.kyrian.units",
    "data.units.kyrian.buildings",
}

for _, path in ipairs(sources) do
    merge(db, require(path), path)
end

return db
