dofile('origwar3map.lua')
local __main = main

function main()
    xpcall(function()
        require("vendor.ext.DebugUtils")
        require("lib.early_error_handler").install()
        require("vendor.ext.WarcraftStudioCode.init")
        _G.__PREINIT = { cfg = rawget(_G, "WSCodeConfig") ~= nil, wscode = rawget(_G, "WSCode") ~= nil }
        Debug.original.print("PREINIT cfg=", rawget(_G, "WSCodeConfig") ~= nil, "wscode=", rawget(_G, "WSCode") ~= nil)
        __main()
        dofile('main.lua')
    end, function(msg)
        local ok, mod = pcall(require, "lib.early_error_handler")
        if ok and mod then
            mod.handleBootstrapFailure(msg)
        else
            local handler = geterrorhandler()
            local text = (type(msg) == "string" and msg ~= "") and msg or tostring(err)
            if handler then
                handler(text)
            else
                print(text)
            end
        end
    end)
end

--[==[
main()
]==]
--
