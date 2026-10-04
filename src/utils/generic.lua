local Generic = {}

---@param at Point
local function pointXY(at)
    if type(at) == "table" then
        return at.x, at.y
    end
    return GetUnitX(at), GetUnitY(at)
end

function Generic.filter(t, predicate)
    local result = {}
    for _, v in ipairs(t) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

--- @param t table
--- @result table
function Generic.reverseTable(t)
    local result = {}
    for k, v in pairs(t) do
        result[v] = k
    end
    return result
end

function Generic.contains(t, value)
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

--- @param t table
--- @result table<integer,any>
function Generic.toArray(t)
    local array = {}
    for _, value in pairs(t) do
        table.insert(array, value)
    end
    return array
end

--- @param t table
--- @result table<any,true>
function Generic.toSet(t)
    local set = {}
    for _, value in pairs(t) do
        set[value] = true
    end
    return set
end

--- @param t table
--- @param value any
--- @result boolean
function Generic.removeValue(t, value)
    for i, v in ipairs(t) do
        if v == value then
            table.remove(t, i)
            return true
        end
    end
    return false
end

--- @param a {x:number,y:number}
--- @param b {x:number,y:number}
function Generic.distance(a, b)
    local aX, aY = pointXY(a)
    local bX, bY = pointXY(b)
    local dX = math.abs(aX - bX)
    local dY = math.abs(aY - bY)
    return math.sqrt(dX ^ 2 + dY ^ 2)
end

return Generic
