--[[
  ARCHETYPE: on-cast-target
  TEMPLATE ONLY — copy to scenario/factions/<faction>/abilities/<slug>.lua

  DATA CHECKLIST:
    - data/abilities: {slug} (e.g. A.channelTarget or active preset)
    - data/units: add "{slug}" to carrier.abilities
    - lua objediting/gen_ids.lua

  STORAGE: usually none
  TEST: cast on valid/invalid target

  REFERENCE: scenario/factions/kyrian/abilities/reusables.lua
  TRIGGERS: templates/_reference.lua
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.reusables, -- CHANGE slug
        },
    },
    balance = {
        -- tuning values
    },
})

local function isValidTarget(caster, target)
    if not target or target == caster then
        return false
    end
    if not Unit.isAlive(target) then
        return false
    end
    return true
end

local function onCast()
    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()

    if not isValidTarget(caster, target) then
        return
    end

    -- effect here
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_CAST",
            spellId = CONFIG.refs.abilities.main,
            action = onCast,
        },
    },
    config = CONFIG,
}
