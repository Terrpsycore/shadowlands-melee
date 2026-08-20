return function(db, kind, ids)
    for slug, data in pairs(db) do
        local id = ids[slug]
        if not id then
            error("missing generated id for " .. slug)
        end
        local spec = kind.resolve(data.parent)
        local obj = spec.new(id, data.parent)
        kind.defaults(obj)
        if spec.apply then
            spec.apply(obj, data)
        end
        if kind.applyFields then
            kind.applyFields(obj, data, slug)
        end
        if data.apply then
            data.apply(obj)
        end
    end
end
