local Ids = require("data.ids")

local Dummy = {}

local function spawnDummy(owner, target, abilityId, level, unitId)
    local dummy = CreateUnit(owner, unitId or FourCC(Ids.units.dummy), GetUnitX(target), GetUnitY(target), 270)
    UnitApplyTimedLife(dummy, FourCC("BTLF"), 10)
    UnitAddAbility(dummy, abilityId)
    if level then
        SetUnitAbilityLevel(dummy, abilityId, level)
    end
    return dummy
end

Dummy.create = spawnDummy

Dummy.applyDummyOrder = function(owner, target, abilityId, order, level)
    IssueTargetOrder(spawnDummy(owner, target, abilityId, level), order, target)
end

Dummy.applyDummyAttack = function(owner, target, abilityId, level)
    IssueTargetOrder(spawnDummy(owner, target, abilityId, level, FourCC(Ids.units.dummyAttack)), "attack", target)
end

Dummy.applyDummyImmediateOrder = function(owner, target, abilityId, order, level)
    local dummy = spawnDummy(owner, target, abilityId, level)
    IssueImmediateOrder(dummy, order)
    return dummy
end

return Dummy
