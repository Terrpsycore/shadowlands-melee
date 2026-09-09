-- TODO
-- - review storage
-- - ? onTargetDeath - dummy AA slow to X nearby enemies; remove spirits
-- - refactor dummy immediate order
-- - test 2+ ability level

local Ids = require("data.ids")
local AbilityConfig = require("scenario.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local Storage = require("scenario.storage.memoryPeer")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.memoryPeer,
            summon = Ids.abilities.memoryPeerSummon,
            slow = Ids.abilities.memoryPeerSlow,
        },
        buffs = {
            main = Ids.buffs.memoryPeer,
        },
        units = {
            spirit = Ids.units.memorySpirit,
            dummyAttack = Ids.units.dummyAttack,
        },
    },
})

local isOrdering = false

local function orderAttack(spirit)
    local target = Storage:get(spirit, "unit")
    if not target or not Unit.isAlive(target) then
        return
    end
    isOrdering = true
    IssueTargetOrder(spirit, "attack", target)
    isOrdering = false
end

local function onSpell()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    if not target then
        return
    end

    local owner = GetOwningPlayer(caster)
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)
    Dummy.applyDummyAttack(owner, target, CONFIG.refs.abilities.slow, level)

    local dummy = Dummy.create(owner, target, CONFIG.refs.abilities.summon, level)
    Storage:set(dummy, "unit", target)
    IssueImmediateOrder(dummy, "spiritwolf")
end

local function onSummoned()
    local spirit = GetSummonedUnit()
    local target = Storage:get(GetSummoningUnit(), "unit")
    if not target then
        return
    end
    Storage:set(spirit, "unit", target)
    Storage:set(target, "summonsLeast", Storage:get(target, "summonsLeast") + 1)
    orderAttack(spirit)
end

local function onOrder()
    if isOrdering then
        return
    end
    local unit = GetTriggerUnit()
    if GetUnitTypeId(unit) ~= AbilityConfig.unitId(CONFIG.refs.units.spirit) then
        return
    end
    if not Storage:have(unit) then
        return
    end
    orderAttack(unit)
end

local function onDeath()
    local spirit = GetDyingUnit()
    local target = Storage:get(spirit, "unit")
    Storage:clear(spirit)
    if not target then
        return
    end
    local left = Storage:get(target, "summonsLeast") - 1
    Storage:set(target, "summonsLeast", left)
    if left <= 0 then
        UnitRemoveBuffBJ(CONFIG.refs.buffs.main, target)
        Storage:clear(target)
    end
end

local function afterDummyAttack(info)
    RemoveUnit(info.source)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SUMMON",
            filter = { target = CONFIG.refs.units.spirit },
            action = onSummoned,
        },
        {
            trigger = "ORDER",
            action = onOrder,
        },
        {
            trigger = "DAMAGE",
            filter = { source = CONFIG.refs.units.dummyAttack },
            action = afterDummyAttack,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.spirit },
            action = onDeath,
        },
    },
    config = CONFIG,
}
