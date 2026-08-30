local htApi = require("lib.storage.ht")
local schema = require("lib.storage.schema")
local Storage = require("lib.storage.instance")

return function(name, fieldSchema)
    local store = Storage.new(name, { mode = "unitFields" })
    local fields = schema.buildFieldMap(fieldSchema)

    local function requireField(fieldName)
        local field = fields[fieldName]
        if not field then
            error("unknown field '" .. fieldName .. "' on " .. name)
        end
        return field
    end

    function store:set(unit, fieldName, value)
        local field = requireField(fieldName)
        field.access.set(self:unitParent(unit), field.child, value)
    end

    function store:get(unit, fieldName)
        local field = requireField(fieldName)
        return field.access.get(self:unitParent(unit), field.child)
    end

    function store:have(unit, fieldName)
        local field = requireField(fieldName)
        return field.access.have(self:unitParent(unit), field.child)
    end

    function store:clear(unit)
        htApi.flushChild(self:unitParent(unit))
    end

    return store
end
