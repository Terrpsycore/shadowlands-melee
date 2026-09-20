local UnitIds = require("vendor.assets.UnitIds")
local Icons = require("vendor.assets.generated.Icons")

return {
    steward = {
        parent = UnitIds.peasant,
        name = "Steward",
        abilities = { "humanBuild", "repairHuman", "harvest", "soakAnima", "fuseAnima" },
        structuresBuilt = {
            "main",
            "animaExtractor",
            "trainingGrounds",
            "workshop",
            "templeOfVirtue",
            "crestOfAscension",
            "herosRest",
            "templeWard",
            "animaStorage",
            "shop",
        },
        mana = { max = 200, initial = 100 },
        art = { icon = Icons.snowOwl },
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
        attack1 = {
            type = "normal",
            weapon = WeaponType.Normal, -- melee, без снаряда
            range = 90, -- 90–128; иначе «мили» с дистанции 450
            weaponSound = WeaponSound.MetalMediumChop, -- удар, не полёт топора
        },
    },
    ascendedWarrior = {
        parent = UnitIds.knight,
        name = "Ascended Warrior",
        abilities = { "ascendedWarriorFly", "bastionSpear" },
    },
    ascendedWarriorFlying = {
        parent = UnitIds.dragonhawk,
        name = "Ascended Warrior",
        abilities = { "ascendedWarriorFly", "bastionSpear" },
    },
    praetor = {
        parent = UnitIds.grunt,
        name = "Praetor",
        abilities = { "defenceProtocol", "defenceProtocolToggle" },
        classification = "Mechanical",
        mana = { max = 200, initial = 100 },
        cost = { lumber = 50 },
        art = { icon = Icons.armorGolem },
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
        art = { icon = Icons.cleric },
    },
    wisdom = {
        parent = UnitIds.sorceress,
        name = "Wisdom",
        abilities = { "dedication", "deepMeditation" },
    },
    loyalty = {
        parent = UnitIds.spellbreaker,
        name = "Loyalty",
        abilities = { "spiritLink" },
    },
    phalynx = {
        parent = UnitIds.whitewolf,
        name = "Phalynx",
        abilities = { "scanToggle" },
        classification = "Mechanical",
        mana = { max = 200, initial = 100 },
    },
    goliath = {
        parent = UnitIds.knight,
        name = "Goliath",
        abilities = { "pulseback", "pulsebackToggle" },
        classification = "Mechanical",
        mana = { max = 200, initial = 100 },
    },
    colossus = {
        parent = UnitIds.archer,
        name = "Colossus",
        abilities = { "animaBarrageToggle" },
        classification = "Mechanical",
        mana = { max = 200, initial = 100 },
    },
    ascendedPurity = {
        parent = UnitIds.footman,
        art = { icon = Icons.cleric },
        name = "Praetor",
    },
    ascendedPurityFlying = {
        parent = UnitIds.footman,
        art = { icon = Icons.cleric },
        name = "Praetor",
    },
    ascendedWisdom = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
    ascendedWisdomFlying = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
    ascendedLoyalty = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
    ascendedLoyaltyFlying = {
        parent = UnitIds.footman,
        name = "Praetor",
    },
    memorySpirit = {
        parent = UnitIds.ghost,
        name = "Burden Memory",
        abilities = {},
        cost = { food = 0 },
        attack1 = { type = "normal" },
        apply = function(u)
            u:setGoldBountyAwardedBase(0)
            u:setGoldBountyAwardedNumberofDice(0)
        end,
    },
}
