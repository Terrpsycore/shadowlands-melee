local UnitIds = require("lib.community.types.assets.UnitIds")

return {
    dummy = {
        parent = UnitIds.footman,
        name = "Dummy",
        art = {
            model = "",
        },
        --abilities = { "locust" },
        apply = function(u)
            u:setManaMaximum(1000)
            u:setManaInitialAmount(1000)
            u:setAttacksEnabled(0)
            u:setAnimationCastPoint(0)
            u:setAnimationCastBackswing(0)
            u:setTurnRate(3)
        end,
    },
    dummyAttack = {
        parent = UnitIds.footman,
        name = "Dummy AA",
        --abilities = { "locust" },
        attack1 = {
            weapon = WeaponType.Instant,
            range = 99999,
            cooldown = 0.1,
            damageBase = 1,
            type = AttackType.Chaos,
            targetsAllowed = "ground,air,structure,enemy,neutral,vulnerable",
        },
        art = {
            model = "",
        },
        apply = function(u)
            u:setSpeedBase(0)
            u:setCollisionSize(0)
            --u:setAttacksEnabled(1)
            --u:setAttack1AnimationDamagePoint(0)
            --u:setAttack1AnimationBackswingPoint(0)
            --u:setAttack1DamageNumberofDice(0)
            --u:setAttack1DamageSidesperDie(1)
        end,
    },
    dummyTarget = {
        parent = UnitIds.footman,
        apply = function(u)
            u:setAttacksEnabled(0)
        end,
    },
    dummyHero = {
        parent = UnitIds.paladin,
        name = "Name",
    },
    dummyInvis = {
        parent = UnitIds.paladin,
        name = "dummyInvis",
        abilities = { "windWalk" },
    },
}
