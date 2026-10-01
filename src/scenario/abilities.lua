local buffTypes = require("data.buffTypes")
local registry = require("scenario.generated.abilities_registry")

_G.dump = require("utils.logger")
_G.Generic = require("utils.generic")

local abilities = {}
for _, mod in ipairs(registry) do
    abilities[#abilities + 1] = require(mod)
end

return {
    buffs = {
        stun = buffTypes.stun,
        root = buffTypes.root,
    },
    abilities = abilities,
}
