local UnitIds = require("lib.community.types.assets.UnitIds")

local db = {
    dummy = {
        parent = UnitIds.footman,
        abilities = { "locust" },
        apply = function(u)
            u:setManaMaximum(1000)
            u:setManaInitialAmount(1000)
            u:setAttacksEnabled(0)
            u:setModelFile("")
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
    steward = {
        parent = UnitIds.peasant,
        name = "Steward",
        abilities = { "soakAnima", "fuseAnima" },
        apply = function(u)
            u:setManaMaximum(200)
            u:setManaInitialAmount(100)
        end,
    },
    aspirant = {
        parent = UnitIds.headhunter,
        name = "Aspirant",
        abilities = { "soulbind", "rangeSwitch", "ascendAspirant" },
    },
    aspirantMelee = {
        parent = UnitIds.headhunter,
        name = "Aspirant",
        abilities = { "soulbind", "rangeSwitch", "ascendAspirant" },
        apply = function(u)
            u:setAttack1AttackType("normal")
            u:setAttack1WeaponType(WeaponType.Normal) -- melee, без снаряда
            u:setAttack1Range(90) -- 90–128; иначе «мили» с дистанции 450
            -- u:setAttack1ProjectileArt("") -- гигиена; для Normal снаряд и так не летит
            u:setAttack1WeaponSound(WeaponSound.MetalMediumChop) -- удар, не полёт топора
        end,
    },
    ascendedWarrior = {
        parent = UnitIds.knight,
        name = "Ascended Warrior",
        abilities = { "ascendedWarriorFly" },
    },
    ascendedWarriorFlying = {
        parent = UnitIds.gryphonrider,
        name = "Ascended Warrior",
        abilities = { "ascendedWarriorFly" },
    },
    praetor = {
        parent = UnitIds.grunt,
        name = "Praetor",
        abilities = { "defenceProtocol" },
        apply = function(u)
            u:setUnitClassification("Mechanical")
            u:setManaMaximum(200)
            u:setManaInitialAmount(100)
        end,
    },
    larion = {
        parent = UnitIds.druidoftheclaw,
        name = "Larion",
        abilities = { "cannibalizeSearch", "pride" },
    },
    purity = {
        parent = UnitIds.priest,
        name = "Purity",
        abilities = { "vesperBell", "humility" },
    },
    wisdom = {
        parent = UnitIds.sorceress,
        name = "Wisdom",
    },
    loyalty = {
        parent = UnitIds.spellbreaker,
        name = "Loyalty",
        abilities = { "spiritLink" },
    },
    phalynx = {
        parent = UnitIds.whitewolf,
        name = "Phalynx",
        apply = function(u)
            u:setUnitClassification("Mechanical")
            u:setManaMaximum(200)
            u:setManaInitialAmount(100)
        end,
    },
    goliath = {
        parent = UnitIds.footman,
        name = "Goliath",
        apply = function(u)
            u:setUnitClassification("Mechanical")
            u:setManaMaximum(200)
            u:setManaInitialAmount(100)
        end,
    },
    colossus = {
        parent = UnitIds.footman,
        name = "Colossus",
        apply = function(u)
            u:setUnitClassification("Mechanical")
            u:setManaMaximum(200)
            u:setManaInitialAmount(100)
        end,
    },
    ascendedPurity = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
    ascendedWisdom = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
    ascendedLoyalty = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
}

return db
