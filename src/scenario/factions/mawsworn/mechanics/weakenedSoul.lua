--[[
-- TODO
-- - prevent spawning lots of dummies on same unit in 1-sec window (prolongate WS/exhaustion debuffs)


-- - - probably reduce WS stacks without dummy rebuff - adjust passive aura only (but buff level will glitch then showing not actual level)
-- - ? optimize by not applying dummy buff EACH time (only when there is at least +1 stack)
-- - visual floating text markers (WS level)
-- - ?? optimize by applying dummy abils only per 0.25-0.5 s ticks (apply if there is delta)
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local UnitMeta = require("lib.units")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.weakenedSoulDebuff,
            ws = Ids.abilities.weakenedSoulEffect,
            exhaustion = Ids.abilities.exhaustionDebuff,
            exhaustionEffect = Ids.abilities.exhaustionEffect,
            neutralize = Ids.abilities.exhaustionNeutralize,
        },
        buffs = {
            dispellMark = Ids.buffs.weakenedSoulDebuff,
            ws = Ids.buffs.weakenedSoulAura,
            exhaustion = Ids.buffs.exhaustion,
            neutralize = Ids.buffs.exhaustionNeutralize,
        },
        units = {},
    },
    balance = {
        flushDelta = 0.2,
        neutralizeDamageIgnoreDuration = 3,
        exhaustionDebuffUpdateDelta = 1,
    },
})

---@alias ExhaustionData { debuffApplied: boolean, dontUpdateExhaustionDebuffUntil: float|nil, neutralizeExpiresAt: float|nil }

--- @type table<unit, boolean>
local memory = {} -- TODO: save/load
--- @type table<unit, ExhaustionData>
local exhausted = {} -- TODO: save/load
local dummyCastQueue = {} -- TODO: save/load

--- @alias ModifierTag "glare"
--- @type table<unit, table<ModifierTag, {modifier: integer, cooldown: integer, availableAt: number}>>
local modifiers = {} -- TODO: save/load

--- @param unit unit
--- @return integer
local function getCurrentWsLevel(unit)
    return GetUnitAbilityLevel(unit, CONFIG.refs.abilities.ws)
end

--- @param unit unit
--- @param stacksDelta integer
--- @param player player | nil Owner of debuff (required only for positive <stacksDelta> values)
local function updateWeakenedSoulState(unit, stacksDelta, player)
    local stacksBefore = getCurrentWsLevel(unit) -- ? save in memory
    local stacks = math.max(0, math.min(10, stacksBefore + stacksDelta))

    if stacks == 0 then
        UnitRemoveAbility(unit, CONFIG.refs.abilities.ws)
        UnitRemoveBuffBJ(CONFIG.refs.buffs.ws, unit)
        memory[unit] = nil
        return
    else
        if not memory[unit] then
            memory[unit] = true
        end

        if stacksBefore == 0 then
            UnitAddAbility(unit, CONFIG.refs.abilities.ws)
        end
        SetUnitAbilityLevel(unit, CONFIG.refs.abilities.ws, stacks)

        if stacks == 10 then
            if not exhausted[unit] then
                exhausted[unit] = {
                    debuffApplied = false,
                    dontUpdateExhaustionDebuffUntil = nil,
                    neutralizeExpiresAt = nil,
                }
            end
            -- apply neutralize only if unit didn't have exhaustion right before
            if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.exhaustion) then
                exhausted[unit].neutralizeExpiresAt = GetElapsedGameTime()
                    + CONFIG.balance.neutralizeDamageIgnoreDuration
                Dummy.applyDummyOrder(player, unit, CONFIG.refs.abilities.neutralize, "thunderbolt")
            end
            -- throttle exhaustion debuff-dummy creation (optimization)
            if
                UnitHasBuffBJ(unit, CONFIG.refs.buffs.dispellMark)
                and (
                    not exhausted[unit].dontUpdateExhaustionDebuffUntil
                    or GetElapsedGameTime() > exhausted[unit].dontUpdateExhaustionDebuffUntil
                )
            then
                Dummy.applyDummyOrder(player, unit, CONFIG.refs.abilities.exhaustion, "acidbomb")
                exhausted[unit].dontUpdateExhaustionDebuffUntil = GetElapsedGameTime()
                    + CONFIG.balance.exhaustionDebuffUpdateDelta
            end
        end
    end
    Unit.applyTimedFloatingText(unit, stacks .. "WS", "purple")
end

