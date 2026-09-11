--[[
  ARCHETYPE: disable-triggered
  TEMPLATE ONLY — copy to scenario/factions/<faction>/abilities/<slug>.lua

  DATA CHECKLIST:
    - data/abilities: {slug} (passive marker, e.g. A.evasion with 0%)
    - data/abilities: {slug}Buff (dummy applier, name="")
    - data/buffs.lua: {slug} buff
    - data/units: add "{slug}" to carrier.abilities
    - lua tools/bake.lua

  STORAGE: usually none (cooldown via ability CD on marker)
  TEST: stun/root triggers buff; cooldown prevents re-trigger

  REFERENCE: scenario/factions/kyrian/abilities/huntedAnimal.lua
  TRIGGERS: templates/_reference.lua (STUN, ROOT)
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Unit = require("utils.unit")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.huntedAnimal, -- CHANGE slug (CD marker)
            buff = Ids.abilities.huntedAnimalBuff,
        },
        buffs = {
            main = Ids.buffs.huntedAnimal,
        },
    },
})

local function activateAbility(unit)
    Dummy.applyDummyOrder(GetOwningPlayer(unit), unit, CONFIG.refs.abilities.buff, "bloodlust")
end

local function onDisable(info)
    local unit = info.target
    if Unit.isOffCooldown(unit, CONFIG.refs.abilities.main) then
        activateAbility(unit)
    end
end

return {
    triggers = {
        {
            trigger = "STUN",
            action = onDisable,
        },
        {
            trigger = "ROOT",
            action = onDisable,
        },
    },
    config = CONFIG,
}
