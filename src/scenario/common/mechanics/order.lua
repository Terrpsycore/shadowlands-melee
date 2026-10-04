local AbilityConfig = require("lib.ability.config")

local CONFIG = AbilityConfig.compile({
    refs = {},
    balance = {},
})

local function onAnyOrder()
    dump("order", GetOrderedUnit(), OrderId2String(GetIssuedOrderId()))
end

local function onSpellEffect()
    local abilityId = BlzGetAbilityId(GetSpellAbility())
    dump("onSpellEffect", GetTriggerUnit(), GetAbilityName(abilityId), abilityId, GetSpellTargetUnit())
end

return {
    triggers = {
        { trigger = "ORDER", action = onAnyOrder },
        { trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT", action = onSpellEffect },
    },
    config = CONFIG,
}
