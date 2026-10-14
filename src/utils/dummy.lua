local Ids = require("data.ids")

local Dummy = {
    default = FourCC(Ids.units.dummy),
}

---@param unitId integer
function Dummy.setDefault(unitId)
    Dummy.default = unitId
end

---@alias Order string|integer

local function spawn(owner, at, abilityId, level, unitId)
    local x, y = Generic.pointXY(at)
    local dummy = CreateUnit(owner, unitId or Dummy.default, x, y, 270)
    UnitApplyTimedLife(dummy, FourCC("BTLF"), 10)
    if abilityId then
        UnitAddAbility(dummy, abilityId)
        if level then
            SetUnitAbilityLevel(dummy, abilityId, level)
        end
    end
    SetUnitInvulnerable(dummy, true)
    SetUnitPathing(dummy, false)
    SetUnitPosition(dummy, x, y)
    return dummy
end

function Dummy.issueImmediate(dummy, order)
    if type(order) == "number" then
        IssueImmediateOrderById(dummy, order)
    else
        IssueImmediateOrder(dummy, order)
    end
end

function Dummy.issueTarget(dummy, order, target)
    if type(order) == "number" then
        IssueTargetOrderById(dummy, order, target)
    else
        IssueTargetOrder(dummy, order, target)
    end
end

function Dummy.issuePoint(dummy, order, x, y)
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
    local s = Dummy.issueTarget(dummy, order, target)
    dump("applyDummyOrder", order, s)
    return dummy
end

function Dummy.applyDummyPointOrder(owner, at, abilityId, order, level)
    local x, y = Generic.pointXY(at)
    local dummy = spawn(owner, at, abilityId, level)
    Dummy.issuePoint(dummy, order, x, y)
    return dummy
end

function Dummy.applyDummyAttack(owner, target, abilityId, level)
    local dummy = spawn(owner, target, abilityId, level, FourCC(Ids.units.dummyAttack))
    Dummy.issueTarget(dummy, "attack", target)
    return dummy
end

function Dummy.applyDummyImmediateOrder(owner, at, abilityId, order, level)
    local dummy = spawn(owner, at, abilityId, level)
    Dummy.issueImmediate(dummy, order)
    return dummy
end

return Dummy
