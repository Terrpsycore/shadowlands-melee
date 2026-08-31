-- TODO:
-- - refactor have/exists

local htApi = require("lib.storage.ht")
local schema = require("lib.storage.schema")
local Storage = require("lib.storage.instance")

return function(name, fieldSchema)
    local store = Storage.new(name, { mode = "unitFields" })
    local fields = schema.buildFieldMap(fieldSchema)
    local units = {}

    local function requireField(fieldName)
        local field = fields[fieldName]
        if not field then
            error("unknown field '" .. fieldName .. "' on " .. name)
        end
        return field
    end

    function store:set(unit, fieldName, value)
        local field = requireField(fieldName)
        units[unit] = true
        field.access.set(self:unitParent(unit), field.child, value)
    end

    function store:get(unit, fieldName)
        local field = requireField(fieldName)
        return field.access.get(self:unitParent(unit), field.child)
    end

    function store:have(unit)
        return not not units[unit]
    end

    function store:clear(unit)
        htApi.flushChild(self:unitParent(unit))
        units[unit] = nil
    end

    function store:forEach(fn)
        for unit in pairs(units) do
            fn(unit)
        end
    end

    return store
end
