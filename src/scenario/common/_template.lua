--[[
  Scenario ability templates — start here.

  DO NOT require this file or anything in templates/ from scenario/abilities.lua.
  Copy an archetype file into scenario/factions/<faction>/abilities/<slug>.lua.

  WORKFLOW:
    1. Pick archetype below (or _reference.lua for custom trigger mix)
    2. Copy template → factions/<faction>/abilities/<slug>.lua
    3. Replace slug placeholders in refs / balance
    4. Implement unique logic (effect, tryActivate, onTick, …)
    5. Add data rows (abilities, buffs, units) → lua tools/bake.lua
    6. Bake подхватит файл в scenario/abilities (gen_ability_registry.lua)
    7. Optional: tests/factions/<faction>/<slug>.lua (gen_test_registry.lua)

  ALL TRIGGERS (18 types):
    templates/_reference.lua

  ARCHETYPES:
    on-cast-target.lua           — SPELL_CAST on target (Reusables)
    on-cast-effect.lua           — SPELL_EFFECT, area/point (Bastion Spear)
    toggle-passive-on-damage.lua — immolation toggle + DAMAGE proc (Defence Protocol, Pulseback)
    toggle-passive-on-attack.lua — immolation toggle + ATTACKED proc (Anima Barrage)
    proximity-tick.lua           — TRAIN + DEATH + TIMER proximity buff (Formation)
    disable-triggered.lua        — STUN/ROOT reactive buff (Hunted Animal)
    buff-chain-storage.lua       — cast → dummy chain + storage + TIMER (Dedication, Deep Meditation)
    pre-damage-modifier.lua      — PRE_DAMAGE hook (Spirit Link)

  Too custom for archetype (use _reference.lua): soulbind, scan, cannibalize, oneMoreChance, lastStand
]]

return {}
