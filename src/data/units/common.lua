local UnitIds = require("vendor.assets.UnitIds")

return {
    soul = {
        parent = UnitIds.banshee,
        name = "Soul",
        corpse = false,
        revive = false,
        apply = function(u)
            u:setAttacksEnabled(0)
        end,
    },
    dummy = {
        parent = UnitIds.footman,
        name = "Dummy",
        art = {
            -- model = "",
        },
        --abilities = { "locust" },
        classification = "Suicidal",
        corpse = false,
        revive = false,
        apply = function(u)
            u:setManaMaximum(1000)
            u:setManaInitialAmount(1000)
            u:setAttacksEnabled(0)
            u:setAnimationCastPoint(0)
            u:setAnimationCastBackswing(0)
            u:setTurnRate(3)
            u:setCollisionSize(0)
        end,
    },
    dummyAttack = {
        parent = UnitIds.footman,
        name = "Dummy AA",
        --abilities = { "locust" },
        classification = "Suicidal",
        corpse = false,
        revive = false,
        attack1 = {
            weapon = WeaponType.Instant,
            range = 99999,
            cooldown = 0.1,
            damageBase = 1,
            type = AttackType.Chaos,
            targetsAllowed = "ground,air,structure,enemy,neutral,vulnerable",
        },
        art = {
            --  model = "",
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
        classification = "Suicidal",
        corpse = false,
        revive = false,
        apply = function(u)
            u:setAttacksEnabled(0)
        end,
    },
    dummyTank = {
        parent = UnitIds.footman,
        corpse = false,
        revive = false,
        apply = function(u)
            u:setAttacksEnabled(0)
            u:setHitPointsMaximumBase(5000)
        end,
    },
    dummyHero = {
        parent = UnitIds.paladin,
        classification = "Suicidal",
        name = "Name",
        corpse = false,
        revive = false,
    },
    dummyInvis = {
        parent = UnitIds.paladin,
        classification = "Suicidal",
        name = "dummyInvis",
        abilities = { "windWalk" },
        corpse = false,
        revive = false,
    },
}
