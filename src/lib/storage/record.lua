local schema = require("lib.storage.schema")
local Storage = require("lib.storage.instance")

return function(name, recordSchema)
    local store = Storage.new(name, { mode = "record" })
    local fields = schema.buildFieldMap(recordSchema.fields)
    local existsField = recordSchema.existsField
    local indexMaps = {}

    if recordSchema.indexes then
        for indexName, fieldNames in pairs(recordSchema.indexes) do
            indexMaps[indexName] = {
                fieldNames = fieldNames,
                map = {},
            }
        end
    end

    local fieldIndexes = {}
    for _, index in pairs(indexMaps) do
        for _, fieldName in ipairs(index.fieldNames) do
            if fields[fieldName] and fields[fieldName].type == "unit" then
                local list = fieldIndexes[fieldName]
                if not list then
                    list = {}
                    fieldIndexes[fieldName] = list
                end
                list[#list + 1] = index
            end
        end
    end

    local function writeField(recordId, fieldName, value)
        local field = fields[fieldName]
        field.access.set(store:parent(recordId), field.child, value)
    end

    local function readField(recordId, fieldName)
        local field = fields[fieldName]
        return field.access.get(store:parent(recordId), field.child)
    end

    local function syncIndexedUnitField(recordId, fieldName, value)
        local indexes = fieldIndexes[fieldName]
        if not indexes then
            return
        end
        local oldUnit = readField(recordId, fieldName)
        for _, index in ipairs(indexes) do
            if oldUnit and index.map[oldUnit] == recordId then
                index.map[oldUnit] = nil
            end
            if value then
                local existing = index.map[value]
                if existing and existing ~= recordId then
                    error(name .. ": unit already indexed by record " .. existing)
                end
                index.map[value] = recordId
            end
        end
    end

    local function registerIndexes(recordId, data)
        for _, index in pairs(indexMaps) do
            for _, fieldName in ipairs(index.fieldNames) do
                local unit = data[fieldName]
                if unit then
                    index.map[unit] = recordId
                end
            end
        end
    end

    local function unregisterIndexes(recordId)
        for _, index in pairs(indexMaps) do
            for unit, mappedId in pairs(index.map) do
                if mappedId == recordId then
                    index.map[unit] = nil
                end
            end
        end
    end

    local function exists(recordId)
        if existsField then
            local field = fields[existsField]
            return field.access.have(store:parent(recordId), field.child)
        end
        for _, field in pairs(fields) do
            if field.access.have(store:parent(recordId), field.child) then
                return true
            end
        end
        return false
    end

    function store:get(recordId)
        if not exists(recordId) then
            return nil
        end
        local data = {}
        for fieldName in pairs(fields) do
            data[fieldName] = readField(recordId, fieldName)
        end
        return data
    end

    function store:create(recordId, data)
        if exists(recordId) then
            return false
        end
        for _, index in pairs(indexMaps) do
            for _, fieldName in ipairs(index.fieldNames) do
                local unit = data[fieldName]
                if unit and index.map[unit] then
                    return false
                end
            end
        end

        for fieldName, field in pairs(fields) do
            local value = data[fieldName]
            if value == nil then
                value = field.default
            end
            if value ~= nil then
                writeField(recordId, fieldName, value)
            end
        end

        registerIndexes(recordId, data)
        self:register(recordId)
        return true
    end

    local RECORD_MT = {
        __index = function(t, key)
            if fields[key] then
                return readField(t.id, key)
            end
        end,
        __newindex = function(t, key, value)
            if fields[key] then
                if fieldIndexes[key] then
                    syncIndexedUnitField(t.id, key, value)
                end
                writeField(t.id, key, value)
                return
            end
            error("unknown record field: " .. key)
        end,
    }

    function store:open(recordId)
        if not exists(recordId) then
            return nil
        end
        return setmetatable({ id = recordId }, RECORD_MT)
    end

    function store:destroy(recordId)
        if not exists(recordId) then
            return
        end
        unregisterIndexes(recordId)
        self:flush(recordId)
        self:unregister(recordId)
    end

    function store:getByUnit(unit)
        for _, index in pairs(indexMaps) do
            local recordId = index.map[unit]
            if recordId then
                return recordId
            end
        end
        return nil
    end

    function store:init()
        for _, index in pairs(indexMaps) do
            for unit in pairs(index.map) do
                index.map[unit] = nil
            end
        end
        self:clearActive()

        local maxId = self:maxAlloc()
        for recordId = 1, maxId do
            local data = self:get(recordId)
            if data then
                self:register(recordId)
                registerIndexes(recordId, data)
            end
        end
    end

    return store
end
