--[[
-- TODO
-- - test pickup/drop to receivers and non-receivers
-- - refactor to use Generic


-- - unify capacity storage (only souls.lua)
-- - probably best to add onSoulUse/onSoulkeeperUse -> fireEvent -> everything sorted
-- - ??? !!! circular imports? souls.api from item. would be fine to trigger item.replace from souls.lua
-- - separate file needed probably
-- - maybe move "replace item" logic to souls.lua or neaby (have to support cooldown preserve - for example, item is 1/2 cd, soul is USED -> item replaced and cd must stay the same)
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local ItemMeta = require("lib.items")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Souls = require("scenario.factions.mawsworn.mechanics.souls")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.soulkeeper,
        },
        buffs = {},
        items = {
            main = { Ids.items.soulkeeper0, Ids.items.soulkeeper1, Ids.items.soulkeeper2, Ids.items.soulkeeper3 },
            soul = Ids.items.soul,
        },
        units = {
            receiver = { Ids.units.mawswornCage, Ids.units.mawswornMechBarracks },
        },
    },
    balance = {
        cooldown = 2,
        maxCapacity = 3,
    },
})

local byLevel = {
    [0] = CONFIG.refs.items.main[1],
    [1] = CONFIG.refs.items.main[2],
    [2] = CONFIG.refs.items.main[3],
    [3] = CONFIG.refs.items.main[4],
}
local byLevelReversed = {
    [byLevel[0]] = 0,
    [byLevel[1]] = 1,
    [byLevel[2]] = 2,
    [byLevel[3]] = 3,
}

--- @param unit unit Unit who receives item
--- @param oldItem item
--- @param slot integer
local function updateSoulkeeper(unit, oldItem, slot)
    local itemId = byLevel[Souls.api.count("item", oldItem)]
    RemoveItem(oldItem)
    UnitAddItemToSlotById(unit, itemId, slot)

    Souls.api.remap("item", oldItem, UnitItemInSlot(unit, slot))
end

local function onPickUpItem()
    local item = GetManipulatedItem()
    if not byLevelReversed[GetItemTypeId(item)] then
        return
    end
    local unit = GetTriggerUnit()
    Souls.api.holder.update(unit, item, true)
end

local function onDropItem()
    -- Game crash lololol
    local item = GetManipulatedItem()
    if not byLevelReversed[GetItemTypeId(item)] then
        return
    end
    local unit = GetTriggerUnit()

    local holder = Souls.api.holder.get(item)
    Timed.call(0.00, function()
        local receiver = Souls.api.holder.get(item)
        dump("onDropItem", holder, receiver)
        if Generic.contains(CONFIG.refs.units.receiver, GetUnitTypeId(receiver)) then
            UnitAddItem(holder, item)

            local capacity = Souls.api.count("item", item)
            local receiverSlots = Unit.countFreeSlots(receiver)
            local amount = math.min(capacity, receiverSlots)
            if amount == 0 then
                dump("Trying to pass 0 souls")
                return
            end
            Souls.api.use("item", item, amount)
            for i = 1, amount do
                UnitAddItemById(receiver, CONFIG.refs.items.soul)
            end
        else
            Souls.api.holder.update(unit, item, false)
        end
    end)
end

--- Sell item to shop
local function onPawnItem()
    local item = GetManipulatedItem()
    if not byLevelReversed[GetItemTypeId(item)] then
        return
    end
    local unit = GetSellingUnit()
    local receiver = GetBuyingUnit()
    dump("onPawnItem event", unit, receiver)
    -- Souls.api.holder.update(unit, item, false)
end

local function onActivate()
    -- TODO: ? multiple soulkeepers on 1 hero
    local caster = GetTriggerUnit()
    local slot = Unit.findItem(caster, function(i)
        return byLevelReversed[GetItemTypeId(i)] ~= nil
    end)

    if not slot then
        dump("Soulkeeper item not found")
        return
    end
    local currentCapacity = Souls.api.count("item", slot.item)
    if currentCapacity >= CONFIG.balance.maxCapacity then
        dump("Soulkeeper has max capacity")
        return
    end

    local q = Souls.api.find(caster, 400, { "corpse" })
    if q then
        local success = Souls.api.use(q.holderType, q.holder)
        if success then
            Souls.api.store("item", slot.item)

            updateSoulkeeper(caster, slot.item, slot.index)

            BlzStartUnitAbilityCooldown(caster, CONFIG.refs.abilities.main, CONFIG.balance.cooldown)
        else
            dump('Fail on Souls.api.use("corpse", q)')
        end
    else
        dump("No souls found")
    end
end

--- @param info {item: item}
local function onSoulUse(info)
    dump("itemSoulkeeper onSoulUse")
    local item = info.item
    local unit = Souls.api.holder.get(item)
    if not UnitHasItem(unit, item) then
        dump("Invalid Soulkeeper holder data")
        return
    end

    local slot = Unit.findItem(unit, function(i)
        return i == item
    end)
    if not slot then
        dump("Soulkeeper slot not found")
        return
    end
    local currentCooldown = BlzGetUnitAbilityCooldownRemaining(unit, CONFIG.refs.abilities.main)

    updateSoulkeeper(unit, slot.item, slot.index)

    BlzSetUnitAbilityCooldown(unit, CONFIG.refs.abilities.main, 1, currentCooldown)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_PICKUP_ITEM",
            action = onPickUpItem,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DROP_ITEM",
            action = onDropItem,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_PAWN_ITEM",
            action = onPawnItem,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onActivate,
        },
        {
            trigger = "SOUL_USE",
            action = onSoulUse,
        },
    },
    config = CONFIG,
    api = {},
}
