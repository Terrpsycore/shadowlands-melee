--[[
TODO:
-- GC memory/marked
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local WS = require("scenario.factions.mawsworn.mechanics.weakenedSoul")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.deadlyBlow,
            mark = Ids.abilities.deadlyBlowMark,
            stun = Ids.abilities.deadlyBlowStun,
        },
        buffs = {
            mark = Ids.buffs.deadlyBlowMark,
        },
        units = {
            carrier = Ids.units.mournebladeHero,
        },
    },
    balance = {
        radius = 800,
    },
})

--- @type table<unit, {target: unit, expiresAt: number}>
local memory = {} -- TODO: save/load
--- @type table<unit, {level: integer}>
local marked = {}

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    if not memory[caster] then
        dump("Cant activate deadly blow - no last AA target")
        return
    end
    local target = memory[caster].target
    if not Unit.isAlive(target) then
        dump("Cant activate deadly blow - last AA target isnt alive")
        return
    end
    if GetElapsedGameTime() > memory[caster].expiresAt then
        dump("Cant activate deadly blow - last AA expired")
        return
    end
    local d = Unit.distance(caster, target)
    if d > CONFIG.balance.radius then
        dump("Cant activate deadly blow - last AA target too far")
        return
    end

    Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.mark, "acidbomb", level)
    marked[target] = {
        level = level,
    }
end

--- @param info damageInfo
local function onDamage(info)
    if not info.isAttack then
        return
    end
    memory[info.source] = { target = info.target, expiresAt = GetElapsedGameTime() + CONFIG.balance.duration }
    if marked[info.target] then
        local owner = GetOwningPlayer(info.source)
        UnitRemoveBuffBJ(CONFIG.refs.buffs.mark, marked[info.target])
        Dummy.applyDummyOrder(owner, info.target, CONFIG.refs.abilities.stun, "thunderbolt", marked[info.target].level)
        marked[info.target] = nil
    end
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
            filter = {
                source = CONFIG.refs.units.carrier,
            },
            action = onDamage,
        },
    },
    config = CONFIG,
}
