--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Souls = require("scenario.factions.mawsworn.mechanics.souls")
local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.gorgoa,
        },
        units = {
            soul = Ids.units.gorgoaSoul,
        },
    },
    balance = {
        radius = 600,
        wsApplyDelta = 1,
        soulSpawnDelta = 0.5,
        timerDelta = 0.5,
    },
})

--- @type table<unit, {player: player, facing: number, point: Point, nextWsAt: number, nextSoulAt: number}>
local memory = {}

--- @type table<unit, {x: number, y: number}>
local souls = {} -- remove on max distance

local function spawnSoul(caster)
    local data = memory[caster]

    local f = data.facingRadians
    local s = CONFIG.balance.radius -- Square side length (adjust to your spell size)

    -- Random point on the far edge (behind hero)
    -- Center of far edge: (-cos(f)*s/2, -sin(f)*s/2) relative to hero
    -- Offset along edge: (+sin(f)*rand, -cos(f)*rand)
    local r = GetRandomReal(-s / 2, s / 2)
    local spawnX = data.x - (math.cos(f) * s / 2) + (math.sin(f) * r)
    local spawnY = data.y - (math.sin(f) * s / 2) - (math.cos(f) * r)

    -- Spawn unit facing the hero
    ---@diagnostic disable-next-line: param-type-mismatch
    local soul = CreateUnit(data.player, CONFIG.refs.units.soul, spawnX, spawnY, data.facing)

    -- Charge X units in direction of hero's facing
    local targetX = data.x + (s * 2) * math.cos(f)
    local targetY = data.y + (s * 2) * math.sin(f)
    IssuePointOrder(soul, "move", targetX, targetY)

    Souls.api.store("gorgoa", soul)
end

local function onCastStart()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()

    local facing = GetUnitFacing(caster)
    local facingRadians = math.rad(facing)
    -- local oppositeAngleDeg = facing + 180.0
    -- local oppositeAngleRad = math.rad(oppositeAngleDeg)

    memory[caster] = {
        player = owner,
        facing = facing,
        facingRadians = facingRadians,
        point = { x = targetX, y = targetY },
        nextWsAt = GetElapsedGameTime(),
        nextSoulAt = GetElapsedGameTime(),
        xVector = CONFIG.balance.radius * 2 * math.cos(facingRadians),
        yVector = CONFIG.balance.radius * 2 * math.sin(facingRadians),
    }
end

local function onCastEnd()
    local caster = GetTriggerUnit()
    memory[caster] = nil
end

local function onTimer()
    -- TODO: ? ensure always identical amount of stacks applies by full cast
    local now = GetElapsedGameTime()
    for caster, data in pairs(memory) do
        if now > data.nextWsAt then
            for _, target in
                ipairs(Unit.getUnitsInRadius(data.point, CONFIG.balance.radius, function(t)
                    return not IsUnitAlly(t, data.player)
                end))
            do
                WS.api.applyWeakenedSoulStack(target, 1, data.player)
                data.nextWsAt = GetElapsedGameTime() + CONFIG.balance.wsApplyDelta
            end
        end
        if now > data.nextSoulAt then
            spawnSoul(caster)
            data.nextSoulAt = GetElapsedGameTime() + CONFIG.balance.soulSpawnDelta
        end
    end
end

local function onSoulStop()
    local unit = GetOrderedUnit()
    Souls.api.use("gorgoa", unit)
    souls[unit] = nil
    RemoveUnit(unit)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onCastStart,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_ENDCAST",
            spellId = CONFIG.refs.abilities.main,
            action = onCastEnd,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.timerDelta,
            action = onTimer,
        },
        {
            trigger = "ORDER",
            order = "stop",
            filter = { source = CONFIG.refs.units.soul },
            action = onSoulStop,
        },
    },
    config = CONFIG,
}
