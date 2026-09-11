-- TODO:
-- - ? filter ally death
local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.surviveWish,
            active = Ids.abilities.surviveWishActive,
        },
        units = {
            carrier = { Ids.units.animate, Ids.units.animateWarrior },
        },
    },
    balance = {},
})

local function onTrain(unit)
    if unit == nil then
        unit = GetTrainedUnit()
    end

    UnitAddAbility(unit, CONFIG.refs.abilities.active)
    IssueImmediateOrder(unit, "berserk")
    UnitRemoveAbility(unit, CONFIG.refs.abilities.active)
end

local function onRevive(info)
    local unit = info.target

    UnitAddAbility(unit, CONFIG.refs.abilities.active)
    IssueImmediateOrder(unit, "berserk")
    UnitRemoveAbility(unit, CONFIG.refs.abilities.active)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onTrain,
        },

        {
            trigger = "REVIVE",
            filter = { target = CONFIG.refs.units.carrier },
            action = onRevive,
        },
    },
    config = CONFIG,
}
