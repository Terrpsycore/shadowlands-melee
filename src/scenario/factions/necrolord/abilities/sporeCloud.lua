--[[
TODO:
- break on unit death
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.sporeCloud")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.sporeCloud,
            dummy = Ids.abilities.sporeCloudDummy,
            damage = Ids.abilities.sporeCloudDamage,
        },
        buffs = {
            --
        },
        units = {
            --
        },
    },
    balance = {
        ticks = 4,
        tickDelta = 0.25,
    },
})

local function spawnCloud(caster)
    local owner = GetOwningPlayer(caster)
    local dummy = Dummy.applyDummyPointOrder(owner, caster, CONFIG.refs.abilities.dummy, "cloudoffog")
    UnitAddAbility(dummy, CONFIG.refs.abilities.damage)
end

local function onSpell()
    local caster = GetTriggerUnit()

    Storage:set(caster, "ticks", CONFIG.balance.ticks)
    Storage:set(caster, "beforeNextTick", 1)

    spawnCloud(caster)
end

local function onTimer()
    Storage:each(function(unit)
        local castStatus = Storage:bind(unit)
        if castStatus then
            castStatus.beforeNextTick = castStatus.beforeNextTick - CONFIG.balance.tickDelta
            if castStatus.beforeNextTick <= 0 then
                castStatus.ticks = castStatus.ticks - 1
                castStatus.beforeNextTick = 1
                spawnCloud(unit)
                if castStatus.ticks == 0 then
                    Storage:drop(unit)
                end
            end
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
            trigger = "TIMER",
            delta = CONFIG.balance.tickDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
