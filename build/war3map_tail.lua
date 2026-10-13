dofile('origwar3map.lua')
local __main = main

function main()
    xpcall(function()
        local bootstrap = require("lib.bootstrap_config")
        require("vendor.ext.DebugUtils")
        require("lib.early_error_handler").install()
        if bootstrap.ENABLE_WSCODE then
            require("vendor.ext.WarcraftStudioCode.init")
        end
        _G.__PREINIT = {
            cfg = rawget(_G, "WSCodeConfig") ~= nil,
            wscode = rawget(_G, "WSCode") ~= nil,
            enableWscode = bootstrap.ENABLE_WSCODE,
        }
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
