--[[
-- TODO
-- - BUG: caged unit releases at grabber position instead of cage position
-- - give experience for possession/transform (charm?transmute?dummy kill?) -- evade onDeath bugs somehow
-- - - most likely - by using dummy Charm on copied unit & removing it (charmed unit loses upgrades/skills)
-- - - make sure that Charm doesn't provoke DEATH event
-- - ? heal possessed unit to full
-- - smart move on command flag after possess/transform
-- -
-- - onTimer test
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local ItemMeta = require("lib.items")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Grab = require("scenario.factions.mawsworn.abilities.common.grab")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            transmute = Ids.abilities.mawswornCageTransmute,
        },
        buffs = {},
        units = {
            main = Ids.units.mawswornCage,
            shade = Ids.units.mawswornShade,
            --
            possess = Ids.units.mawswornCagePossess,
            transmute = Ids.units.mawswornCageTransmute,
            transform = Ids.units.mawswornCageTransform,
        },
    },
    balance = {
        tickDelta = 1,
        dropsAfter = 90,
    },
})

--- @alias TrainAction "possess"|"transmute"|"transform"

--- @type table<integer,TrainAction>
local trainActions = {
    [CONFIG.refs.units.possess] = "possess",
    [CONFIG.refs.units.transmute] = "transmute",
    [CONFIG.refs.units.transform] = "transform",
}

--- @param building unit
--- @return {item:item,data:GrabMemory}|nil
local function getCagedData(building)
    local item = UnitItemInSlotBJ(building, 1)
    if not item then
        return nil
    end

    local itemData = Grab.api.getItemMemory(item)
    if not itemData then
        return nil
    end

    return { item = item, data = itemData }
end

local function onTrainStart()
    dump("onTrainStart() start")
    local building = GetTriggerUnit()

    if not getCagedData(building) then
        dump("onTrainStart() break - no caged data")
        IssueImmediateOrderById(building, 851976)
        return
    end

    local action = trainActions[GetTrainedUnitType()]
    if not action then
        error("Invalid train order")
    end
    dump("onTrainStart() end")
end

local function onTrainFinish()
    dump("onTrainFinish() start")
    local building = GetTriggerUnit()
    local owner = GetOwningPlayer(building)
    local trained = GetTrainedUnit()
    local action = trainActions[GetUnitTypeId(trained)]
    RemoveUnit(trained)

    local cagedData = getCagedData(building)
    if not cagedData then
        error("Invalid train data")
    end

    local unit = cagedData.data.unit
    SetUnitX(unit, GetUnitX(building))
    SetUnitY(unit, GetUnitY(building))
    dump("onTrainFinish action", action)
    if action == "possess" then
        SetUnitOwner(unit, owner, true) -- ? replace with Charm ability to give exp
        SetUnitState(unit, UNIT_STATE_LIFE, GetUnitState(unit, UNIT_STATE_MAX_LIFE))
        SetUnitState(unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MAX_MANA))
        Grab.api.onDropItem(cagedData.item)
    elseif action == "transmute" then
        Grab.api.onDropItem(cagedData.item)
        local s = Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.transmute, "transmute") -- TODO: check order
        dump("onTrainFinish transmute", s)
    elseif action == "transform" then
        SetUnitOwner(unit, owner, true) -- ? replace with Charm ability to give exp
        ---@diagnostic disable-next-line: param-type-mismatch -- TODO: remove
        ReplaceUnitBJ(unit, CONFIG.refs.units.shade, bj_UNIT_STATE_METHOD_DEFAULTS)
        Grab.api.onDropItem(cagedData.item)
    end
    dump("onTrainFinish() end")
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_START",
            action = onTrainStart,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            action = onTrainFinish,
        },
    },
    config = CONFIG,
}
