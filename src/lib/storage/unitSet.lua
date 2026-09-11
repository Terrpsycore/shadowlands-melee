local htApi = require("lib.storage.ht")
local Storage = require("lib.storage.instance")

return function(name)
    local store = Storage.new(name, { mode = "unit" })
    local units = {}
    local unitToId = {}

    function store:add(unit)
        local existingId = unitToId[unit]
        if existingId then
            return existingId
        end
        local id = self:alloc()
        self:setUnitHandle(id, htApi.FIELD_UNIT, unit)
        self:register(id)
        unitToId[unit] = id
        units[unit] = true
        return id
    end

    function store:has(unit)
        return not not unitToId[unit]
    end

    function store:drop(unit)
        local id = unitToId[unit]
        if not id then
            return
        end
        self:flush(id)
        self:unregister(id)
        unitToId[unit] = nil
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
        self:clearActive()

        local maxId = self:maxAlloc()
        for id = 1, maxId do
            if self:hasSaved(id, htApi.FIELD_UNIT) then
                local unit = self:getUnitHandle(id, htApi.FIELD_UNIT)
                if unit then
                    self:register(id)
                    unitToId[unit] = id
                    units[unit] = true
                end
            end
        end
    end

    return store
end