--- Add or substract <stacksDelta> stacks of WS, refresh buff duration on add
--- Apply modifiers
--- @param unit unit
--- @param stacksDelta integer
--- @param player player|nil Owner of debuff (required only for positive <stacksDelta> values)
local function applyWeakenedSoulStack(unit, stacksDelta, player)
    if stacksDelta > 0 then
        local mods = modifiers[unit] or {}
        for tag, mod in pairs(mods) do
            local now = GetElapsedGameTime()
            if now > mod.availableAt then
                stacksDelta = stacksDelta + mod.modifier
                modifiers[unit][tag].availableAt = now + mod.cooldown
            end
        end

        local dummy = Dummy.create(player, unit, CONFIG.refs.abilities.main)
        dummyCastQueue[dummy] = stacksDelta
        IssueTargetOrder(dummy, "curse", unit)
    elseif stacksDelta < 0 then
        updateWeakenedSoulState(unit, stacksDelta, player)
    end
end

local function onApplyWeakenedSoulCast()
    -- - ? optimize by bypassing event gets() from trigger service
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    local delta = dummyCastQueue[caster]
    dummyCastQueue[caster] = nil
    updateWeakenedSoulState(target, delta, owner)
end

local function onApplyExhaustionCast()
    local target = GetSpellTargetUnit()
    Timed.call(0.1, function()
        exhausted[target].debuffApplied = true
        UnitAddAbility(target, CONFIG.refs.abilities.exhaustionEffect)
    end)
end

--- Remove 1 WS stack on each attack to enemy mawsworn.
--- @param info damageInfo
local function onDamageToMawsworn(info)
    if not info.isAttack then
        return
    end
    if UnitMeta.factionOf(info.target) ~= UnitMeta.FACTIONS.mawsworn then
        return
    end
    if IsUnitAlly(info.target, GetOwningPlayer(info.source)) then
        return
    end
    applyWeakenedSoulStack(info.source, -1)
end

--- Remove neutralize stun effect when unit is attacked after <balance.neutralizeDamageIgnoreDuration>
--- @param info damageInfo
local function onDamageToNeutralized(info)
    local unit = info.target
    if not exhausted[unit] then
        return
    end
    local neutralizeExpiresAt = exhausted[unit].neutralizeExpiresAt
    if neutralizeExpiresAt and GetElapsedGameTime() > neutralizeExpiresAt then
        UnitRemoveBuffBJ(CONFIG.refs.buffs.neutralize, unit)
        exhausted[unit].neutralizeExpiresAt = nil
    end
end

local function onTimer()
    -- == Exhaustion flush
    local exhaustionFlushQueue = {}
    for unit, _ in pairs(exhausted) do
        -- remove effect ability when debuff fades
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.exhaustion) then
            UnitRemoveAbility(unit, CONFIG.refs.abilities.exhaustionEffect)
            table.insert(exhaustionFlushQueue, unit)
        end
    end
    for _, unit in ipairs(exhaustionFlushQueue) do
        exhausted[unit] = nil
    end

    -- == WS flush
    local flushQueue = {}
    for unit, _ in pairs(memory) do
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.dispellMark) then
            UnitRemoveAbility(unit, CONFIG.refs.abilities.ws)
            table.insert(flushQueue, unit)
        end
    end
    for _, unit in ipairs(flushQueue) do
        memory[unit] = nil
    end
end

--- modifiers

local function addModifier(target, tag, value, cooldown)
    dump("addModifier MODIFIED")
    if not modifiers[target] then
        modifiers[target][tag] = {}
    end
    if not modifiers[target][tag] then
        modifiers[target][tag] =
            { modifier = math.max(0, value), cooldown = cooldown, availableAt = GetElapsedGameTime() }
    end
end

local function removeModifier(target, tag)
    if modifiers[target] and modifiers[target][tag] then
        modifiers[target][tag] = nil
    end
    if not Generic.length(modifiers[target]) then
        modifiers[target] = nil
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onApplyWeakenedSoulCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.exhaustion,
            action = onApplyExhaustionCast,
        },
        {
            trigger = "DAMAGE",
            action = onDamageToMawsworn,
        },
        {
            trigger = "DAMAGE",
            action = onDamageToNeutralized,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.flushDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
    api = {
        applyWeakenedSoulStack = applyWeakenedSoulStack,
        get = getCurrentWsLevel,
        has = function(t)
            return not not memory[t]
        end,
        isExhausted = function(u)
            return not not exhausted[u]
        end,
        modifiers = {
            add = addModifier,
            remove = removeModifier,
        },
    },
}
