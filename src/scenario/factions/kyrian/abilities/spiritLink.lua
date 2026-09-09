local Ids = require("data.ids")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local CONFIG = {
    damageReduceAmount = 6,
    minDamage = 3,

    buffId = FourCC(Ids.buffs.spiritLink),
}

local onPreDamage = function(info)
    if UnitHasBuffBJ(info.target, CONFIG.buffId) then
        info.damage = math.max(info.damage - CONFIG.damageReduceAmount, CONFIG.minDamage)
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
