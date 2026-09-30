--[[
TODO:
-- - BUG: 10-stack weighted hit applies stun, but doesn't apply exhaust debuff
- higher WS on single hero at T2/T3
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {},
        units = {
            carrier = { Ids.units.forswornHero, Ids.units.mawcasterHero, Ids.units.mournebladeHero },
        },
    },
    balance = {},
})

-- local memory = {} -- TODO: save/load -- process 1.33/1.5 WS stacks per hit

--- @param info damageInfo
local function onDamage(info)
    if not info.isAttack then
        return
    end
    WS.api.applyWeakenedSoulStack(
        info.target,
        10, -- tmp
        GetOwningPlayer(info.source)
    )
end

return {
    triggers = {
        {
            trigger = "DAMAGE",
            filter = {
                source = CONFIG.refs.units.carrier,
            },
            action = onDamage,
        },
    },
    config = CONFIG,
}
