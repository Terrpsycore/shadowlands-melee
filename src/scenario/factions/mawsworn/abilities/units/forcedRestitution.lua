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
            main = Ids.abilities.forcedRestitution,
            decay = Ids.abilities.forcedRestitutionDecay,
        },
        buffs = {
            decay = Ids.buffs.forcedRestitutionDecay,
        },
        units = {},
    },
    balance = {
        decayDamagePerSecond = 3,
        timerDelta = 0.5,
    },
})

--- @type table<unit, {buffApplied: boolean}>
local memory = {}

local function onSpell()
    local target = GetSpellTargetUnit()
    local owner = GetOwningPlayer(target)

    for _, unit in
        Unit.getUnitsInRadius(target, CONFIG.balance.radius, function(u)
            return IsUnitAlly(u, owner) -- TODO: type organic
        end)
    do
        memory[unit] = { buffApplied = UnitHasBuffBJ(unit, CONFIG.refs.buffs.decay) }
        Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.decay, "acidbomb")
    end
end

local function onTimer()
    for unit, data in pairs(memory) do
        if UnitHasBuffBJ(unit, CONFIG.refs.buffs.decay) then
            Damage.apply(
                unit,
                unit,
                CONFIG.balance.decayDamagePerSecond * CONFIG.balance.timerDelta,
                false,
                false,
                ATTACK_TYPE_CHAOS,
                DAMAGE_TYPE_DEATH
            )
        else
            memory[unit] = nil
        end
    end
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
            delta = CONFIG.balance.timerDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
