--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.frenzyPotion")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            explosivePotion = Ids.abilities.concoctPotionExplosive,
            healPotion = Ids.abilities.concoctPotionHealing,
            frenzyPotion = Ids.abilities.concoctPotionFrenzy,
            --
            explosiveOrder = Ids.abilities.concoctedExplosionActive,
            healingOrder = Ids.abilities.concoctedHealingActive,
            frenzyOrder = Ids.abilities.concoctedFrenzyActive,
            --
            explosionDummy = Ids.abilities.concoctedExplosionDummy,
            healStunDummy = Ids.abilities.concoctedHealingStunDummy,
            healDummy = Ids.abilities.concoctedHealingRejuvDummy,
            frenzyPassive = Ids.abilities.concoctedFrenzyPassiveDoom,
        },
        buffs = {
            --
        },
        units = {
            --
        },
        items = {
            explosive = Ids.items.explosivePotion,
            healing = Ids.items.healingPotion,
            frenzy = Ids.items.frenzyPotion,
        },
    },
    balance = {
        frenzyDoomMaxLevel = 5,
    },
})

local CONCOCT_TABLE = {
    [CONFIG.refs.abilities.explosivePotion] = CONFIG.refs.items.explosive,
    [CONFIG.refs.abilities.healPotion] = CONFIG.refs.items.healing,
    [CONFIG.refs.abilities.frenzyPotion] = CONFIG.refs.items.frenzy,
}

local function activateExplosivePotion(caster)
    if caster == nil then
        caster = GetTriggerUnit()
    end
    local owner = GetOwningPlayer(caster)
    Dummy.applyDummyImmediateOrder(owner, caster, CONFIG.refs.abilities.explosionDummy, "selfdestruct")
end

local function activateHealingPotion()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    Dummy.applyDummyOrder(owner, caster, CONFIG.refs.abilities.healStunDummy, "thunderbolt")
    Dummy.applyDummyOrder(owner, caster, CONFIG.refs.abilities.healDummy, "rejuvination")
end

local function activateFrenzyPotion()
    local caster = GetTriggerUnit()
    UnitAddAbility(caster, CONFIG.refs.abilities.frenzyPassive)
    Storage:add(caster)
end

local function onConcoct()
    local target = GetSpellTargetUnit()
    local spellId = GetSpellAbilityId()

    local position = Unit.getPosition(target)

    local itemId = CONCOCT_TABLE[spellId]
    local item = CreateItem(itemId, position.x, position.y)

    UnitAddItem(target, item)
end

local function onDeath()
    local unit = GetDyingUnit()

    if UnitHasItemOfTypeBJ(unit, CONFIG.refs.items.explosive) then
        activateExplosivePotion(unit)
    end
end

local function onTimer()
    -- TODO: beware to keep debuff skill on morph (currently it will drop most likely)
    Storage:each(function(unit)
        SetUnitAbilityLevel(
            unit,
            CONFIG.refs.abilities.frenzyPassive,
            math.min(
                CONFIG.balance.frenzyDoomMaxLevel,
                GetUnitAbilityLevel(unit, CONFIG.refs.abilities.frenzyPassive) + 1
            )
        )
    end)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = {
                CONFIG.refs.abilities.explosivePotion,
                CONFIG.refs.abilities.healPotion,
                CONFIG.refs.abilities.frenzyPotion,
            },
            action = onConcoct,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.explosiveOrder,
            action = activateExplosivePotion,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.healingOrder,
            action = activateHealingPotion,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.frenzyOrder,
            action = activateFrenzyPotion,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            action = onDeath,
        },
        {
            trigger = "TIMER",
            delta = 1,
            action = onTimer,
        },
    },
    config = CONFIG,
}
