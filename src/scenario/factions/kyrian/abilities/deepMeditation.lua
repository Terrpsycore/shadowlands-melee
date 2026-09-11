-- TODO:
-- - percentage regen
-- - make stun instant
local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local GetElapsedGameTime = require("scenario.common.timer")
local Dummy = require("utils.dummy")
local dump = require("utils.logger")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.deepMeditation")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.deepMeditation,
            stunDummy = Ids.abilities.deepMeditationStunDummy,
            rejuvDummy = Ids.abilities.deepMeditationRejuvDummy,
        },
        buffs = {
            main = Ids.buffs.deepMeditation,
            stun = Ids.buffs.deepMeditationStun,
        },
    },
    balance = {
        duration = 8,
        damageThreshold = 50,
    },
})

local function removeEffects(target)
    UnitRemoveBuffBJ(CONFIG.refs.buffs.main, target)
    UnitRemoveBuffBJ(CONFIG.refs.buffs.stun, target)
    Storage:drop(target)
end

local function onCast()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    if Unit.isManaFull(target) then
        return
    end

    Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.stunDummy, "thunderbolt")
    Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.rejuvDummy, "rejuvination")
end

local function onDummyCast()
    local target = GetSpellTargetUnit()

    Storage:set(target, "damageReceived", 0)
end

local function onDamage(info)
    if not Storage:has(info.target) then
        return
    end

    local damageReceived = Storage:get(info.target, "damageReceived") + info.damage
    Storage:set(info.target, "damageReceived", damageReceived)

    if damageReceived > CONFIG.balance.damageThreshold then
        removeEffects(info.target)
    end
end

local function onTimer()
    Storage:each(function(target)
        dump("onTimer deepMeditation forEach", UnitHasBuffBJ(target, CONFIG.refs.buffs.main), Unit.isManaFull(target))
        if not UnitHasBuffBJ(target, CONFIG.refs.buffs.main) then
            removeEffects(target)
            return
        end

        if Unit.isManaFull(target) then
            removeEffects(target)
            return
        end
    end)
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
            spellId = CONFIG.refs.abilities.stunDummy,
            action = onDummyCast,
        },
        {
            trigger = "DAMAGE",
            action = onDamage,
        },
        {
            trigger = "TIMER",
            delta = 0.03,
            action = onTimer,
        },
    },
    config = CONFIG,
}
