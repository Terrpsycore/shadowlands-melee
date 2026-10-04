local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local removeControl = require("scenario.common.control")
local Type = require("utils.type")
local Unit = require("utils.unit")

local Souls = require("scenario.factions.mawsworn.mechanics.souls")
local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.soulFeast,
            cannibalize = Ids.abilities.soulFeastEat,
        },
    },
    balance = {
        radius = 600,
        searchRadiusPoint = 300,
        requiredUpgradeId = nil,
    },
})

--- @type table<unit, {pointX: number, pointY: number, holderType: string, holder: unit|item}> -- TODO: save/load
local memory = {}

--- @type boolean
local reordering = false

local function periodicOrder(unit, x, y)
    if not memory[unit] then
        return
    end
    if Unit.isAtPoint(unit, x, y, 16) then
        local success = Souls.api.use(memory[unit].holderType, memory[unit].holder)
        memory[unit] = nil
        if not success then
            return
        end
        UnitRemoveAbility(unit, CONFIG.refs.abilities.main)
        UnitAddAbility(unit, CONFIG.refs.abilities.cannibalize)
        if GetUnitState(unit, UNIT_STATE_LIFE) >= BlzGetUnitMaxHP(unit) - 1 then
            SetUnitState(unit, UNIT_STATE_LIFE, BlzGetUnitMaxHP(unit) - 5)
        end
        IssueImmediateOrder(unit, "cannibalize")
    else
        reordering = true
        IssuePointOrder(unit, "move", x, y)
        reordering = false
    end
end

local function onSearchCast()
    local unit = GetTriggerUnit()
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()

    local soul = Souls.api.find({ x = targetX, y = targetY }, CONFIG.balance.searchRadiusPoint, { "orphan", "corpse" })
    if not soul then
        dump("No soul found")
        return
    end

    local targetClass
    if soul.holderType == "orphan" then
        targetClass = "item"
    else
        targetClass = "unit"
    end
    local x, y = Generic.pointXY(soul.holder, targetClass)

    memory[unit] = {
        pointX = x,
        pointY = y,
        holderType = soul.holderType,
        holder = soul.holder,
    }

    periodicOrder(unit, x, y)
end

local function onCannibalizeEndCast()
    local unit = GetTriggerUnit()
    UnitRemoveAbility(unit, CONFIG.refs.abilities.cannibalize)
    UnitAddAbility(unit, CONFIG.refs.abilities.main)
end

local function onCannibalizeFinish()
    local unit = GetTriggerUnit()
    local owner = GetOwningPlayer(unit)

    for _, target in
        Unit.getUnitsInRadius(unit, CONFIG.balance.radius, function(t)
            return not IsUnitAlly(t, owner)
        end)
    do
        WS.api.applyWeakenedSoulStack(target, 1, owner)
    end
end

local function onAnyOrder()
    local unit = GetTriggerUnit()
    if not memory[unit] then
        return
    end
    if not reordering then
        memory[unit] = nil
    end
end

local function onTimer()
    for unit, data in pairs(memory) do
        periodicOrder(unit, data.pointX, data.pointY)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSearchCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_ENDCAST",
            spellId = CONFIG.refs.abilities.cannibalize,
            action = onCannibalizeEndCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_FINISH",
            spellId = CONFIG.refs.abilities.cannibalize,
            action = onCannibalizeFinish,
        },
        { trigger = "ORDER", filter = { source = CONFIG.refs.units.carrier }, action = onAnyOrder },
        { trigger = "TIMER", delta = 0.25, action = onTimer },
    },
    config = CONFIG,
}
