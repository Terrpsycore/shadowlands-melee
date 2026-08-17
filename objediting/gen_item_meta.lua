local reserved = {
    parent = true,
    apply = true,
}

local tags = {
    unit = true,
    unique = true,
}

local outPath = "src/generated/item_meta.lua"

return function(assigned, db)
    local rows = {}
    for slug, data in pairs(db) do
        local id = assigned[slug]
        if not id then
            error("missing generated id for item " .. slug)
        end
        for key, value in pairs(data) do
            if not reserved[key] then
                if not tags[key] then
                    error("unknown item field '" .. key .. "' on " .. slug)
                end
                if type(value) ~= "boolean" then
                    error("item tag '" .. key .. "' on " .. slug .. " must be boolean")
                end
            end
        end
        rows[#rows + 1] = {
            id = id,
            slug = slug,
            hero = data.unit ~= true,
            unique = data.unique == true,
        }
    end
    table.sort(rows, function(a, b)
        return a.id < b.id
    end)

    local f = assert(io.open(outPath, "w"))
    f:write("return {\n")
    for _, row in ipairs(rows) do
        f:write(("    %s = { slug = %q, hero = %s, unique = %s },\n"):format(
            row.id,
            row.slug,
            tostring(row.hero),
            tostring(row.unique)
        ))
    end
    f:write("}\n")
    f:close()
end
