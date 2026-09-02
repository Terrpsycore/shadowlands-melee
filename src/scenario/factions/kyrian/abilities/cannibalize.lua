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
local removeControl = require("scenario.common.control")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local ControlStore = require("scenario.storage.control")

local CONFIG = {
    radius = 600,
    cooldown = 5,

    buffId = FourCC(Ids.buffs.defenceProtocol),

    abilityId = FourCC(Ids.abilities.cannibalizeSearch),
    phaseAbilityId = FourCC(Ids.abilities.phase),
    cannibalizeAbilityId = FourCC(Ids.abilities.cannibalize),
    dummyAbilityId = FourCC(Ids.abilities.defenceProtocolBuff),
    requiredUpgradeId = nil,
}

local state = {}
local isOrdering = false

local function searchCorpse(unit, x, y)
    local targetCorpse = nil
    local searchGroup = CreateGroup()
    GroupEnumUnitsInRange(searchGroup, x, y, 300.0, nil)

    -- Ищем первый мертвый юнит (труп) в группе
    ForGroup(searchGroup, function()
        local u = GetEnumUnit()
        if IsUnitDeadBJ(u) and targetCorpse == nil then
            targetCorpse = u
        end
    end)

    if targetCorpse == nil then
        return
    end

    local cX = GetUnitX(targetCorpse)
    local cY = GetUnitY(targetCorpse)

    local onReach = function() end

    local order = function()
        -- dump("cannib action at point", Unit.isAtPoint(unit, cX, cY, 16))
        -- dump("cannib corpse found", targetCorpse)
        if Unit.isAtPoint(unit, cX, cY, 16) then
            UnitRemoveAbility(unit, CONFIG.abilityId)
            UnitAddAbility(unit, CONFIG.cannibalizeAbilityId)
            if GetUnitState(unit, UNIT_STATE_LIFE) >= BlzGetUnitMaxHP(unit) - 1 then
                -- dump("full hp, cannib won't work")
                SetUnitState(unit, UNIT_STATE_LIFE, BlzGetUnitMaxHP(unit) - 5)
            end
            IssueImmediateOrder(unit, "cannibalize")
            -- TODO: check if corpse disappeared
            -- TODO: remove phase buff
            ControlStore:remove(unit)
            state[unit] = nil
        else
            IssuePointOrder(unit, "move", cX, cY)
        end
    end

    ControlStore:add(unit)

    UnitAddAbility(unit, CONFIG.phaseAbilityId)
    IssueImmediateOrder(unit, "windwalk")
    UnitRemoveAbility(unit, CONFIG.phaseAbilityId)

    state[unit] = state[unit] or {}
    state[unit].state = "uncontrollable"
    state[unit].order = order
    -- removeControl(unit, action)

    -- UnitRemoveAbility(unit, CONFIG.phaseAbilityId)

    order()

    -- removecontrol
    -- add phase
    -- use phase
    -- move to corpse point
    -- order cannibalize
    -- return control

    return targetCorpse
end

local function onCannibalize()
    local unit = GetTriggerUnit()
    state[unit] = state[unit] or {}
    state[unit].state = "cannibalizing"
end

-- @
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
    -- dump(GetIssuedOrderId(), OrderId2String(GetIssuedOrderId()))
    if not state[GetTriggerUnit()] then
        return
    end
    if isOrdering then
        return
    end
    local unit = GetTriggerUnit()
    if state[unit].state == "uncontrollable" then
        -- TODO: check - same order shouldn't interrupt
        issueUncontrollableOrders()
    elseif state[unit].state == "cannibalizing" then
        UnitRemoveAbility(unit, CONFIG.cannibalizeAbilityId)
        UnitAddAbility(unit, CONFIG.abilityId)
        BlzSetUnitAbilityCooldown(unit, CONFIG.abilityId, 1, CONFIG.cooldown)
    end
    -- dump("onOrder called")
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.abilityId,
            action = onSearchCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.cannibalizeAbilityId,
            action = onCannibalize,
        },
        { trigger = "ORDER", action = onAnyOrder },
        { trigger = "TIMER", delta = 0.05, action = issueUncontrollableOrders },
    },
    config = CONFIG,
}
