local Storage = require("scenario.storage")
local NS = Storage.NS.SOULBIND

local FIELD = {
    LEVEL = 1,
    PROGRESS = 2,
    ACTIVE = 3,
    UNIT_A = 4,
    UNIT_B = 5,
}

local function bondParent(bondId)
    return NS * 1000000 + bondId
end

local unitBond = {} -- runtime-only: unit -> bondId

local function registerUnit(unit, bondId)
    unitBond[unit] = bondId
end

local function unregisterUnit(unit)
    unitBond[unit] = nil
end

local SoulbindStore = {}

function SoulbindStore.allocBondId()
    return Storage.allocId("soulbind_next_bond")
end

function SoulbindStore.exists(bondId)
    return SoulbindStore.get(bondId) ~= nil
end

function SoulbindStore.isUnitBonded(unit)
    return unitBond[unit] ~= nil
end

function SoulbindStore.create(bondId, u1, u2)
    if SoulbindStore.get(bondId) then
        return false
    end
    if unitBond[u1] or unitBond[u2] then
        return false
    end

    local p = bondParent(bondId)
    Storage.setInt(p, FIELD.LEVEL, 1)
    Storage.setReal(p, FIELD.PROGRESS, 0)
    Storage.setBool(p, FIELD.ACTIVE, false)
    Storage.setUnitHandle(p, FIELD.UNIT_A, u1)
    Storage.setUnitHandle(p, FIELD.UNIT_B, u2)
    registerUnit(u1, bondId)
    registerUnit(u2, bondId)
    Storage.registerActive(NS, bondId)
    return true
end

function SoulbindStore.get(bondId)
    local p = bondParent(bondId)
    if not Storage.haveSaved(p, FIELD.LEVEL) then
        return nil
    end
    local u1 = Storage.getUnitHandle(p, FIELD.UNIT_A)
    local u2 = Storage.getUnitHandle(p, FIELD.UNIT_B)
    return {
        units = { u1, u2 },
        level = Storage.getInt(p, FIELD.LEVEL),
        progress = Storage.getReal(p, FIELD.PROGRESS),
        active = Storage.getBool(p, FIELD.ACTIVE),
    }
end

local BOND_MT = {
    -- ЧТЕНИЕ: bond.active → ключа нет → __index → Storage
    __index = function(t, key)
        local p = bondParent(t.id)
        if key == "level" then
            return Storage.getInt(p, FIELD.LEVEL)
        elseif key == "progress" then
            return Storage.getReal(p, FIELD.PROGRESS)
        elseif key == "active" then
            return Storage.getBool(p, FIELD.ACTIVE)
        end
    end,
    -- ЗАПИСЬ: bond.active = true → ключа нет → __newindex → Storage
    __newindex = function(t, key, value)
        local p = bondParent(t.id)
        if key == "level" then
            Storage.setInt(p, FIELD.LEVEL, value)
        elseif key == "progress" then
            Storage.setReal(p, FIELD.PROGRESS, value)
        elseif key == "active" then
            Storage.setBool(p, FIELD.ACTIVE, value)
        else
            error("unknown bond field: " .. key)
        end
    end,
}

function SoulbindStore.open(bondId)
    local snapshot = SoulbindStore.get(bondId)
    if not snapshot then
        return nil
    end
    return setmetatable({ id = bondId, units = snapshot.units }, BOND_MT)
end

function SoulbindStore.destroy(bondId)
    local bond = SoulbindStore.get(bondId)
    if not bond then
        return
    end
    for _, unit in ipairs(bond.units) do
        unregisterUnit(unit)
    end
    Storage.flushChild(bondParent(bondId))
    Storage.unregisterActive(NS, bondId)
end

function SoulbindStore.getBondIdByUnit(unit)
    return unitBond[unit]
end

function SoulbindStore.forEachActive(fn)
    Storage.forEachActive(NS, fn)
end

function SoulbindStore.init()
    for unit in pairs(unitBond) do
        unitBond[unit] = nil
    end

    local maxBondId = Storage.getAllocCounter("soulbind_next_bond")
    for bondId = 1, maxBondId do
        local bond = SoulbindStore.get(bondId)
        if bond then
            Storage.registerActive(NS, bondId)
            registerUnit(bond.units[1], bondId)
            registerUnit(bond.units[2], bondId)
        end
    end
end

return SoulbindStore
