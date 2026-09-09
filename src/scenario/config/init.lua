require("scenario.config.types")

local compile = require("scenario.config.compile")

return {
    compile = compile.compile,
    unitId = compile.unitId,
}
