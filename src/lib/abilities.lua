local Ids = require("data.ids")

--- Dev / infra ability ids by slug (runtime-safe; no data.abilities rows).
---@param slug AbilitySlug
---@return string
local function id(slug)
    local raw = Ids.abilities[slug]
    if raw == nil then
        error(string.format("unknown ability slug %q", slug))
    end
    return raw
end

---@param slug AbilitySlug
---@return integer
local function fourcc(slug)
    return FourCC(id(slug))
end

return {
    id = id,
    fourcc = fourcc,
}
