--- Shared helpers for icon preview export (icons.json / units.json).

local M = {}

function M.parseMode(argv)
    local mode = "all"
    for i = 1, #argv do
        local flag = argv[i]
        if flag == "--icons" then
            mode = "icons"
        elseif flag == "--units" then
            mode = "units"
        elseif flag == "--all" then
            mode = "all"
        end
    end
    return mode
end

function M.sourceFilePath(root, modulePath)
    return root .. "/src/" .. modulePath:gsub("%.", "/") .. ".lua"
end

function M.ensureDir(dir)
    dir = dir:gsub("/", "\\")
    os.execute('if not exist "' .. dir .. '" mkdir "' .. dir .. '"')
end

function M.jsonEscape(value)
    return (value:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r"))
end

function M.jsonString(value)
    return '"' .. M.jsonEscape(tostring(value)) .. '"'
end

function M.jsonEncode(value, indent)
    indent = indent or 0
    local pad = string.rep("  ", indent)
    local padInner = string.rep("  ", indent + 1)
    local t = type(value)

    if t == "nil" then
        return "null"
    end
    if t == "boolean" or t == "number" then
        return tostring(value)
    end
    if t == "string" then
        return M.jsonString(value)
    end
    if t == "table" then
        local isArray = true
        local maxIndex = 0
        for k in pairs(value) do
            if type(k) ~= "number" then
                isArray = false
                break
            end
            if k > maxIndex then
                maxIndex = k
            end
        end
        if isArray and maxIndex == #value then
            local parts = {}
            for i = 1, #value do
                parts[#parts + 1] = padInner .. M.jsonEncode(value[i], indent + 1)
            end
            if #parts == 0 then
                return "[]"
            end
            return "[\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "]"
        end

        local keys = {}
        for k in pairs(value) do
            keys[#keys + 1] = k
        end
        table.sort(keys, function(a, b)
            return tostring(a) < tostring(b)
        end)

        local parts = {}
        for _, k in ipairs(keys) do
            parts[#parts + 1] = padInner .. M.jsonString(tostring(k)) .. ": " .. M.jsonEncode(value[k], indent + 1)
        end
        if #parts == 0 then
            return "{}"
        end
        return "{\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "}"
    end

    error("unsupported json type: " .. t)
end

function M.writeJson(path, payload)
    local out = assert(io.open(path, "w"))
    out:write(M.jsonEncode(payload))
    out:write("\n")
    out:close()
end

function M.writeStamp(jsonPath, generatedAt)
    local stampPath = jsonPath:gsub("%.json$", ".stamp")
    local out = assert(io.open(stampPath, "w"))
    out:write(generatedAt)
    out:write("\n")
    out:close()
end

function M.utcTimestamp()
    return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

return M
