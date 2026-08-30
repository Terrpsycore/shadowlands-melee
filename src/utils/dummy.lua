local Ids = require("data.ids")

local Dummy = {}

Dummy.applyDummyOrder = function(owner, target, abilityId, order, level)
    local dummy = CreateUnit(owner, FourCC(Ids.units.dummy), GetUnitX(target), GetUnitY(target), 270)
    UnitApplyTimedLife(dummy, FourCC("BTLF"), 10)
    UnitAddAbility(dummy, abilityId)
    if level then
        SetUnitAbilityLevel(dummy, abilityId, level)
    end
    IssueTargetOrder(dummy, order, target)
end

return Dummy
