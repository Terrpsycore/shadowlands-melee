---@beginFile abduct
--[[
TODO:
- resolve conflict with antiair stun
- different behaviour when caster as ground form and air form
- switch to air on end cast
- targets only ground units
- ? special apply to ground-air units
- ? pontential bug - default fly height handle
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")

local Fly = require("scenario.factions.mawsworn.abilities.common.fly")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.abduct,
            height = Ids.abilities.abductHeight,
            morph = Ids.abilities.forswornHeroFly,
        },
        buffs = {},
        units = {
            carrierGround = Ids.units.forswornHero,
            carrierAir = Ids.units.forswornHeroFlying,
        },
        items = {},
    },
    balance = {
        --
        ascendSpeed = 100, -- per second
        fallSpeed = 1000, -- per second
        fallDamage = 50, -- per 100 units of height
        ascendTimerDelta = 0.5,
    },
})

--- @type table<unit, {target: unit}>
local abductors = {}
--- @type table<unit, {caster: unit, height: number, falling: boolean}>
local abducted = {} -- TODO: save/load

local function endEffect(caster, target)
    -- drop
    -- restore fly height
    -- damage basing on current height
    local height = abducted[target].height
    local fallTime = height / CONFIG.balance.fallSpeed
    SetUnitFlyHeight(caster, 0, height / CONFIG.balance.fallSpeed)
    SetUnitFlyHeight(target, 0, height / CONFIG.balance.fallSpeed)
    Timed.call(fallTime, function()
        abductors[caster] = nil
        abducted[target] = nil
        local dummy = Dummy.create(GetOwningPlayer(caster), target)
        local fallDamage = Damage.apply(
            dummy,
            target,
            height / CONFIG.balance.fallDamage,
            false,
            false,
            ATTACK_TYPE_CHAOS,
            DAMAGE_TYPE_ENHANCED
        )
    end)
end

local function onSpell()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    abductors[caster] = { target = target }
    abducted[target] = { caster = caster, height = 0, falling = false } -- TODO: diff default height
end

local function onEndcast()
    -- TODO: ? conflict with antiair stun
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    endEffect(caster, target)
end

local function onOrder()
    local unit = GetOrderedUnit()
    if not abducted[unit] then
        return
    end
    IssueImmediateOrder(unit, "hold")
end

local function onTimer()
    for target, data in pairs(abducted) do
        if not data.falling then
            local caster = data.caster
            local ascendPerSecond = (CONFIG.balance.ascendSpeed / CONFIG.balance.ascendTimerDelta)
            SetUnitFlyHeight(caster, ascendPerSecond, ascendPerSecond)
            SetUnitFlyHeight(target, ascendPerSecond, ascendPerSecond)
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
            trigger = "EVENT_PLAYER_UNIT_SPELL_ENDCAST",
            spellId = CONFIG.refs.abilities.main,
            action = onEndcast,
        },
        {
            trigger = "ORDER",
            action = onOrder,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.ascendTimerDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
