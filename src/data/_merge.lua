local function merge(into, part, source, class, domain)
    for slug, row in pairs(part) do
        if into[slug] then
            error("duplicate " .. domain .. " slug '" .. slug .. "' in " .. source)
        end
        into[slug] = row

        if class and not row.class then
            row.class = class
        end
    end
end

return {
    merge = merge,
}
