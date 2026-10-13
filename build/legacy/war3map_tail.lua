dofile('origwar3map.lua')
local __main = main
function main()
    xpcall(function()
        __main()
        dofile('main.lua')
    end, function(msg)
        local handler = geterrorhandler()
        if handler and msg then
            return handler(msg)
        end
    end)
end
