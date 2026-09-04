local dump = require("utils.logger")

local CONFIG = {}

local function onAnyOrder()
    dump(GetIssuedOrderId(), OrderId2String(GetIssuedOrderId()))
end

return {
    triggers = {
        { trigger = "ORDER", action = onAnyOrder },
    },
    config = CONFIG,
}
