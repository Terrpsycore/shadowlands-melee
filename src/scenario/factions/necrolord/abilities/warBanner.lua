local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.warBanner,
            aura = Ids.abilities.warBannerAura,
        },
        units = {
            banner = Ids.units.warBanner,
        },
    },
})

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)

    local x = GetSpellTargetX()
    local y = GetSpellTargetY()

    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    ---@diagnostic disable-next-line: param-type-mismatch
    local banner = CreateUnit(owner, CONFIG.refs.units.banner, x, y, 270)
    SetUnitAbilityLevel(banner, CONFIG.refs.abilities.aura, level)
    Unit.applyTimedLife(banner, 30)
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
