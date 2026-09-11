require("lib.ability.config.types")

local compile = require("lib.ability.config.compile")

return {
    compile = compile.compile,
    unitId = compile.unitId,
}
