--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.ammunitionControl,
            selfBuff = Ids.abilities.ammunitionControlBuff,
            bonusDamage = Ids.abilities.ammunitionControlBonusDamage,
            bonusArmor = Ids.abilities.ammunitionControlBonusArmor,
        },
        buffs = {
            main = Ids.buffs.ammunitionControl,
        },
        units = {
            carrier = Ids.units.bonesmith,
        },
    },
    balance = {
        radius = 600,
        flushDelta = 0.2,
    },
})

local memory = {} -- todo: save/load persistence

local function onTrain()
    local target = GetTrainedUnit()

    local bonesmiths = Unit.getAllyUnitsInRadius(target, CONFIG.balance.radius, function(u)
        return GetUnitTypeId(u) == CONFIG.refs.units.carrier
    end)
    local caster
    local maxLevel
    for _, bonesmith in ipairs(bonesmiths) do
        local level = GetUnitAbilityLevel(bonesmith, CONFIG.refs.abilities.main)
        if level > 0 and (not maxLevel or level > maxLevel) then
            caster = bonesmith
            maxLevel = level
        end
    end
    if caster == nil then
        return
    end

    local level = maxLevel
    if level > 0 then
        -- visible buff
        UnitAddAbility(target, CONFIG.refs.abilities.selfBuff)
        SetUnitAbilityLevel(target, CONFIG.refs.abilities.selfBuff, level)
        IssueImmediateOrder(target, "berserk")
        UnitRemoveAbility(target, CONFIG.refs.abilities.selfBuff)
        -- passive bonuses
        UnitAddAbility(target, CONFIG.refs.abilities.bonusDamage)
        UnitAddAbility(target, CONFIG.refs.abilities.bonusArmor)
        SetUnitAbilityLevel(target, CONFIG.refs.abilities.bonusDamage, level)
        SetUnitAbilityLevel(target, CONFIG.refs.abilities.bonusArmor, level)
        table.insert(memory, target)
    end
end

local function onTimer()
    for i = #memory, 1, -1 do
        local unit = memory[i]
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            UnitRemoveAbility(unit, CONFIG.refs.abilities.bonusDamage)
            UnitRemoveAbility(unit, CONFIG.refs.abilities.bonusArmor)
            table.remove(memory, i)
        end
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_TRAIN_FINISH",
            action = onTrain,
        },
        {
            trigger = "TIMER",
            delta = CONFIG.balance.flushDelta,
            action = onTimer,
        },
    },
    config = CONFIG,
}
