local Type = {}

function Type.toSet(array)
    local set = {}
    for _, value in ipairs(array) do
        set[value] = true
    end
    return set
end

function Type.toBool(v)
    return not not v
end

return Type
