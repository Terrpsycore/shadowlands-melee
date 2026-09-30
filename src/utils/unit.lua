-- TODO
-- - optimize exclude

local buffTypes = require("data.buffTypes")

local Unit = {}

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

function Unit.getPosition(unit)
    return { x = GetUnitX(unit), y = GetUnitY(unit) }
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

function Unit.isHealthFull(unit)
    return GetUnitState(unit, UNIT_STATE_LIFE) >= GetUnitState(unit, UNIT_STATE_MAX_LIFE) - 0.01
end

function Unit.isOffCooldown(unit, abilityId)
    local remainingCd = BlzGetUnitAbilityCooldownRemaining(unit, abilityId)
    return remainingCd <= 0
end

function Unit.face(sourceUnit, targetUnit)
    -- Get coordinates of both units
    local x1 = GetUnitX(sourceUnit)
    local y1 = GetUnitY(sourceUnit)
    local x2 = GetUnitX(targetUnit)
    local y2 = GetUnitY(targetUnit)

    -- Calculate angle in radians, then convert to degrees
    local angleRad = math.atan(y2 - y1, x2 - x1)
    local angleDeg = angleRad * bj_RADTODEG -- bj_RADTODEG is approximately 57.2958

    -- Apply instant facing
    SetUnitFacing(sourceUnit, angleDeg)
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
function Unit.getClosestUnit(point, radius, filter)
    local x, y = pointXY(point)
    local exclude = type(point) ~= "table" and point or nil
    forEachInRadius(x, y, radius, function(u)
        if UnitAlive(u) and u ~= exclude and (not filter or filter(u)) then
            return u
        end
    end)
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

function Unit.getCorpsesInRadius(point, radius)
    local x, y = pointXY(point)
    local exclude = type(point) ~= "table" and point or nil
    local resultsTable = {}
    forEachInRadius(x, y, radius, function(u)
        if IsUnitDeadBJ(u) and u ~= exclude then
            table.insert(resultsTable, u)
        end
    end)
    return resultsTable
end

function Unit.applyTimedLife(unit, duration)
    UnitApplyTimedLife(unit, FourCC("BTLF"), duration)
end

--- @alias Color "red" | "purple" | "grey"

--- @param unit unit
--- @param label string
--- @param color Color
function Unit.applyTimedFloatingText(unit, label, color)
    local r, g, b, o
    if color == "red" then
        r, g, b, o = 100, 0, 0, 0
    elseif color == "purple" then
        r, g, b, o = 100, 0, 100, 0
    elseif color == "grey" then
        r, g, b, o = 50, 50, 50, 0
    end
    local text = CreateTextTagUnitBJ(label, unit, 0, 10, r, g, b, o)
    SetTextTagVelocityBJ(text, 64, 90)
    SetTextTagPermanent(text, false)
    SetTextTagLifespan(text, 2.0)
    SetTextTagFadepoint(text, 1.5)
end

return Unit
