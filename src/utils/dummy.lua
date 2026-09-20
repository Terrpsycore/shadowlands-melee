local Ids = require("data.ids")

local Dummy = {}

---@alias Order string|integer

---@param at Point
local function pointXY(at)
    if type(at) == "table" then
        return at.x, at.y
    end
    return GetUnitX(at), GetUnitY(at)
end

local function spawn(owner, at, abilityId, level, unitId)
    local x, y = pointXY(at)
    local dummy = CreateUnit(owner, unitId or FourCC(Ids.units.dummy), x, y, 270)
    UnitApplyTimedLife(dummy, FourCC("BTLF"), 10)
    UnitAddAbility(dummy, abilityId)
    if level then
        SetUnitAbilityLevel(dummy, abilityId, level)
    end
    SetUnitInvulnerable(dummy, true)
    SetUnitPathing(dummy, false)
    SetUnitPosition(dummy, x, y)
    return dummy
end

local function issueImmediate(dummy, order)
    if type(order) == "number" then
        IssueImmediateOrderById(dummy, order)
    else
        IssueImmediateOrder(dummy, order)
    end
end

local function issueTarget(dummy, order, target)
    if type(order) == "number" then
        IssueTargetOrderById(dummy, order, target)
    else
        IssueTargetOrder(dummy, order, target)
    end
end

local function issuePoint(dummy, order, x, y)
    if type(order) == "number" then
        IssuePointOrderById(dummy, order, x, y)
    else
        IssuePointOrder(dummy, order, x, y)
    end
end

function Dummy.create(owner, at, abilityId, level, unitId)
    return spawn(owner, at, abilityId, level, unitId)
end

function Dummy.applyDummyOrder(owner, target, abilityId, order, level)
    local dummy = spawn(owner, target, abilityId, level)
    issueTarget(dummy, order, target)
    return dummy
end

function Dummy.applyDummyPointOrder(owner, at, abilityId, order, level)
    local x, y = pointXY(at)
    local dummy = spawn(owner, at, abilityId, level)
    issuePoint(dummy, order, x, y)
    return dummy
end

function Dummy.applyDummyAttack(owner, target, abilityId, level)
    local dummy = spawn(owner, target, abilityId, level, FourCC(Ids.units.dummyAttack))
    issueTarget(dummy, "attack", target)
    return dummy
end

function Dummy.applyDummyImmediateOrder(owner, at, abilityId, order, level)
    local dummy = spawn(owner, at, abilityId, level)
    issueImmediate(dummy, order)
    return dummy
end

return Dummy
