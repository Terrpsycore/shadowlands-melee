--[[
TODO:
- upgrade reqs
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            relink = Ids.abilities.mawChainRelink,
            moveToAttack = Ids.abilities.mawChainAttack,
            channelDamage = Ids.abilities.mawChainChanneledDamage,
            retreat = Ids.abilities.mawChainFallback,
        },
        buffs = {},
        units = {
            carrier = { Ids.units.mawChain },
            basement = { Ids.units.mawswornMain },
        },
    },
    balance = {
        radius = 1000,
    },
})

---@diagnostic disable-next-line: param-type-mismatch
local basements = Generic.toArray(CONFIG.refs.units.basement)

local ORDERS = {
    retreat = "acidbomb",
}

--- @type table<unit, {isAttacking: boolean, chainedTo: Point}>
local memory = {} -- TODO: save/load

-- Commands

local function relink(unit, building)
    SetUnitPosition(unit, GetUnitX(building), GetUnitY(building))
    memory[unit].chainedTo = building
end

local function attackStart(unit, point)
    IssueImmediateOrder(unit, "stop")
    UnitAddAbility(unit, CONFIG.refs.abilities.moveToAttack)
    IssuePointOrder(unit, "shadowstrike", point.x, point.y)
end

local function damageStart(unit, point)
    SetUnitPosition(unit, point.x, point.y)
    UnitAddAbility(unit, CONFIG.refs.abilities.channelDamage)
    IssuePointOrder(unit, "earthquake", point.x, point.y)
    memory[unit].isAttacking = true
end

local function damageFinish(unit)
    -- apply instant AoE channelDamage
end

--- @param unit unit
--- @param point Point
local function fallbackStart(unit, point)
    UnitAddAbility(unit, CONFIG.refs.abilities.retreat)
    IssuePointOrder(unit, ORDERS.retreat, point.x, point.y)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.retreat)
    memory[unit].isAttacking = false
end

--- @param unit unit
--- @param point Point
local function fallbackFinish(unit, point)
    SetUnitPosition(unit, point.x, point.y)
end

-- Events

local function onCreate()
    dump("onCreate unit setPropWindow")
    local unit = GetEnteringUnit()
    SetUnitPropWindow(unit, 0)

    local x, y = Generic.pointXY(unit, "unit")
    memory[unit] = { isAttacking = false, chainedTo = { x = x, y = y } }
end

local function onRelink()
    local unit = GetTriggerUnit()
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()

    local basement = Unit.getNearestUnit({ x = targetX, y = targetY }, CONFIG.balance.radius, function(u)
        return basements[GetUnitTypeId(u)]
    end)

    if not basement then
        dump("Basement not found")
        return
    end

    relink(unit, basement)
end

local function onOrder()
    local unit = GetOrderedUnit()
    local order = GetIssuedOrderId()
    local x
    local y
    if memory[unit].isAttacking then
        -- retreat (channel cancelled)
        fallbackStart(unit, memory[unit].chainedTo)
        return
    else
        if order == String2OrderIdBJ("smart") then
            IssueImmediateOrder(unit, "stop")
            return
        elseif order == String2OrderIdBJ("attack") then
            local target = GetOrderTargetUnit()
            x = GetUnitX(target)
            y = GetUnitY(target)
        elseif order == String2OrderIdBJ("attackground") then
            x = GetOrderPointX()
            y = GetOrderPointY()
        else
            return
        end
    end

    attackStart(unit, { x = x, y = y })
end

local function onCastAttack()
    local unit = GetTriggerUnit()
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()
    damageStart(unit, { x = targetX, y = targetY })
end

local function onEndAttack()
    local unit = GetTriggerUnit()
    damageFinish(unit)
end

local function onCastFallback()
    local unit = GetTriggerUnit()
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()
    fallbackFinish(unit, { x = targetX, y = targetY })
end

return {
    triggers = {
        {
            trigger = "ORDER",
            filter = { source = CONFIG.refs.units.carrier },
            action = onOrder,
        },
        {
            trigger = "CREATE",
            filter = { source = CONFIG.refs.units.carrier },
            action = onCreate,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.moveToAttack,
            action = onCastAttack,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_FINISH",
            spellId = CONFIG.refs.abilities.moveToAttack,
            action = onCastAttack,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_FINISH",
            spellId = CONFIG.refs.abilities.channelDamage,
            action = onEndAttack,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_FINISH",
            spellId = CONFIG.refs.abilities.retreat,
            action = onCastFallback,
        },
    },
    config = CONFIG,
}
