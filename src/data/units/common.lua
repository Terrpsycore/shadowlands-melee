local UnitIds = require("lib.community.types.assets.UnitIds")

return {
    dummy = {
        parent = UnitIds.footman,
        name = "Dummy",
        --abilities = { "locust" },
        apply = function(u)
            u:setManaMaximum(1000)
            u:setManaInitialAmount(1000)
            u:setAttacksEnabled(0)
            -- u:setModelFile("")
        end,
    },
    dummyAttack = {
        parent = UnitIds.footman,
        name = "Dummy AA",
        --abilities = { "locust" },
        apply = function(u)
            --u:setModelFile("")
            u:setSpeedBase(0)
            u:setCollisionSize(0)
            --u:setAttacksEnabled(1)
            u:setAttack1WeaponType(WeaponType.Instant)
            u:setAttack1Range(99999)
            u:setAttack1CooldownTime(0.1)
            --u:setAttack1AnimationDamagePoint(0)
            --u:setAttack1AnimationBackswingPoint(0)
            u:setAttack1DamageBase(1)
            --u:setAttack1DamageNumberofDice(0)
            --u:setAttack1DamageSidesperDie(1)
            u:setAttack1AttackType(AttackType.Chaos)
            u:setAttack1TargetsAllowed("ground,air,structure,enemy,neutral,vulnerable")
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
}
