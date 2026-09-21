--[[
TODO:
- WARNING - won't work on undead because of disease cloud hardcode
- check duration (must be almost infinite now); beware infinite spread reapply duration refresh


apply plague buff to target (curse or smth)
add plague cloud OE ability + -armor to target
store disased to memory
timer scan nearby units around diseased
add ability + add to memory

timer check plague cloud buff, remove debuffs if dispelled
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local Storage = require("scenario.storage.corrosivePlague")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.corrosivePlague,
            disease = Ids.abilities.corrosivePlagueSpread,
            debuff = Ids.abilities.corrosivePlagueArmorDebuff,
        },
        buffs = {
            main = Ids.buffs.corrosivePlague,
        },
    },
    balance = {
        spreadRadius = 64,
    },
})

local memory = {}

local function applyDisease(unit, owner)
    -- dump("applyDisease", unit, GetUnitName(unit), unit, GetUnitRace(unit), GetUnitRace(unit) == RACE_UNDEAD)
    if GetUnitAbilityLevel(unit, CONFIG.refs.abilities.disease) == 0 then
        local r1 = UnitAddAbility(unit, CONFIG.refs.abilities.debuff)
        local r2 = UnitAddAbility(unit, CONFIG.refs.abilities.disease)
        -- dump("applyDisease -armor", r1, r2)
        Storage:set(unit, "owner", GetPlayerId(owner))
    end
end

local function cleanseDisease(unit)
    -- dump("cleanseDisease", unit, GetUnitName(unit), unit, GetUnitRace(unit), GetUnitRace(unit) == RACE_UNDEAD)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.debuff)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.disease)
    Storage:drop(unit)
end

local function onSpell()
    local owner = GetOwningPlayer(GetTriggerUnit())
    local target = GetSpellTargetUnit()
    applyDisease(target, owner)
end

local function onTimerSpread()
    Storage:each(function(unit)
        if UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            local owner = Player(Storage:get(unit, "owner")) -- TODO: ensure player N correct
            for _, u in
                ipairs(Unit.getUnitsInRadius(unit, CONFIG.balance.spreadRadius * 2, function(x)
                    return not Storage:has(x)
                        and not IsUnitAlly(x, owner)
                        and not UnitHasBuffBJ(x, CONFIG.refs.buffs.main)
                        and GetUnitRace(x) ~= RACE_UNDEAD
                end))
            do
                applyDisease(u, owner)
            end
        end
    end)
end

local function onTimerCleanse()
    Storage:each(function(unit)
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            cleanseDisease(unit)
        end
    end)
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
        {
            trigger = "TIMER",
            delta = 0.2,
            action = onTimerCleanse,
        },
        {
            trigger = "TIMER",
            delta = 0.5,
            action = onTimerSpread,
        },
    },
    config = CONFIG,
}
