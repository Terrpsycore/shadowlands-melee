local function merge(into, part, source)
    for slug, row in pairs(part) do
        if into[slug] then
            error("duplicate ability slug '" .. slug .. "' in " .. source)
        end
        into[slug] = row
    end
end

local db = {}

local sources = {
    "data.abilities.common",
    "data.abilities.kyrian.common",
    "data.abilities.kyrian.units",
    "data.abilities.kyrian.heroes",
}

for _, path in ipairs(sources) do
    merge(db, require(path), path)
end

return db
