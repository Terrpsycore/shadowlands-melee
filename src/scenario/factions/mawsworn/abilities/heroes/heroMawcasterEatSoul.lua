--[[
TODO:
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Souls = require("scenario.factions.mawsworn.mechanics.souls")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.eatSoul,
            dummy = Ids.abilities.eatSoulRegenTimed,
        },
    },
    balance = {
        radius = 600, -- TODO: connect with data. attributes
    },
})

local function onSpell()
    dump("mawcaster onspell")
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()

    local soul = Souls.api.find({ x = targetX, y = targetY }, CONFIG.balance.radius, { "corpse", "item" })
    if not soul then
        dump("Soul not found")
        return
    end

    local level = GetUnitAbilityLevel(caster, GetSpellAbilityId())

    local activated = Souls.api.use(soul.holderType, soul.holder)
    if not activated then
        dump("Soul activate failed")
        return
    end
    Dummy.applyDummyOrder(owner, caster, CONFIG.refs.abilities.dummy, "rejuvination", level)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
    },
    config = CONFIG,
}
