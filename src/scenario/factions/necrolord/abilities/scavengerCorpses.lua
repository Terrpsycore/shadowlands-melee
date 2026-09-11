-- - create corpse on drop
-- - preserve corpse lifetime if not in body banks
-- - ? different storage model (now corpse is PK and it recreates)
-- - ? pause&hide picked corpse, move&show dropped corpse
local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Slugs = require("lib.slugs")
local Items = require("lib.items")
local Unit = require("utils.unit")

local ScavengerStore = require("scenario.storage.scavenger")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            search = Ids.abilities.collectCorpsesSearch,
            collect = Ids.abilities.collectCorpses,
            toggle = Ids.abilities.collectCorpsesToggle,
            drop = Ids.abilities.dropCorpses,
        },
        units = {
            carrier = Ids.units.scavenger,
        },
    },
    balance = {
        radius = 600,
        tickSeconds = 1,
        linkRadius = 275,
    },
})

local function onCollect(unit)
    dump("onCollect run")
    local caster = GetTriggerUnit()
    local corpse = GetSpellTargetUnit()
    local slug = Slugs.unit(GetUnitTypeId(corpse)) -- "steward"
    -- unit handle → corpse item type id
    local itemTypeId = Items.getCorpseItemId(GetUnitTypeId(corpse))
    dump("onCollect GetUnitTypeId(corpse)", GetUnitTypeId(corpse))
    if not itemTypeId then
        dump("onCollect itemTypeId =", itemTypeId)
        -- TODO: error
        return
    end
    UnitAddItem(caster, CreateItem(itemTypeId, GetUnitX(corpse), GetUnitY(corpse)))
end

local function onTrain(unit)
    if unit == nil then
        unit = GetTrainedUnit()
    end
    ScavengerStore:add(unit)
end

local function onDeath(unit)
    if unit == nil then
        unit = GetDyingUnit()
    end
    ScavengerStore:drop(unit)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_CAST",
            spellId = CONFIG.refs.abilities.collect,
            action = onCollect,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onTrain,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_DEATH",
            filter = { target = CONFIG.refs.units.carrier },
            action = onDeath,
        },
    },
    config = CONFIG,
}
