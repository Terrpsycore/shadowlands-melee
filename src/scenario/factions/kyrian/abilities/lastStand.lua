-- TODO
-- - hard cancelled like starfall (doesn't cancel on move)
-- - make aura apply instantly
local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.lastStand")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.lastStand,
            aura = Ids.abilities.lastStandAura,
            heal = Ids.abilities.lastStandHealDummy,
        },
        buffs = {
            main = Ids.buffs.lastStand,
        },
    },
    balance = {
        radius = 600,
        healOrder = 852273, -- TODO: find order id dumping it with listener event
    },
})

local function onChannelStart()
    local caster = GetTriggerUnit()
    UnitAddAbility(caster, CONFIG.refs.abilities.aura)
end

local function onChannelEnd()
    local caster = GetTriggerUnit()
    UnitRemoveAbility(caster, CONFIG.refs.abilities.aura)
    local dummy = Dummy.create(
        GetOwningPlayer(caster),
        caster,
        CONFIG.refs.abilities.heal,
        GetUnitAbilityLevel(caster, CONFIG.refs.abilities.main)
    )
    IssueImmediateOrderById(dummy, CONFIG.balance.healOrder)
    Storage:set(dummy, "caster", caster)
end

local function onHeal()
    local dummy = GetTriggerUnit()
    local caster = Storage:get(dummy, "caster")
    UnitRemoveAbility(caster, CONFIG.refs.abilities.aura)
    Storage:drop(dummy)
    for _, target in ipairs(Unit.getAllyUnitsInRadius(caster, CONFIG.balance.radius)) do
        UnitRemoveBuffBJ(CONFIG.refs.buffs.main, target)
    end
end

local function onDamage(info)
    if not UnitHasBuffBJ(info.target, CONFIG.refs.buffs.main) then
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
            spellId = CONFIG.refs.abilities.main,
            action = onChannelStart,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_ENDCAST",
            spellId = CONFIG.refs.abilities.main,
            action = onChannelEnd,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.heal,
            action = onHeal,
        },
        {
            trigger = "DAMAGE",
            action = onDamage,
        },
    },
    config = CONFIG,
}
