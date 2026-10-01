---@class AbilityScenarioSpec
---@class AbilityScenarioConfig

local function resolveId(value, path)
    if value == nil then
        error(string.format("%s: nil id — use Ids.<domain>.<slug>", path))
    end
    if type(value) ~= "string" then
        error(string.format("%s: expected id string from Ids.*, got %s", path, type(value)))
    end
    return FourCC(value)
end

local function resolveScalarRef(value, path)
    if type(value) == "table" then
        error(string.format("%s: expected scalar id, got array", path))
    end
    return resolveId(value, path)
end

local function resolveFlexRef(value, path)
    if type(value) == "table" then
        local resolved = {}
        for i, id in ipairs(value) do
            resolved[i] = resolveId(id, path .. "[" .. i .. "]")
        end
        return resolved
    end
    return resolveId(value, path)
end

local function resolveRefsDomain(refs, basePath, resolveValue)
    local resolved = {}
    if refs == nil then
        return resolved
    end
    for key, value in pairs(refs) do
        resolved[key] = resolveValue(value, basePath .. "." .. key)
    end
    return resolved
end

local M = {}

---@param ref FourCCId|FourCCId[]
---@return FourCCId
function M.unitId(ref)
    if type(ref) == "table" then
        error("expected scalar unit ref")
    end
    return ref
end

---@param spec AbilityScenarioSpec
---@return AbilityScenarioConfig
function M.compile(spec)
    if type(spec) ~= "table" then
        error("AbilityConfig.compile: expected spec table")
    end
    if type(spec.refs) ~= "table" then
        error("AbilityConfig.compile: expected spec.refs table")
    end

    local refs = {
        abilities = resolveRefsDomain(spec.refs.abilities, "refs.abilities", resolveScalarRef),
        buffs = resolveRefsDomain(spec.refs.buffs, "refs.buffs", resolveScalarRef),
        units = resolveRefsDomain(spec.refs.units, "refs.units", resolveFlexRef),
        items = resolveRefsDomain(spec.refs.items, "refs.items", resolveFlexRef),
    }

    return {
        refs = refs,
        balance = spec.balance or {},
    }
end

return M
