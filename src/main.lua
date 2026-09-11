require("lib.init")

require("tests.init")

require("scenario.dev.spawn").run()

local Storage = require("lib.storage.storage")
Storage.initAll()
