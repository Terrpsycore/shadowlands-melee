-- TODO
-- - hard cancelled like starfall (doesn't cancel on move)
-- - make aura apply instantly
local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.lastStand")

local CONFIG = {
    radius = 600,

    abilityId = FourCC(Ids.abilities.lastStand),
    auraAbilityId = FourCC(Ids.abilities.lastStandAura),
    healAbilityId = FourCC(Ids.abilities.lastStandHealDummy),
    buffId = FourCC(Ids.buffs.lastStand),

    healOrder = 852273, -- TODO: find order id dumping it with listener event
}

local function onChannelStart()
    local caster = GetTriggerUnit()
    UnitAddAbility(caster, CONFIG.auraAbilityId)
end

local function onChannelEnd()
    local caster = GetTriggerUnit()
    UnitRemoveAbility(caster, CONFIG.auraAbilityId)
    local dummy = Dummy.create(
        GetOwningPlayer(caster),
        caster,
        CONFIG.healAbilityId,
        GetUnitAbilityLevel(caster, CONFIG.abilityId)
    )
    IssueImmediateOrderById(dummy, CONFIG.healOrder)
    Storage:set(dummy, "caster", caster)
end

local function onHeal()
    local dummy = GetTriggerUnit()
    local caster = Storage:get(dummy, "caster")
    UnitRemoveAbility(caster, CONFIG.auraAbilityId)
    Storage:clear(dummy)
    for _, target in ipairs(Unit.getAllyUnitsInRadius(caster, 600)) do
        UnitRemoveBuffBJ(CONFIG.buffId, target)
    end
end

local function onDamage(info)
    if not UnitHasBuffBJ(info.target, CONFIG.buffId) then
        return
    end
    local life = GetUnitState(info.target, UNIT_STATE_LIFE)
    if life - info.damage < 1 then
        info.damage = math.max(0, life - 1)
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.abilityId,
            action = onChannelStart,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_ENDCAST",
            spellId = CONFIG.abilityId,
            action = onChannelEnd,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.healAbilityId,
            action = onHeal,
        },
        {
            trigger = "DAMAGE",
            action = onDamage,
        },
    },
    config = CONFIG,
}
