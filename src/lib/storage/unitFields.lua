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

    local function exists(unit)
        local parent = store:unitParent(unit)
        for _, field in pairs(fields) do
            if field.access.have(parent, field.child) then
                return true
            end
        end
        return false
    end

    local function readField(unit, fieldName)
        local field = requireField(fieldName)
        return field.access.get(store:unitParent(unit), field.child)
    end

    local function writeField(unit, fieldName, value)
        units[unit] = true
        local field = requireField(fieldName)
        field.access.set(store:unitParent(unit), field.child, value)
    end

    function store:set(unit, fieldName, value)
        writeField(unit, fieldName, value)
    end

    function store:get(unit, fieldName)
        return readField(unit, fieldName)
    end

    function store:have(unit)
        return not not units[unit] or exists(unit)
    end

    local UNIT_MT = {
        __index = function(t, key)
            if fields[key] then
                return readField(t.unit, key)
            end
        end,
        __newindex = function(t, key, value)
            if fields[key] then
                writeField(t.unit, key, value)
                return
            end
            error("unknown field '" .. key .. "' on " .. name)
        end,
    }

    function store:open(unit)
        if not exists(unit) then
            return nil
        end
        units[unit] = true
        return setmetatable({ unit = unit }, UNIT_MT)
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
