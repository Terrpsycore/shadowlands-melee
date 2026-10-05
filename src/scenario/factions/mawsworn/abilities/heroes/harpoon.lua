--[[
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.harpoon,
            dummy = Ids.abilities.harpoonDummy,
        },
        buffs = {
            main = Ids.buffs.harpoon,
        },
        units = {
            carrier = { Ids.units.forswornHero, Ids.units.forswornHeroFlying },
        },
    },
    balance = {
        radius = 64,
    },
})

--- @type table<unit, {owner: player, level: integer}>
local memory = {}

local function onSpell()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    local level = GetUnitAbilityLevel(caster, CONFIG.refs.abilities.harpoon)
end

--- @param info damageInfo
local function onAfterDamage(info)
    local source = info.source
    local target = info.target
    Timed.call(0.1, function()
        if memory[target] and UnitHasBuffBJ(target, CONFIG.refs.buffs.main) then
            for _, unit in
                ipairs(Unit.getUnitsInRadius(target, CONFIG.balance.radius, function(u)
                    return not IsUnitAlly(u, GetOwningPlayer(source))
                end))
            do
                Dummy.applyDummyOrder(
                    GetOwningPlayer(source),
                    target,
                    CONFIG.refs.abilities.harpoonDummy,
                    "thunderbolt",
                    memory[target].level
                )
            end
            memory[target] = nil
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
            trigger = "AFTER_DAMAGE",
            filter = { source = CONFIG.refs.units.carrier },
            action = onAfterDamage,
        },
    },
    config = CONFIG,
}
