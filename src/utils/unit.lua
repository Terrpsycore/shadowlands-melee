local Unit = {}

--- @param a unit
--- @param b unit
function Unit.distance(a, b)
    local dX = math.abs(GetUnitX(a) - GetUnitX(b))
    local dY = math.abs(GetUnitY(a) - GetUnitY(b))
    return math.sqrt(dX ^ 2 + dY ^ 2)
end

function Unit.isAlive(unit)
    return GetUnitState(unit, UNIT_STATE_LIFE) > 0
end

function Unit.isOffCooldown(unit, abilityId)
    local remainingCd = BlzGetUnitAbilityCooldownRemaining(unit, abilityId)
    return remainingCd <= 0
end

function Unit.getAllyUnitsOfTypeInRadius(unit, targetTypeId, radius)
    local resultsTable = {}
    local x = GetUnitX(unit)
    local y = GetUnitY(unit)
    local owner = GetOwningPlayer(unit)

    local tempGroup = CreateGroup()
    GroupEnumUnitsInRange(tempGroup, x, y, radius, nil)

    for i = 1, BlzGroupGetSize(tempGroup) do
        local u = BlzGroupUnitAt(tempGroup, i)

        if
            u
            and UnitAlive(u)
            and GetUnitTypeId(u) == targetTypeId
            and IsUnitAlly(u, owner)
            -- and IsUnitInRangeXY(u, x, y, radius)
        then
            table.insert(resultsTable, u)
        end
    end

    DestroyGroup(tempGroup)

    return resultsTable
end

return Unit
