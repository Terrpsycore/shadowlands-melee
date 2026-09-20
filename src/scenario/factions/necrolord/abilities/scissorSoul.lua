--[[
TODO:
- add delay
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.regenBlock")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.scissorSoul,
            dummy = Ids.abilities.scissorSoulDummy,
            burn = Ids.abilities.scissorSoulManaBurn,
        },
        buffs = {
            main = Ids.buffs.scissorSoul,
        },
        units = {
            --
        },
    },
    balance = {
        decaySpeed = 25, -- per second
        tickDelta = 0.03,
    },
})
local DECAY_PER_TICK = CONFIG.balance.decaySpeed * CONFIG.balance.tickDelta

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.dummy, "acidbomb")
    Dummy.applyDummyAttack(owner, target, CONFIG.refs.abilities.burn)
end

local function afterDummyAttack(info)
    if GetUnitAbilityLevel(info.source, CONFIG.refs.abilities.burn) > 0 then
        RemoveUnit(info.source)

        Storage:set(info.target, "type", 2)
        Storage:set(info.target, "frozenAmount", GetUnitState(info.target, UNIT_STATE_MANA))
    end
end

local function onTimer()
    Storage:each(function(unit)
        local status = Storage:bind(unit)
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            Storage:drop(unit)
        elseif status and status.type == 2 then
            local currentMana = GetUnitState(unit, UNIT_STATE_MANA)
            if currentMana > status.frozenAmount then
                local mana = math.max(status.frozenAmount, currentMana - DECAY_PER_TICK)
                SetUnitState(unit, UNIT_STATE_MANA, mana)
            elseif currentMana < status.frozenAmount then
                status.frozenAmount = currentMana
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
            trigger = "AFTER_DAMAGE",
            filter = { source = CONFIG.refs.units.dummyAttack },
            action = afterDummyAttack,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.tickDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
