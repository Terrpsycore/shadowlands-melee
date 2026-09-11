-- TODO:
-- - single buff effect
-- - check at least 1 mana overflow to overcharge buff
local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.overcharge,
            damageBuff = Ids.abilities.overchargeDummyDamageBuff,
            speedBuff = Ids.abilities.overchargeDummySpeedBuff,
            manaDummy = Ids.abilities.overchargeManaDummy,
        },
    },
    balance = {
        radius = 600,
        manaOrder = 852277,
    },
})

local onSpell = function()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    Dummy.applyDummyImmediateOrder(owner, caster, CONFIG.refs.abilities.manaDummy, CONFIG.balance.manaOrder, level)
end

local onDummySpell = function()
    local dummy = GetTriggerUnit()
    local owner = GetOwningPlayer(dummy)
    local level = GetUnitAbilityLevel(dummy, CONFIG.refs.abilities.manaDummy)

    Timed.call(0.1, function()
        for _, unit in ipairs(Unit.getAllyUnitsInRadius(dummy, CONFIG.balance.radius, Unit.isMech)) do
            dump("overcharge timed", Unit.isManaFull(unit))
            if Unit.isManaFull(unit) then
                Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.damageBuff, "innerfire", level)
                Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.speedBuff, "bloodlust", level)
            end
        end
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
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.manaDummy,
            action = onDummySpell,
        },
    },
    config = CONFIG,
}
