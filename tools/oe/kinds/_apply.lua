local M = {}

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
