local htApi = require("lib.storage.ht")

local instances = {}

local PARENT_ACCESSORS = {
    {
        prefix = "Int",
        get = htApi.getInt,
        set = htApi.setInt,
    },
    {
        prefix = "Real",
        get = htApi.getReal,
        set = htApi.setReal,
    },
    {
        prefix = "Bool",
        get = htApi.getBool,
        set = htApi.setBool,
    },
    {
        prefix = "UnitHandle",
        get = htApi.getUnitHandle,
        set = htApi.setUnitHandle,
    },
}

local Storage = {}

function Storage.new(name, opts)
    opts = opts or {}
    if instances[name] then
        error("duplicate storage instance: " .. name)
    end

    local nsId = htApi.getOrAssignNsId(name)
    local mode = opts.mode or "raw"
    local activeRegistry = {}

    local instance = {
        name = name,
        nsId = nsId,
        mode = mode,
    }

    function instance:parent(key)
        return nsId * 1000000 + key
    end

    function instance:register(id)
        activeRegistry[id] = true
    end

    function instance:unregister(id)
        activeRegistry[id] = nil
    end

    function instance:eachActive(fn)
        for id in pairs(activeRegistry) do
            fn(id)
        end
    end

    function instance:clearActive()
        for id in pairs(activeRegistry) do
            activeRegistry[id] = nil
        end
    end

    function instance:unitParent(unit)
        return StringHash(name .. ":u:" .. tostring(GetHandleId(unit)))
    end

    function instance:flush(key)
        htApi.flushChild(self:parent(key))
    end

    function instance:hasSaved(parentKey, fieldKey)
        return htApi.haveSaved(self:parent(parentKey), fieldKey)
    end

    for _, accessor in ipairs(PARENT_ACCESSORS) do
        instance["get" .. accessor.prefix] = function(self, parentKey, fieldKey)
            return accessor.get(self:parent(parentKey), fieldKey)
        end
        instance["set" .. accessor.prefix] = function(self, parentKey, fieldKey, value)
            accessor.set(self:parent(parentKey), fieldKey, value)
        end
    end

    if mode == "record" or mode == "unit" or mode == "unitFields" then
        local slot = htApi.allocSlot(name)

        function instance:maxAlloc()
            return htApi.getInt(htApi.GLOBAL, slot)
        end

        function instance:alloc()
            local nextId = self:maxAlloc() + 1
            htApi.setInt(htApi.GLOBAL, slot, nextId)
            return nextId
        end
    end

    instances[name] = instance
    return instance
end

function Storage.initAll()
    for _, instance in pairs(instances) do
        if instance.init then
            instance:init()
        end
    end
end

return Storage
