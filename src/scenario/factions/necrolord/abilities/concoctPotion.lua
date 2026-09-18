--[[
TODO:
- timed life for potions
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

-- PotionStorage -- timedlife
local StorageFrenzy = require("scenario.storage.frenzyPotion")
local StorageHealing = require("scenario.storage.healingPotion")
local DeathStorage = require("scenario.storage.death")

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
            healingStun = Ids.buffs.concoctedHealingStun,
            healing = Ids.buffs.concoctedHealingRejuv,
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

local function activateExplosivePotion(owner, caster)
    if caster == nil then
        caster = GetTriggerUnit()
    end
    if owner == nil then
        owner = GetOwningPlayer(caster)
    end

    local dummy = Dummy.create(owner, caster, CONFIG.refs.abilities.explosionDummy)
    IssueTargetOrder(dummy, "selfdestruct", dummy)
end

local function activateHealingPotion()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    Dummy.applyDummyOrder(owner, caster, CONFIG.refs.abilities.healStunDummy, "thunderbolt")
    Dummy.applyDummyOrder(owner, caster, CONFIG.refs.abilities.healDummy, "rejuvination")
    StorageHealing:add(caster)
end

local function activateFrenzyPotion()
    local caster = GetTriggerUnit()
    UnitAddAbility(caster, CONFIG.refs.abilities.frenzyPassive)
    StorageFrenzy:add(caster)
end

local function onConcoct()
    local target = GetSpellTargetUnit()
    local spellId = GetSpellAbilityId()

    local position = Unit.getPosition(target)

    local itemId = CONCOCT_TABLE[spellId]
    local item = CreateItem(itemId, position.x, position.y)

    UnitAddItem(target, item)
end

local function onLethalDamage(info)
    dump("onLethalDamage", UnitHasItemOfTypeBJ(info.target, CONFIG.refs.items.explosive))
    if UnitHasItemOfTypeBJ(info.target, CONFIG.refs.items.explosive) then
        dump("onLethalDamage activateExplosivePotion")
        local owner = Player(DeathStorage:get(info.target, "originalOwner"))
        activateExplosivePotion(owner, info.target)
    end
end

local function onTimer()
    -- TODO: beware to keep debuff skill on morph (currently it will drop most likely)
    StorageFrenzy:each(function(unit)
        SetUnitAbilityLevel(
            unit,
            CONFIG.refs.abilities.frenzyPassive,
            math.min(
                CONFIG.balance.frenzyDoomMaxLevel,
                GetUnitAbilityLevel(unit, CONFIG.refs.abilities.frenzyPassive) + 1
            )
        )
    end)
    StorageHealing:each(function(unit)
        if Unit.isHealthFull() then
            StorageHealing:drop(unit)
        end
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
            trigger = "LETHAL_DAMAGE",
            action = onLethalDamage,
        },
        {
            trigger = "TIMER",
            delta = 1,
            action = onTimer,
        },
    },
    config = CONFIG,
}
