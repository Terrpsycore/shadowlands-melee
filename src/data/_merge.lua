local function merge(into, part, source, class, domain, faction)
    for slug, row in pairs(part) do
        if into[slug] then
            error("duplicate " .. domain .. " slug '" .. slug .. "' in " .. source)
        end
        into[slug] = row

        if class and not row.class then
            row.class = class
        end
        if faction and not row.faction then
            row.faction = faction
        end
    end
end

return {
    merge = merge,
}
