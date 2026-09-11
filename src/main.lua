require("lib.init")

require("tests.init")

require("spawn").run()

local Storage = require("lib.storage.storage")
Storage.initAll()
