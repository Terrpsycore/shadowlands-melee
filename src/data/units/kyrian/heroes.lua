local UnitIds = require("vendor.assets.UnitIds")

return {
    watcher = {
        parent = UnitIds.jaina,
        name = "Watcher",
        abilities = { "watcherFly" },
        heroAbilities = { "judgingGaze", "memoryPeer", "oneMoreChance", "lastStand" },
    },
    watcherFlying = {
        parent = UnitIds.jaina,
        name = "Watcher",
        abilities = { "watcherFly" },
        heroAbilities = { "judgingGaze", "memoryPeer", "oneMoreChance", "lastStand" },
        apply = function(u)
            u:setMovementType(MovementType.Fly)
            u:setMovementHeight(240)
        end,
    },
    forgelite = {
        parent = UnitIds.tinker,
        name = "Forgelite",
        heroAbilities = { "overcharge", "reusables", "securityLeak", "piloting" },
    },
    bearer = {
        parent = UnitIds.paladin,
        name = "Bearer",
    },
}
