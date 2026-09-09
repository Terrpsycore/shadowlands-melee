local Ids = require("data.ids")
local AbilityConfig = require("scenario.config")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local CONFIG = AbilityConfig.compile({
    refs = {
        buffs = {
            main = Ids.buffs.spiritLink,
        },
    },
    balance = {
        damageReduceAmount = 6,
        minDamage = 3,
    },
})

local onPreDamage = function(info)
    if UnitHasBuffBJ(info.target, CONFIG.refs.buffs.main) then
        info.damage = math.max(info.damage - CONFIG.balance.damageReduceAmount, CONFIG.balance.minDamage)
    end
end

return {
    triggers = {
        {
            trigger = "PRE_DAMAGE",
            action = onPreDamage,
        },
    },
    config = CONFIG,
}
