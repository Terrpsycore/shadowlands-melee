local Reporter = require("tests.support.reporter")

Reporter.mode = Reporter.Mode.summary

local registry = require("tests.generated.registry")

for _, mod in ipairs(registry) do
    require(mod)
end

require("tests.support.runner").runAll()

Debug.original.print("tests ready")
