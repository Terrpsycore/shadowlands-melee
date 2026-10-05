--[[
TODO:
- upgrade reqs
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.overwhelming,
        },
        buffs = {},
        units = {
            carrier = { Ids.units.charredBehemoth },
        },
    },
    balance = {
        radius = 250,
        bonusDamage = 15,
        splashAmount = 0.5,
    },
})

--- @param info damageInfo
local function onDamage(info)
    if not info.isAttack then
        return
    end
    if not GetUnitAbilityLevel(info.source, CONFIG.refs.abilities.main) then
        return
    end
    if Unit.getMaxLife(info.target) > Unit.getMaxLife(info.source) then
        return
    end

    local owner = GetOwningPlayer(info.source)

    info.damage = info.damage + CONFIG.balance.bonusDamage

    for _, target in
        ipairs(Unit.getUnitsInRadius(info.target, CONFIG.balance.radius, function(u)
            return not IsUnitAlly(u, owner)
        end))
    do
        Damage.apply(
            info.source,
            target,
            info.damage * CONFIG.balance.splashAmount,
            false,
            false,
            ATTACK_TYPE_CHAOS,
            DAMAGE_TYPE_NORMAL -- ?
        )
    end
end

return {
    triggers = {
        {
            trigger = "DAMAGE",
            filter = { source = CONFIG.refs.units.carrier },
            action = onDamage,
        },
    },
    config = CONFIG,
}
