require("lib.init")

require("tests.init")

Timed.delay(5, function()
    require("spawn").run()
end)

local Storage = require("lib.storage.storage")
Storage.initAll()
