-- TODO:
-- - levels
-- - check range before applying onDamage dummy effect
-- - mb add delay between turn on/off and affecting dummy
local Ids = require("data.ids")
local AbilityConfig = require("scenario.config")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local Storage = require("scenario.storage.autocast")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.judgingGaze,
            missDebuff = Ids.abilities.judgingGazeMissDebuff,
            armorDebuff = Ids.abilities.judgingGazeArmorDebuff,
        },
        buffs = {
            event = Ids.buffs.judgingGazeEvent,
        },
        units = {
            carrier = Ids.units.watcher,
        },
    },
    balance = {
        manacost = 8,
    },
})

local function applyEffect(caster, target)
    local owner = GetOwningPlayer(caster)
    Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.missDebuff, "curse")
    Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.armorDebuff, "acidbomb")
end

local function onManualUse()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    applyEffect(caster, target)
end

local function onTurnOn()
    local unit = GetTriggerUnit()
    Storage:add(unit)
end

local function onTurnOff()
    local unit = GetTriggerUnit()
    Storage:remove(unit)
end

local function onDamage(info)
    if Storage:get(info.source) and UnitHasBuffBJ(info.target, CONFIG.refs.buffs.event) then
        UnitRemoveBuffBJ(CONFIG.refs.buffs.event, info.target)
        applyEffect(info.source, info.target)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_CAST",
            spellId = CONFIG.refs.abilities.main,
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
