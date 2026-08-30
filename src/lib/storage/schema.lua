local htApi = require("lib.storage.ht")

local FIELD_TYPES = {
    int = {
        get = htApi.getInt,
        set = htApi.setInt,
        have = function(parent, child)
            return HaveSavedInteger(htApi.ht, parent, child)
        end,
    },
    real = {
        get = htApi.getReal,
        set = htApi.setReal,
        have = function(parent, child)
            return HaveSavedReal(htApi.ht, parent, child)
        end,
    },
    bool = {
        get = htApi.getBool,
        set = htApi.setBool,
        have = function(parent, child)
            return HaveSavedBoolean(htApi.ht, parent, child)
        end,
    },
    unit = {
        get = htApi.getUnitHandle,
        set = htApi.setUnitHandle,
        have = function(parent, child)
            return HaveSavedHandle(htApi.ht, parent, child)
        end,
    },
}

local function normalizeFieldSpec(spec)
    if type(spec) == "string" then
        return { type = spec }
    end
    return spec
end

local function buildFieldMap(schemaFields)
    local fields = {}
    for name, spec in pairs(schemaFields) do
        local normalized = normalizeFieldSpec(spec)
        local fieldType = FIELD_TYPES[normalized.type]
        if not fieldType then
            error("unknown field type '" .. tostring(normalized.type) .. "'")
        end
        fields[name] = {
            child = normalized.child or StringHash(name),
            type = normalized.type,
            default = normalized.default,
            access = fieldType,
        }
    end
    return fields
end

return {
    buildFieldMap = buildFieldMap,
}
