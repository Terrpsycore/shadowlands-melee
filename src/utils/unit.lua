local dump = require("utils.logger")

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

function Unit.isFlying(unit)
    return IsUnitType(unit, UNIT_TYPE_FLYING)
end

function Unit.isMech(unit)
    return IsUnitType(unit, UNIT_TYPE_MECHANICAL)
end

function Unit.isManaFull(unit)
    return GetUnitState(unit, UNIT_STATE_MANA) >= GetUnitState(unit, UNIT_STATE_MAX_MANA) - 0.01
end

function Unit.isOffCooldown(unit, abilityId)
    local remainingCd = BlzGetUnitAbilityCooldownRemaining(unit, abilityId)
    return remainingCd <= 0
end

function Unit.isAtPoint(whichUnit, targetX, targetY, range)
    local uX = GetUnitX(whichUnit)
    local uY = GetUnitY(whichUnit)

    local dx = targetX - uX
    local dy = targetY - uY
    local distanceSq = (dx * dx) + (dy * dy)

    return distanceSq <= (range * range)
end

function Unit.getUnitsInRadius(unit, radius)
    local resultsTable = {}
    local x = GetUnitX(unit)
    local y = GetUnitY(unit)

    local tempGroup = CreateGroup()
    GroupEnumUnitsInRange(tempGroup, x, y, radius, nil)

    for i = 0, BlzGroupGetSize(tempGroup) - 1 do
        local u = BlzGroupUnitAt(tempGroup, i)

        if u and UnitAlive(u) and u ~= unit then
            table.insert(resultsTable, u)
        end
    end

    DestroyGroup(tempGroup)

    return resultsTable
end

function Unit.getAllyUnitsOfTypeInRadius(unit, targetTypeId, radius)
    local resultsTable = {}
    local x = GetUnitX(unit)
    local y = GetUnitY(unit)
    local owner = GetOwningPlayer(unit)

    local tempGroup = CreateGroup()
    GroupEnumUnitsInRange(tempGroup, x, y, radius, nil)

    for i = 0, BlzGroupGetSize(tempGroup) - 1 do
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

function Unit.getAllyUnitsInRadius(unit, radius, filter)
    local resultsTable = {}
    local x = GetUnitX(unit)
    local y = GetUnitY(unit)
    local owner = GetOwningPlayer(unit)

    local tempGroup = CreateGroup()
    GroupEnumUnitsInRange(tempGroup, x, y, radius, nil)

    for i = 0, BlzGroupGetSize(tempGroup) - 1 do
        local u = BlzGroupUnitAt(tempGroup, i)
        -- dump("Unit.getAllyUnitsInRadius", u, UnitAlive(u), IsUnitAlly(u, owner), filter, filter and filter(unit))
        if
            u
            and UnitAlive(u)
            and IsUnitAlly(u, owner)
            and (filter and filter(u))
            -- and IsUnitInRangeXY(u, x, y, radius)
        then
            table.insert(resultsTable, u)
        end
    end

    DestroyGroup(tempGroup)

    return resultsTable
end

return Unit
