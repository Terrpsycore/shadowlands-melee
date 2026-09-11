-- cannibalizeSearch
-- Toggle Ability
-- use storage
-- check GetIssuedOrderId for toggle on off

-- TODO:
-- - BUG - "eat corpse" tmp ability doesn't remove after eating (only after moving)
-- - store corpses which start being cannibalized - prevent glitches when 2 units try to eat same corpse
-- - remove controlstore
-- - remove cannibalism on spell finish (exists?)
-- - bug: glitch if unit just died - trigger provoked, but cannibalism doesn't work

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local removeControl = require("scenario.common.control")
local Type = require("utils.type")
local Unit = require("utils.unit")

local ControlStore = require("scenario.storage.control")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.cannibalizeSearch,
            phase = Ids.abilities.phase,
            cannibalize = Ids.abilities.cannibalize,
        },
    },
    balance = {
        radius = 600,
        searchRadiusPoint = 300,
        cooldown = 5,
        requiredUpgradeId = nil,
    },
})

local state = {}
local isOrdering = false

local function searchCorpse(unit, x, y)
    local targetCorpse = Unit.getNearestCorpse(unit, CONFIG.balance.searchRadiusPoint)
    if targetCorpse == nil then
        return
    end

    local cX = GetUnitX(targetCorpse)
    local cY = GetUnitY(targetCorpse)

    local order = function()
        if Unit.isAtPoint(unit, cX, cY, 16) then
            UnitRemoveAbility(unit, CONFIG.refs.abilities.main)
            UnitAddAbility(unit, CONFIG.refs.abilities.cannibalize)
            if GetUnitState(unit, UNIT_STATE_LIFE) >= BlzGetUnitMaxHP(unit) - 1 then
                SetUnitState(unit, UNIT_STATE_LIFE, BlzGetUnitMaxHP(unit) - 5)
            end
            IssueImmediateOrder(unit, "cannibalize")
            ControlStore:drop(unit)
            state[unit] = nil
        else
            IssuePointOrder(unit, "move", cX, cY)
        end
    end

    ControlStore:add(unit)

    UnitAddAbility(unit, CONFIG.refs.abilities.phase)
    IssueImmediateOrder(unit, "windwalk")
    UnitRemoveAbility(unit, CONFIG.refs.abilities.phase)

    state[unit] = state[unit] or {}
    state[unit].state = "uncontrollable"
    state[unit].order = order

    order()

    return targetCorpse
end

local function onCannibalize()
    local unit = GetTriggerUnit()
    state[unit] = state[unit] or {}
    state[unit].state = "cannibalizing"
end

local function onSearchCast()
    local unit = GetTriggerUnit()
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()
    searchCorpse(unit, targetX, targetY)
end

local function issueUncontrollableOrder(unit)
    local order = state[unit].order
    if order then
        isOrdering = true
        order()
        isOrdering = false
    end
end

local function issueUncontrollableOrders()
    for unit, _ in pairs(state) do
        issueUncontrollableOrder(unit)
    end
end

local function onAnyOrder()
    if not state[GetTriggerUnit()] then
        return
    end
    if isOrdering then
        return
    end
    local unit = GetTriggerUnit()
    if state[unit].state == "uncontrollable" then
        issueUncontrollableOrders()
    elseif state[unit].state == "cannibalizing" then
        UnitRemoveAbility(unit, CONFIG.refs.abilities.cannibalize)
        UnitAddAbility(unit, CONFIG.refs.abilities.main)
        BlzSetUnitAbilityCooldown(unit, CONFIG.refs.abilities.main, 1, CONFIG.balance.cooldown)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSearchCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.cannibalize,
            action = onCannibalize,
        },
        { trigger = "ORDER", action = onAnyOrder },
        { trigger = "TIMER", delta = 0.05, action = issueUncontrollableOrders },
    },
    config = CONFIG,
}
