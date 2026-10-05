local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {},
        units = {
            dummy = Ids.units.dummyDispellMeter,
        },
    },
    balance = {
        radius = 600, -- TODO: connect with data. attributes
    },
})

--- @alias dispellMetricsCategory {mp: integer|nil, hp: integer|nil}
--- @alias dispellMeterResult {buff: integer|nil, unit: integer|nil}

--- Dummy abil must heritage Obsidian Destroyer's "Devour Magic", cost 0 mana
--- @param owner player
--- @param order {ability: integer, level: integer|nil, target: unit|Point}
--- @param per {buff: dispellMetricsCategory, unit: dispellMetricsCategory}
--- @param resultCallback function
local function dispellCount(owner, order, per, resultCallback)
    local dummy = Dummy.create(owner, order.target, order.ability, order.level, CONFIG.refs.units.dummy)
    Unit.applyTimedLife(dummy, 10)
    local manaBefore = Unit.getCurrentMana(dummy)
    local x, y = Generic.pointXY(order.target)
    Dummy.issuePoint(dummy, "devourmagic", x, y) -- TODO: check order string
    Timed.call(0.1, function()
        local manaAfter = Unit.getCurrentMana(dummy)
        local manaD = manaAfter - manaBefore
        --- @type dispellMeterResult
        local result = {}
        if per.buff and per.buff.mp then
            result.buff = manaD // per.buff.mp
        end
        if per.unit and per.unit.mp then
            result.unit = manaD // per.unit.mp
        end
        -- RemoveUnit(dummy)
        resultCallback(result)
    end)
end

return {
    triggers = {},
    api = {
        count = dispellCount,
    },
}
