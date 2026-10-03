--[[
-- TODO
-- - ! "SOUL" item transmute
-- - ! use hidden train actions
-- - check that cage actions flush grabbed data
-- - make sure that dummyExtractKillXP doesn't provoke DEATH event
-- - ? add some maximum cage storage time
-- - ? prevent possess/transform on supply block
-- - VISUALS:
-- - - change train buttons to skill buttons - enable/disable on trigger
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
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

--- Beware bugs in onDeath&onDamage events (corpse-creating, death-triggered skills too should be handled (suicide))
--- @param cage unit
--- @param target unit
local function dummyExtractKillXP(cage, target)
    local dummy = Dummy.create(GetOwningPlayer(cage), cage)
    local copiedUnit = Unit.copy(target)
    UnitAddType(copiedUnit, UNIT_TYPE_SAPPER)
    Damage.apply(dummy, copiedUnit, 99999, false, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_DIVINE)
    RemoveUnit(copiedUnit)
    RemoveUnit(dummy)
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
    dump("onTrainFinish action", action)
    SetUnitX(unit, GetUnitX(building))
    SetUnitY(unit, GetUnitY(building))

    local rally = GetUnitRallyPoint(building)

    if action == "possess" then
        dummyExtractKillXP(building, unit)
        SetUnitOwner(unit, owner, true)
        SetUnitState(unit, UNIT_STATE_LIFE, GetUnitState(unit, UNIT_STATE_MAX_LIFE))
        SetUnitState(unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MAX_MANA))
        Grab.api.onDropItem(cagedData.item)
        SetUnitPosition(unit, GetUnitX(building), GetUnitY(building))
    elseif action == "transmute" then
        Grab.api.onDropItem(cagedData.item)
        SetUnitPosition(unit, GetUnitX(building), GetUnitY(building))
        Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.transmute, "transmute")
    elseif action == "transform" then
        dummyExtractKillXP(building, unit)
        SetUnitOwner(unit, owner, true)
        ---@diagnostic disable-next-line: param-type-mismatch -- TODO: remove
        unit = ReplaceUnitBJ(unit, CONFIG.refs.units.shade, bj_UNIT_STATE_METHOD_DEFAULTS)
        Grab.api.onDropItem(cagedData.item)
        SetUnitPosition(unit, GetUnitX(building), GetUnitY(building))
    end

    if action ~= "transmute" then
        IssuePointOrder(unit, "move", GetLocationX(rally), GetLocationY(rally))
    end
    dump("onTrainFinish() end")
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_START",
            filter = { source = CONFIG.refs.units.main },
            action = onTrainStart,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            filter = { source = CONFIG.refs.units.main },
            action = onTrainFinish,
        },
    },
    config = CONFIG,
}
