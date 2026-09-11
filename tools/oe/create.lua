return function(db, kind, ids)
    for slug, data in pairs(db) do
        local id = ids[slug]
        if not id then
            error("missing generated id for " .. slug)
        end
        local spec = kind.resolve(data.parent)
        local ok, obj = pcall(spec.new, id, data.parent, data.class)
        if not ok then
            error(string.format("failed to create %s (%s): %s", slug, id, obj), 0)
        end
        kind.defaults(obj, data)
        if spec.apply then
            spec.apply(obj, data)
        end
        if kind.applyFields then
            kind.applyFields(obj, data, slug)
        end
        if kind.finalize then
            kind.finalize(obj, data, slug)
        end
        if data.apply then
            data.apply(obj)
        end
    end
end
