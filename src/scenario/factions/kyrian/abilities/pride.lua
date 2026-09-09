-- todo: handle revive, etc.
local Ids = require("data.ids")
local AbilityConfig = require("scenario.config")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local PrideStore = require("scenario.storage.pride")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.pride,
            damage = Ids.abilities.prideDamage,
        },
        units = {
            dummy = Ids.units.dummy,
            carrier = Ids.units.larion,
        },
    },
    balance = {
        radius = 600,
        tickSeconds = 1,
        maxStacks = 5,
        adPerStack = 4,
    },
})

local function isCountable(host, other)
    if other == host then
        return false
    end
    if not Unit.isAlive(other) then
        return false
    end
    if GetUnitTypeId(other) == AbilityConfig.unitId(CONFIG.refs.units.dummy) then
        return false
    end
    if IsUnitType(other, UNIT_TYPE_STRUCTURE) then
        return false
    end
    return true
end

--- raw стаки: может быть < 0; кап 5 не здесь
local function countStacks(unit)
    local selfHp = BlzGetUnitMaxHP(unit)
    local raw = 0
    for _, other in ipairs(Unit.getUnitsInRadius(unit, CONFIG.balance.radius)) do
        if isCountable(unit, other) then
            if BlzGetUnitMaxHP(other) < selfHp then
                raw = raw + 1
            else
                raw = raw - 1
            end
        end
    end
    return raw
end

local function effectiveStacks(raw)
    if raw <= 0 then
        return 0
    end
    if raw > CONFIG.balance.maxStacks then
        return CONFIG.balance.maxStacks
    end
    return raw
end

local function applyPride(unit)
    local stacks = effectiveStacks(countStacks(unit))
    UnitRemoveAbility(unit, CONFIG.refs.abilities.damage)
    if stacks > 0 then
        UnitAddAbility(unit, CONFIG.refs.abilities.damage)
        SetUnitAbilityLevel(unit, CONFIG.refs.abilities.damage, stacks)
    end
end

local function onTick()
    PrideStore:forEach(function(unit)
        if Unit.isAlive(unit) then
            applyPride(unit)
        end
    end)
end

local function onTrain(unit)
    if unit == nil then
        unit = GetTrainedUnit()
    end
    PrideStore:add(unit)
end

local function onDeath(unit)
    if unit == nil then
        unit = GetDyingUnit()
    end
    PrideStore:remove(unit)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onTrain,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDeath,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.tickSeconds,
            action = onTick,
        },
    },
    config = CONFIG,
    countStacks = countStacks,
    effectiveStacks = effectiveStacks,
    debug = {
        onTrain = onTrain,
        onDeath = onDeath,
        applyPride = applyPride,
    },
}
