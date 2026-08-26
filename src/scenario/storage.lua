local ht = InitHashtable()

-- Реестр namespace'ов — чтобы способности не пересекались
local NS = {
    GLOBAL = 0,
    SOULBIND = 1,
    PRIDE = 2,
    PHALYNX = 3,
    CONTROL = 4,
}

local activeRegistry = {} -- runtime-only: ns -> { [id] = true }

local ALLOC = {
    soulbind_next_bond = 1,
    pride_next = 2,
    phalynx_next = 3,
    control_next = 4,
}

local function getInt(parent, child)
    return LoadInteger(ht, parent, child)
end

local function setInt(parent, child, value)
    SaveInteger(ht, parent, child, value)
end

local function getReal(parent, child)
    return LoadReal(ht, parent, child)
end

local function setReal(parent, child, value)
    SaveReal(ht, parent, child, value)
end

local function getBool(parent, child)
    return LoadBoolean(ht, parent, child)
end

local function setBool(parent, child, value)
    SaveBoolean(ht, parent, child, value)
end

local function setUnitHandle(parent, child, unit)
    SaveUnitHandle(ht, parent, child, unit)
end

local function getUnitHandle(parent, child)
    return LoadUnitHandle(ht, parent, child)
end

local function getAllocCounter(name)
    local child = ALLOC[name]
    if not child then
        error("unknown alloc key: " .. tostring(name))
    end
    return getInt(NS.GLOBAL, child)
end

local function allocId(name)
    local child = ALLOC[name]
    if not child then
        error("unknown alloc key: " .. tostring(name))
    end
    local next = getAllocCounter(name) + 1
    setInt(NS.GLOBAL, child, next)
    return next
end

local function registerActive(ns, id)
    local reg = activeRegistry[ns]
    if not reg then
        reg = {}
        activeRegistry[ns] = reg
    end
    reg[id] = true
end

local function unregisterActive(ns, id)
    local reg = activeRegistry[ns]
    if reg then
        reg[id] = nil
    end
end

local function forEachActive(ns, fn)
    local reg = activeRegistry[ns]
    if not reg then
        return
    end
    for id in pairs(reg) do
        fn(id)
    end
end

local function flushChild(parent)
    FlushChildHashtable(ht, parent)
end

local function haveSaved(parent, child)
    return HaveSavedInteger(ht, parent, child)
        or HaveSavedReal(ht, parent, child)
        or HaveSavedBoolean(ht, parent, child)
        or HaveSavedHandle(ht, parent, child)
end

return {
    ht = ht,
    NS = NS,
    getInt = getInt,
    setInt = setInt,
    getReal = getReal,
    setReal = setReal,
    getBool = getBool,
    setBool = setBool,
    getAllocCounter = getAllocCounter,
    allocId = allocId,
    registerActive = registerActive,
    unregisterActive = unregisterActive,
    forEachActive = forEachActive,
    flushChild = flushChild,
    haveSaved = haveSaved,
    setUnitHandle = setUnitHandle,
    getUnitHandle = getUnitHandle,
}
