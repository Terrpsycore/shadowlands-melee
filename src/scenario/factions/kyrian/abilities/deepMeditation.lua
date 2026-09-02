-- TODO:
-- - percentage regen
-- - make stun instant
local Ids = require("data.ids")
local GetElapsedGameTime = require("scenario.common.timer")
local Dummy = require("utils.dummy")
local dump = require("utils.logger")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.deepMeditation")

local CONFIG = {
    duration = 8,
    damageThreshold = 50,

    abilityId = FourCC(Ids.abilities.deepMeditation),
    stunDummyId = FourCC(Ids.abilities.deepMeditationStunDummy),
    rejuvDummyId = FourCC(Ids.abilities.deepMeditationRejuvDummy),
    buffId = FourCC(Ids.buffs.deepMeditation),
    stunBuffId = FourCC(Ids.buffs.deepMeditationStun),
}

local function removeEffects(target)
    UnitRemoveBuffBJ(CONFIG.buffId, target)
    UnitRemoveBuffBJ(CONFIG.stunBuffId, target)
    Storage:clear(target)
end

local function onCast()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local target = GetSpellTargetUnit()

    if Unit.isManaFull(target) then
        return
    end

    Dummy.applyDummyOrder(owner, target, CONFIG.stunDummyId, "thunderbolt")
    Dummy.applyDummyOrder(owner, target, CONFIG.rejuvDummyId, "rejuvination")
end

local function onDummyCast()
    local target = GetSpellTargetUnit()

    Storage:set(target, "damageReceived", 0)
end

local function onDamage(info)
    if not Storage:have(info.target) then
        return
    end

    local damageReceived = Storage:get(info.target, "damageReceived") + info.damage
    Storage:set(info.target, "damageReceived", damageReceived)

    if damageReceived > CONFIG.damageThreshold then
        removeEffects(info.target)
    end
end

local function onTimer()
    Storage:forEach(function(target)
        dump("onTimer deepMeditation forEach", UnitHasBuffBJ(target, CONFIG.buffId), Unit.isManaFull(target))
        if not UnitHasBuffBJ(target, CONFIG.buffId) then
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
            spellId = CONFIG.abilityId,
            action = onCast,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.stunDummyId,
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
