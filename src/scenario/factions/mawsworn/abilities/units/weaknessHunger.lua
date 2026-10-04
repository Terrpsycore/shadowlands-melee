--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.weaknessHunger,
        },
        units = {
            carrier = { Ids.units.soulEater },
        },
    },
    balance = {
        bonusDamagePerStack = 2,
    },
})

--- @param info damageInfo
local function onDamage(info)
    if not info.isAttack then
        return
    end
    local stacks = WS.api.get(info.target)
    if not stacks then
        return
    end
    local bonusDamage = stacks * CONFIG.balance.bonusDamagePerStack
    info.damage = info.damage + bonusDamage
    Unit.applyTimedFloatingText(info.target, bonusDamage, "red")
end

return {
    triggers = {
        {
            trigger = "DAMAGE",
            filter = { source = CONFIG.refs.units.carrier },
            action = onDamage,
        },
    },
    config = CONFIG,
}
