local AbilityConfig = require("lib.ability.config")

local CONFIG = AbilityConfig.compile({
    refs = {},
    balance = {},
})

--- @param info damageInfo
local function onAfterDamage(info)
    local r, g, b
    if info.isAttack then
        r, g, b = 100, 100, 100
    elseif info.isSpell then
        r, g, b = 85, 45, 100
    else
        return
    end

    local text = CreateTextTagUnitBJ(string.format("%.0f!", info.damage), info.target, 0, 10, r, g, b, 0)
    SetTextTagVelocityBJ(text, 64, 90)
    SetTextTagPermanent(text, false)
    SetTextTagLifespan(text, 2.0)
    SetTextTagFadepoint(text, 1.5)
end

return {
    triggers = {
        {
            trigger = "AFTER_DAMAGE",
            action = onAfterDamage,
        },
    },
    config = CONFIG,
}
