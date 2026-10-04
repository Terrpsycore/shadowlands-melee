--[[
- ? upgrade shackle power
- ? apply shackle power to current HP, not only max (weaker units surrender easier)
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.shackle,
            slow = Ids.abilities.shackleSlow,
        },
        buffs = {
            -- debuff = Ids.buffs.bastionSpearSlow, -- optional
        },
        units = {
            -- source = { Ids.units.ascendedWarrior }, -- optional DAMAGE filter
        },
    },
    balance = {
        timerDelta = 0.5,
        shacklePower = 1000, -- (POWER - TARGET_MAX_HP) / 100 = DURATION -- ? upgradable
        radius = 100,
    },
})

local memory = {} -- TODO: save/load

--- @type table<unit, {shacklers: unit[]}> -- TODO: save/load
local shackles = {}
--- @type table<unit, {target: unit, charges: integer}> -- TODO: save/load
local shacklers = {}

local function removeShackle(shackler)
    local target = shacklers[shackler].target
    shacklers[shackler] = nil

    Generic.removeValue(shackles[target].shacklers, shackler)
end

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    local targetMaxHp = GetUnitState(target, UNIT_STATE_MAX_LIFE)
    local maxDuration = math.min(2, (CONFIG.balance.shacklePower - targetMaxHp) // 100)

    shacklers[caster] = {
        target = target,
        charges = maxDuration, -- int
    }
    if not shackles[target] then
        shackles[target].shacklers = {}
    end
    table.insert(shackles[target].shacklers, caster)

    -- get max duration, save to memory
    -- onTimer (0.5): check status and distance and duration, apply slow+ws, order stop on limit
    -- (1 shackle effects at time)
    -- ? maybe don't spend duration points if another shackle spends point
    -- onOrder/?onSpellCancel?: change status

    return
end

local function onSpellEndCast()
    local caster = GetTriggerUnit()

    removeShackle(caster)
    return
end

local function onTimer()
    local flushQueue = {}
    for target, data in pairs(shackles) do
        if #data.shacklers == 0 then
            flushQueue[target] = true
        end
        local shackler = data.shacklers[0]
        local owner = GetOwningPlayer(shackler)
        local shacklerData = shacklers[shackler]
        WS.api.applyWeakenedSoulStack(target, 1, owner)
        Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.slow, "slow")
        shacklerData.charges = shacklerData.charges - 1
        if shacklerData.charges == 0 then
            IssueImmediateOrder(shackler, "stop")
            removeShackle(shackler)
        end
    end
    for _, v in ipairs(flushQueue) do
        shackles[v] = nil
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
            trigger = "EVENT_PLAYER_UNIT_SPELL_ENDCAST",
            spellId = CONFIG.refs.abilities.main,
            action = onSpellEndCast,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.timerDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
