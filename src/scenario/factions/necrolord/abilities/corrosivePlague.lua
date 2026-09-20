--[[
try devotion aura or smth

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

local function applyDisease(unit)
    dump("applyDisease")
    if GetUnitAbilityLevel(unit, CONFIG.refs.abilities.disease) == 0 then
        UnitAddAbility(unit, CONFIG.refs.abilities.disease)
        local r = UnitAddAbility(unit, CONFIG.refs.abilities.debuff)
        dump("applyDisease -armor", r)
        Storage:set(unit, "owner", GetPlayerId(GetOwningPlayer(unit)))
    end
end

local function cleanseDisease(unit)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.disease)
    UnitRemoveAbility(unit, CONFIG.refs.abilities.debuff)
    Storage:drop(unit)
end

local function onSpell()
    local target = GetSpellTargetUnit()
    applyDisease(target)
end

local function onTimer()
    Storage:each(function(unit)
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.main) then
            cleanseDisease(unit)
        else
            local owner = Player(Storage:get(unit, "owner")) -- TODO: ensure player N correct
            for _, u in
                ipairs(Unit.getUnitsInRadius(unit, CONFIG.balance.spreadRadius * 2, function(x)
                    return not Storage:has(x)
                        and not IsUnitAlly(x, owner)
                        and not UnitHasBuffBJ(x, CONFIG.refs.buffs.main)
                end))
            do
                applyDisease(u)
            end
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
            delta = 0.5,
            action = onTimer,
        },
    },
    config = CONFIG,
}
