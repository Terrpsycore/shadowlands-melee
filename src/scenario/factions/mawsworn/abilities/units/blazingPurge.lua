--[[
TODO:
- BUG: morph doesn't work
- OE data: restored mana
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local DispellMeter = require("scenario.common.mechanics.dispellMeter")
local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.blazingPurge,
            morph = Ids.abilities.blazingPurgeMorph,
            dummyDispell = Ids.abilities.blazingPurgeDispell,
        },
        buffs = {},
        units = {
            carrier = { Ids.units.mawcasterFire },
        },
    },
    balance = {
        morphDuration = 10,
        maxCharges = 3,
        timerDelta = 0.5,
    },
})

--- @type table<unit, {charges: integer, fadesAt: number}>
local memory = {} -- TODO: save/load

--- @param caster unit
local function removeEffect(caster)
    UnitAddAbility(caster, CONFIG.refs.abilities.morph)
    IssueImmediateOrder(caster, "unbearform")
    UnitRemoveAbility(caster, CONFIG.refs.abilities.morph)
    memory[caster] = nil
end

local function onSpell()
    local caster = GetTriggerUnit()

    UnitAddAbility(caster, CONFIG.refs.abilities.morph)
    IssueImmediateOrder(caster, "bearform")
    Timed.call(1, function()
        UnitRemoveAbility(caster, CONFIG.refs.abilities.morph)
    end)

    memory[caster] = {
        charges = CONFIG.balance.maxCharges,
        fadesAt = GetElapsedGameTime() + CONFIG.balance.morphDuration,
    }
end

--- @param info damageInfo
local function onAfterDamage(info)
    if not info.isAttack then
        return
    end

    if not memory[info.source] then
        return
    end

    local owner = GetOwningPlayer(info.source)

    memory[info.source].charges = memory[info.source].charges - 1
    if not memory[info.source].charges then
        removeEffect(info.source)
    end

    -- TODO: some special effect

    DispellMeter.api.count(
        owner,
        { ability = CONFIG.refs.abilities.dummyDispell, target = info.target },
        { unit = { mp = 1 } },
        --- @param result dispellMeterResult
        function(result)
            if result.unit then
                WS.api.applyWeakenedSoulStack(info.target, 1, owner)
            end
        end
    )
end

local function onTimer()
    local flushQueue = {}
    for unit, data in pairs(memory) do
        if GetElapsedGameTime() > data.fadesAt then
            removeEffect(unit)
        end
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell, -- ? cast start
        },
        {
            trigger = "AFTER_DAMAGE",
            filter = { source = CONFIG.refs.units.carrier },
            action = onAfterDamage, -- ? cast start
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.timerDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
