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
        radius = 100,
        burnMana = { 200, 400, 600 },
        drawbackDelay = 3,
    },
})

local memory = {}
local sigilMemory = {} -- TODO: save/load

local function onSpell()
    -- note: can be rewritten to "onSpawn" trigger
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()

    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    local targets = Unit.getUnitsInRadius({ x = targetX, y = targetY }, 50, function(u)
        return GetOwningPlayer(u) == owner and GetUnitTypeId(u) == CONFIG.refs.units.sigil
    end)

    for _, target in ipairs(targets) do
        SetUnitAbilityLevel(target, CONFIG.refs.abilities.activation, level)
        memory[target] = caster
    end
end

local function onActivation()
    local sigil = GetDyingUnit()
    local owner = GetOwningPlayer(sigil)

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
    end

    if not maxMana then
        return
    end

    local level = GetUnitAbilityLevel(sigil, CONFIG.refs.abilities.activation)
    Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.drain, "channel", level)

    local burnMana = math.min(CONFIG.balance.burnMana, maxMana)

    local drawbackLevel = math.min((burnMana // 50) + 1, 10)

    sigilMemory[target] = {
        caster = memory[sigil],
        level = level,
        drawbackLevel = drawbackLevel,
        mana = maxMana,
    }
end

local function onDrain()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    local data = sigilMemory[target]

    local dummy = Dummy.create(owner, caster, CONFIG.refs.abilities.transfer, data.level)
    IssueTargetOrder(dummy, "channel", data.caster)

    Timed.delay(CONFIG.balance.drawbackDelay, function()
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
