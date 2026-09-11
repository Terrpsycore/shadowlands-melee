local M = {}

function M.normalizePath(path)
    return path:gsub("/", "\\")
end

function M.applySubfields(obj, value, mapping, context)
    for key, val in pairs(value) do
        local handler = mapping[key]
        if not handler then
            error("unknown " .. context .. " field '" .. key .. "'")
        end
        handler(obj, val)
    end
end

return M
