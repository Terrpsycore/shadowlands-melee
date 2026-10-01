--[[
-- TODO
-- - !!! check distance - prevent grab if target has moved far away
-- - BUG: grabber doesn't flush
-- - process 1.33/1.5 WS stacks per hit
-- - debuff kidnapper for dmg/speed
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local ItemMeta = require("lib.items")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.mawswornGrab,
        },
        buffs = {
            exhaustion = Ids.buffs.exhaustion,
        },
        units = {
            cage = Ids.units.mawswornCage,
        },
    },
    balance = {
        tickDelta = 1,
        dropsAfter = 90,
    },
})

--- @alias GrabMemory {holder: unit|nil, unit: unit, dropsAt: float|nil}

local grabId = 1
--- @type table<item, GrabMemory>
local memory = {} -- TODO: save/load --
--- @type table<unit, item>
local grabbers = {}
local grabQueue = {}

--- @param item item
local function flushGrabber(item)
    if grabbers[memory[item]] and memory[item].holder then
        grabbers[memory[item].holder] = nil
    end
end

--- @param item item
--- @param unit unit
local function onPickUpItem(item, unit)
    flushGrabber(item)
    memory[item].holder = unit
    if GetUnitTypeId(unit) == CONFIG.refs.units.cage then
        memory[item].dropsAt = nil
    else
        memory[item].dropsAt = GetElapsedGameTime() + CONFIG.balance.dropsAfter
    end
end

--- @param item item
local function onDropItem(item)
    SetUnitX(memory[item].unit, GetItemX(item))
    SetUnitY(memory[item].unit, GetItemX(item))
    ShowUnitShow(memory[item].unit)
    RemoveItem(item)
    flushGrabber(item)
    memory[item] = nil
end

--- @param item item
local function getItemMemory(item)
    return memory[item]
end

--- @param item item
local function flushItemMemory(item)
    flushGrabber(item)
    memory[item] = nil
end

local function onGrabCast()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    grabQueue[caster] = target
end

local function onGrabCastFinish()
    local unit = GetTriggerUnit()
    local target = grabQueue[unit]

    if grabbers[unit] then
        dump("onGrabCastFinish break: unit already has grabbed someone")
        return
    end
    if not UnitHasBuffBJ(target, CONFIG.refs.buffs.exhaustion) then
        dump("onGrabCastFinish break: target doesnt have exhaust debuff")
        return
    end
    if not Unit.hasSpaceInInventory(unit) then
        dump("onGrabCastFinish break: unit doesnt have free space in inventory")
        return
    end

    ShowUnitHide(target)
    local itemId = ItemMeta.getGrabItemId(GetUnitTypeId(target))
    local item = CreateItem(itemId, GetUnitX(target), GetUnitY(target))
    UnitAddItem(unit, item)

    memory[item] = {
        unit = target,
    }
    onPickUpItem(item, unit)
    grabbers[unit] = item
end

local function onDropItemEvent()
    local caster = GetTriggerUnit()
    local item = GetManipulatedItem()
    dump("onDropItemEvent()", item)
    if not item or not memory[item] then
        return
    end

    flushGrabber(item)
    memory[item].holder = nil
    memory[item].dropsAt = nil

    -- TODO: warning!!! Can be desync cause?
    Timed.call(0.00, function()
        if memory[item] and not memory[item].holder then
            dump("onDropItem() FLUSH")
            onDropItem(item)
        end
    end)
end

local function onPickUpItemEvent()
    local unit = GetTriggerUnit()
    local item = GetManipulatedItem()
    dump("onPickUpItemEvent()", item)
    if not memory[item] then
        return
    end

    onPickUpItem(item, unit)
end

local function onTimer()
    -- == WS flush
    local now = GetElapsedGameTime()
    local flushQueue = {}
    for item, memoryData in pairs(memory) do
        if memoryData.dropsAt and now > memoryData.dropsAt then
            onDropItem(item)
            table.insert(flushQueue, item)
        end
    end
    for _, item in ipairs(flushQueue) do
        dump("Grab TIMER FLUSH", item)
        flushGrabber(item)
        memory[item] = nil
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onGrabCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_FINISH",
            spellId = CONFIG.refs.abilities.main,
            action = onGrabCastFinish,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_PICKUP_ITEM",
            action = onPickUpItemEvent,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DROP_ITEM",
            action = onDropItemEvent,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.tickDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
    api = {
        getItemMemory = getItemMemory,
        flushItemMemory = flushItemMemory,
        onDropItem = onDropItem,
    },
}
