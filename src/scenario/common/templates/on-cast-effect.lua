--[[
  ARCHETYPE: on-cast-effect
  TEMPLATE ONLY — copy to scenario/factions/<faction>/abilities/<slug>.lua

  DATA CHECKLIST:
    - data/abilities: {slug} (e.g. A.channelArea, A.channelPoint)
    - optional hidden abilities for dummy debuffs
    - data/buffs.lua for debuff slugs
    - data/units: add "{slug}" to carrier.abilities
    - lua objediting/gen_ids.lua

  STORAGE: usually none
  TEST: cast hits targets in radius; optional DAMAGE hook

  REFERENCE: scenario/factions/kyrian/abilities/bastionSpear.lua
  TRIGGERS: templates/_reference.lua
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.bastionSpear, -- CHANGE slug
            debuff = Ids.abilities.bastionSpearSlow, -- optional dummy
        },
        buffs = {
            debuff = Ids.buffs.bastionSpearSlow, -- optional
        },
        units = {
            source = { Ids.units.ascendedWarrior }, -- optional DAMAGE filter
        },
    },
    balance = {
        radius = 100,
    },
})

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()

    local targets = Unit.getUnitsInPointRadius(targetX, targetY, CONFIG.balance.radius, function(u)
        return IsUnitAliveBJ(u) and IsUnitEnemy(u, owner)
    end)

    for _, target in ipairs(targets) do
        -- Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.debuff, "shadowstrike")
    end
end

local function onDamage(info)
    -- optional: modify damage when debuff present
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
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
