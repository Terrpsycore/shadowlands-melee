--[[
-- TODO
-- - ? different damage/root duration for main and secondary targets
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.harpoon,
            dummy = Ids.abilities.harpoonDummy,
            rootUI = Ids.abilities.harpoonRootUI,
        },
        buffs = {
            main = Ids.buffs.harpoon,
            root = Ids.buffs.harpoonRoot,
        },
        units = {
            carrier = { Ids.units.forswornHero, Ids.units.forswornHeroFlying },
        },
    },
    balance = {
        radius = 200,
        rootDuration = 3,
        flushDelta = 0.5,
    },
})

--- @type table<unit, {owner: player, level: integer}>
local memory = {} -- harpoon missiled
--- @type table<unit, {propWindow: number, expiresAt: number}>
local rooted = {}

local function applyEffect(unit)
    rooted[unit] =
        { propWindow = GetUnitPropWindow(unit), expiresAt = GetElapsedGameTime() + CONFIG.balance.rootDuration }
    SetUnitPropWindow(unit, 0)
end

local function removeEffect(unit)
    SetUnitPropWindow(unit, rooted[unit].propWindow)
    UnitRemoveBuffBJ(CONFIG.refs.buffs.root, unit)
    rooted[unit] = nil
end

local function onSpell()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)

    local owner = GetOwningPlayer(caster)

    memory[target] = { owner = owner, level = level }
    Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.rootUI, "acidbomb", level)
    dump("harpoon onSpell save memory", memory)
end

--- @param info damageInfo
local function onAfterDamage(info)
    local source = info.source
    local target = info.target
    dump("harpoon onAfterDamage", memory[target], UnitHasBuffBJ(target, CONFIG.refs.buffs.main))
    Timed.call(0.1, function()
        if memory[target] and UnitHasBuffBJ(target, CONFIG.refs.buffs.main) then
            applyEffect(target)
            local neighbours = Unit.getUnitsInRadius(target, CONFIG.balance.radius, function(u)
                return not IsUnitAlly(u, GetOwningPlayer(source))
            end)
            dump("harpoon Timed.call neighbours", #neighbours)
            for _, unit in
                ipairs(Unit.getUnitsInRadius(target, CONFIG.balance.radius, function(u)
                    return not IsUnitAlly(u, GetOwningPlayer(source))
                end))
            do
                applyEffect(unit)
                Dummy.applyDummyOrder(
                    GetOwningPlayer(source),
                    unit,
                    CONFIG.refs.abilities.dummy,
                    "thunderbolt",
                    memory[target].level
                )
                Dummy.applyDummyOrder(
                    GetOwningPlayer(source),
                    target,
                    CONFIG.refs.abilities.rootUI,
                    "acidbomb",
                    memory[target].level
                )
            end
            memory[target] = nil
        end
    end)
end

local function onTimer()
    for unit, data in pairs(rooted) do
        if GetElapsedGameTime() > data.expiresAt then
            removeEffect(unit)
        end
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
            trigger = "AFTER_DAMAGE",
            filter = { source = CONFIG.refs.units.carrier },
            action = onAfterDamage,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.flushDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
