-- TODO: corpse search + eat flow (needs death mechanic setup)
local Ids = require("data.ids")
local T = require("tests.support.runner").suite("cannibalize")

T:test("Search cast without nearby corpse does not crash", function(case)
    local larion = case:createUnit(Ids.units.larion)
    local x, y = GetUnitX(larion), GetUnitY(larion)

    IssuePointOrder(larion, "cannibalizesearch", x, y)

    return case:delay(1, function()
        assert(GetUnitState(larion, UNIT_STATE_LIFE) > 0, "caster died during empty search")
    end)
end)
