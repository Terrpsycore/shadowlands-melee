--[[
  ARCHETYPE: pre-damage-modifier
  TEMPLATE ONLY — copy to scenario/factions/<faction>/abilities/<slug>.lua

  DATA CHECKLIST:
    - data/abilities: {slug} (visible cast, applies buff — e.g. A.spiritLink)
    - data/buffs/: {slug} buff
    - data/units: add "{slug}" to carrier.abilities
    - lua tools/bake.lua

  STORAGE: usually none (buff state from WC3)
  TEST: damage reduced when buff present; min damage floor

  REFERENCE: scenario/factions/kyrian/abilities/spiritLink.lua
  TRIGGERS: templates/_reference.lua (PRE_DAMAGE)
]]

local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")

local CONFIG = AbilityConfig.compile({
    refs = {
        buffs = {
            main = Ids.buffs.spiritLink, -- CHANGE slug
        },
    },
    balance = {
        damageReduceAmount = 6,
        minDamage = 3,
    },
})

local function onPreDamage(info)
    if UnitHasBuffBJ(info.target, CONFIG.refs.buffs.main) then
        info.damage = math.max(
            info.damage - CONFIG.balance.damageReduceAmount,
            CONFIG.balance.minDamage
        )
    end
end

return {
    triggers = {
        {
            trigger = "PRE_DAMAGE",
            action = onPreDamage,
        },
        -- optional filter:
        -- {
        --     trigger = "PRE_DAMAGE",
        --     filter = { target = CONFIG.refs.units.carrier },
        --     action = onPreDamage,
        -- },
    },
    config = CONFIG,
}
