local Ids = require("data.ids")
local AbilityConfig = require("lib.ability.config")
local Dummy = require("utils.dummy")
local Type = require("utils.type")
local Unit = require("utils.unit")
local dump = require("utils.logger")

local CONFIG = AbilityConfig.compile({
    refs = {
        abilities = {
            main = Ids.abilities.bastionSpear,
            slow = Ids.abilities.bastionSpearSlow,
            bonusDamage = Ids.abilities.bastionSpearBonusDamageDebuff,
        },
        buffs = {
            bonusDamage = Ids.buffs.bastionSpearBonusDamage,
        },
        units = {
            source = { Ids.units.ascendedWarrior, Ids.units.ascendedWarriorFlying },
        },
    },
    balance = {
        radius = 100,
        bonusDamage = 25,
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
        Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.slow, "shadowstrike")
        Dummy.applyDummyOrder(owner, target, CONFIG.refs.abilities.bonusDamage, "slow")
    end
end

local function onDamage(info)
    dump("onDamage bastionSpear", UnitHasBuffBJ(info.target, CONFIG.refs.buffs.bonusDamage))
    if not UnitHasBuffBJ(info.target, CONFIG.refs.buffs.bonusDamage) then
        return
    end
    UnitRemoveBuffBJ(CONFIG.refs.buffs.bonusDamage, info.target)
    info.damage = info.damage + CONFIG.balance.bonusDamage
end

return {
    triggers = {
        {
            trigger = "EVENT_PLAYER_UNIT_SPELL_EFFECT",
            spellId = CONFIG.refs.abilities.main,
            action = onSpell,
        },
        {
            trigger = "DAMAGE",
            filter = { source = CONFIG.refs.units.source },
            action = onDamage,
        },
    },
    config = CONFIG,
}
