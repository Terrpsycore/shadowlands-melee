--[[
  ARCHETYPE: proximity-tick
  TEMPLATE ONLY — copy to scenario/factions/<faction>/abilities/<slug>.lua

  DATA CHECKLIST:
    - data/abilities: {slug}BuffSpeed, {slug}BuffDamage (A.itemAura*, name="")
    - data/units: carrier has passive marker ability (e.g. A.evasion with 0%)
    - scenario/storage/{slug}.lua — unit set registry
    - lua objediting/gen_ids.lua

  STORAGE: dedicated unit set (add on train, remove on death)
  TEST: units in range get buff; leave range lose buff; death cleanup

  REFERENCE: scenario/factions/kyrian/abilities/formation.lua, pride.lua
  TRIGGERS: templates/_reference.lua
]]

local Ids = require("data.ids")
local AbilityConfig = require("scenario.config")
local Unit = require("utils.unit")

-- local Store = require("scenario.storage.phalynx") -- CHANGE storage module

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            speedBuff = Ids.abilities.formationBuffSpeed, -- CHANGE slugs
            damageBuff = Ids.abilities.formationBuffDamage,
        },
        units = {
            carrier = Ids.units.phalynx, -- CHANGE carrier
        },
    },
    balance = {
        tickSeconds = 1,
        linkRadius = 275,
    },
})

local function setBuff(unit, active)
    if active then
        UnitAddAbility(unit, CONFIG.refs.abilities.damageBuff)
        UnitAddAbility(unit, CONFIG.refs.abilities.speedBuff)
    else
        UnitRemoveAbility(unit, CONFIG.refs.abilities.damageBuff)
        UnitRemoveAbility(unit, CONFIG.refs.abilities.speedBuff)
    end
end

local function onTick()
    -- === UNIQUE LOGIC: enumerate Store, compute proximity, call setBuff ===
end

local function onTrain()
    -- Store:add(GetTrainedUnit())
end

local function onDeath()
    -- Store:remove(GetDyingUnit())
end

return {
    triggers = {
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
        {
            trigger = "TIMER",
            delta = CONFIG.balance.tickSeconds,
            action = onTick,
        },
    },
    config = CONFIG,
}
