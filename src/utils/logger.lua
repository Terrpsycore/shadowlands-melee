local function dump(t)
    local parts = {}
    for k, v in pairs(t) do
        local key = type(k) == "string" and string.format("%q", k) or tostring(k)
        local value = type(v) == "string" and string.format("%q", v) or tostring(v)
        table.insert(parts, key .. " = " .. value)
    end
    local line = "{ " .. table.concat(parts, ", ") .. " }"
    Debug.original.print(line)
    return line
end

return dump
