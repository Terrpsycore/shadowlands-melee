--[[
-- TODO
-- - hide forge train buttons
-- - on soul drop -> ...
-- - TEST
-- - TRAIN triggers filters (optimize, refactor)
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            cloak = Ids.abilities.soulforgeForgeCloak,
            gauntlets = Ids.abilities.soulforgeForgeGauntlets,
            spikedArmor = Ids.abilities.soulforgeForgeSpikedArmor,
        },
        buffs = {},
        items = {
            soul = Ids.items.soul,
            cloak = Ids.items.soulforgedCloak,
            gauntlets = Ids.items.soulforgedGauntlets,
            spikedArmor = Ids.items.soulforgedSpikedArmor,
        },
        units = {
            cloak = Ids.units.soulforgeCloak,
            gauntlets = Ids.units.soulforgeGauntlets,
            spikedArmor = Ids.units.soulforgeSpikedArmor,
        },
    },
    balance = {
        -- tickDelta = 1,
    },
})

local abilitiesMap = Generic.reverseTable(CONFIG.refs.abilities)
-- local trainMap = Generic.reverseTable(CONFIG.refs.units)

--- @param forge unit
--- @return item[]
local function getSouls(forge)
    return Unit.findItems(forge, function(i)
        return GetItemTypeId(i) == CONFIG.refs.items.soul
    end, true)
end

local function onSpell()
    dump("mawcaster onspell")
    local building = GetTriggerUnit()
    local ability = GetSpellAbility()

    local abilitySlug = abilitiesMap[BlzGetAbilityId(ability)]
    local trainOrder = CONFIG.refs.units[abilitySlug]
    ---@diagnostic disable-next-line: param-type-mismatch -- TODO: remove
    IssueImmediateOrderById(building, trainOrder)
end

local function onTrainStart()
    dump("onTrainStart() start")
    local building = GetTriggerUnit()

    if #getSouls(building) < 3 then
        dump("Not enough souls")
        IssueImmediateOrderById(building, 851976)
        return
    end
end

local function onTrainFinish()
    dump("onTrainFinish() start")
    local building = GetTriggerUnit()
    local owner = GetOwningPlayer(building)
    local trained = GetTrainedUnit()

    local itemTypeId = CONFIG.refs.items[GetUnitTypeId(trained)]
    RemoveUnit(trained)

    local souls = getSouls(building)

    if #souls < 3 then
        dump("Not enough souls")
        return
    end

    for i = 1, 3 do
        RemoveItem(souls[i])
    end

    UnitAddItemById(building, itemTypeId)

    dump("onTrainFinish() end")
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = {
                CONFIG.refs.abilities.forgeCloak,
                CONFIG.refs.abilities.forgeGauntlets,
                CONFIG.refs.abilities.forgeSpikedArmor,
            },
            action = onSpell,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_START",
            action = onTrainStart,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            action = onTrainFinish,
        },
    },
    config = CONFIG,
}
