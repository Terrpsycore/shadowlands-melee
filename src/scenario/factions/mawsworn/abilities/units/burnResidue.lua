-- TODO:
-- - BUG: burned enemy dies without giving exp -> replace with triggered DoT

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")

local Souls = require("scenario.factions.mawsworn.mechanics.souls")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.burnResidue,
            dummy = Ids.abilities.burnResidueDummy,
        },
    },
    balance = {
        searchRadiusPoint = 300,
    },
})

local function onCast()
    local unit = GetTriggerUnit()
    local owner = GetOwningPlayer(unit)
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()

    local soul = Souls.api.find(
        { x = targetX, y = targetY },
        CONFIG.balance.searchRadiusPoint,
        { "orphan", "corpse", "item" }
    )
    if not soul then
        dump("No soul found")
        return
    end

    local x, y
    if soul.holderType == "item" then
        ---@diagnostic disable-next-line: param-type-mismatch -- TODO: remove
        local holderUnit = Souls.api.holder.get(soul.holder)
        if not holderUnit then
            dump("Invalid item holder")
            return
        end
        x, y = Generic.pointXY(holderUnit)
    else
        x, y = Generic.pointXY(soul.holder)
    end
    local point = { x = x, y = y }

    Dummy.applyDummyImmediateOrder(owner, point, CONFIG.refs.abilities.dummy, "howlofterror")
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onCast,
        },
    },
    config = CONFIG,
}
