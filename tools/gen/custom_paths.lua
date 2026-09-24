--- Resolve WC3_CUSTOM root (external custom assets directory).

local FALLBACK = "../wc3-custom"
local DOTENV_REL = "tools/icon_preview/.env"

local function trim(s)
    return (s:match("^%s*(.-)%s*$"))
end

local function normalizeSlashes(path)
    return path:gsub("/", "\\")
end

local function resolvePath(raw)
    raw = normalizeSlashes(raw)
    if raw:match("^%a:") then
        return raw
    end
    local p = io.popen('for %I in ("' .. raw .. '") do @echo %~fI')
    if p then
        local abs = p:read("*l")
        p:close()
        if abs and abs ~= "" then
            return normalizeSlashes(abs)
        end
    end
    return raw
end

local function readDotEnv(repoRoot)
    local values = {}
    local path = repoRoot .. "/" .. DOTENV_REL
    local f = io.open(path, "r")
    if not f then
        return values
    end
    for raw in f:lines() do
        local line = trim(raw)
        if line ~= "" and not line:match("^#") then
            local key, value = line:match("^([^=]+)=(.*)$")
            if key then
                key = trim(key)
                value = trim(value):gsub('^["\'](.-)["\']$', "%1")
                values[key] = value
            end
        end
    end
    f:close()
    return values
end

local function resolveCustomRoot(repoRoot)
    local raw = os.getenv("WC3_CUSTOM")
    if not raw or raw == "" then
        raw = readDotEnv(repoRoot).WC3_CUSTOM
    end
    if not raw or raw == "" then
        raw = FALLBACK
    end
    return resolvePath(raw)
end

return {
    FALLBACK = FALLBACK,
    resolveCustomRoot = resolveCustomRoot,
}
