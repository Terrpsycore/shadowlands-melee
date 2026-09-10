local AbilityConfig = require("scenario.config")
local dump = require("utils.logger")

local CONFIG = AbilityConfig.compile({
    refs = {},
    balance = {},
})

local function onAnyOrder()
    dump("order", OrderId2String(GetIssuedOrderId()))
end

return {
    triggers = {
        { trigger = "ORDER", action = onAnyOrder },
    },
    config = CONFIG,
}
