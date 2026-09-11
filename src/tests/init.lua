local registry = require("tests.generated.registry")

for _, mod in ipairs(registry) do
    require(mod)
end

Debug.original.print("tests ready")
