local reserved = {
    parent = true,
    apply = true,
}

local fields = {
    name = function(b, value)
        b:setName(1, value)
    end,
}

local function applyFields(b, data, slug)
    for key, value in pairs(data) do
        if not reserved[key] then
            local handler = fields[key]
            if not handler then
                error("unknown buff field '" .. key .. "' on " .. slug)
            end
            handler(b, value)
        end
    end
end

return {
    resolve = function()
        return {
            new = function(id, parent)
                return BuffDefinition:new(id, parent)
            end,
        }
    end,
    defaults = function() end,
    applyFields = applyFields,
}
