local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")

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

local spawnQueue = {}

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)
    spawnQueue[owner] = { level = level }
end

local function onSpawn()
    local banner = GetEnteringUnit()
    local owner = GetOwningPlayer(banner)
    local data = spawnQueue[owner]
    spawnQueue[owner] = nil
    if not data then
        return
    end

    local level = data.level
    if GetUnitAbilityLevel(banner, CONFIG.refs.abilities.aura) < 1 then
        UnitAddAbility(banner, CONFIG.refs.abilities.aura)
    end
    SetUnitAbilityLevel(banner, CONFIG.refs.abilities.aura, level)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
        {
            trigger = "CREATE",
            filter = { target = CONFIG.refs.units.banner },
            action = onSpawn,
        },
    },
    config = CONFIG,
}
