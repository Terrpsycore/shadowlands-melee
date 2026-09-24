local UnitDeath = require("data.units.death")

local reserved = {
    parent = true,
    class = true,
    faction = true,
    apply = true,
}

local tags = {
    corpse = true,
    revive = true,
}

local outPath = "src/data/generated/unit_meta.lua"

return function(assigned, db)
    local rows = {}
    for slug, data in pairs(db) do
        local id = assigned[slug]
        if not id then
            error("missing generated id for unit " .. slug)
        end

        for key, value in pairs(data) do
            if not reserved[key] then
                if tags[key] then
                    if type(value) ~= "boolean" then
                        error("unit tag '" .. key .. "' on " .. slug .. " must be boolean")
                    end
                end
            end
        end

        rows[#rows + 1] = {
            id = id,
            slug = slug,
            faction = data.faction,
            corpse = UnitDeath.leavesCorpse(data),
            revive = UnitDeath.canRevive(data),
        }
    end

    table.sort(rows, function(a, b)
        return a.id < b.id
    end)

    local f = assert(io.open(outPath, "w"))
    f:write("return {\n")
    for _, row in ipairs(rows) do
        if row.faction then
            f:write(
                ("    %s = { slug = %q, faction = %q, corpse = %s, revive = %s },\n"):format(
                    row.id,
                    row.slug,
                    row.faction,
                    tostring(row.corpse),
                    tostring(row.revive)
                )
            )
        else
            f:write(
                ("    %s = { slug = %q, corpse = %s, revive = %s },\n"):format(
                    row.id,
                    row.slug,
                    tostring(row.corpse),
                    tostring(row.revive)
                )
            )
        end
    end
    f:write("}\n")
    f:close()
end
