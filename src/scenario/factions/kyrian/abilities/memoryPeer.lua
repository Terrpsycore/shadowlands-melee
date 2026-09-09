-- TODO
-- - review storage
-- - ? onTargetDeath - dummy AA slow to X nearby enemies; remove spirits
-- - refactor dummy immediate order
-- - test 2+ ability level

local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local Storage = require("scenario.storage.memoryPeer")

local CONFIG = {
    abilityId = FourCC(Ids.abilities.memoryPeer),
    summonAbilityId = FourCC(Ids.abilities.memoryPeerSummon),
    slowAbilityId = FourCC(Ids.abilities.memoryPeerSlow),
    buffId = FourCC(Ids.buffs.memoryPeer),
    spiritTypeId = FourCC(Ids.units.memorySpirit),
}

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
    local level = GetUnitAbilityLevel(caster, CONFIG.abilityId)
    Dummy.applyDummyAttack(owner, target, CONFIG.slowAbilityId, level)

    local dummy = Dummy.create(owner, target, CONFIG.summonAbilityId, level)
    Storage:set(dummy, "unit", target)
    -- dump("dummy 2 - ", dummy)
    IssueImmediateOrder(dummy, "spiritwolf")
    -- dump("r - ", r)
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
    if GetUnitTypeId(unit) ~= CONFIG.spiritTypeId then
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
        UnitRemoveBuffBJ(CONFIG.buffId, target)
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
            spellId = CONFIG.abilityId,
            action = onSpell,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SUMMON",
            filter = { target = CONFIG.spiritTypeId },
            action = onSummoned,
        },
        {
            trigger = "ORDER",
            action = onOrder,
        },
        {
            trigger = "DAMAGE",
            filter = { source = FourCC(Ids.units.dummyAttack) },
            action = afterDummyAttack,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.spiritTypeId },
            action = onDeath,
        },
    },
    config = CONFIG,
}
