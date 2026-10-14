-- TODO:
-- - check range from caster, not only from dummy
-- - immunity to "taunt"
-- - adjust numbers in OE and script
-- v 2

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")

local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.glare,
            greater = Ids.abilities.glareGreater,
            debuff = Ids.abilities.glareDebuff,
            vision = Ids.abilities.trueSight,
            reveal = Ids.buffs.glareReveal,
        },
        buffs = {
            main = Ids.abilities.glare,
            reveal = Ids.buffs.piercingGazeReveal,
        },
        units = {
            vision = Ids.units.dummyVision,
        },
    },
    balance = {
        castRange = 1000,
        maxRange = 2000,
        castRangeGreater = 2500,
        maxRangeGreater = 5000,
        wsModifierCooldown = 2,
    },
})

--- @type table<unit,{target: unit, dummy: unit, range: number, bonusWsSince: float}>
local memory = {}
--- @type table<unit,unit[]>
local revealed = {}

local function removeEffect(caster)
    local data = memory[caster]
    local target = data.target

    WS.api.modifiers.remove(target, "glare")
    UnitRemoveBuffBJ(CONFIG.refs.buffs.main, target)
    RemoveUnit(data.dummy)
    memory[caster] = nil

    if revealed[target] then
        Generic.removeValue(revealed[target], caster)
        if #revealed[target] == 0 then
            revealed[target] = nil
        end
    end
end

local function startEffect(owner, caster, target)
    local x, y = Generic.pointXY(target)
    ---@diagnostic disable-next-line: param-type-mismatch
    local dummy = CreateUnit(owner, CONFIG.refs.units.vision, x, y, 270)
    UnitAddAbility(dummy, CONFIG.refs.abilities.vision)
    UnitAddAbility(dummy, CONFIG.refs.abilities.reveal)
    Dummy.issueImmediate(dummy, "ORDER") -- TODO

    memory[caster] = { target = target, dummy = dummy }

    if not revealed[target] then
        revealed[target] = {}
    end
    table.insert(revealed[target], caster)

    WS.api.modifiers.add(target, "glare", 1, CONFIG.balance.wsModifierCooldown) -- TODO: visuals callback
end

local function onCast()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    Timed.call(0.1, function()
        startEffect(owner, caster, target)
    end)
end

local function onCastGreater()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    if not UnitHasBuffBJ(target, CONFIG.refs.buffs.reveal) then
        dump("Target lacks reveal debuff")
        return
    end

    Timed.call(0.1, function()
        startEffect(owner, caster, target)
    end)
end

local function onEndCast()
    local caster = GetTriggerUnit()
    if not memory[caster] then
        return
    end
    removeEffect(caster)
end

local function onTimer()
    for caster, data in pairs(memory) do
        local target = data.target
        local dummy = data.dummy
        local d = Unit.distance(dummy, target)
        if d > CONFIG.balance.maxRange then
            removeEffect(caster)
        else
            local x, y = Generic.pointXY(target)
            SetUnitPosition(dummy, x, y)
        end
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.greater,
            action = onCastGreater,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_ENDCAST",
            spellId = { CONFIG.refs.abilities.main, CONFIG.refs.abilities.greater },
            action = onEndCast,
        },
        { trigger = "TIMER", delta = 0.25, action = onTimer },
    },
    config = CONFIG,
}
