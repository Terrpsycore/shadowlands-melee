local Generic = {}

function Generic.filter(t, predicate)
    local result = {}
    for _, v in ipairs(t) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

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

return Generic
