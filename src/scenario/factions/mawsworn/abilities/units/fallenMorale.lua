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
            main = Ids.abilities.fallenMorale,
        },
        buffs = {},
        units = {},
    },
    balance = {
        radius = 500,
    },
})

local function onSpell()
    local target = GetSpellTargetUnit()
    local owner = GetOwningPlayer(target)

    local donor
    local maxWs
    for _, unit in
        Unit.getUnitsInRadius(target, CONFIG.balance.radius, function(u)
            return WS.api.has(u) and not IsUnitAlly(u, owner)
        end)
    do
        local ws = WS.api.get(unit)
        if not maxWs or ws > maxWs then
            donor = unit
            maxWs = ws
        end
    end

    if not donor then
        dump("fallenMorale -> no donor with WS found")
        return
    end

    local targetWs = WS.api.get(target)
    local wsDelta = maxWs - targetWs
    if wsDelta <= 0 then
        dump("fallenMorale -> no donor with higher WS found")
        return
    end

    WS.api.applyWeakenedSoulStack(target, wsDelta, owner)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
    },
    config = CONFIG,
}
