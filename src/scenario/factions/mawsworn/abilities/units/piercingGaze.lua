--[[
TODO:
-- - map borders collision check
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.piercingGaze,
            dummyVision = Ids.abilities.piercingGazeDummyVision,
            glareGreater = Ids.abilities.glareGreater,
        },
        buffs = {
            reveal = Ids.buffs.piercingGazeReveal,
        },
        units = {
            vision = Ids.units.dummyVisionShort,
        },
    },
    balance = {
        timerDelta = 0.5,
        distance = 3000,
        radius = 100,
    },
})

--- @type table<unit, boolean>
local memory = {} -- TODO: save/load

--- @param owner player
--- @param startX number
--- @param startY number
--- @param targetX number
--- @param targetY number
--- @param totalDistance number
--- @param radius number
function revealLineInstant(owner, startX, startY, targetX, targetY, totalDistance, radius)
    local angleInRadians = math.atan(targetY - startY, targetX - startX)

    local duration = 3.0
    local stepDistance = radius * 1.5
    local currentDistance = 0.0

    local someoneFound = false

    while currentDistance < totalDistance do
        local currentX = startX + currentDistance * math.cos(angleInRadians)
        local currentY = startY + currentDistance * math.sin(angleInRadians)
        local point = { x = currentX, y = currentY }

        local modifier = CreateFogModifierRadius(owner, FOG_OF_WAR_VISIBLE, currentX, currentY, radius, true, false)
        FogModifierStart(modifier)

        local dummy = Dummy.create(owner, point, CONFIG.refs.abilities.dummyVision, 1, CONFIG.refs.units.vision)
        Dummy.issueImmediate(dummy, "ORDER")

        if Unit.getNearestUnit(point, radius, function(u)
            return not IsUnitAlly(u, owner)
        end) then
            someoneFound = true
        end

        Timed.call(duration, function()
            DestroyFogModifier(modifier)
        end)

        currentDistance = currentDistance + stepDistance
    end

    return someoneFound
end

local function onGreaterGlareBreak()
    local caster = GetTriggerUnit()
    if GetUnitAbilityLevel(caster, CONFIG.refs.abilities.glareGreater) then
        UnitRemoveAbility(caster, CONFIG.refs.abilities.glareGreater)
        UnitAddAbility(caster, CONFIG.refs.abilities.main)
    end
end

local function onGaze()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local cX, cY = Generic.pointXY(caster)
    local tX = GetSpellTargetX()
    local tY = GetSpellTargetY()

    local someoneFound = revealLineInstant(owner, cX, cY, tX, tY, CONFIG.balance.distance, CONFIG.balance.radius)
    if someoneFound then
        UnitRemoveAbility(caster, CONFIG.refs.abilities.main)
        UnitAddAbility(caster, CONFIG.refs.abilities.glareGreater)
        Timed.call(5, function()
            if GetUnitAbilityLevel(caster, CONFIG.refs.abilities.glareGreater) then
                UnitRemoveAbility(caster, CONFIG.refs.abilities.glareGreater)
                UnitAddAbility(caster, CONFIG.refs.abilities.main)
            end
        end)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onGaze,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_ENDCAST",
            spellId = CONFIG.refs.abilities.glareGreater,
            action = onGreaterGlareBreak,
        },
    },
    config = CONFIG,
}
