-- todo: handle revive, etc.
local Ids = require("data.ids")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local PrideStore = require("scenario.storage.pride")

local CONFIG = {
    radius = 600,
    tickSeconds = 1,
    maxStacks = 5,
    adPerStack = 4,
    abilityId = FourCC(Ids.abilities.pride),
    damageAbilityId = FourCC(Ids.abilities.prideDamage),
    dummyTypeId = FourCC(Ids.units.dummy),
    carrierTypeId = FourCC(Ids.units.larion),
}

local function isCountable(host, other)
    if other == host then
        return false
    end
    if not Unit.isAlive(other) then
        return false
    end
    if GetUnitTypeId(other) == CONFIG.dummyTypeId then
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
    for _, other in ipairs(Unit.getUnitsInRadius(unit, CONFIG.radius)) do
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
    if raw > CONFIG.maxStacks then
        return CONFIG.maxStacks
    end
    return raw
end

local function applyPride(unit)
    local stacks = effectiveStacks(countStacks(unit))
    UnitRemoveAbility(unit, CONFIG.damageAbilityId)
    if stacks > 0 then
        UnitAddAbility(unit, CONFIG.damageAbilityId)
        SetUnitAbilityLevel(unit, CONFIG.damageAbilityId, stacks)
    end
end

local function onTick()
    -- dump("onTick pride")
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
        EVENT_PLAYER_UNIT_TRAIN_FINISH = {
            unitType = CONFIG.carrierTypeId,
            action = onTrain,
        },
        EVENT_PLAYER_UNIT_DEATH = {
            unitType = CONFIG.carrierTypeId,
            action = onDeath,
        },
        -- on death - clean storage
        TIMER = {
            delta = CONFIG.tickSeconds,
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
