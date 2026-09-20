local UnitIds = require("vendor.assets.UnitIds")
local Icons = require("vendor.assets.generated.Icons")

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
        art = { icon = Icons.owlBear },
    },
    bearer = {
        parent = UnitIds.paladin,
        name = "Bearer",
    },
}
