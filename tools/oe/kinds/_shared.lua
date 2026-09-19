local Ids = require("data.generated.ids")
local AbilityIds = require("vendor.assets.AbilityIds")

local M = {}

function M.resolveAbilityId(slug)
    local id = Ids.abilities[slug] or AbilityIds[slug]
    if not id then
        error("unknown ability '" .. slug .. "'")
    end
    return id
end

function M.normalizePath(path)
    return path:gsub("/", "\\")
end

function M.applySubfields(obj, value, mapping, context)
    for key, val in pairs(value) do
        local handler = mapping[key]
        if not handler then
            error("unknown " .. context .. " field '" .. key .. "'")
        end
        handler(obj, val)
    end
end

---@param fn fun(a: any, level?: integer)
---@param obj any
---@param data { levels?: integer }
function M.runApplyPerLevel(fn, obj, data)
    local levels = (data and data.levels) or 1
    if debug.getinfo(fn, "u").nparams >= 2 then
        for level = 1, levels do
            fn(obj, level)
        end
        return
    end
    fn(obj)
end

return M
