-- todo: handle revive, etc.
-- - visual buff
local Ids = require("data.ids")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local PhalynxStore = require("scenario.storage.phalynx")

local CONFIG = {
    radius = 600,
    tickSeconds = 1,
    buffSpeedId = FourCC(Ids.abilities.formationBuffSpeed),
    buffDamageId = FourCC(Ids.abilities.formationBuffDamage),
    dummyTypeId = FourCC(Ids.units.dummy),
    carrierTypeId = FourCC(Ids.units.phalynx),
}

local function setBuff(unit, status)
    -- dump("formation setBuff", status)
    if status then
        UnitAddAbility(unit, CONFIG.buffDamageId)
        UnitAddAbility(unit, CONFIG.buffSpeedId)
    else
        UnitRemoveAbility(unit, CONFIG.buffDamageId)
        UnitRemoveAbility(unit, CONFIG.buffSpeedId)
    end
end

local RADIUS = 275
local RADIUS2 = RADIUS * RADIUS
local function dist2(a, b)
    local dx = GetUnitX(a) - GetUnitX(b)
    local dy = GetUnitY(a) - GetUnitY(b)
    return dx * dx + dy * dy
end

local function onTick()
    -- dump("onTick formation")
    -- 1) короткий список: только живые из стора
    local units = {}
    PhalynxStore:forEach(function(unit)
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
    -- 2) пары: A-B, A-C, B-C, ...
    for i = 1, n do
        for j = i + 1, n do
            if dist2(units[i], units[j]) <= RADIUS2 then
                adj[i][#adj[i] + 1] = j
                adj[j][#adj[j] + 1] = i
                deg[i] = deg[i] + 1
                deg[j] = deg[j] + 1
            end
        end
    end
    -- 3) зерно: у кого >= 2 соседей, затем «прилипание» по очереди
    local inChain = {}
    local queue = {}
    for i = 1, n do
        if deg[i] >= 2 then
            inChain[i] = true
            queue[#queue + 1] = i
        end
    end
    -- dump("onTick formation #queue", #queue)
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
    -- 4) бонус только если состояние изменилось
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
    PhalynxStore:remove(unit)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            filter = { target = CONFIG.carrierTypeId },
            action = onTrain,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.carrierTypeId },
            action = onDeath,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.tickSeconds,
            action = onTick,
        },
    },
    config = CONFIG,
    debug = {
        onTrain = onTrain,
    },
}
