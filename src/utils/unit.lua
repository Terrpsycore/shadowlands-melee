local buffTypes = require("data.buffTypes")

local Unit = {}

---@alias Point unit|{ x: number, y: number }

---@param point Point
---@return number x
---@return number y
local function pointXY(point)
    if type(point) == "table" then
        return point.x, point.y
    end
    return GetUnitX(point), GetUnitY(point)
end

local function forEachInRadius(x, y, radius, fn)
    local tempGroup = CreateGroup()
    GroupEnumUnitsInRange(tempGroup, x, y, radius, nil)

    for i = 0, BlzGroupGetSize(tempGroup) - 1 do
        local u = BlzGroupUnitAt(tempGroup, i)
        if u then
            fn(u)
        end
    end

    DestroyGroup(tempGroup)
end

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

function Unit.hasInvisibilityBuff(unit)
    for _, buffId in ipairs(buffTypes.invisibility) do
        if UnitHasBuffBJ(unit, FourCC(buffId)) then
            return true
        end
    end
    return false
end

function Unit.substractMana(unit, amount)
    local maxMana = GetUnitState(unit, UNIT_STATE_MAX_MANA)
    local currentMana = GetUnitState(unit, UNIT_STATE_MANA)
    return SetUnitState(unit, UNIT_STATE_MANA, math.max(0, currentMana - amount))
end

function Unit.restoreMana(unit, amount)
    local maxMana = GetUnitState(unit, UNIT_STATE_MAX_MANA)
    local currentMana = GetUnitState(unit, UNIT_STATE_MANA)
    return SetUnitState(unit, UNIT_STATE_MANA, math.min(maxMana, currentMana + amount))
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

---@param point Point unit center excludes self; { x, y } does not
---@param radius number
---@param filter? fun(u: unit): boolean
function Unit.getUnitsInRadius(point, radius, filter)
    local x, y = pointXY(point)
    local exclude = type(point) ~= "table" and point or nil
    local resultsTable = {}
    forEachInRadius(x, y, radius, function(u)
        if UnitAlive(u) and u ~= exclude and (not filter or filter(u)) then
            table.insert(resultsTable, u)
        end
    end)
    return resultsTable
end

function Unit.getAllyUnitsInRadius(unit, radius, filter)
    local resultsTable = {}
    local owner = GetOwningPlayer(unit)
    forEachInRadius(GetUnitX(unit), GetUnitY(unit), radius, function(u)
        if UnitAlive(u) and IsUnitAlly(u, owner) and (not filter or filter(u)) then
            table.insert(resultsTable, u)
        end
    end)
    return resultsTable
end

function Unit.getAllyUnitsOfTypeInRadius(unit, targetTypeId, radius)
    return Unit.getAllyUnitsInRadius(unit, radius, function(u)
        return GetUnitTypeId(u) == targetTypeId
    end)
end

function Unit.getNearestCorpse(unit, radius)
    local corpse
    forEachInRadius(GetUnitX(unit), GetUnitY(unit), radius, function(u)
        if not corpse and IsUnitDeadBJ(u) then
            corpse = u
        end
    end)
    return corpse
end

return Unit
