--[[
-- ? include all ground-fly units
-- ? maybe use on/off version of Channel ability instead of memory<>
-- handle units with default flying state
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            forsworn = Ids.abilities.forswornHeroFly,
            forswornInstant = Ids.abilities.forswornHeroFlyInstant,
        },
        buffs = {},
        units = {
            carrier = { Ids.units.forswornHero, Ids.units.forswornHeroFlying },
        },
        items = {},
    },
    balance = {
        --
    },
})

-- MAPPING = {}

--- @type table<unit, {flying: boolean}>
local memory = {} -- TODO: save/load

--- Default: false
local function getFlyingState(unit)
    if not memory[unit] then
        memory[unit] = {
            flying = false,
        }
    end
    return memory[unit].flying
end

local function updateFlyingState(unit, status)
    if not memory[unit] then
        memory[unit] = {}
    end
    local order
    if status then
        order = "ravenform"
    else
        order = "unravenform"
    end
    local success = IssueImmediateOrder(unit, order)
    dump("IssueImmediateOrder", status, order, order, success)
    if success or Unit.isFlying(unit) == status then
        memory[unit].flying = status
    end
    return success
end

local function toggleFlyingState(unit)
    updateFlyingState(unit, not getFlyingState(unit))
end

local function onFlyToggle()
    local unit = GetTriggerUnit()
    dump("fly state before", unit, getFlyingState(unit))
    toggleFlyingState(unit)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_FINISH",
            spellId = CONFIG.refs.abilities.forsworn,
            action = onFlyToggle,
        },
    },
    config = CONFIG,
    api = {
        get = getFlyingState,
        set = updateFlyingState,
    },
}
