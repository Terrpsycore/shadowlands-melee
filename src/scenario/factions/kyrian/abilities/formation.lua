-- todo: handle revive, etc.
-- - visual buff
local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Unit = require("utils.unit")

local PhalynxStore = require("scenario.storage.phalynx")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            speedBuff = Ids.abilities.formationBuffSpeed,
            damageBuff = Ids.abilities.formationBuffDamage,
        },
        units = {
            dummy = Ids.units.dummy,
            carrier = Ids.units.phalynx,
        },
    },
    balance = {
        radius = 600,
        tickSeconds = 1,
        linkRadius = 275,
    },
})

local function setBuff(unit, status)
    if status then
        UnitAddAbility(unit, CONFIG.refs.abilities.damageBuff)
        UnitAddAbility(unit, CONFIG.refs.abilities.speedBuff)
    else
        UnitRemoveAbility(unit, CONFIG.refs.abilities.damageBuff)
        UnitRemoveAbility(unit, CONFIG.refs.abilities.speedBuff)
    end
end

local linkRadius2 = CONFIG.balance.linkRadius * CONFIG.balance.linkRadius

local function dist2(a, b)
    local dx = GetUnitX(a) - GetUnitX(b)
    local dy = GetUnitY(a) - GetUnitY(b)
    return dx * dx + dy * dy
end

local function onTick()
    local units = {}
    PhalynxStore:each(function(unit)
        if Unit.isAlive(unit) then
            units[#units + 1] = unit
        end
    end)
    local n = #units
    local adj = {}
    local deg = {}
    for i = 1, n do
        adj[i] = {}
        deg[i] = 0
    end
    for i = 1, n do
        for j = i + 1, n do
            if dist2(units[i], units[j]) <= linkRadius2 then
                adj[i][#adj[i] + 1] = j
                adj[j][#adj[j] + 1] = i
                deg[i] = deg[i] + 1
                deg[j] = deg[j] + 1
            end
        end
    end
    local inChain = {}
    local queue = {}
    for i = 1, n do
        if deg[i] >= 2 then
            inChain[i] = true
            queue[#queue + 1] = i
        end
    end
    local head = 1
    while head <= #queue do
        local i = queue[head]
        head = head + 1
        for _, j in ipairs(adj[i]) do
            if not inChain[j] then
                inChain[j] = true
                queue[#queue + 1] = j
            end
        end
    end
    for i = 1, n do
        setBuff(units[i], inChain[i] == true)
    end
end

local function onTrain(unit)
    if unit == nil then
        unit = GetTrainedUnit()
    end
    PhalynxStore:add(unit)
end

local function onDeath(unit)
    if unit == nil then
        unit = GetDyingUnit()
    end
    PhalynxStore:drop(unit)
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
    debug = {
        onTrain = onTrain,
        onTick = onTick,
    },
}
