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

return Unit
