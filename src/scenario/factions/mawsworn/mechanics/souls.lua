--[[
item holder type = Soulkeeper only

?? any special storage for plain "soul" items?

-- TODO
-- - ADR (orphan~corpse, item, unit)
-- - on "soul" item drop/pickup without soulkeeper -> ... destroy with effect
-- - on "soul" item pickup with soulkeeper -> updateSoulkeeper or drop if full
-- - on "soulkeeper" drop/pickup to cage/forge -> create "soul" item, return "soulkeeper" back
-- - ?? separate method for inventory souls (cage, soulforge)
-- - UI effect on corpse with drained soul
-- - drained corpse decay timer
-- - put soul in cage
-- - search() in items and units
-- - unit sells item -> nullify holder
-- - maybe rewrite to class
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Triggers = require("lib.triggers.callbacks")
local UnitMeta = require("lib.units")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.death")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {},
        buffs = {},
        units = {},
    },
    balance = {},
})

--- Hero spell holders
--- @type table<unit,integer>
local unitHolders = {} -- TODO: save/load
--- @type table<item,integer>
local itemHolders = {}

--- @type table<item,{x: number, y: number}>
local orphanItemHolders = {}

--- @type table<item,unit>
local itemToUnit = {}
--- @type table<unit,item[]>
local unitToItems = {}

--- @param item item
--- @return unit
local function getItemHolder(item)
    return itemToUnit[item]
end

--- @param unit unit
--- @return item[]
local function getItemsHeld(unit)
    return unitToItems[unit]
end

--- @param item item
--- @return boolean
local function hasOrphanStatus(item)
    return orphanItemHolders[item] ~= nil
end

--- @param unit unit
--- @param item item
--- @param status boolean
local function updateItemHolder(unit, item, status)
    local previousHolder = itemToUnit[item]

    if status then
        itemToUnit[item] = unit
    else
        itemToUnit[item] = nil
    end
    dump("updateItemHolder", unit, item, status, "previousHolder=", previousHolder)

    if previousHolder then
        local previousHolderItems = Generic.filter(unitToItems[previousHolder], function(i)
            return i ~= item
        end)
        if #previousHolderItems > 0 then
            unitToItems[previousHolder] = previousHolderItems
        else
            unitToItems[previousHolder] = nil
        end
    end

    if status then
        if not unitToItems[unit] then
            unitToItems[unit] = {}
        end
        table.insert(unitToItems[unit], item)
    end
end

--- @alias soulSource "orphan"|"corpse"|"unit"|"item"

--- @param point {x:number,y:number}
--- @param radius integer
--- @param sources soulSource[]|nil
--- @return {holder:item|unit,holderType:soulSource}|nil
local function findSoul(point, radius, sources)
    -- TODO: optimized search grouping - 1 cycle instead of 2-3
    if not sources then
        sources = { "orphan", "corpse", "item", "unit" }
    end

    local holder
    local holderType
    for _, source in ipairs(sources) do
        if source == "orphan" then
            local nearestOrphan --- @type item|nil
            local nearestOrphanD --- @type number|nil
            for item, orphanPoint in pairs(orphanItemHolders) do
                local d = Generic.distance(point, orphanPoint)
                if not nearestOrphan or d < nearestOrphanD then
                    nearestOrphan = item
                    nearestOrphanD = d
                end
            end
            if nearestOrphan then
                holder = nearestOrphan
            end
        elseif source == "corpse" then
            holder = Unit.getNearestCorpse(point, radius, function(x)
                return Storage:has(x) and Storage:get(x, "soulAvailable") -- remove :has - safe?
            end)
        elseif source == "item" then
            local unit = Unit.getNearestUnit(point, radius, function(x)
                return unitToItems[x]
            end)
            if unit then
                local slot = Unit.findItem(unit, function(i)
                    return itemHolders[i]
                end, true)
                if slot then
                    holder = slot.item
                end
            end
        elseif source == "unit" then
            -- TODO
        end
        if holder then
            holderType = source
            break
        end
    end
    if holder then
        return {
            holder = holder,
            holderType = holderType,
        }
    else
        return nil
    end
end

--- Soft count, returns 0 on not found.
--- @param holderType "unit"|"item"
--- @param holder unit|item
--- @return integer
local function countSouls(holderType, holder)
    dump("countSoul", holderType, holder)
    if holderType == "unit" and unitHolders[holder] then
        return unitHolders[holder]
    elseif holderType == "item" and itemHolders[holder] then
        return itemHolders[holder]
    end
    return 0
end

--- @param holderType soulSource
--- @param holder unit|item
--- @param amount integer|nil
--- @return boolean
local function useSoul(holderType, holder, amount)
    if not amount then
        amount = 1
    end
    dump("useSoul", holderType, holder, amount)
    if holderType == "orphan" and orphanItemHolders[holder] and amount == 1 then
        orphanItemHolders[holder] = nil
        ---@diagnostic disable-next-line: param-type-mismatch
        RemoveItem(holder)
        return true
    elseif holderType == "corpse" and amount == 1 then
        Storage:set(holder, "soulAvailable", false)
        return true
    elseif holderType == "unit" and unitHolders[holder] and unitHolders[holder] >= amount then
        unitHolders[holder] = unitHolders[holder] - amount
        return true
    elseif holderType == "item" and itemHolders[holder] and itemHolders[holder] >= amount then
        itemHolders[holder] = itemHolders[holder] - amount
        Triggers.fireEvent("SOUL_USE", { item = holder })
        dump("fireEvent SOUL_USE")
        return true
    end
    return false
end

--- @param holderType "orphan"|"unit"|"item"
--- @param holder unit|item
--- @return boolean
local function storeSoul(holderType, holder)
    if holderType == "orphan" then
        ---@diagnostic disable-next-line: param-type-mismatch
        orphanItemHolders[holder] = { x = GetItemX(holder), y = GetItemY(holder) }
        return true
    elseif holderType == "unit" then
        unitHolders[holder] = unitHolders[holder] or 0
        unitHolders[holder] = unitHolders[holder] + 1
        return true
    elseif holderType == "item" then
        itemHolders[holder] = itemHolders[holder] or 0
        itemHolders[holder] = itemHolders[holder] + 1
        return true
    end
    return false
end

--- @param holderType "unit"|"item"
--- @param holderBefore unit|item
--- @param holderAfter unit|item
--- @return boolean
local function remapStorage(holderType, holderBefore, holderAfter)
    if holderType == "unit" then
        unitHolders[holderAfter] = unitHolders[holderBefore]
        unitHolders[holderBefore] = nil
        return true
    elseif holderType == "item" then
        itemHolders[holderAfter] = itemHolders[holderBefore]
        itemHolders[holderBefore] = nil
        return true
    end
    return false
end

return {
    triggers = {},
    config = CONFIG,
    api = {
        count = countSouls,
        find = findSoul,
        use = useSoul,
        store = storeSoul,
        remap = remapStorage,
        holder = {
            get = getItemHolder,
            getItems = getItemsHeld,
            isOrphan = hasOrphanStatus,
            update = updateItemHolder,
        },
    },
}
