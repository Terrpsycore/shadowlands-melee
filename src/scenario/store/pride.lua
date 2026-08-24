-- trained alive units store
local Storage = require("scenario.storage")
local NS = Storage.NS.PRIDE
local FIELD_UNIT = 1

local function parent(id)
    return NS * 1000000 + id
end

local unitToId = {}

local PrideStore = {}

function PrideStore.add(unit)
    local id = Storage.allocId("pride_next")
    Storage.setUnitHandle(parent(id), FIELD_UNIT, unit)
    Storage.registerActive(NS, id)
    unitToId[unit] = id
    return id
end

function PrideStore.forEach(fn)
    Storage.forEachActive(NS, function(id)
        local unit = Storage.getUnitHandle(parent(id), FIELD_UNIT)
        if unit then
            fn(unit, id)
        end
    end)
end

function PrideStore.remove(unit)
    local id = unitToId[unit]
    if not id then
        return
    end
    Storage.flushChild(parent(id))
    Storage.unregisterActive(NS, id)
    unitToId[unit] = nil
end

-- Lua-кэш activeRegistry после load пустой; hashtable живая
function PrideStore.init()
    local maxId = Storage.getAllocCounter("pride_next")
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

return PrideStore
