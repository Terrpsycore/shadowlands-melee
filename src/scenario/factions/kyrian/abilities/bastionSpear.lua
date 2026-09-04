local Ids = require("data.ids")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local CONFIG = {
    radius = 100,
    -- cooldown = 5,

    -- buffId = FourCC(Ids.buffs.defenceProtocol),
    ability = FourCC(Ids.abilities.bastionSpear),
    dummyBonusDamageDebuffAbility = FourCC(Ids.abilities.bastionSpearBonusDamageDebuff),
    dummySlowAbility = FourCC(Ids.abilities.bastionSpearSlow),
    dummyBonusDamageDebuff = FourCC(Ids.buffs.bastionSpearBonusDamage),
    -- requiredUpgradeId = nil,
}

local function onSpell()
    local caster = GetTriggerUnit()
    local owner = GetOwningPlayer(caster)
    local targetX = GetSpellTargetX()
    local targetY = GetSpellTargetY()

    local targets = Unit.getUnitsInPointRadius(targetX, targetY, CONFIG.radius, function(u)
        return IsUnitAliveBJ(u) and IsUnitEnemy(u, owner)
    end)

    for _, target in ipairs(targets) do
        Dummy.applyDummyOrder(owner, target, CONFIG.dummySlowAbility, "shadowstrike")
        Dummy.applyDummyOrder(owner, target, CONFIG.dummyBonusDamageDebuffAbility, "slow")
    end
end

local function onDamage(info)
    dump("onDamage bastionSpear", UnitHasBuffBJ(info.target, CONFIG.dummyBonusDamageDebuff))
    if not UnitHasBuffBJ(info.target, CONFIG.dummyBonusDamageDebuff) then
        return
    end
    UnitRemoveBuffBJ(CONFIG.dummyBonusDamageDebuffAbility, info.target)
    info.damage = info.damage + 25
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.ability,
            action = onSpell,
        },
        {
            trigger = "DAMAGE",
            action = onDamage,
            source = {
                type = FourCC(Ids.units.ascendedWarrior), -- TODO: add other ascended, refactor triggers
            },
        },
        {
            trigger = "DAMAGE",
            action = onDamage,
            source = {
                type = FourCC(Ids.units.ascendedWarriorFlying),
            },
        },
    },
    config = CONFIG,
}
