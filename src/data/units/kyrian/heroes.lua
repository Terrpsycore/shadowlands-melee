local UnitIds = require("lib.community.types.assets.UnitIds")

return {
    watcher = {
        parent = UnitIds.jaina,
        name = "Watcher",
        abilities = { "judgingGaze", "memoryPeer" },
    },
}
