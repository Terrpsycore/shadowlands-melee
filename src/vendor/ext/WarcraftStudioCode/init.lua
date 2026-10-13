for _, mod in ipairs({
    "vendor.ext.WarcraftStudioCode.WSCodeConfig",
    "vendor.ext.WarcraftStudioCode.HandleType",
    "vendor.ext.WarcraftStudioCode.AsyncControlHandler",
    "vendor.ext.WarcraftStudioCode.WarcraftStudioCode",
    "vendor.ext.WarcraftStudioCode.WSCodeFunctionPreview",
    "vendor.ext.WarcraftStudioCode.FileIO",
}) do
    local ok, err = pcall(require, mod)
    Debug.original.rawprint(mod, ok, err)
    if not ok then
        error(tostring(err))
    end
end

require("lib.wscode_nil_hook_shim")

_G.__wscode_boot = { cfg = rawget(_G, "WSCodeConfig") ~= nil, code = rawget(_G, "WSCode") ~= nil }
