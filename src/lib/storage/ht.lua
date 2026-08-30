local GLOBAL = 0
local NS_META = StringHash("__ns_meta__")

local ht = InitHashtable()

local function nsSlot(name)
    return StringHash("__ns:" .. name)
end

local function allocSlot(name)
    return StringHash(name .. "_next")
end

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

local function flushChild(parent)
    FlushChildHashtable(ht, parent)
end

local function haveSaved(parent, child)
    return HaveSavedInteger(ht, parent, child)
        or HaveSavedReal(ht, parent, child)
        or HaveSavedBoolean(ht, parent, child)
        or HaveSavedHandle(ht, parent, child)
end

local function getOrAssignNsId(name)
    local slot = nsSlot(name)
    if HaveSavedInteger(ht, GLOBAL, slot) then
        return getInt(GLOBAL, slot)
    end
    local nsId = getInt(GLOBAL, NS_META) + 1
    setInt(GLOBAL, NS_META, nsId)
    setInt(GLOBAL, slot, nsId)
    return nsId
end

return {
    GLOBAL = GLOBAL,
    FIELD_UNIT = 1,
    ht = ht,
    getInt = getInt,
    setInt = setInt,
    getReal = getReal,
    setReal = setReal,
    getBool = getBool,
    setBool = setBool,
    getUnitHandle = getUnitHandle,
    setUnitHandle = setUnitHandle,
    flushChild = flushChild,
    haveSaved = haveSaved,
    getOrAssignNsId = getOrAssignNsId,
    allocSlot = allocSlot,
}
