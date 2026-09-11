require("lib.init")

require("tests.init")

Timed.call(5, function()
    require("spawn").run({ "necrolord" })
end)

local Storage = require("lib.storage.storage")
Storage.initAll()
