-- trained alive units store
local Storage = require("scenario.storage")
local NS = Storage.NS.PHALYNX
local FIELD_UNIT = 1

local function parent(id)
    return NS * 1000000 + id
end

local unitToId = {}

local PhalynxStore = {}

function PhalynxStore.add(unit)
    local id = Storage.allocId("phalynx_next")
    Storage.setUnitHandle(parent(id), FIELD_UNIT, unit)
    Storage.registerActive(NS, id)
    unitToId[unit] = id
    return id
end

function PhalynxStore.forEach(fn)
    Storage.forEachActive(NS, function(id)
        local unit = Storage.getUnitHandle(parent(id), FIELD_UNIT)
        if unit then
            fn(unit, id)
        end
    end)
end

function PhalynxStore.remove(unit)
    local id = unitToId[unit]
    if not id then
        return
    end
    Storage.flushChild(parent(id))
    Storage.unregisterActive(NS, id)
    unitToId[unit] = nil
end

-- Lua-кэш activeRegistry после load пустой; hashtable живая
function PhalynxStore.init()
    local maxId = Storage.getAllocCounter("phalynx_next")
    for id = 1, maxId do
        if Storage.haveSaved(parent(id), FIELD_UNIT) then
            Storage.registerActive(NS, id)
            local unit = Storage.getUnitHandle(parent(id), FIELD_UNIT)
            if unit then
                unitToId[unit] = id
            end
        end
    end
end

return PhalynxStore
