--[[
-- TODO
-- - refactor removeOrder (larion) + develop gauntlets ability
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local ItemMeta = require("lib.items")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Souls = require("scenario.factions.mawsworn.mechanics.souls")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            cloak = Ids.abilities.soulforgedCloak,
            cloakInvis = Ids.abilities.soulforgedCloakInvis,
            gauntletsFrenzy = Ids.abilities.soulforgedGauntletsFrenzy,
        },
        buffs = {},
        items = {
            cloak = Ids.items.soulforgedCloak,
            gauntlets = Ids.items.soulforgedGauntlets,
            -- spikedArmor = Ids.items.soulforgedSpikedArmor,
        },
        units = {},
    },
    balance = {
        -- cooldown = 2,
        -- maxCapacity = 3,
        gauntletsActivateThreshold = 0.2,
    },
})

local function onCloakActivate()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    local owner = GetOwningPlayer(caster)

    KillUnit(target) -- ally

    Dummy.applyDummyOrder(owner, caster, CONFIG.refs.abilities.cloakInvis, "invisibility")
end

local function onAfterDamage(info)
    if not info.isAttack then
        return
    end
    if not UnitHasItemOfTypeBJ(info.source, CONFIG.refs.items.gauntlets) then
        return
    end
    if not GetUnitStatePercent(info.target, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) > 20 then -- return value format
        return
    end
    UnitAddAbility(info.source, CONFIG.refs.abilities.gauntletsFrenzy)
    IssueImmediateOrder(info.source, "berserk")
    UnitRemoveAbility(info.source, CONFIG.refs.abilities.gauntletsFrenzy)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.cloak,
            action = onCloakActivate,
        },
        {
            trigger = "AFTER_DAMAGE",
            action = onAfterDamage,
        },
    },
    config = CONFIG,
    api = {},
}
