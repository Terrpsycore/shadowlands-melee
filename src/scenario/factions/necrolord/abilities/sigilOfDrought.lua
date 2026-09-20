--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.droughtSigil,
            activation = Ids.abilities.sigilOfDroughtActivation,
            drain = Ids.abilities.sigilOfDroughtDrainMana,
            transfer = Ids.abilities.sigilOfDroughtTransferMana,
            regen = Ids.abilities.sigilOfDroughtDrawback,
        },
        units = {
            sigil = Ids.units.sigilOfDrought,
        },
    },
    balance = {
        radius = 150,
        duration = { 60, 60, 60 },
        burnMana = { 200, 400, 600 },
        drawbackDelay = 3,
    },
})

local spawnQueue = {}
local memory = {}
local sigilMemory = {} -- TODO: save/load

local function onSpell()
    -- note: can be rewritten to "onSpawn" trigger
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)

    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)
    spawnQueue[owner] = { level = level, caster = caster }
end

local function onSpawn()
    -- note: can be rewritten to "onSpawn" trigger
    local sigil = GetEnteringUnit()
    local owner = GetOwningPlayer(sigil)

    local data = spawnQueue[owner]
    spawnQueue[owner] = nil

    Unit.applyTimedLife(sigil, CONFIG.balance.duration[data.level])
    SetUnitAbilityLevel(sigil, CONFIG.refs.abilities.activation, data.level)
    memory[sigil] = data.caster
end

local function onActivation()
    local sigil = GetDyingUnit()
    local owner = GetOwningPlayer(sigil)

    dump("sigil onActivation owner=", GetPlayerId(owner))
    local targets = Unit.getUnitsInRadius(sigil, CONFIG.balance.radius, function(u)
        return IsUnitAliveBJ(u) and IsUnitEnemy(u, owner)
    end)

    local target
    local maxMana
    for _, t in ipairs(targets) do
        local mana = GetUnitState(t, UNIT_STATE_MANA)
        if not maxMana or mana > maxMana then
            target = t
            maxMana = mana
        end
        dump("drought iter", t, mana)
    end

    if not maxMana then
        dump("drought no target with mana, return")
        return
    end

    local level = GetUnitAbilityLevel(sigil, CONFIG.refs.abilities.activation)
    local burnMana = math.min(CONFIG.balance.burnMana[level], maxMana)
    local drawbackLevel = math.min((burnMana // 50) + 1, 10)

    sigilMemory[target] = {
        caster = memory[sigil],
        level = level,
        drawbackLevel = drawbackLevel,
        mana = maxMana,
    }

    Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.drain, "drain", level)
end

local function onDrain()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    local data = sigilMemory[target]

    local dummy = Dummy.create(owner, caster, CONFIG.refs.abilities.transfer, data.level)
    IssueTargetOrder(dummy, "drain", data.caster)

    Timed.call(CONFIG.balance.drawbackDelay, function()
        Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.regen, "rejuvenation", data.drawbackLevel)
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
            trigger = "CREATE",
            filter = { target = CONFIG.refs.units.sigil },
            action = onSpawn,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.sigil },
            action = onActivation,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.drain,
            action = onDrain,
        },
    },
    config = CONFIG,
}
