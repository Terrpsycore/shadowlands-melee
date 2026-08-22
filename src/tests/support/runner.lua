local Case = require("tests.support.case")

local T = {}

function T.create_case(name, testFunc)
    return Case.new(name, testFunc)
end

function T.test(name, testFunc)
    return T.create_case(name, testFunc):run()
end

return T
