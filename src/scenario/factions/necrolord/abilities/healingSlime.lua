--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.healingSlime")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.healingSlime,
        },
        buffs = {
            main = Ids.buffs.healingSlime,
        },
    },
    balance = {
        shield = 100, -- max damage soaked
    },
})

local function onSpell()
    local target = GetSpellTargetUnit()
    Storage:set(target, "shieldAmount", CONFIG.balance.shield)
end

local function onDamage(info)
    local shieldAmount = Storage:get(info.target, "shieldAmount")
    if shieldAmount then
        local soaked = math.min(info.damage, shieldAmount)
        info.damage = info.damage - shieldAmount

        if soaked == shieldAmount then
            Storage:drop(info.target)
        else
            Storage:set(info.target, "shieldAmount", shieldAmount - soaked)
        end
    end
end

local function onTimer()
    Storage:each(function(unit)
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            Storage:drop(unit)
        end
    end)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
        {
            trigger = "DAMAGE",
            action = onDamage,
        },
        {
            trigger = "TIMER",
            delta = 0.5,
            action = onTimer,
        },
    },
    config = CONFIG,
}
