--[[
TODO:
- visual effect for banner shield
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.opressiveBanner,
            aura = Ids.abilities.opressiveBannerAura,
            shield = Ids.abilities.opressiveBannerShield,
        },
        buffs = {
            shield = Ids.buffs.opressiveBannerShield,
        },
        units = {
            banner = Ids.units.opressiveBanner,
        },
    },
    balance = {
        shieldTime = 3,
        shieldCapacity = { 50, 100, 150 },
    },
})

local memory = {} -- todo: save/load
local spawnQueue = {}

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)

    local x = GetSpellTargetX()
    local y = GetSpellTargetY()
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    ---@diagnostic disable-next-line: param-type-mismatch
    local banner = CreateUnit(owner, CONFIG.refs.units.banner, x, y, 270)
    Unit.applyTimedLife(banner, 60)
    UnitAddAbility(banner, CONFIG.refs.abilities.aura)
    UnitAddAbility(banner, CONFIG.refs.abilities.shield)
    SetUnitAbilityLevel(banner, CONFIG.refs.abilities.aura, level)
    SetUnitAbilityLevel(banner, CONFIG.refs.abilities.shield, level)
    memory[banner] = {
        shield = CONFIG.balance.shieldCapacity[level],
    }
end

local function onDamage(info)
    if not memory[info.target] then
        return
    end

    local shield = memory[info.target].shield
    local blocked = math.min(shield, info.damage)

    info.damage = info.damage - blocked

    if blocked >= shield then
        memory[info.target] = nil
    else
        memory[info.target].shield = shield - blocked
    end
end

local function onDeath()
    memory[GetDyingUnit()] = nil
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
        {
            trigger = "DAMAGE",
            filter = { target = CONFIG.refs.units.banner },
            action = onDamage,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.banner },
            action = onDeath,
        },
    },
    config = CONFIG,
}
