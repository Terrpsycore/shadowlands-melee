-- TODO:
-- - ? filter ally death
local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Unit = require("utils.unit")

local Store = require("scenario.storage.combatExpertise")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.combatExpertise,
            damageBuff = Ids.abilities.combatExpertiseDamage,
            -- TODO: final passive for max level
        },
        units = {
            carrier = Ids.units.animateWarrior,
        },
    },
    balance = {
        maxLevel = 5,
        radius = 300,
    },
})

local function updateAbility(unit, level)
    if GetUnitAbilityLevel(unit, CONFIG.refs.abilities.damageBuff) < 1 then
        UnitAddAbility(unit, CONFIG.refs.abilities.damageBuff)
    end
    SetUnitAbilityLevel(unit, CONFIG.refs.abilities.damageBuff, level)
end

local function onDeath(unit)
    if unit == nil then
        unit = GetDyingUnit()
    end

    if GetUnitTypeId(unit) == CONFIG.refs.units.carrier then
        Store:clear(unit)
        return
    end

    local nearbyAnimates = Unit.getUnitsInRadius(unit, CONFIG.balance.radius, function(u)
        return GetUnitTypeId(u) == CONFIG.refs.units.carrier
    end)
    for _, carrier in ipairs(nearbyAnimates) do
        if not Store:have(carrier) then
            Store:set(carrier, "buffLevel", 0)
            Store:set(carrier, "frags", 0)
        end
        local stat = Store:open(carrier)
        if stat and stat.buffLevel < CONFIG.balance.maxLevel then
            stat.frags = stat.frags + 1
            local newLevel = math.min(stat.frags // 2, CONFIG.balance.maxLevel)
            if newLevel > stat.buffLevel then
                stat.buffLevel = newLevel
                updateAbility(carrier, stat.buffLevel)
            end
        end
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            action = onDeath,
        },
    },
    config = CONFIG,
    debug = {
        onDeath = onDeath,
    },
}
