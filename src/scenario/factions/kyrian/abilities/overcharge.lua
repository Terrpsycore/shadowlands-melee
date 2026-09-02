-- TODO:
-- - single buff effect
-- - check at least 1 mana overflow to overcharge buff
local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local CONFIG = {
    radius = 600,

    abilityId = FourCC(Ids.abilities.overcharge),
    dummyDamageBuffAbilityId = FourCC(Ids.abilities.overchargeDummyDamageBuff),
    dummySpeedBuffAbilityId = FourCC(Ids.abilities.overchargeDummySpeedBuff),
    dummyManaAbilityId = FourCC(Ids.abilities.overchargeManaDummy),
}

local onSpell = function()
    -- dump("overcharge onSpell")
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local level = GetUnitAbilityLevel(caster, CONFIG.abilityId)

    Dummy.applyDummyImmediateOrder(owner, caster, CONFIG.dummyManaAbilityId, 852277, level)
end

local onDummySpell = function()
    -- dump("overcharge onSpell")
    local dummy = GetTriggerUnit()
    local owner = GetOwningPlayer(dummy)
    local level = GetUnitAbilityLevel(dummy, CONFIG.dummyManaAbilityId)

    Timed.call(0.1, function()
        for _, unit in ipairs(Unit.getAllyUnitsInRadius(dummy, CONFIG.radius, Unit.isMech)) do
            dump("overcharge timed", Unit.isManaFull(unit))
            if Unit.isManaFull(unit) then
                Dummy.applyDummyOrder(owner, unit, CONFIG.dummyDamageBuffAbilityId, "innerfire", level)
                Dummy.applyDummyOrder(owner, unit, CONFIG.dummySpeedBuffAbilityId, "bloodlust", level)
            end
        end
    end)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.abilityId,
            action = onSpell,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.dummyManaAbilityId,
            action = onDummySpell,
        },
    },
    config = CONFIG,
}
