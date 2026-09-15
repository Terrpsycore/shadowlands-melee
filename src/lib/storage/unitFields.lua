local htApi = require("lib.storage.ht")
local schema = require("lib.storage.schema")
local Storage = require("lib.storage.instance")

---@param name string
---@param fieldSchema table
return function(name, fieldSchema)
    local store = Storage.new(name, { mode = "unitFields" })
    local fields = schema.buildFieldMap(fieldSchema)
    local units = {}
    local unitToId = {}

    local function requireField(fieldName)
        local field = fields[fieldName]
        if not field then
            error("unknown field '" .. fieldName .. "' on " .. name)
        end
        return field
    end

    local function hasData(unit)
        local parent = store:unitParent(unit)
        for _, field in pairs(fields) do
            if field.access.have(parent, field.child) then
                return true
            end
        end
        return false
    end

    local function trackUnit(unit)
        if unitToId[unit] then
            return
        end
        local id = store:alloc()
        store:setUnitHandle(id, htApi.FIELD_UNIT, unit)
        unitToId[unit] = id
    end

    local function readField(unit, fieldName)
        local field = requireField(fieldName)
        return field.access.get(store:unitParent(unit), field.child)
    end

    local function writeField(unit, fieldName, value)
        trackUnit(unit)
        units[unit] = true
        local field = requireField(fieldName)
        field.access.set(store:unitParent(unit), field.child, value)
    end

    function store:has(unit)
        return not not units[unit] or hasData(unit)
    end

    function store:get(unit, fieldName)
        if fieldName == nil then
            error("unitFields:get(unit, nil) is forbidden call")
        end
        return readField(unit, fieldName)
    end

    function store:set(unit, fieldName, value)
        writeField(unit, fieldName, value)
    end

    local UNIT_MT = {
        __index = function(t, key)
            if fields[key] then
                return readField(t._key, key)
            end
        end,
        __newindex = function(t, key, value)
            if fields[key] then
                writeField(t._key, key, value)
                return
            end
            error("unknown field '" .. key .. "' on " .. name)
        end,
    }

    function store:bind(unit)
        if not hasData(unit) then
            return nil
        end
        units[unit] = true
        return setmetatable({ _key = unit }, UNIT_MT)
    end

    function store:drop(unit)
        htApi.flushChild(self:unitParent(unit))
        local id = unitToId[unit]
        if id then
            self:flush(id)
            unitToId[unit] = nil
        end
        units[unit] = nil
    end

    function store:each(fn)
        for unit in pairs(units) do
            fn(unit)
        end
    end

    function store:init()
        for unit in pairs(units) do
            units[unit] = nil
        end
        for unit in pairs(unitToId) do
            unitToId[unit] = nil
        end

        local maxId = self:maxAlloc()
        for id = 1, maxId do
            if self:hasSaved(id, htApi.FIELD_UNIT) then
                local unit = self:getUnitHandle(id, htApi.FIELD_UNIT)
                if unit and hasData(unit) then
                    unitToId[unit] = id
                    units[unit] = true
                end
            end
        end
    end

    return store
end
