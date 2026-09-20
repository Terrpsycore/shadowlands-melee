local RUN = {
    tests = false,
    spawn = true,
    spawnPacks = { "necrolord", "enemies" }, -- kyrian | necrolord | enemies | fae | ...
}

require("lib.init")

require("tests.init")

Timed.call((RUN.tests and 5) or 2, function()
    require("spawn").run(RUN.spawnPacks)
end)

local Storage = require("lib.storage.storage")
Storage.initAll()
