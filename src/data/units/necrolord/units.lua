local UnitIds = require("lib.community.types.assets.UnitIds")

return {
    animateWarrior = {
        parent = UnitIds.skeletonwarrior,
        name = "Animate Warrior",
        abilities = { "combatExpertise" },
    },
    aranakkSpy = {
        parent = UnitIds.nerubianwarrior,
        name = "Aranakk Spy",
        abilities = { "vanish" },
    },
    necromancer = {
        parent = UnitIds.necromancer,
        abilities = { "animateDead" },
    },
}
