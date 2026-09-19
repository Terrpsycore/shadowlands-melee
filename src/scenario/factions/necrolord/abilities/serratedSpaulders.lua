--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.serratedSpaulders,
            thorns = Ids.abilities.serratedSpauldersThorns,
        },
        buffs = {
            thorns = Ids.buffs.serratedSpaulders,
        },
    },
    balance = {},
})

local memory = {} -- TODO: move to storage // or maybe move level-detect to dummy passive

local function onSpell()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    local spell = GetSpellAbilityId()
    local level = GetUnitAbilityLevel(caster, spell)
    memory[target] = level
end

local function onAttack()
    local target = GetTriggerUnit()
    if not UnitHasBuffBJ(target, CONFIG.refs.buffs.thorns) then
        return
    end
    local unit = GetAttacker()
    local owner = GetOwningPlayer(target)
    Dummy.applyDummyOrder(owner, unit, CONFIG.refs.abilities.thorns, "acidbomb", memory[target])
end

local function onTimer()
    local removeQueue = {}
    for _, unit in pairs(memory) do
        if not UnitHasBuffBJ(unit, CONFIG.refs.buffs.thorns) then
            table.insert(removeQueue, unit)
        end
    end
    for _, unit in ipairs(removeQueue) do
        memory[unit] = nil
    end
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
        {
            trigger = "EVENT_PLAYER_UNIT_ATTACKED",
            action = onAttack,
        },
        {
            trigger = "TIMER",
            delta = 1,
            action = onTimer,
        },
        -- uncomment if DAMAGE hook needed:
        -- {
        --     trigger = "DAMAGE",
        --     filter = { source = CONFIG.refs.units.source },
        --     action = onDamage,
        -- },
    },
    config = CONFIG,
}
