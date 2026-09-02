local UnitIds = require("lib.community.types.assets.UnitIds")

return {
    watcher = {
        parent = UnitIds.jaina,
        name = "Watcher",
        abilities = { "watcherFly", "judgingGaze", "memoryPeer", "oneMoreChance", "lastStand" },
    },
    watcherFlying = {
        parent = UnitIds.jaina,
        name = "Watcher",
        abilities = { "watcherFly", "judgingGaze", "memoryPeer", "oneMoreChance", "lastStand" },
        apply = function(u)
            u:setMovementType(MovementType.Fly)
            u:setMovementHeight(240)
        end,
    },
    forgelite = {
        parent = UnitIds.tinker,
        name = "Forgelite",
        abilities = { "overcharge", "reusables", "securityLeak", "piloting" },
    },
}
