local RUN = {
    tests = false,
    spawn = true,
    spawnPacks = { "mawsworn", "enemies" }, -- kyrian | necrolord | corpses | enemies | ...
}

require("lib.init")

if RUN.tests then
    require("tests.init")
end

Timed.call((RUN.tests and 5) or 0, function()
    require("spawn").run(RUN.spawnPacks)
end)

local Storage = require("lib.storage.storage")
Storage.initAll()
