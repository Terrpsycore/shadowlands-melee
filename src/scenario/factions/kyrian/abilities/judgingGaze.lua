-- TODO:
-- - levels
-- - check range before applying onDamage dummy effect
-- - mb add delay between turn on/off and affecting dummy
local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local Storage = require("scenario.storage.autocast")

local CONFIG = {
    -- radius = 600,
    -- cooldown = 5,
    manacost = 10,

    unitId = FourCC(Ids.units.watcher),

    abilityId = FourCC(Ids.abilities.judgingGaze),
    buffId = FourCC(Ids.buffs.judgingGazeEvent),

    dummyMissAbilityId = FourCC(Ids.abilities.judgingGazeMissDebuff),
    dummyArmorAbilityId = FourCC(Ids.abilities.judgingGazeArmorDebuff),
}

local function applyEffect(caster, target)
    dump("onOrbEffect")
    local owner = GetOwningPlayer(caster)
    Dummy.applyDummyOrder(owner, target, CONFIG.dummyMissAbilityId, "curse")
    Dummy.applyDummyOrder(owner, target, CONFIG.dummyArmorAbilityId, "acidbomb")
end

local function onManualUse()
    dump("onManualUse")
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    applyEffect(caster, target)
end

local function onTurnOn()
    local unit = GetTriggerUnit()
    Storage:add(unit)
    dump("onTurnOn ->", Storage:get(unit))
end

local function onTurnOff()
    local unit = GetTriggerUnit()
    Storage:remove(unit)
    dump("onTurnOff ->", Storage:get(unit))
end

local function onDamage(info)
    dump("onDamage ->", Storage:get(info.source), UnitHasBuffBJ(info.target, CONFIG.buffId))
    if Storage:get(info.source) and UnitHasBuffBJ(info.target, CONFIG.buffId) then
        UnitRemoveBuffBJ(CONFIG.buffId, info.target)
        applyEffect(info.source, info.target)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_CAST",
            spellId = CONFIG.abilityId,
            action = onManualUse,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "coldarrows",
            action = onTurnOn,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ISSUED_ORDER",
            order = "uncoldarrows",
            action = onTurnOff,
        },
        {
            trigger = "DAMAGE",
            action = onDamage,
        },
    },
    config = CONFIG,
}
